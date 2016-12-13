set :output, 'log/crontab.log'
set :environment, :prod
set :raidid, '26'
env :PATH, ENV['PATH']
job_type :rbenv_rake, %q!eval "$(rbenv init -)"; cd :path && :environment_variable=:environment bundle exec rake :task --silent :output!
  
every '*/15 * * * *' do
  rake 'highscore[26]'
end

every '*/20 * * * *' do
  rake 'bookmaker[26]'
end