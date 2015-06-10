#! /usr/bin/env ruby -S rspec
# -*- encoding : utf-8 -*-

# Copied from modules/stdlib/spec/lib/puppet_spec/verbose.rb

# Support code for running stuff with warnings disabled.
module Kernel
  def with_verbose_disabled
    verbose, $VERBOSE = $VERBOSE, nil
    result = yield
    $VERBOSE = verbose
    return result
  end
end
