# -*- encoding : utf-8 -*-

require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet'

# Use UTF-8 encoding to parse Ruby .rb files, and don't escape non-ASCII
# characters in unicode strings when printing and calling `#inspect`.
$KCODE = "UTF-8"

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
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
