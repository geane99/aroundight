require 'test/unit'
require File.expand_path('../../core/extension_test_double', __FILE__)
require File.expand_path('../../../../lib/aroundight/battlefield/public_server_repository', __FILE__)

class TestPublicServerRepository < Test::Unit::TestCase
  def self.startup
    Aroundight::PublicServerRepository.send :prepend, ExtensionTestDouble
  end
  
  def setup
    @repo = Aroundight::PublicServerRepository.new
  end
  
  def teardown
  end
  
  def test_save_and_load_bookmaker_schedule
    @now = DateTime.now
    @start_t = DateTime.new 2016, 12, 22, 19, 0, 0, @now.offset
    @end_t = DateTime.new 2016, 12, 29, 23, 59, 59, @now.offset
    
    schedule = Aroundight::BookmakerSchedule.new @start_t, @end_t, 2, 1
    schedule.id = 1
    scored = DateTime.new 2016, 12, 26, 9, 15, 0, @now.offset
    schedule.add_score! scored, { "east" => "100", "west" => "200", "south" => "300", "north" => "400" }

    @repo.save_bookmaker_schedule schedule
    loadschedule = @repo.load_bookmaker_schedule schedule.id
    
    assert_equal loadschedule.id, schedule.id
    assert_equal loadschedule.term_start_date, schedule.term_start_date
    assert_equal loadschedule.term_end_date, schedule.term_end_date
    assert_equal loadschedule.instance_variable_get(:@round2)["score"][0]["east"], schedule.instance_variable_get(:@round2)["score"][0]["east"]
  end
  
  def test_save_and_load_ranking_schedule
    @now = DateTime.now
    @start_t = DateTime.new 2016, 12, 22, 19, 0, 0, @now.offset
    @end_t = DateTime.new 2016, 12, 29, 23, 59, 59, @now.offset
    
    schedule = Aroundight::RankingSchedule.new @start_t, @end_t, 2, 1
    schedule.id = 1
    scored = DateTime.new 2016, 12, 26, 18, 0, 0, @now.offset
    schedule.add_score! scored, { "ranking1000" => "100", "ranking3000" => "200", "time" => "2016-12-26 18:00:00" }
      
    @repo.save_ranking_schedule schedule
    loadschedule = @repo.load_ranking_schedule schedule.id
    
    assert_equal loadschedule.id, schedule.id
    assert_equal loadschedule.term_start_date, schedule.term_start_date
    assert_equal loadschedule.term_end_date, schedule.term_end_date
    assert_equal loadschedule.instance_variable_get(:@score)[0]["ranking1000"], schedule.instance_variable_get(:@score)[0]["ranking1000"]
  end
  
  def test_save_and_load_qualifying_schedule
    @now = DateTime.now
    @start_t = DateTime.new 2016, 12, 22, 19, 0, 0, @now.offset
    @end_t = DateTime.new 2016, 12, 29, 23, 59, 59, @now.offset
    
    schedule = Aroundight::QualifyingSchedule.new @start_t, @end_t, 2, 1
    schedule.id = 1
    scored = DateTime.new 2016, 12, 23, 18, 0, 0, @now.offset
    schedule.add_score! scored, { "qualifying120" => "100", "qualifying2400" => "200", "qualifying3000" => "300", "seed120" => "3000", "seed660" => "4000", "time" => "2016-12-23 18:00:00" }
      
    @repo.save_qualifying_schedule schedule
    loadschedule = @repo.load_qualifying_schedule schedule.id
    
    assert_equal loadschedule.id, schedule.id
    assert_equal loadschedule.term_start_date, schedule.term_start_date
    assert_equal loadschedule.term_end_date, schedule.term_end_date
    assert_equal loadschedule.instance_variable_get(:@score)[0]["qualifying120"], schedule.instance_variable_get(:@score)[0]["qualifying120"]
  end
end