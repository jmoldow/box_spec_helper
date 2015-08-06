require 'spec_helper'

describe '::undef_test::undef', :type => :class do
  shared_examples 'examples' do
    # For each of param1 and param2, the value of the param on the foobar declaration is
    # expected to be the same as its value in the :params Hash. Unless it is not
    # specified in the :params Hash, in which case it should default to undef.
    let(:expected_params) { {:param1 => UNDEF, :param2 => UNDEF}.merge(params) }

    it { should compile.with_all_deps }
    it { should contain_undef_test__foobar('foobar').with(expected_params) }
  end

  shared_examples 'param2 variations' do
    context 'with param2 unspecified' do
      include_examples 'examples'
    end

    context 'with param2 defined' do
      let_params_merge(:param2 => 2)
      include_examples 'examples'
    end

    context 'with param2=undef' do
      let_params_merge(:param2 => UNDEF)
      include_examples 'examples'
    end
  end

  context 'with param1 defined' do
    let_params_merge(:param1 => 1)
    include_examples 'param2 variations'
  end

  context 'with param1=undef' do
    let_params_merge(:param1 => UNDEF)
    include_examples 'param2 variations'
  end
end
