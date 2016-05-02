# Exercise some custom types for Windows, to ensure that RSpec can test them.

class windows_platform_test {
  # Also exercise the windows file provider, which needed some modifications to work
  # properly when running Windows tests on non-Windows platforms.
  file { 'C:/Users/bob/foobar.txt':
    content => 'Hello World!',
    owner   => 'bob',
    group   => 'Administrators',
  }

  registry::value { 'Setting0':
    key   => 'HKLM\System\CurrentControlSet\Services\Puppet',
    value => '(default)',
    data  => 'Hello World!',
    type  => 'string',
  }

  windows_env { 'title':
    ensure            => present,
    mergemode         => 'prepend',
    variable          => 'VAR',
    value             => ['VAL', 'VAL2'],
    user              => 'bob',
    separator         => ':',
    broadcast_timeout => 2000,
    type              => 'REG_SZ',
  }
}
