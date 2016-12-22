require 'test/unit'
require 'date'
require File.expand_path('../../../../lib/aroundight/battlefield/ranking_schedule', __FILE__)

class TestRankingSchedule < Test::Unit::TestCase
  def self.startup
  end
  
  def self.shutdown
  end
  
  def setup
    # term       : 2016-12-22 19:00:00 - 2016-12-29 23:59:59
    # qualifying : 2016-12-22 19:00:00 - 2016-12-23 23:59:59
    # interval   : 2016-12-24 00:00:00 - 2016-12-24 23:59:59
    # finals     : 2016-12-25 00:00:00 - 2017-01-01 23:59:59
    
    # days
    # 1  : 2016-12-22 : qualifying (1)
    # 2  : 2016-12-23 : qualifying (2)
    # 3  : 2016-12-24 : interval (1)
    # 4  : 2016-12-25 : finals (1)
    # 5  : 2016-12-26 : finals (2)
    # 6  : 2016-12-27 : finals (3)
    # 7  : 2016-12-28 : finals (4)
    # 8  : 2016-12-29 : finals (5)

    @now = DateTime.now
    @start_t = DateTime.new 2016, 12, 22, 19, 0, 0, @now.offset
    @end_t = DateTime.new 2016, 12, 29, 23, 59, 59, @now.offset
    
    @schedule = Aroundight::RankingSchedule.new @start_t, @end_t, 2, 1
    scored = DateTime.new 2016, 12, 26, 18, 0, 0, @now.offset
    @schedule.add_score! scored, { "ranking1000" => "100", "ranking3000" => "200", "time" => "2016-12-26 18:00:00" }
  end
  
  def teardown
  end
  
  def test_initialize
    assert_equal @schedule.qualifying_start_date, DateTime.new(2016, 12, 22, 19, 0, 0, @now.offset)
    assert_equal @schedule.qualifying_end_date, DateTime.new(2016, 12, 23, 23, 59, 59, @now.offset)
    assert_equal @schedule.interval_start_date, DateTime.new(2016, 12, 24, 0, 0, 0, @now.offset)
    assert_equal @schedule.interval_end_date, DateTime.new(2016, 12, 24, 23, 59, 59, @now.offset)
    assert_equal @schedule.finals_start_date, DateTime.new(2016, 12, 25, 0, 0, 0, @now.offset)
    assert_equal @schedule.finals_end_date, DateTime.new(2016, 12, 30, 0, 14, 59, @now.offset)
    assert_equal @schedule.qualifying_length, 2
    assert_equal @schedule.interval_length, 1
    assert_equal @schedule.finals_length, 5
  end
  
  def test_to_hash
    hash = @schedule.to_hash
    assert_equal hash["score"][0]["ranking1000"], "100"
  end
  
  def test_merge!
    @schedule.clear!
    @schedule.merge!({
      "start_date" => "2016-12-22 19:00:00",
      "end_date" => "2016-12-30 00:14:59",
      "interval_length" => "1",
      "qualifying_length" => "2",
      "score" => [
        { "ranking1000" => "1000", "ranking3000" => "2000", "time" => "2016-12-27 10:00:00" },
        { "ranking1000" => "1500", "ranking3000" => "2600", "time" => "2016-12-27 10:05:00" }
      ]
    })
    assert_equal @schedule.qualifying_start_date, DateTime.new(2016, 12, 22, 19, 0, 0, @now.offset)
    assert_equal @schedule.qualifying_end_date, DateTime.new(2016, 12, 23, 23, 59, 59, @now.offset)
    assert_equal @schedule.interval_start_date, DateTime.new(2016, 12, 24, 0, 0, 0, @now.offset)
    assert_equal @schedule.interval_end_date, DateTime.new(2016, 12, 24, 23, 59, 59, @now.offset)
    assert_equal @schedule.finals_start_date, DateTime.new(2016, 12, 25, 0, 0, 0, @now.offset)
    assert_equal @schedule.finals_end_date, DateTime.new(2016, 12, 30, 0, 14, 59, @now.offset)
    assert_equal @schedule.qualifying_length, 2
    assert_equal @schedule.interval_length, 1
    assert_equal @schedule.finals_length, 5
    assert_equal @schedule.instance_variable_get(:@score)[0]["ranking1000"], "1000"
  end
  
  def test_cover?
    current = DateTime.new 2016, 12, 22, 18, 59, 59, @now.offset
    assert_false @schedule.cover?(current)

    current = DateTime.new 2016, 12, 22, 19, 0, 0, @now.offset
    assert_true @schedule.cover?(current)
    
    current = DateTime.new 2016, 12, 23, 23, 59, 59, @now.offset
    assert_true @schedule.cover?(current)

    current = DateTime.new 2016, 12, 24, 23, 59, 59, @now.offset
    assert_true @schedule.cover?(current)
    
    current = DateTime.new 2016, 12, 25, 6, 59, 59, @now.offset
    assert_false @schedule.cover?(current)
    
    current = DateTime.new 2016, 12, 25, 7, 0, 0, @now.offset
    assert_true @schedule.cover?(current)

    current = DateTime.new 2016, 12, 26, 0, 14, 59, @now.offset
    assert_true @schedule.cover?(current)

    current = DateTime.new 2016, 12, 26, 0, 15, 0, @now.offset
    assert_false @schedule.cover?(current)
    
    current = DateTime.new 2016, 12, 26, 6, 59, 59, @now.offset
    assert_false @schedule.cover?(current)

    current = DateTime.new 2016, 12, 26, 7, 0, 0, @now.offset
    assert_true @schedule.cover?(current)

    current = DateTime.new 2016, 12, 29, 23, 59, 59, @now.offset
    assert_true @schedule.cover?(current)

    current = DateTime.new 2016, 12, 30, 0, 14, 59, @now.offset
    assert_true @schedule.cover?(current)

    current = DateTime.new 2016, 12, 30, 0, 15, 0, @now.offset
    assert_false @schedule.cover?(current)
  end
  
  def test_add_score!
    scored = DateTime.new 2016, 12, 26, 18, 15, 0, @now.offset
    @schedule.add_score! scored, { "ranking1000" => "10000", "ranking3000" => "20000", "time" => "2016-12-26 18:15:00" }
    assert_equal @schedule.instance_variable_get(:@score)[1]["ranking1000"], "10000"
      
    scored = DateTime.new 2016, 12, 26, 18, 30, 0, @now.offset
    @schedule.add_score! scored, { "ranking1000" => "10000", "ranking3000" => "20000", "time" => "2016-12-26 18:30:00" }
    assert_equal 2, @schedule.instance_variable_get(:@score).length
  end
end