# -*- encoding : utf-8 -*-

require 'rubygems'

require 'puppet'
require 'rspec-puppet'
require 'rspec-puppet/support'

require 'support/warn'

# Up through version 2.2.0, RSpec::Puppet::Support's import_str() and setup_puppet()
# methods could not correctly handle multiple module path directories [1]. As of the
# time of this writing, these bugs have been fixed in the master branch, but there has
# not yet been a release containing these fixes. In this file, we override those methods
# with the fixes from the master branch.
#
# [1] https://github.com/rodjek/rspec-puppet/pull/223

unless (rspec_puppet_version = Gem.loaded_specs['rspec-puppet'].version) <= Gem::Version.new('2.2.0')
  # Don't raise an exception, in case upgrading of rspec-puppet doesn't happen all at
  # once; we still want testing to work during the transition period.  But do print a
  # very prominent warning to stderr.
  warn_with_emphasis "
    Expected rspec-puppet version <=2.2.0, got #{rspec_puppet_version}.
    If all Puppet test machines are no longer running <=2.2.0, remove
    RSpec::Puppet::Support#import_str() patch in
    spec/support/site_manifest_import.rb, as it is no longer necessary.
  ".strip.gsub(/^ +/, '')
else
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
