# -*- encoding : utf-8 -*-

require 'spec_helper'

describe 'platform shared contexts', :as_platform => PLATFORM_TYPE do
  it 'should allow the same platform to be declared twice' do
    group = RSpec::Core::ExampleGroup.describe 'context with platform declared twice', :as_platform => :posix, :as_arch => :posix_x86 do
      it { expect(true).to eq(true) }
    end
    example = group.examples.first
    example.run(group.new, double.as_null_object)
    expect(example).to pass
  end

  it 'should not allow two different platforms to be declared' do
    group = RSpec::Core::ExampleGroup.describe 'posix context', :as_platform => :posix do
      context 'windows context', :as_platform => :windows do
        it { expect(true).to eq(true) }
      end
    end
    example = group.children.first.examples.first
    example.run(group.new, double.as_null_object)
    expect(example).to fail_with_regexp('Attempted to stub platform windows after already stubbing platform posix')
  end

  it 'should return platform stubs to their previous values (not necessarily the correct values for the underlying machine) when example completes' do
    expect(File::ALT_SEPARATOR).to eq(FILE_ALT_SEPARATOR)
    expect(Puppet.features.microsoft_windows?).to eq(IS_WINDOWS)

    group = RSpec::Core::ExampleGroup.describe 'nested example with opposite stubbed platform', :as_platform => OTHER_PLATFORM_TYPE do
      it do
        expect(File::ALT_SEPARATOR).not_to eq(FILE_ALT_SEPARATOR)
        expect(Puppet.features.microsoft_windows?).to eq(!IS_WINDOWS)

        group = RSpec::Core::ExampleGroup.describe 'nested example with same stubbed platform', :as_platform => OTHER_PLATFORM_TYPE do
          it do
            expect(File::ALT_SEPARATOR).not_to eq(FILE_ALT_SEPARATOR)
            expect(Puppet.features.microsoft_windows?).to eq(!IS_WINDOWS)
          end
        end
        example = group.examples.first
        example.run(group.new, double.as_null_object)
        expect(example).to pass

        expect(File::ALT_SEPARATOR).not_to eq(FILE_ALT_SEPARATOR)
        expect(Puppet.features.microsoft_windows?).to eq(!IS_WINDOWS)
      end
    end
    example = group.examples.first
    example.run(group.new, double.as_null_object)
    expect(example).to pass

    expect(File::ALT_SEPARATOR).to eq(FILE_ALT_SEPARATOR)
    expect(Puppet.features.microsoft_windows?).to eq(IS_WINDOWS)
  end
end
