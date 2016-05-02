# box_spec_helper
 A set of extensions to puppetlabs_spec_helper and rspec-puppet, for monolithic spaghetti puppet repos

## Homepage

[https://github.com/jmoldow/box_spec_helper](https://github.com/jmoldow/box_spec_helper)


## How to Use

These files all go into the root directory of your puppet control repo.

Create spec tests in spec/classes/, spec/defines/, and spec/functions/.

Run tests with any of the following commands:

- rake spec

  - Run all tests

- rake spec SPEC=spec/classes/foo

  - Run all tests in a directory

- rake spec SPEC=spec/classes/foo/init_spec.rb

  - Run all tests in a file

- rake spec SPEC=spec/*/foo/

  - Run all tests that match a path glob

Or use [box/clusterrunner](https://forge.puppet.com/box/clusterrunner) to
deploy [ClusterRunner](http://clusterrunner.com/) and execute your test suite
across a pool of machines (sample [clusterrunner.yaml](/clusterrunner.yaml)
file provided in this repository).

## Blog Posts and Presentations

- [Developing an Efficient Puppet Unit Testing Workflow Using ClusterRunner](https://www.box.com/blog/developing-efficient-puppet-unit-testing-workflow-using-clusterrunner/)

More blog posts comming soon. Stay tuned to
[https://www.box.com/blog/engineering/](https://www.box.com/blog/engineering/).

- [https://cloud.box.com/s/aeqhi3obhmu8yghi6w5xad31yt9fwcx5](https://cloud.box.com/s/aeqhi3obhmu8yghi6w5xad31yt9fwcx5)
  - Draft slides for PuppetConf talk proposal.

## Related Projects

- puppetlabs_spec_helper

  - [https://github.com/puppetlabs/puppetlabs_spec_helper](https://github.com/puppetlabs/puppetlabs_spec_helper)

  - [https://rubygems.org/gems/puppetlabs_spec_helper](https://rubygems.org/gems/puppetlabs_spec_helper)

  - [http://rubydoc.info/gems/puppetlabs_spec_helper](http://rubydoc.info/gems/puppetlabs_spec_helper)

- rspec-puppet

  - [https://github.com/rodjek/rspec-puppet](https://github.com/rodjek/rspec-puppet)

  - [https://rubygems.org/gems/rspec-puppet](https://rubygems.org/gems/rspec-puppet)

  - [http://rubydoc.info/gems/rspec-puppet](http://rubydoc.info/gems/rspec-puppet)

- rspec

  - [https://github.com/rspec](https://github.com/rspec)

  - [https://rubygems.org/gems/rspec](https://rubygems.org/gems/rspec)

  - [https://relishapp.com/rspec](https://relishapp.com/rspec)

  - [http://rspec.info/](http://rspec.info/)

- puppet

  - [https://github.com/puppetlabs/puppet](https://github.com/puppetlabs/puppet)

  - [https://rubygems.org/gems/puppet](https://rubygems.org/gems/puppet)

  - [https://docs.puppet.com](https://docs.puppet.com)

- box/clusterrunner

  - [https://forge.puppet.com/box/clusterrunner](https://forge.puppet.com/box/clusterrunner)

  - [https://github.com/box/puppet-clusterrunner](https://github.com/box/puppet-clusterrunner)

## Other Resources

- [https://github.com/jmoldow](https://github.com/jmoldow)

- [https://github.com/box](https://github.com/box)

- [http://opensource.box.com](http://opensource.box.com)

- [https://www.box.com/careers](https://www.box.com/careers)

## Contributors

The list of contributors can be found in [AUTHORS.md](/AUTHORS.md) and on
[Github](https://github.com/jmoldow/box_spec_helper/graphs/contributors).

## Support

Need to contact us directly? Email oss@box.com and be sure to include the name
of this project in the subject. For questions, please contact us directly
rather than opening an issue.

Feel free to contact the author at jmoldow@alum.mit.edu.

## Contributing

This project is not yet ready for external contributions.

The plan is to try upstreaming pieces of this project into the appropriate
libraries, and create one or more Ruby gems for the rest of the project.  The
repositories for those Ruby gems would be open for contributions, subject to
the [Box Contributor License Agreement (CLA)](http://opensource.box.com/cla/)
and the
[Box Open Code of Conduct](http://opensource.box.com/code-of-conduct/).

## Copyright and License

Copyright 2016 Box, Inc. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
