# A sample Guardfile
# More info at https://github.com/guard/guard#readme
# ignore(/\/.#.+/)

guard :rubocop, all_on_start: false, keep_failed: false, notification: false do
  watch(/^lib\/(.+)\.rb$/)
  watch(/^spec\/(.+)\.rb$/)
end

guard :rspec, cmd: 'bundle exec rspec' do
  watch(/^spec\/.+_spec\.rb$/)
  watch(/^spec\/spec_helper\.rb$/) { 'spec' }
  watch(/^lib\/(.+)\.rb$/)         { |m| "spec/lib/#{m[1]}_spec.rb" }
end
