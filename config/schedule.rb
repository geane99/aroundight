set :output, 'log/crontab.log'
set :environment, :prod
set :raidid, '26'
  
every '*/15 * * * *' do
  rake 'highscore[26]'
end

every '*/20 * * * *' do
  rake 'bookmaker[26]'
end