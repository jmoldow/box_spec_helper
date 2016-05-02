# -*- encoding : utf-8 -*-

# Based on modules/stdlib/spec/lib/puppet_spec/verbose.rb

# Support code for running stuff with warnings disabled/enabled.
module Kernel
  def with_verbose_disabled
    with_verbose(nil) do
      yield
    end
  end

  # If `enabled` is `true`, run the given block with warnings enabled.
  # If `enabled` is `false` or `nil`, run the given block with warnings disabled.
  # In all cases, restore $VERBOSE (the global variable that determines if warnings are
  # enabled or disabled) back to its original value when exiting the block, and return
  # the value of the block.
  #
  # @example
  #
  #   # Print the warning 'DO warn', return 17.
  #   with_verbose do
  #     warn 'DO warn'
  #     17
  #   end
  #
  # @example
  #
  #   # Do not print any warnings, return 17.
  #   with_verbose_disabled do
  #     warn 'DO NOT warn'
  #     17
  #   end
  def with_verbose(enabled=true)
    # Store the old value of $VERBOSE, then set its new value.
    # enabled==true   => $VERBOSE=true
    # enabled==false  => $VERBOSE=nil
    # enabled==nil    => $VERBOSE=nil
    verbose, $VERBOSE = $VERBOSE, (!enabled ? nil : true)

    begin
      yield
    ensure
      $VERBOSE = verbose
    end
  end
end
