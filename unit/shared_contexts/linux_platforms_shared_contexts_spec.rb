# -*- encoding : utf-8 -*-

require 'spec_helper'

describe 'linux platforms shared contexts' do
  vardir = '/var/lib/puppet'
  concat_dir = "#{vardir}/concat"
  facts_posix = {:vardir => vardir, :puppet_vardir => vardir, :concat_basedir => concat_dir}
  facts_linux = {:kernel => 'Linux', :osfamily => 'Linux', :root_home => '/root'}.merge(facts_posix)
  facts_x64 = {:architecture => 'x86_64', :hardwaremodel => 'x86_64'}
  facts_posix_x64 = facts_posix.merge(facts_x64)
  facts_linux_x64 = facts_linux.merge(facts_x64)
  facts_x86 = {:architecture => 'x86', :hardwaremodel => 'x86'}
  facts_posix_x86 = facts_posix.merge(facts_x86)
  facts_linux_x86 = facts_linux.merge(facts_x86)

  context 'with {:as_platform => :linux, :as_arch => :posix_x64}', :as_platform => :linux, :as_arch => :posix_x64 do
    it { expect(facts).to eq(facts_linux_x64) }
  end

  context 'with {:as_platform => :linux, :as_arch => :x86}', :as_platform => :linux, :as_arch => :x86 do
    it { expect(facts).to eq(facts_linux_x86) }
  end

  context 'with {:as_platform => :linux, :as_arch => :posix_x86}', :as_platform => :linux, :as_arch => :posix_x86 do
    it { expect(facts).to eq(facts_linux_x86) }
  end

  context 'with {:as_arch => :posix_x64, :as_platform => :linux}', :as_arch => :posix_x64, :as_platform => :linux do
    it { expect(facts).to eq(facts_linux_x64) }
  end

  context 'with {:as_arch => :x86, :as_platform => :linux}', :as_arch => :x86, :as_platform => :linux do
    it { expect(facts).to eq(facts_linux_x86) }
  end

  context 'with {:as_arch => :posix_x86, :as_platform => :linux}', :as_arch => :posix_x86, :as_platform => :linux do
    it { expect(facts).to eq(facts_linux_x86) }
  end

  context 'with :as_platform => :linux', :as_platform => :linux do
    it { expect(facts).to eq(facts_linux) }

    context 'with :as_arch => :posix_x64', :as_arch => :posix_x64 do
      it { expect(facts).to eq(facts_linux_x64) }
    end

    context 'with :as_arch => :x86', :as_arch => :x86 do
      it { expect(facts).to eq(facts_linux_x86) }
    end
  end

  context 'with :as_arch => :posix_x64', :as_arch => :posix_x64 do
    it { expect(facts).to eq(facts_posix_x64) }

    context 'with :as_platform => :linux', :as_platform => :linux do
      it { expect(facts).to eq(facts_linux_x64) }
    end
  end

  context 'with :as_arch => :x86', :as_arch => :x86 do
    it { expect(facts).to eq(facts_x86) }

    context 'with :as_platform => :linux', :as_platform => :linux do
      it { expect(facts).to eq(facts_linux_x86) }
    end
  end

  context 'with :as_arch => :posix_x86', :as_arch => :posix_x86 do
    it { expect(facts).to eq(facts_posix_x86) }

    context 'with :as_platform => :linux', :as_platform => :linux do
      it { expect(facts).to eq(facts_linux_x86) }
    end
  end
end
