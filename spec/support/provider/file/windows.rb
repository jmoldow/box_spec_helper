# -*- encoding : utf-8 -*-

require 'rubygems'

require 'puppet'
require 'puppet/util/windows'

require 'support/verbose'

# When mocking out the operating system using the :as_platform => :windows shared
# context defined in spec/shared_contexts/platforms.rb, it becomes impossible to test
# any Puppet File resources that have an owner or a group.
#
# This is because the windows file provider's `validate` method calls the
# `supports_acl?` method, which is originally defined in the
# `Puppet::Util::Windows::Security` module, and included at load time only if
# `Puppet.features.microsoft_windows?` is `true`.
#
# - So if the File resource type is loaded before that feature is stubbed out, then the
#   `supports_acl?` method isn't included in the windows file provider, and an
#   "undefined method" exception is raised during validation.
#
# - But if the File resource type is loaded after that feature is stubbed out, then Ruby
#   will attempt to import Windows-only modules and crash.
#
# Because of the particular way in which providers are defined in the Puppet framework,
# it does not appear to be possible to monkey patch the windows file provider to resolve
# this issue. Instead, we resort to copying the Puppet source code and making a tiny
# modification to fix the problem, so that the type can be loaded without problems on
# any platform before any features are stubbed out.

# NOTE: This file must define Puppet::Util::Windows::Security,
# Puppet::Util::Windows::Security#supports_acl?, and the windows file provider.
# The windows file provider should be identical to what it is in the official
# Puppet repository [1], except for the change to make sure that
# ``include Puppet::Util::Windows::Security`` is always executed regardless of
# `Puppet.features.microsoft_windows?`.
#
# [1] <https://github.com/puppetlabs/puppet/blob/3.6.2/lib/puppet/provider/file/windows.rb>
# Change the tag to see the correct version of puppet.

PUPPET_VERSION = '3.6.2'

unless Puppet::PUPPETVERSION == PUPPET_VERSION
  raise "\n
    Expected Puppet version #{PUPPET_VERSION}, got #{Puppet::PUPPETVERSION}.

    Use the correct version of Puppet; or, if upgrading, update
    spec/support/provider/file/windows.rb to match the corresponding source in the new
    version of Puppet.
  \n"
end

module Puppet::Util::Windows::Security
  def supports_acl?(path)
    true  # Assume that real Windows machines will always support ACL.
  end
end

# Load the file type, so that Puppet's providers get defined first, and then overriden
# by ours, rather than the other way around.
require 'puppet/type'
require 'puppet/type/file'

# NOTE: Everything in this proc, starting with ``Puppet::Type.type(:file).provide``, is
# from the official Puppet repository, with the exception of minor changes that need to
# be made, as described above.
define_windows_file_provider = proc do
  Puppet::Type.type(:file).provide :windows do
    desc "Uses Microsoft Windows functionality to manage file ownership and permissions."

    confine :operatingsystem => :windows
    has_feature :manages_symlinks if Puppet.features.manages_symlinks?

    include Puppet::Util::Warnings

    # NOTE: Commented out this conditional from the Puppet source, so that
    # ``include Puppet::Util::Windows::Security`` is always executed.
    #if Puppet.features.microsoft_windows?
      require 'puppet/util/windows'
      require 'puppet/util/adsi'
      include Puppet::Util::Windows::Security
    #end

    # Determine if the account is valid, and if so, return the UID
    def name2id(value)
      Puppet::Util::Windows::Security.name_to_sid(value)
    end

    # If it's a valid SID, get the name. Otherwise, it's already a name,
    # so just return it.
    def id2name(id)
      if Puppet::Util::Windows::Security.valid_sid?(id)
        Puppet::Util::Windows::Security.sid_to_name(id)
      else
        id
      end
    end

    # We use users and groups interchangeably, so use the same methods for both
    # (the type expects different methods, so we have to oblige).
    alias :uid2name :id2name
    alias :gid2name :id2name

    alias :name2gid :name2id
    alias :name2uid :name2id

    def owner
      return :absent unless resource.stat
      get_owner(resource[:path])
    end

    def owner=(should)
      begin
        set_owner(should, resolved_path)
      rescue => detail
        raise Puppet::Error, "Failed to set owner to '#{should}': #{detail}", detail.backtrace
      end
    end

    def group
      return :absent unless resource.stat
      get_group(resource[:path])
    end

    def group=(should)
      begin
        set_group(should, resolved_path)
      rescue => detail
        raise Puppet::Error, "Failed to set group to '#{should}': #{detail}", detail.backtrace
      end
    end

    def mode
      if resource.stat
        mode = get_mode(resource[:path])
        mode ? mode.to_s(8) : :absent
      else
        :absent
      end
    end

    def mode=(value)
      begin
        set_mode(value.to_i(8), resource[:path])
      rescue => detail
        error = Puppet::Error.new("failed to set mode #{mode} on #{resource[:path]}: #{detail.message}")
        error.set_backtrace detail.backtrace
        raise error
      end
      :file_changed
    end

    def validate
      if [:owner, :group, :mode].any?{|p| resource[p]} and !supports_acl?(resource[:path])
        resource.fail("Can only manage owner, group, and mode on filesystems that support Windows ACLs, such as NTFS")
      end
    end

    attr_reader :file
    private
    def file
      @file ||= Puppet::FileSystem.pathname(resource[:path])
    end

    def resolved_path
      path = file()
      # under POSIX, :manage means use lchown - i.e. operate on the link
      return path.to_s if resource[:links] == :manage

      # otherwise, use chown -- that will resolve the link IFF it is a link
      # otherwise it will operate on the path
      Puppet::FileSystem.symlink?(path) ? Puppet::FileSystem.readlink(path) : path.to_s
    end
  end
end

with_verbose_disabled do
  define_windows_file_provider.call
end
