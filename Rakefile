require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'rake/testtask'
require File.expand_path('../lib/aroundight',__FILE__)

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc 'run test-unit based test!'
Rake::TestTask.new do |task|
  task.libs << "test"
  task.test_files = Dir["test/**/test_*.rb"]
  task.verbose = true
end

# rake define['26', '2016-12-18', '2016-12-25', '2', '1']
task :define, ['raidid', 'start_date', 'end_date', 'qualifying', 'interval'] do |task, args|
  Aroundight::define_battlefield *args
end

task :bookmaker, ['raidid'] do |task, args|
  Aroundight::bookmaker *args
end

task :highscore, ['raidid'] do |task, args|
  Aroundight::highscore *args
end

task :ranking, ['raidid'] do |task, args|
  Aroundight::ranking *args
end

task :qualifying, ['raidid'] do |task, args|
  Aroundight::qualifying *args
end


# crontab
=begin
3 */1 * * * cd /data/batch/aroundight; rake ranking[26]
2,22,42 * 18-20 * * cd /data/batch/aroundight; rake qualifying[26]
1,16,31,46 * 21-26 * * cd /data/batch/aroundight; rake bookmaker[26]
=end