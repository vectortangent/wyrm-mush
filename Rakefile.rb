$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), *%w[engine]))

require 'aresmush'
require 'erubis'
require 'rspec'
require 'rspec/core/rake_task'
require 'tempfile'
#require 'mongoid'
require_relative 'install/init_db.rb'
require_relative 'install/configure_game.rb'

def minimal_boot
  bootstrapper = AresMUSH::Bootstrapper.new
  bootstrapper.config_reader.load_game_config
  AresMUSH::Global.plugin_manager.load_all
  bootstrapper.db.load_config
end

task :startares do
  bootstrapper = AresMUSH::Bootstrapper.new
  bootstrapper.start
end
  
task :configure do
  AresMUSH::Install.configure_game
end

task :add_plugin, [:plugin_name] do |t, args|
  minimal_boot
  plugin_name = args[:plugin_name]
  importer = AresMUSH::Manage::PluginImporter.new(plugin_name)
  importer.import
end

task :webexport do
  minimal_boot
  load File.join(AresMUSH.root_path, "plugins/website/public/filename_sanitizer.rb")
  load File.join(AresMUSH.root_path, "plugins/website/wiki_exporter.rb")
  
  AresMUSH::Website::WikiExporter.export
end

task :dumpdb do
  minimal_boot
  AresMUSH::Channel.all.each do |c|
    puts c.inspect
  end
  
  AresMUSH::Character.all.each do |c|
    puts c.inspect
  end

  AresMUSH::Room.all.each do |c|
    puts c.inspect
  end
  
  puts AresMUSH::Game[1].inspect
end

task :init do    
  minimal_boot
  AresMUSH::Install.init_db
end

task :dbscript, [:scriptname, :param] do |t, args|
  minimal_boot
  scriptname = args[:scriptname]
  ENV['ares_rake_param'] = args[:param]
  require_relative "install/scripts/#{scriptname}.rb"
end

desc "Run all specs."
begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec, :tag) do |t, task_args|
    tag = task_args[:tag]
    if (tag)
      t.pattern = "spec/**/*_specs.rb,spec/**/*_spec.rb,plugins/**/*_specs.rb,plugins/**/*_spec.rb"
      t.rspec_opts = "--example #{tag}"
    end
  end
rescue LoadError
  # no rspec available
end

desc "Run all specs except the db ones."
begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new('spec:unit', :tag) do |t, task_args|
    t.pattern = "spec/**/*_specs.rb,spec/**/*_spec.rb,plugins/**/*_specs.rb,plugins/**/*_spec.rb"
    t.rspec_opts = "--tag ~dbtest"
  end
rescue LoadError
  # no rspec available
end


# Generate documentation
#require 'rdoc/task'

#RDoc::Task.new do |rdoc|
#  rdoc.rdoc_dir = 'rdoc'
#  rdoc.main = "README.doc"
  
#  plugin_files = AresMUSH::PluginManager.plugin_files
#  templates = plugin_files.select { |f| f =~ /template/ }
   
#  rdoc.rdoc_files = templates
#  rdoc.rdoc_files.include("plugins/**/*.rb")
#  rdoc.rdoc_files.exclude("^((?!Template).)*$")
#end

task :default => 'spec:unit'

