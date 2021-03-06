# -*- encoding : utf-8 -*-

require 'spec_helper'

describe 'windows platform shared contexts' do
  vardir = 'C:/ProgramData/PuppetLabs/puppet/var/state'
  concat_dir = "#{vardir}/concat"
  facts_windows = {:operatingsystem => 'windows', :osfamily => 'windows', :kernel => 'windows', :root_home => 'C:\Users\Administrator'}
  facts_windows.merge!(:puppet_vardir => vardir, :concat_basedir => concat_dir)
  facts_windows[:path] = "C:\\Windows\\system32;C:\\Windows;C:\\Windows\\System32\\Wbem"
  facts_windows_x64 = {:architecture => 'x64', :hardwaremodel => 'x64'}.merge(facts_windows)
  facts_x86 = {:architecture => 'x86', :hardwaremodel => 'x86'}
  facts_windows_x86 = facts_windows.merge(facts_x86)

  it 'should pass when testing Windows providers' do
    group = RSpec::Core::ExampleGroup.describe '::windows_platform_test', :type => :class, :as_platform => :windows do
      it do
        should compile

        should contain_file('C:/Users/bob/foobar.txt').with({
          :content  => 'Hello World!',
          :owner    => 'bob',
          :group    => 'Administrators',
        })

        should contain_registry__value('Setting0').with({
          :key    => 'HKLM\System\CurrentControlSet\Services\Puppet',
          :value  => '(default)',
          :data   => "Hello World!",
          :type   => 'string',
        })

        should contain_windows_env('title').with({
          :ensure             => 'present',
          :mergemode          => 'prepend',
          :variable           => 'VAR',
          :value              => ['VAL', 'VAL2'],
          :user               => 'bob',
          :separator          => ':',
          :broadcast_timeout  => 2000,
          :type               => 'REG_SZ',
        })
      end
    end
    example = group.examples.first
    example.run(group.new, double.as_null_object)
    expect(example).to pass
  end

  context 'with {:as_platform => :windows, :as_arch => :windows_x64}', :as_platform => :windows, :as_arch => :windows_x64 do
    it { expect(facts).to eq(facts_windows_x64) }
  end

  context 'with {:as_platform => :windows, :as_arch => :x86}', :as_platform => :windows, :as_arch => :x86 do
    it { expect(facts).to eq(facts_windows_x86) }
  end

  context 'with {:as_platform => :windows, :as_arch => :windows_x86}', :as_platform => :windows, :as_arch => :windows_x86 do
    it { expect(facts).to eq(facts_windows_x86) }
  end

  context 'with {:as_arch => :windows_x64, :as_platform => :windows}', :as_arch => :windows_x64, :as_platform => :windows do
    it { expect(facts).to eq(facts_windows_x64) }
  end

  context 'with {:as_arch => :x86, :as_platform => :windows}', :as_arch => :x86, :as_platform => :windows do
    it { expect(facts).to eq(facts_windows_x86) }
  end

  context 'with {:as_arch => :windows_x86, :as_platform => :windows}', :as_arch => :windows_x86, :as_platform => :windows do
    it { expect(facts).to eq(facts_windows_x86) }
  end

  context 'with :as_platform => :windows', :as_platform => :windows do
    it { expect(facts).to eq(facts_windows) }

    context 'with :as_arch => :windows_x64', :as_arch => :windows_x64 do
      it { expect(facts).to eq(facts_windows_x64) }
    end

    context 'with :as_arch => :x86', :as_arch => :x86 do
      it { expect(facts).to eq(facts_windows_x86) }
    end
  end

  context 'with :as_arch => :windows_x64', :as_arch => :windows_x64 do
    it { expect(facts).to eq(facts_windows_x64) }

    context 'with :as_platform => :windows', :as_platform => :windows do
      it { expect(facts).to eq(facts_windows_x64) }
    end
  end

  context 'with :as_arch => :x86', :as_arch => :x86 do
    it { expect(facts).to eq(facts_x86) }

    context 'with :as_platform => :windows', :as_platform => :windows do
      it { expect(facts).to eq(facts_windows_x86) }
    end
  end

  context 'with :as_arch => :windows_x86', :as_arch => :windows_x86 do
    it { expect(facts).to eq(facts_windows_x86) }

    context 'with :as_platform => :windows', :as_platform => :windows do
      it { expect(facts).to eq(facts_windows_x86) }
    end
  end
end
