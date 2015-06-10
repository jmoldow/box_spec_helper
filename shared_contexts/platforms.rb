# -*- encoding : utf-8 -*-

require 'rubygems'
require 'rspec-puppet'
require 'puppet'
require 'support/update_let_definition_support'
require 'support/verbose'

VARDIR = {
  :posix    =>  '/var/lib/puppet',
  :windows  =>  'C:/ProgramData/PuppetLabs/puppet/var/state',
}

# Taken from <https://github.com/puppetlabs/puppet/blob/3.7.5/spec/shared_contexts/platform.rb>.

# Contexts for stubbing platforms
# In a describe or context block, adding :as_platform => :windows or
# :as_platform => :posix will stub the relevant Puppet features, as well as
# the behavior of Ruby's filesystem methods by changing File::ALT_SEPARATOR.
# It will also set the relevant facts, which may be used by the manifest being
# tested or its dependencies.

shared_context 'platform' do |platform|
  is_windows = (platform == :windows)

  vardir = VARDIR[platform]
  let_facts_merge(:vardir => vardir, :puppet_vardir => vardir, :concat_basedir => "#{vardir}/concat")

  before :each do
    Puppet.features.stubs(:microsoft_windows?).returns(is_windows)
    Puppet.features.stubs(:posix?).returns(! is_windows)
  end

  around do |example|
    file_alt_separator = File::ALT_SEPARATOR
    file_path_separator = File::PATH_SEPARATOR

    # prevent Ruby from warning about changing a constant
    with_verbose_disabled do
      File::ALT_SEPARATOR = if is_windows then '\\' else nil end
      File::PATH_SEPARATOR = if is_windows then ';' else ':' end
    end
    example.run
    with_verbose_disabled do
      File::ALT_SEPARATOR = file_alt_separator
      File::PATH_SEPARATOR = file_path_separator
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
