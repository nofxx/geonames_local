#!/usr/bin/env ruby
#
#  DB => br, cl ~ 6k objects
#
require 'benchmark'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'geonames_local'

# @db.flush

