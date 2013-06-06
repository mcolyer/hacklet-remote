task :default => :test

desc "Run the tests"
task :test => :spec

desc "Run the server"
task :run do
  Kernel.exec('rackup')
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new
