# -*- encoding : utf-8 -*-

require 'rubygems'

require 'rspec-puppet/example'

# If an example group has one of these modules as an ancestor, then its `subject` method
# is defined to return a `Proc` that, when called, loads and returns the catalog.
EXAMPLE_GROUPS_WITH_SUBJECT_THAT_LOADS_CATALOG = [
  RSpec::Puppet::DefineExampleGroup,
  RSpec::Puppet::ClassExampleGroup,
  RSpec::Puppet::HostExampleGroup,
]
