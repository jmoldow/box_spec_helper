# -*- encoding : utf-8 -*-

# This source file contains copied and modified source file snippets from
# rspec-puppet 2.3.0, which is available under an MIT Expat license. For
# details, see:
#
# - <https://github.com/rodjek/rspec-puppet/tree/v2.3.0>
# - LICENSE-rspec-puppet-2.3.0 or <https://github.com/rodjek/rspec-puppet/blob/v2.3.0/LICENSE>
# - <https://github.com/rodjek/rspec-puppet/blob/v2.3.0/lib/rspec-puppet/support.rb>

require 'rubygems'

require 'puppet'
require 'rspec-puppet'
require 'rspec-puppet/support'

# Up through version 2.2.0, RSpec::Puppet::Support's import_str() and
# setup_puppet() methods could not correctly handle multiple module path
# directories [1]. These bugs are fixed by [1], and exist in versions 2.3.0 and
# later. In this file, we override those methods with the fixes, so that
# box_spec_helper can be used with rspec-puppet 2.2.0 and eariler.
#
# [1] https://github.com/rodjek/rspec-puppet/pull/223

if Gem.loaded_specs['rspec-puppet'].version <= Gem::Version.new('2.2.0')
  module RSpec::Puppet
    module Support
      alias :setup_puppet_before_appending_to_load_path :setup_puppet

      def setup_puppet
        vardir = setup_puppet_before_appending_to_load_path
        Puppet[:modulepath].split(File::PATH_SEPARATOR).map do |d|
          Dir["#{d}/*/lib"].entries
        end.flatten.each do |lib|
          $LOAD_PATH << lib
        end
        vardir
      end

      def import_str
        import_str = ""
        Puppet[:modulepath].split(File::PATH_SEPARATOR).each { |d|
          if File.exists?(File.join(d, 'manifests', 'init.pp'))
            path_to_manifest = File.join([
              d,
              'manifests',
              class_name.split('::')[1..-1]
            ].flatten)
            import_str = [
              "import '#{d}/manifests/init.pp'",
              "import '#{path_to_manifest}.pp'",
              '',
            ].join("\n")
            break
          elsif File.exists?(d)
            import_str = "import '#{Puppet[:manifest]}'\n"
            break
          end
        }

        import_str
      end
    end
  end
end
