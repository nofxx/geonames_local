# A sample Guardfile
# More info at https://github.com/guard/guard#readme
require 'guard'

guard 'rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { 'spec' } # { |m| "spec spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { 'spec' }
end
