set :output, 'log/crontab.log'
set :environment, :prod
set :raidid, '26'
  
every '*/15 * * * *' do
  rake 'highscore[#{:raidid}]'
end

every '*/20 * * * *' do
  rake 'bookmaker[#{:raidid}]'
end