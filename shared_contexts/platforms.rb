# -*- encoding : utf-8 -*-

# Contexts for stubbing platforms
# In a describe or context block, adding :as_platform => :windows or
# :as_platform => :posix will stub the relevant Puppet features, as well as
# the behavior of Ruby's filesystem methods by changing File::ALT_SEPARATOR.
# It will also set the relevant facts, which may be used by the manifest being
# tested or its dependencies.
#
# Full list of available :as_platform options:
# - :windows
# - :posix
#   - :solaris
#   - :linux
#     - :debian
#     - :redhat
#       - :scientific
#       - :centos
#   - :darwin
#
# Nested labels inherit properties from their ancestors and add their own more-specific
# facts.

require 'rubygems'

require 'mocha/mockery'
require 'puppet'
require 'rspec-puppet'

require 'support/example'
require 'support/update_let_definition_support'
require 'support/verbose'

IS_WINDOWS = Puppet.features.microsoft_windows?
PLATFORM_TYPE, OTHER_PLATFORM_TYPE = if IS_WINDOWS then [:windows, :posix] else [:posix, :windows] end

# Cache the values of the separators at load time, before doing any mocking.
FILE_ALT_SEPARATOR = File::ALT_SEPARATOR
FILE_PATH_SEPARATOR = File::PATH_SEPARATOR

VARDIR = {
  :posix    =>  '/var/lib/puppet',
  :windows  =>  'C:/ProgramData/PuppetLabs/puppet/var/state',
}

RSpec.configure do |c|
  vardir = VARDIR[PLATFORM_TYPE]
  c.default_facts = c.default_facts.merge(:vardir => vardir, :puppet_vardir => vardir, :concat_basedir => "#{vardir}/concat")
end

# Taken from <https://github.com/puppetlabs/puppet/blob/3.7.5/spec/shared_contexts/platform.rb>.

shared_context 'platform' do |platform|
  vardir = VARDIR[platform]
  let_facts_merge(:vardir => vardir, :puppet_vardir => vardir, :concat_basedir => "#{vardir}/concat")

  before :each do
    # For a given example, don't allow the stubbing of conflicting platforms, and don't
    # bother re-stubbing the same platform.
    @stubbed_platform ||= nil
    next if platform == @stubbed_platform
    raise "Attempted to stub platform #{platform} after already stubbing platform #{@stubbed_platform}" unless @stubbed_platform.nil?
    @stubbed_platform = platform

    @is_windows = (platform == :windows)
    @parent_is_windows = Puppet.features.microsoft_windows?

    # Don't bother stubbing the platform if the actual machine (or the stubbed platform
    # from a parent example) is of the same type.
    next if @is_windows == @parent_is_windows

    with_verbose_disabled do
      # Compile the catalog a few times, ignoring all exceptions (which can be caused by
      # platform differences), to make sure that all custom types have been defined
      # before the platform is stubbed out.
      # This needs to happen in a ``before :each`` block, rather than an `around` block,
      # to take advantage of rspec-puppet using an earlier ``before :each`` block to
      # call `Puppet::Test::TestHelper.before_each_test()`, which is necessary for
      # compilation to succeed.
      (0..4).each do
        begin
          unless (self.class.ancestors & EXAMPLE_GROUPS_WITH_SUBJECT_THAT_LOADS_CATALOG).empty?
            subject.call
          end
        rescue
          # For now, ignore any exceptions, since we're purposely trying to trigger and
          # ignore any one-time exceptions that occur during Puppet type loading. If
          # they aren't one-time exceptions, they will get raised again during the test.
        else
          break
        end
      end
    end

    # Puppet builds into its objects the ability to do stubbing with the mocha framework.
    # `stubs` is a method defined in the mocha framework.
    # Stubbed methods must be torn down at the end of each test. But because we do not
    # register mocha with rspec (instead, we register rspec-mocks, because we need the
    # `double` method that it defines), this is not done automatically. So we must call
    # `Mocha::Mockery.teardown` in an ``after(:each)`` block, below.
    Puppet.features.stubs(:microsoft_windows?).returns(if @is_windows then true else nil end)
    Puppet.features.stubs(:posix?).returns(! @is_windows)

    # prevent Ruby from warning about changing a constant
    with_verbose_disabled do
      @parent_alt_separator = File::ALT_SEPARATOR
      @parent_path_separator = File::PATH_SEPARATOR
      File::ALT_SEPARATOR = if @is_windows then '\\' else nil end
      File::PATH_SEPARATOR = if @is_windows then ';' else ':' end
    end

    # Convert the module path into the correct format for this platform.
    RSpec.configure do |c|
      c.fix_module_path_separator
    end
  end

  after :each do
    # Return platform stubs to their previous values when example completes.  This is
    # not necessarily the same as the correct, un-stubbed values for the underlying
    # machine. In case an example is running inside another example, when the nested
    # example completes, the platform stubs should be the same as when the outer example
    # began. Say, for example, there is a Windows example running inside a Windows
    # example, running on a Linux machine. When the inner example completes, the outer
    # example should NOT be running with unstubbed Linux values. It should instead
    # continue running with its original Windows stubs.

    next if @is_windows == @parent_is_windows

    with_verbose_disabled do
      File::ALT_SEPARATOR = @parent_alt_separator
      File::PATH_SEPARATOR = @parent_path_separator
    end
    if @parent_is_windows == IS_WINDOWS
      Mocha::Mockery.teardown
    else
      Puppet.features.stubs(:microsoft_windows?).returns(@parent_is_windows)
      Puppet.features.stubs(:posix?).returns(! @parent_is_windows)
    end

    RSpec.configure do |c|
      c.fix_module_path_separator
    end
  end
end

shared_context 'windows', :as_platform => :windows do
  include_context 'platform', :windows
  let_facts_merge(:kernel => 'windows', :osfamily => 'windows', :operatingsystem => 'windows', :root_home => 'C:\Users\Administrator')
end

shared_context 'posix', :as_platform => :posix do
  include_context 'platform', :posix
end

shared_context 'solaris', :as_platform => :solaris do
  include_context 'posix'
  let_facts_merge(:kernel => 'Solaris', :osfamily => 'Solaris', :operatingsystem => 'Solaris', :root_home => '/root')
end

shared_context 'linux', :as_platform => :linux do
  include_context 'posix'
  let_facts_merge(:kernel => 'Linux', :osfamily => 'Linux', :root_home => '/root')
end

shared_context 'debian', :as_platform => :debian do
  include_context 'linux'
  let_facts_merge(:osfamily => 'Debian')
end

shared_context 'redhat', :as_platform => :redhat do
  include_context 'linux'
  let_facts_merge(:osfamily => 'RedHat')
end

shared_context 'scientific', :as_platform => :scientific do
  include_context 'redhat'
  let_facts_merge(:operatingsystem => 'Scientific')
end

shared_context 'centos', :as_platform => :centos do
  include_context 'redhat'
  let_facts_merge(:operatingsystem => 'CentOS')
end

shared_context 'darwin', :as_platform => :darwin do
  include_context 'posix'
  let_facts_merge(:operatingsystem => 'Darwin', :osfamily => 'Darwin', :kernel => 'Darwin', :root_home => '/var/root')
end
