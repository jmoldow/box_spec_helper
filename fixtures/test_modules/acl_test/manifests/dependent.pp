# Exercise including a manifests that defines an Acl resource.
class acl_test::dependent {
  include ::acl_test::basic
  include ::acl_test::full
}
