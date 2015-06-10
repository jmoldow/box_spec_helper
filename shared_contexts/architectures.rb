# -*- encoding : utf-8 -*-

require 'rubygems'
require 'rspec-puppet'
require 'support/update_let_definition_support'
require 'shared_contexts/platforms'

ARCHITECTURES = {
  :x86  =>  {
    :posix    =>  'x86',
    :windows  =>  'x86',
  },
  :x64  =>  {
    :posix    =>  'x86_64',
    :windows  =>  'x64',
  },
}

# Contexts for stubbing architectures
# In a describe or context block, adding any of
# - :as_arch => :x86
# - :as_arch => :posix_x86
# - :as_arch => :windows_x86
# - :as_arch => :posix_x64
# - :as_arch => :windows_x64
# will set the relevant facts, which may be used by the manifest being tested or
# its dependencies.
# NOTE: There is no :x64 shared context, because its facts are different on the
# two platform types.

shared_context 'architecture' do |architecture|
  let_facts_merge({
    :architecture   =>  architecture,
    :hardwaremodel  =>  architecture,
  })
end

shared_context 'x86', :as_arch => :x86 do
  include_context 'architecture', 'x86'
end

ARCHITECTURES.each do |architecture, platform_hash|
  platform_hash.each do |platform, architecture_string|
    symbol = :"#{platform}_#{architecture}"
    shared_context symbol, :as_arch => symbol do
      include_context platform.to_s
      include_context 'architecture', architecture_string
    end
  end
end
