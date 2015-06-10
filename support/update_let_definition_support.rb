# -*- encoding : utf-8 -*-

require 'rubygems'
require 'rspec/core/memoized_helpers'

module RSpec
  module Core
    module MemoizedHelpers
      # If `let(name)` is called multiple times within the same context nesting
      # level (perhaps because of multiple included shared_contexts), the last
      # definition completely overwrites all previous definitions. There is no
      # ability to use super() to invoke the previous definition; this feature can
      # only be used to invoke a definition from a parent context.
      #
      # All of the following methods define or update an existing `let` definition
      # in this context, rather than overwrite it. They will also take the
      # definition from a parent context, and update it in this context.
      module ClassMethods

        # Treat `name` as an Array (with default value []), and add `array` to the
        # end of the definition.
        def let_array_add(name, array)
          let_accumulate(name, :+, []) { array }
        end


        # Treat `name` as a Hash (with default value {}), and merge `hash` into
        # the definition.
        def let_hash_merge(name, hash)
          let_accumulate(name, :merge, {}) { hash }
        end

        # Helper method specifically for Puppet Facter facts. Treat `:facts` as a
        # Hash (with default value {}), and merge `hash` into the definition.
        def let_facts_merge(hash)
          let_hash_merge(:facts, hash)
        end

        private

        # @private
        #
        # The block is the same as for `let`. But rather than using the result
        # directly and overriding previous definitions, the result is combined
        # with previous definitions, providing a new accumulated value.
        #
        # `operation` can be any:
        # - one argument UnboundMethod (it is bound to the previous value `memo`,
        # and called with the result of the block `obj`); or
        # - symbol for a method on the previous value `memo` (it is called with
        # the result of the block `obj`); or
        # - two argument Proc (the previous value `memo` is passed as the first
        # argument, and the result of the block `obj` is passed as the second
        # argument).
        #
        # If this is the first definition for `name` in this nested context level,
        # `memo` will be `super()`, or `default` if no parent contexts have `let`
        # definitions for `name`.
        #
        # Because of the way this method is implemented, the block cannot use
        # `super` or `return`, unlike for `let`.
        #
        # @example
        #
        #   describe RSpec::Core::MemoizedHelpers::ClassMethods do
        #     let_accumulate(:foo, :+, []) { [:foo] }
        #     let_accumulate(:foo, :+, []) { [:bar] }
        #
        #     it { expect(foo).to eq([:foo, :bar]) }
        #
        #     context 'child' do
        #       let_accumulate(:foo, :+, []) { [:baz] }
        #       let_accumulate(:foo, :+, []) { [:foobarbaz] }
        #
        #       it { expect(foo).to eq([:foo, :bar, :baz, :foobarbaz]) }
        #     end
        #   end
        #
        # @note `let_accumulate` is private, because it relies on the caller to
        # pass the same values of `operation` and `default` for all definitions of
        # the same `name`.  Instead, use public helper methods to make use of this
        # method.
        def let_accumulate(name, operation, default, &block)
          op = if operation.is_a?(UnboundMethod)
            lambda { |memo, obj| operation.bind(memo).call(obj) }
          elsif operation.is_a?(Symbol)
            lambda { |memo, obj| memo.method(operation).call(obj) }
          else
            operation
          end
          let_reduce(name, default) { |memo, example| op.call(memo, block.call(example)) }
        end

        # @private
        #
        # The block can take one or two parameters. The optional second parameter
        # is the current RSpec example, equivalent to the optional parameter to
        # the block for `let`.  The first parameter is `memo`, the accumulated
        # value of all previous `let_reduce` definitions for `name` in this
        # context nesting level. The block should compute, without modifying
        # `memo`, the next memo, which will also serve as the final accumulated
        # definition for `name` in this context nesting level if there are no more
        # `let` definitions for `name` in this context nesting level. The initial
        # memo is `super()`, or `default` if no parent contexts have `let` or
        # definitions for `name`.
        #
        # Because of the way this method is implemented, the block cannot use
        # `super` or `return`, unlike for `let`.
        #
        # @example
        #
        #   describe RSpec::Core::MemoizedHelpers::ClassMethods do
        #     let_reduce(:foo, []) { |memo| memo + [:foo] }
        #     let_reduce(:foo, []) { |memo| memo + [:bar] }
        #
        #     it { expect(foo).to eq([:foo, :bar]) }
        #
        #     context 'child' do
        #       let_reduce(:foo, []) { |memo| memo + [:baz] }
        #       let_reduce(:foo, []) { |memo| memo + [:foobarbaz] }
        #
        #       it { expect(foo).to eq([:foo, :bar, :baz, :foobarbaz]) }
        #     end
        #   end
        #
        # @note `let_reduce` is private, because it relies on the caller to pass
        # the same value of `default` for all definitions of the same `name`.
        # Instead, use public helper methods to make use of this method.
        def let_reduce(name, default, &block)
          @lets ||= Hash.new { |hash, key| hash[key] = [] }
          definitions = @lets[name]
          definitions << block
          let(name) do |example|
            initial = begin
              super()
            rescue NoMethodError
              default
            end
            definitions.reduce(initial) { |memo, block| block.call(memo, example) }
          end
        end
      end
    end
  end
end
