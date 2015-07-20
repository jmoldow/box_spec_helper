# -*- encoding : utf-8 -*-

require 'spec_helper'

describe 'acl support' do
  def self.compile_should_be_skipped(test_description, puppet_class)
    it test_description do
      group = RSpec::Core::ExampleGroup.describe puppet_class, :type => :class, :as_platform => :windows do
        it { should compile }
      end
      example = group.examples.first
      example.run(group.new, double.as_null_object)
      expect(example).to be_skipped_with_regexp(SHORT_ACL_SKIP_MESSAGE)
    end
  end

  compile_should_be_skipped 'compile test with basic Acl resource should be skipped', '::acl_test::basic'
  compile_should_be_skipped 'compile test with basic Acl resource should be skipped again', '::acl_test::basic'
  compile_should_be_skipped 'compile test with full Acl resouce should be skipped', '::acl_test::full'
  compile_should_be_skipped 'compile test with dependent of class with Acl resource should be skipped', '::acl_test::dependent'

  it 'can still perform other tests' do
    group = RSpec::Core::ExampleGroup.describe '::acl_test::full', :type => :class, :as_platform => :windows do
      it do
        should contain_acl('C:\Users\bob\foobar.txt').with({
          :owner        => 'bob',
          :group        => 'Administrators',
          :permissions  => [
            {
              'identity'  => 'bob',
              'rights'    => ['full'],
            },
            {
              'identity'  => 'Administrators',
              'rights'    => ['full'],
            },
            {
              'identity'  => 'SYSTEM',
              'rights'    => ['full'],
            },
          ],
        })
      end
    end
    example = group.examples.first
    example.run(group.new, double.as_null_object)
    expect(example).to pass
  end
end
