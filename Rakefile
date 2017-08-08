task :default => :test

desc "Run the tests"
task :test => :spec

desc "Run the server"
task :run do
  Kernel.exec('bundle exec rackup -p9292 --host 0.0.0.0')
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new
