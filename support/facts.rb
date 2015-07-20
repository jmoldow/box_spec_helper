# -*- encoding : utf-8 -*-

# This file contains patches related to Facter facts.

require 'rubygems'

require 'rspec-puppet/support'

# Patch rspec-puppet to clear all facts before each test, before adding test stubs for
# various facts.
#
# This is perfectly safe. The documentation for `Facter.clear` says that it is intended
# to be used for testing. Any facts that are needed during the test will be regenerated.
#
# Without this, in certain situations, the Facter cache will not be cleared, meaning
# that real system facts or previously stubbed facts can leak from a previous test into
# the current test. It is possibly a bug that rspec-puppet does not already do this.

module RSpec::Puppet
  module Support
    alias :add_facts! :stub_facts!

    def stub_facts!(facts)
      Facter.clear
      add_facts!(facts)
    end
  end
end
