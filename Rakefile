# encoding: utf-8

require 'yard'
YARD::Rake::YardocTask.new
task :doc => :yard

require 'rake/testtask'
Rake::TestTask.new do |test|
  test.libs << 'spec'
  test.libs << 'lib'

  test.pattern = 'spec/**/*_spec.rb'
  test.verbose = true
  test.warning = false
end

task :default => :test
task :spec => :test
