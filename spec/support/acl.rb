# -*- encoding : utf-8 -*-

# This file contains patches related to the puppetlabs/acl module
# <https://forge.puppetlabs.com/puppetlabs/acl>.

require 'rubygems'

require 'puppet/util/windows'
require 'rspec/core/pending'
require 'rspec-puppet/matchers/compile'

require 'support/warn'

# This module is defined on Windows platforms, but not on POSIX platforms.
# ``it { should compile }`` tests execute code that requires this module, and its
# :symlink? function, to be defined. So make sure the module is defined, and define the
# :symlink? function if it isn't already defined.
module Puppet::Util::Windows::File
  if not method_defined?(:symlink?)
    def symlink?(file_name)
      false
    end
    module_function :symlink?
  end
end

# Patch RSpec::Puppet::ManifestMatchers::Compile to not fail when encountering certain
# exceptions raised by the Acl resource type on Ruby 1.8.
#
# The puppetlabs/acl module <https://forge.puppetlabs.com/puppetlabs/acl> provides the
# Acl resource type, which is needed by manifests that need to set file permissions on
# Windows. Although it is not documented, this module requires Ruby 1.9+. It uses a
# number of constructs that do not exist in Ruby 1.8:
# - Array#sort_by!
# - Symbol#empty?
# - String#[index] returns a length-1 string in Ruby 1.9+, but a fixnum in Ruby 1.8.
#
# The first two problems occur any time Puppet::Type::Acl is initialized with a
# non-empty `permissions` parameter list. The latter occurs up when auto-requiring is
# triggered.
#
# It turns out that these code paths are only executed on the Puppet client. All of the
# puppetlabs/acl code that is executed on the Puppet master is Ruby 1.8 compliant.
#
# However, the rspec-puppet test ``it { should compile }`` executes this
# client-side code, and is negatively affected by the incompatibility, if the
# Puppet test machines are running Ruby 1.8. This would cause the compilation
# test to fail for manifests that would successfully compile in production.
#
# Rather than dissuade use of ``it { should compile }`` (and attempt to educate
# developers that their test failures might not be their fault), this file patches
# RSpec::Puppet::ManifestMatchers::Compile when tests are being run on Ruby 1.8. If any
# of the known exceptions are raised during a compilation test, the test is skipped,
# with an explanation displayed to the user. And when systems upgrade to Ruby 1.9, the
# tests will begin to work again.
#
# Other types of rspec-puppet tests do not execute client-side code, and are unaffected
# by this problem.

SHORT_ACL_SKIP_MESSAGE = 'Skipped ``it { should compile }`` test because of Acl resource type.'

VERBOSE_ACL_SKIP_MESSAGE = SHORT_ACL_SKIP_MESSAGE + ' ' + ("
  Must skip ``it { should compile }`` tests with manifests that use the Acl
  resource type, because it requires Ruby version >=1.9, while we are running
  #{RUBY_VERSION}. You may leave these skipped tests, as they will start
  working after we upgrade Ruby. But make sure to test these manifests in other
  ways, as these skipped tests are not currently providing any coverage.
".strip.gsub(/\n/, ' ').gsub(/ +/, ' '))

KNOWN_ACL_EXCEPTION_MESSAGES = [

  # When validating an Acl resource, an exception may be raised because of an undefined
  # method on a Ruby core class that isn't introduced until Ruby 1.9.
  /Acl.*undefined method/,

  # When validating an Acl resource, an exception may be raised when it tries
  # to `downcase` the drive letter of a Windows file path. This fails because
  # ``string[0]`` is expected to return a length-1 string in Ruby 1.9, but in
  # Ruby 1.8 returns a Fixnum, which has no `downcase` method.
  /undefined method `downcase' for \d+:Fixnum/,
]

unless Gem::Version.new(RUBY_VERSION) < Gem::Version.new('1.9')
  # Don't raise an exception, in case upgrading off of Ruby version 1.8 doesn't happen
  # all at once; we still want testing to work during the transition period. But do
  # print a very prominent warning to stderr.
  warn_with_emphasis "
    Expected Ruby version 1.8, got #{RUBY_VERSION}.
    If all Puppet test machines are no longer running 1.8, remove
    RSpec::Puppet::ManifestMatchers::Compile hack in spec/support/acl.rb, as it is no
    longer necessary.
  ".strip.gsub(/^ +/, '')
else
  module RSpec::Puppet
    module ManifestMatchers
      class Compile
        alias :pre_acl_hack_matches? :matches?

        # Defines the `skip` method, which is normally only available in examples.
        include RSpec::Core::Pending

        @@warned_about_acl_skip = false

        def matches?(catalogue)
          exception = nil

          # If the original `matches?` method returns `true`, no further action is
          # needed. If it returns `false` because of a Puppet exception, then get the
          # error message from the `failure_message` method. The original `matches?`
          # will not rescue non-Puppet exceptions, so if an exception is raised, rescue
          # it and get its message.
          error_message = begin
            return true if pre_acl_hack_matches?(catalogue)
          rescue => exception
            exception.message
          else
            failure_message
          end

          # Even if Acl is causing problems, `catalogue.call` should still return
          # successfully. If it doesn't, re-raise/re-return the result from the original
          # `matches?` method.
          begin
            catalogue.call
          rescue
            raise exception unless exception.nil?
            return false
          end

          # If the error message matches any of the known exception messages that can be
          # raised by Acl because of its incompatibility with Ruby 1.8, then skip the
          # current test.  On the first skip, use a more verbose message than on
          # subsequent skips.
          unless KNOWN_ACL_EXCEPTION_MESSAGES.select(&error_message.method(:match)).empty?
            @error_msg = ''
            skip_message = if @@warned_about_acl_skip then SHORT_ACL_SKIP_MESSAGE else VERBOSE_ACL_SKIP_MESSAGE end
            @@warned_about_acl_skip = true
            skip(skip_message)
          end

          # If this is a different error message, don't skip the test, and
          # re-raise/re-return the result from the original `matches?` method.
          raise exception unless exception.nil?
          false
        end
      end
    end
  end
end
