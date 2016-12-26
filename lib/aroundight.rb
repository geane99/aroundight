require 'date'
require File.expand_path('../aroundight/battlefield/battlefield_service', __FILE__)
require File.expand_path("../aroundight/version",__FILE__)

module Aroundight
  def self.bookmaker raidid
    service = self.create_service
    service.update_bookmaker_score raidid, self.correct_20_date_now
  end
  
  def self.highscore raidid
    date = self.correct_20_date_now
    service = self.create_service
    service.update_ranking_score raidid, date
    service.update_qualifying_score raidid, date
  end

  def self.ranking raidid
    date = self.correct_60_date_now
    service = self.create_service
    service.update_ranking_score raidid, date
  end
  
  def self.qualifying raidid
    date = self.correct_20_date_now
    service = self.create_service
    service.update_qualifying_score raidid, date
  end
  
  def self.ranking_all raidid
    service = self.create_service
    service.get_ranking_all raidid
  end
  
  def self.define_battlefield raidid, start_date, end_date, qualifying, interval
    service = self.create_service
    date_s = Date.parse start_date
    date_e = Date.parse end_date
    qualifying_i = qualifying.to_i
    interval_i = interval.to_i
    datetime_s = DateTime.new date_s.year, date_s.month, date_s.day, 0, 0, 0, DateTime.now.offset
    datetime_e = DateTime.new date_e.year, date_e.month, date_e.day, 0, 0, 0, DateTime.now.offset
    service.define_battlefield raidid, datetime_s, datetime_e, qualifying_i, interval_i
  end
  
  def self.version
    puts Synthe::Aroundight::VERSION
  end
  
  def self.create_service
    Aroundight::BattlefieldService.new
  end
  
  private
  def self.correct_15_date_now
    Aroundight::BattlefieldService.correct_15_date_now
  end
  
  def self.correct_20_date_now
    Aroundight::BattlefieldService.correct_20_date_now
  end

  def self.correct_60_date_now
    Aroundight::BattlefieldService.correct_60_date_now
  end
end