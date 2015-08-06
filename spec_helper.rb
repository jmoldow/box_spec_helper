# -*- encoding : utf-8 -*-

require 'rubygems'
require 'pathname'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet'
require 'puppet/settings/autosign_setting'

# Use UTF-8 encoding to parse Ruby .rb files, and don't escape non-ASCII
# characters in unicode strings when printing and calling `#inspect`.
$KCODE = "UTF-8"

default_architecture = 'x86'
default_fqdn = 'foo.bar.baz.net'

RSpec.configure do |c|
  def c.spec_dir
    @spec_dir ||= File.expand_path(File.dirname(__FILE__))
  end

  def c.spec_dir_pathname
    @spec_dir_pathname ||= Pathname.new(spec_dir)
  end

  def c.fixture_path
    @fixture_path ||= File.join(spec_dir, 'fixtures')
  end

  c.manifest_dir = File.join(c.fixture_path, 'manifests')
  c.default_facts = {
    :architecture   =>  default_architecture,
    :hardwaremodel  =>  default_architecture,
    :fqdn           =>  default_fqdn,
    :hostname       =>  default_fqdn.split('.').first,
    :domain         =>  default_fqdn.split('.', 2).last,
    :ipaddress      =>  '192.168.0.1',
    :gid            =>  '0',
    :timezone       =>  'PST',
  }
  c.default_facts.merge!({
    :facterversion  =>  Facter::FACTERVERSION,
    :puppetversion  =>  Puppet::PUPPETVERSION,
    :rubyversion    =>  RUBY_VERSION,
  })

  # The rspec-mocks framework is needed in order to call the `double` method to create
  # test double objects inside examples.
  c.mock_framework = :rspec

  c.before :each do
    Puppet::Settings::AutosignSetting.any_instance.stubs(:munge).returns(false)
  end

  # Detect and return the platform path separator that is being used in the module path,
  # or nil if there is none.
  def c.module_path_separator
    (self.module_path.chars.to_a & [':', ';']).first
  end

  # Get the list of directories in the module path.
  def c.module_path_dirs
    self.module_path.split(self.module_path_separator)
  end

  # Construct and set the module_path configuration setting, given a list of
  # directories.
  def c.set_module_path_from_dir_list(dir_list)
    self.module_path = dir_list.join(File::PATH_SEPARATOR)
  end

  # Reset the value of the module_path configuration setting, ensuring that the current
  # value of File::PATH_SEPARATOR (which may have been changed in
  # spec/shared_contexts/platform.rb) is used as the path separator.
  def c.fix_module_path_separator
    self.module_path.gsub!(/[:;]/, File::PATH_SEPARATOR)
  end

  c.set_module_path_from_dir_list([
    File.join(c.fixture_path, 'test_modules'),
    File.join(c.fixture_path, 'modules'),
  ])

  Pathname.glob("#{c.spec_dir}/support/**/*.rb") do |file|
    require file.relative_path_from(c.spec_dir_pathname)
  end

  Pathname.glob("#{c.spec_dir}/shared_contexts/*.rb") do |file|
    require file.relative_path_from(c.spec_dir_pathname)
  end

  Pathname.glob("#{c.spec_dir}/shared_examples/*.rb") do |file|
    require file.relative_path_from(c.spec_dir_pathname)
  end
end

# NOTE(jmoldow): Despite what you may read online, setting a param to
# `nil` in Ruby is NOT the same thing as setting it to `undef` in
# Puppet.  The only good solution to this that I've found was proposed
# at the end of this thread [1].
# [1] <https://groups.google.com/forum/#!topic/puppet-users/6nL2eROH8is>
class PuppetUndef
  def inspect
    'undef'
  end

  def nil?
    true
  end
end

# NOTE(jmoldow): Use this instead of `undef` or `nil`.
UNDEF = PuppetUndef.new
