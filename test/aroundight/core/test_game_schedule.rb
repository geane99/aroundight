require 'test/unit'
require 'date'
require File.expand_path('../../../../lib/aroundight/core/game_schedule', __FILE__)

class TestGameSchedule < Test::Unit::TestCase
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
    # 9  : 2016-12-30 : finals (6)
    # 10 : 2016-12-31 : finals (7)
    # 11 : 2017-01-01 : finals (8)

    @now = DateTime.now
    @start_t = DateTime.new 2016, 12, 22, 19, 0, 0, @now.offset
    @end_t = DateTime.new 2017, 1, 1, 23, 59, 59, @now.offset
    
    @schedule = Aroundight::GameSchedule.new
    @schedule.term! @start_t, @end_t
    @schedule.define_qualifying! 1, 2
    
    @no_qualifying_schedule = Aroundight::GameSchedule.new
    @no_qualifying_schedule.term! @start_t, @end_t
  end
  
  def teardown
  end
  
  def test_to_hash
    hash = @schedule.to_hash
    assert_equal "2016-12-22 19:00:00", hash["qualifying_start_date"]
    assert_equal "2016-12-23 23:59:59", hash["qualifying_end_date"]
    assert_equal "2016-12-24 00:00:00", hash["interval_start_date"]
    assert_equal "2016-12-24 23:59:59", hash["interval_end_date"]
    assert_equal "2016-12-25 00:00:00", hash["finals_start_date"]
    assert_equal "2017-01-01 23:59:59", hash["finals_end_date"]
    
    assert_equal 2, hash["qualifying_length"]
    assert_equal 1, hash["interval_length"]
    assert_equal 8, hash["finals_length"]
  end
  
  def test_define
    #test setup
  end
  
  def test_merge!
    @schedule = Aroundight::GameSchedule.new
    @schedule.merge!({
      "start_date" => "2016-12-22 19:00:00",
      "end_date" => "2017-01-01 23:59:59",
      "interval_length" => "1",
      "qualifying_length" => "2"
    })
    assert_equal @schedule.qualifying_start_date, DateTime.new(2016, 12, 22, 19, 0, 0, @now.offset)
    assert_equal @schedule.qualifying_end_date, DateTime.new(2016, 12, 23, 23, 59, 59, @now.offset)
    assert_equal @schedule.interval_start_date, DateTime.new(2016, 12, 24, 0, 0, 0, @now.offset)
    assert_equal @schedule.interval_end_date, DateTime.new(2016, 12, 24, 23, 59, 59, @now.offset)
    assert_equal @schedule.finals_start_date, DateTime.new(2016, 12, 25, 0, 0, 0, @now.offset)
    assert_equal @schedule.finals_end_date, DateTime.new(2017, 1, 1, 23, 59, 59, @now.offset)
    assert_equal @schedule.qualifying_length, 2
    assert_equal @schedule.interval_length, 1
    assert_equal @schedule.finals_length, 8
  end
  
  def test_clear!
    @no_qualifying_schedule.define_qualifying! 1, 2
    assert_equal @no_qualifying_schedule.qualifying_start_date, DateTime.new(2016, 12, 22, 19, 0, 0, @now.offset)
    assert_true @no_qualifying_schedule.concentrate?

    @no_qualifying_schedule.clear!
    
    assert_false @no_qualifying_schedule.concentrate?
    assert_equal @no_qualifying_schedule.qualifying_start_date, nil
    assert_equal @no_qualifying_schedule.qualifying_end_date, nil
    assert_equal @no_qualifying_schedule.interval_start_date, nil
    assert_equal @no_qualifying_schedule.interval_end_date, nil
    assert_equal @no_qualifying_schedule.finals_start_date, nil
    assert_equal @no_qualifying_schedule.finals_end_date, nil

    assert_equal @no_qualifying_schedule.qualifying_length, nil
    assert_equal @no_qualifying_schedule.interval_length, nil
    assert_equal @no_qualifying_schedule.finals_length, nil

    offset = DateTime.now.offset
    current = DateTime.new 2016, 12, 22, 19, 0, 0, offset
    assert_false @no_qualifying_schedule.cover_qualifying?(current)
    current = DateTime.new 2016, 12, 23, 23, 59, 59, offset
    assert_false @no_qualifying_schedule.cover_qualifying?(current)    
    current = DateTime.new 2016, 12, 22, 18, 59, 59, offset
    assert_false @no_qualifying_schedule.cover_qualifying?(current)    
    current = DateTime.new 2016, 12, 24, 0, 0, 0, offset
    assert_false @no_qualifying_schedule.cover_qualifying?(current)
    current = DateTime.new 2016, 12, 24, 0, 0, 0, offset
    assert_true @schedule.cover_interval?(current)
    assert_false @no_qualifying_schedule.cover_interval?(current)
    current = DateTime.new 2016, 12, 24, 23, 59, 59, offset
    assert_false @no_qualifying_schedule.cover_interval?(current)
    current = DateTime.new 2016, 12, 23, 23, 59, 59, offset
    assert_false @no_qualifying_schedule.cover_interval?(current)
    current = DateTime.new 2016, 12, 25, 0, 0, 0, offset
    assert_false @no_qualifying_schedule.cover_interval?(current)
    current = DateTime.new 2016, 12, 25, 0, 0, 0, offset
    assert_true @schedule.cover_finals?(current)
    assert_false @no_qualifying_schedule.cover_finals?(current)
    current = DateTime.new 2017, 1, 1, 23, 59, 59, offset
    assert_false @no_qualifying_schedule.cover_finals?(current)
    current = DateTime.new 2016, 12, 24, 23, 59, 59, offset
    assert_false @no_qualifying_schedule.cover_finals?(current)
    current = DateTime.new 2017, 1, 2, 0, 0, 0, offset
    assert_false @no_qualifying_schedule.cover_finals?(current)
  end
  
  def test_qualifying_start_date
    assert_equal @schedule.qualifying_start_date, DateTime.new(2016, 12, 22, 19, 0, 0, @now.offset)
    assert_equal @no_qualifying_schedule.qualifying_start_date, nil
  end
  
  def test_qualifying_end_date
    assert_equal @schedule.qualifying_end_date, DateTime.new(2016, 12, 23, 23, 59, 59, @now.offset)
    assert_equal @no_qualifying_schedule.qualifying_end_date, nil
  end
  
  def test_interval_start_date
    assert_equal @schedule.interval_start_date, DateTime.new(2016, 12, 24, 0, 0, 0, @now.offset)
    assert_equal @no_qualifying_schedule.interval_start_date, nil
  end
  
  def test_interval_end_date
    assert_equal @schedule.interval_end_date, DateTime.new(2016, 12, 24, 23, 59, 59, @now.offset)
    assert_equal @no_qualifying_schedule.interval_end_date, nil
  end
  
  def test_finals_start_date
    assert_equal @schedule.finals_start_date, DateTime.new(2016, 12, 25, 0, 0, 0, @now.offset)
    assert_equal @no_qualifying_schedule.finals_start_date, nil
  end
  
  def test_finals_end_date
    assert_equal @schedule.finals_end_date, DateTime.new(2017, 1, 1, 23, 59, 59, @now.offset)
    assert_equal @no_qualifying_schedule.finals_end_date, nil
  end

  
  def test_qualifying_length
    assert_equal @schedule.qualifying_length, 2
    assert_equal @no_qualifying_schedule.qualifying_length, nil
  end
  
  def test_interval_length
    assert_equal @schedule.interval_length, 1
    assert_equal @no_qualifying_schedule.interval_length, nil
  end
 
  def test_finals_length
    assert_equal @schedule.finals_length, 8
    assert_equal @no_qualifying_schedule.finals_length, nil
  end
  
  def test_cover_qualifying?
    offset = DateTime.now.offset
    
    current = DateTime.new 2016, 12, 22, 19, 0, 0, offset
    assert_true @schedule.cover_qualifying?(current)
    assert_false @no_qualifying_schedule.cover_qualifying?(current)

    current = DateTime.new 2016, 12, 23, 23, 59, 59, offset
    assert_true @schedule.cover_qualifying?(current)
    assert_false @no_qualifying_schedule.cover_qualifying?(current)
    
    current = DateTime.new 2016, 12, 22, 18, 59, 59, offset
    assert_false @schedule.cover_qualifying?(current)
    assert_false @no_qualifying_schedule.cover_qualifying?(current)
    
    current = DateTime.new 2016, 12, 24, 0, 0, 0, offset
    assert_false @schedule.cover_qualifying?(current)
    assert_false @no_qualifying_schedule.cover_qualifying?(current)
  end
  
  def test_cover_interval?
    offset = DateTime.now.offset
    
    current = DateTime.new 2016, 12, 24, 0, 0, 0, offset
    assert_true @schedule.cover_interval?(current)
    assert_false @no_qualifying_schedule.cover_interval?(current)

    current = DateTime.new 2016, 12, 24, 23, 59, 59, offset
    assert_true @schedule.cover_interval?(current)
    assert_false @no_qualifying_schedule.cover_interval?(current)
    
    current = DateTime.new 2016, 12, 23, 23, 59, 59, offset
    assert_false @schedule.cover_interval?(current)
    assert_false @no_qualifying_schedule.cover_interval?(current)
    
    current = DateTime.new 2016, 12, 25, 0, 0, 0, offset
    assert_false @schedule.cover_interval?(current)
    assert_false @no_qualifying_schedule.cover_interval?(current)
  end
  
  def test_cover_finals?
    offset = DateTime.now.offset
    
    current = DateTime.new 2016, 12, 25, 0, 0, 0, offset
    assert_true @schedule.cover_finals?(current)
    assert_false @no_qualifying_schedule.cover_finals?(current)

    current = DateTime.new 2017, 1, 1, 23, 59, 59, offset
    assert_true @schedule.cover_finals?(current)
    assert_false @no_qualifying_schedule.cover_finals?(current)
    
    current = DateTime.new 2016, 12, 24, 23, 59, 59, offset
    assert_false @schedule.cover_finals?(current)
    assert_false @no_qualifying_schedule.cover_finals?(current)
    
    current = DateTime.new 2017, 1, 2, 0, 0, 0, offset
    assert_false @schedule.cover_finals?(current)
    assert_false @no_qualifying_schedule.cover_finals?(current)
  end

  def test_concentrate?
    assert_true @schedule.concentrate?
    assert_false @no_qualifying_schedule.concentrate?
  end
end