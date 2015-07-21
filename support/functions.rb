# -*- encoding : utf-8 -*-

# Allow custom functions to be stubbed during puppet manifest tests.
#
# Some custom functions will always fail during puppet manifest tests. This
# file makes it possible to stub such functions. If a stub is defined in the
# appropriate place in the spec/fixtures/override_modules/ directory, then this
# stub function will be used during puppet manifest tests, instead of the real
# function.
#
# This is accomplished by placing spec/fixtures/override_modules/ at the head of the
# module search path during puppet manifest tests. Only functions defined there will be
# stubbed; all other functions, even in the same module, will continue to execute
# normally.
#
# The stub function should perform input validation and return a value of the correct
# type, so that this test coverage is not lost.
#
# Manifests should not be placed in the spec/fixtures/override_modules/ directory.
#
# This functionality is not used during puppet custom function tests. That way, it is
# still possible to write tests for such functions.

RSpec.configure do |c|
  # A list of directories that contain modules with stub functions.
  def c.override_module_path_dirs
    [File.join(self.fixture_path, 'override_modules')]
  end

  c.before :each do
    # If this is a manifest test, prepend override_module_path_dirs to the module path.
    unless (self.class.ancestors & EXAMPLE_GROUPS_WITH_SUBJECT_THAT_LOADS_CATALOG).empty?
      RSpec.configure do |c|
        c.set_module_path_from_dir_list(c.override_module_path_dirs + c.module_path_dirs)
      end
    end
  end

  c.after :each do
    # After each test, remove override_module_path_dirs from the module path.
    RSpec.configure do |c|
      c.set_module_path_from_dir_list(c.module_path_dirs.reject(&c.override_module_path_dirs.method(:member?)))
    end
  end
end
