require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "geonames_local"
    gem.summary = "Dump and feed a tokyo local geonames db"
    gem.description = "Dump and feed a tokyo cabinet for local geonames search"
    gem.email = "x@nofxx.com"
    gem.homepage = "http://github.com/nofxx/geonames_local"
    gem.authors = ["Marcos Piccinini"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_dependency "nofxx-georuby", ">= 1.7.1"
    gem.post_install_message = <<-POST_INSTALL_MESSAGE

Geonames Local
--------------

To use the adapter, install the corresponding gem:

  PostgreSQL   =>   pg
  MongoDB      =>   mongodb (optional: mongo_ext)
  Tokyo        =>   tokyocabinet

PostgreSQL
----------

Be sure to use a database based on the PostGIS template.

MongoDB
-------

MongoDB 2D support is new, only mongo >= 1.3.3 mongodb gem >= 0.19.2
http://github.com/mongodb/mongo-ruby-driver

Have fun because:
POST_INSTALL_MESSAGE
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "geonames_local #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

#
# Tokyo Tyrant rake tasks
#
namespace :tyrant do
  TYRANT_DB_FILE  = File.join("tyrant.tct")
  TYRANT_PID_FILE = File.join("tyrant.pid")
  TYRANT_LOG_FILE = File.join("tyrant.log")

  desc "Start Tyrant server"
  task :start  do
    raise RuntimeError, "Tyrant is already running." if tyrant_running?
    system "ttserver -pid #{TYRANT_PID_FILE} -log #{TYRANT_LOG_FILE} #{TYRANT_DB_FILE}&"
    sleep(2)
    if tyrant_running?
      puts "Tyrant started successfully (pid #{tyrant_pid})."
    else
      puts "Failed to start tyrant push server. Check logs."
    end
  end

  desc "Stop Tyrant server"
  task :stop do
    raise RuntimeError, "Tyrant isn't running." unless tyrant_running?
    system "kill #{tyrant_pid}"
    sleep(2)
    if tyrant_running?
      puts "Tyrant didn't stopped. Check the logs."
    else
      puts "Tyrant stopped."
    end
  end

  desc "Restart Tyrant server"
  task :restart => [:stop, :start]

  desc "Get Tyrant Server Status"
  task :status do
    puts tyrant_running? ? "Tyrant running. (#{tyrant_pid})" : "Tyrant not running."
  end
end

def tyrant_pid
  `cat #{TYRANT_PID_FILE}`.to_i
end

def tyrant_running?
  return false unless File.exist?(TYRANT_PID_FILE)
  process_check = `ps -p #{tyrant_pid} | wc -l`
  if process_check.to_i < 2
    puts "Erasing pidfile..."
    `rm #{TYRANT_PID_FILE}`
  end
  tyrant_pid
end

