# Exercise an Acl resource with a full set of parameters.
class acl_test::full {
  acl { 'C:\Users\bob\foobar.txt':
    owner        => 'bob',
    group        => 'Administrators',
    permissions  => [
      {
        identity    => 'bob',
        rights      => ['full'],
      },
      {
        identity    => 'Administrators',
        rights      => ['full'],
      },
      {
        identity    => 'SYSTEM',
        rights      => ['full'],
      },
    ],
  }
}
