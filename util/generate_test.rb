#!/usr/bin/ruby

require 'fileutils'
require 'pathname'
require 'yaml'

if ARGV.empty?
  git_root = Pathname.new(`git rev-parse --show-toplevel`.strip)
  absolute_file_path = Pathname.new(File.expand_path(__FILE__))
  puts "Usage: #{absolute_file_path.relative_path_from(git_root)} modules/[module name]/manifests/[path_to_manifest]"
  exit 1
end

path = ARGV[0]
raise 'File does not exist' unless File.exists?(path)

basename = File.basename(path)
raise 'Path does not point to a .pp file' unless basename =~ /.*\.pp/

dirname = File.dirname(path)
directories = dirname.split(File::SEPARATOR)
raise "First directory is not modules, it is #{directories[0]}" unless directories[0] == 'modules'

puppet_module = directories[1]
fixtures = YAML.load_file('.fixtures.yml')
fixtures.inspect()
unless fixtures['fixtures']['symlinks'].has_key? puppet_module
  fixtures['fixtures']['symlinks'][puppet_module] = "\#{source_dir}/modules/#{puppet_module}"
  File.open('.fixtures.yml', 'w') { |file| file.write fixtures.to_yaml }
end

puppet_class = File.open(path, 'r').read().scan(/^class ([\w\d_:-]+)/)
puppet_manifest = basename.split('.').first()
manifest_directories = directories.drop(3) # Captures any directories between 'manifests' and the .pp file
test_directories = ["spec", "classes", puppet_module] + manifest_directories + ["#{puppet_manifest}_spec.rb"]

target_path = test_directories.join(File::SEPARATOR)
raise "File already exists: #{target_path}" if File.exists?(target_path)

boilerplate_test = %{require 'spec_helper'

describe '::#{puppet_class}' do
  include_examples 'default'
end
}

FileUtils.mkpath(File.dirname(target_path))
File.open(target_path, 'w+') { |file| file.write(boilerplate_test) }
puts(target_path)
