# -*- encoding : utf-8 -*-

require 'spec_helper'

describe 'update_let_definition_support' do
  context 'let_array_add' do
    let_array_add(:foo, [:foo])
    let_array_add(:foo, [:bar])

    it { expect(foo).to eq([:foo, :bar]) }

    context 'child' do
      let_array_add(:foo, [:baz])
      let_array_add(:foo, [:foobarbaz])

      it { expect(foo).to eq([:foo, :bar, :baz, :foobarbaz]) }
    end
  end

  context 'let_hash_merge' do
    let_hash_merge(:foo, :foo => 0)
    let_hash_merge(:foo, :bar => 1)
    let_hash_merge(:foo, :bar => 2)

    it { expect(foo).to eq({:foo => 0, :bar => 2}) }

    context 'child' do
      let_hash_merge(:foo, :baz => 2)
      let_hash_merge(:foo, :foobarbaz => 3)
      let_hash_merge(:foo, :baz => 4)

      it { expect(foo).to eq({:foo => 0, :bar => 2, :baz => 4, :foobarbaz => 3}) }
    end
  end
end

