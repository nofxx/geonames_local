#!/usr/bin/env ruby
#
#  DB => br, cl ~ 6k objects
#
require 'benchmark'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'geonames_local'

# @db.flush

def b1(db)
  puts "#{db.count} Objects"
  Benchmark.bmbm do |b|
    b.report("All Country") { db.all({ :kind => "country" })}
    b.report("Find by GID") { db.find(888) }
    b.report("Find by name") { db.all({ :name => "Maxaranguape"}) }
    b.report("Find on country") { db.all({ :country => "CL"}) }
  end
end

print "Tyrant => "
b1(Geonames::Tokyo.new(:tyrant))


print "Cabinet => "
b1(Geonames::Tokyo.new)

