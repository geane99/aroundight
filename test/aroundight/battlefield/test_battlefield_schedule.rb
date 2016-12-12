require 'test/unit'
require 'date'
require File.expand_path('../../../../lib/aroundight/battlefield/battlefield_schedule', __FILE__)

class TestBattlefieldSchedule < Test::Unit::TestCase
  def self.startup
  end
  
  def self.shutdown
  end
  
  def setup
  end
  
  def teardown
  end
  
  def test_to_start_datetime
    now = DateTime.now
    schedule = Aroundight::BattlefieldSchedule.new
    schedule_date = schedule.to_start_datetime now
    
    assert_equal now.year, schedule_date.year
    assert_equal now.month, schedule_date.month
    assert_equal now.day, schedule_date.day
    assert_equal 19, schedule_date.hour
    assert_equal 0, schedule_date.min
    assert_equal 0, schedule_date.sec
  end
  
  def test_to_end_datetime
    now = DateTime.now
    schedule = Aroundight::BattlefieldSchedule.new
    schedule_date = schedule.to_end_datetime now, 5
    
    now += 5
    assert_equal now.year, schedule_date.year
    assert_equal 0, schedule_date.hour
    assert_equal 14, schedule_date.min
    assert_equal 59, schedule_date.sec
    
    assert_equal now.month, schedule_date.month
    assert_equal now.day, schedule_date.day
  end
  
  def test_duplicate?
    score = [
      {"time" => "2016-12-15 18:00:00"},
      {"time" => "2016-12-15 18:15:00"},
      {"time" => "2016-12-15 18:30:00"},
      {"time" => "2016-12-15 18:45:00"},
      {"time" => "2016-12-15 19:00:00"},
      {"time" => "2016-12-15 19:15:00"}
    ]
    schedule = Aroundight::BattlefieldSchedule.new
    
    current = DateTime.new 2016,12,14,18,0,0,DateTime.now.offset
    assert_false schedule.duplicate?(score, current)
  end
end