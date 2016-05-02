This directory is for modules that contain test stubs of custom puppet
functions. During rspec-puppet manifest tests, this directory is placed
before the modules/ directory in the puppet module path. That way, any
stub functions will be defined before the real functions, and the real
functions will be ignored.

The names of modules in this directory must be unique from the names of modules
in the modules/ directory. Otherwise, the puppet parser will only look in
override_modules/<name>/ for *.pp files, and the classes and defines in
modules/<name>/ will not be discoverable during tests. If the function being
stubbed is in modules/foobar/lib/puppet/parser/functions/, the stub should be
placed in override_modules/foobar_overrides/lib/puppet/parser/functions/.

If a function is not stubbed in this directory, then its normal
functionality will be used during tests.

Manifests should not be placed in this directory.
