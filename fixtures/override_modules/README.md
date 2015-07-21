This directory is for modules that contain test stubs of custom puppet
functions. During rspec-puppet manifest tests, this directory is placed
before the modules/ directory in the puppet module path. That way, any
stub functions will be defined before the real functions, and the real
functions will be ignored.

If a function is not stubbed in this directory, then its normal
functionality will be used during tests.

Manifests should not be placed in this directory.
