#!/usr/bin/env ruby
require 'benchmark'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'geonames_local'

@db = Geonames::Tokyo.new('localhost', 1978)

puts "Starting benchmark. Cabinet objects => #{@db.count}"

Benchmark.bmbm do |b|
  b.report("All Country") { @db.all({ :kind => "country" })}
  b.report("Find by GID") { @db.find(888) }
  b.report("Find by name") { @db.all({ :name => "Maxaranguape"}) }

end
