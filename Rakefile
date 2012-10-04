#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'yard'


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
