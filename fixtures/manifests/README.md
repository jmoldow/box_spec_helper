This is the manifests directory that gets used during rspec-puppet
testing. It should contain a symlink to site.pp, so that during testing
we use the same global defaults as we do in production.

NOTE: Since we are using a symlink, this may break if we ever try
running tests on actual Windows machines.
