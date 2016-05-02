# This is for testing that we can successfully set parameters to undef, and that we can
# successfully check for undef parameters.
class undef_test::undef ($param1, $param2 = undef) {
  foobar { 'foobar':
    param1  => $param1,
    param2  => $param2,
  }
}
