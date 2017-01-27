require 'date'
require File.expand_path('../granblue_server_repository', __FILE__)
require File.expand_path('../public_server_repository', __FILE__)
require File.expand_path('../bookmaker_schedule', __FILE__)
require File.expand_path('../ranking_schedule', __FILE__)
require File.expand_path('../qualifying_schedule', __FILE__)

module Aroundight
  class BattlefieldService
    class << self
      @@correct_date = -> (correct, timebase) {
        DateTime.new timebase.year, timebase.month, timebase.day, timebase.hour, (timebase.min - timebase.min % correct), 0, timebase.offset
      }
      @@correct_date_now_15 = @@correct_date.curry.call(15)
      @@correct_date_now_20 = @@correct_date.curry.call(20)
      @@correct_date_now_60 = @@correct_date.curry.call(60)
      def correct_date timebase, correct
        @@correct_date.(timebase, correct)
      end
      
      def correct_15_date_now
        @@correct_date_now_15.(DateTime.now)
      end
      
      def correct_20_date_now
        @@correct_date_now_20.(DateTime.now)
      end
      
      def correct_60_date_now
        @@correct_date_now_60.(DateTime.now)
      end
    end
    
    def initialize
      @game_server = GranblueServerRepository.new
      @publish_server = PublicServerRepository.new
    end
    
    def define_battlefield raidid, start_date, end_date, qualifying, interval
      bookmaker = BookmakerSchedule.new start_date, end_date, qualifying, interval
      bookmaker.id = raidid
      @publish_server.save_bookmaker_schedule bookmaker
      
      ranking = RankingSchedule.new start_date, end_date, qualifying, interval
      ranking.id = raidid
      @publish_server.save_ranking_schedule ranking
      
      qualifying = QualifyingSchedule.new start_date, end_date, qualifying, interval
      qualifying.id = raidid
      @publish_server.save_qualifying_schedule qualifying
    end
    
    def update_ranking_score raidid, datetime
      _update({
        "load" => lambda{|server, id| server.load_ranking_schedule id },
        "get" => lambda{|server,id,time| server.get_ranking_score id, time },
        "save" => lambda{|server,domain| server.save_ranking_schedule domain },
        "raidid" => raidid,
        "time" => datetime
      })
    end
    
    def update_qualifying_score raidid, datetime
      _update({
        "load" => lambda{|server, id| server.load_qualifying_schedule id },
        "get" => lambda{|server,id,time| server.get_qualifying_score id, time },
        "save" => lambda{|server,domain| server.save_qualifying_schedule domain },
        "raidid" => raidid,
        "time" => datetime
      })
    end
    
    def update_bookmaker_score raidid,datetime
      _update({
        "load" => lambda{|server, id| server.load_bookmaker_schedule id },
        "get" => lambda{|server,id,time| server.get_bookmaker_score id, time },
        "save" => lambda{|server,domain| server.save_bookmaker_schedule domain },
        "raidid" => raidid,
        "time" => datetime
      })
    end
    
    def get_ranking_all raidid
      r = @game_server.get_ranking_all(raidid)
      def r.to_hash 
        self 
      end
      @publish_server.save_ranking_all raidid, r
    end
    
    def update_connect
      @game_server.update_connect
    end
    
    private
    def _update conf
      domain = conf["load"].(@publish_server,conf["raidid"])
      return unless domain.cover? conf["time"]
      score = conf["get"].(@game_server, conf["raidid"], conf["time"])
      @game_server.logger.info score
      domain.add_score! conf["time"], score
      conf["save"].(@publish_server, domain)
    end
  end
end