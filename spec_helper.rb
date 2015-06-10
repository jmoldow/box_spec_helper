# -*- encoding : utf-8 -*-

require 'rubygems'
require 'pathname'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet'
require 'puppet/settings/autosign_setting'

# Use UTF-8 encoding to parse Ruby .rb files, and don't escape non-ASCII
# characters in unicode strings when printing and calling `#inspect`.
$KCODE = "UTF-8"

dir = File.expand_path(File.dirname(__FILE__))
fixture_path = File.join(dir, 'fixtures')
dir_pathname = Pathname.new(dir)

Pathname.glob("#{dir}/support/**/*.rb") do |file|
  require file.relative_path_from(dir_pathname)
end

Pathname.glob("#{dir}/shared_contexts/*.rb") do |file|
  require file.relative_path_from(dir_pathname)
end

default_architecture = 'x86'
default_fqdn = 'foo.bar.baz.net'

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
  c.default_facts = {
    :architecture   =>  default_architecture,
    :hardwaremodel  =>  default_architecture,
    :fqdn           =>  default_fqdn,
    :domain         =>  default_fqdn.split('.').first,
    :hostname       =>  default_fqdn.split('.', 2).last,
    :ipaddress      =>  '192.168.0.1',
    :gid            =>  '0',
    :timezone       =>  'PST',
  }
  c.default_facts.merge!({
    :facterversion  =>  Facter::FACTERVERSION,
    :puppetversion  =>  Puppet::PUPPETVERSION,
    :rubyversion    =>  RUBY_VERSION,
  })
  c.before :each do
    Puppet::Settings::AutosignSetting.any_instance.stubs(:munge).returns(false)
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
end

# NOTE(jmoldow): Use this instead of `undef` or `nil`.
UNDEF = PuppetUndef.new
