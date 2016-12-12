require 'test/unit'
require 'date'
require File.expand_path('../../../../lib/aroundight/core/schedule', __FILE__)

class Testschedule < Test::Unit::TestCase
  def self.startup
  end
  
  def self.shutdown
  end
  
  def setup
  end
  
  def teardown
  end
  
  def test_to_hash
    offset = DateTime.now.offset
    sdate = DateTime.new 2016, 12, 1, 17, 25, 30, offset
    edate = DateTime.new 2016, 12, 5, 23, 59, 59, offset
    schedule = Aroundight::Schedule.new
    schedule.term! sdate, edate
    schedule.id = 1
    hash = schedule.to_hash
    
    assert_equal hash['start_date'], "2016-12-01 17:25:30"
    assert_equal hash['end_date'], "2016-12-05 23:59:59"
    assert_equal hash['id'], 1
  end
  
  def test_merge!
    offset = DateTime.now.offset
    sdate = DateTime.new 2016, 12, 1, 17, 25, 30, offset
    edate = DateTime.new 2016, 12, 5, 23, 59, 59, offset
    schedule = Aroundight::Schedule.new
    hash = {
      "start_date" => "2016-12-01 17:25:30",
      "end_date" => "2016-12-05 23:59:59",
      "id" => 1
    }
    schedule.merge! hash
    
    assert_equal schedule.term_start_date, sdate
    assert_equal schedule.term_end_date, edate
    assert_equal schedule.id(), 1
  end
  
  def test_clear!
    now = DateTime.now
    after1month = now >> 1
    
    schedule = Aroundight::Schedule.new
    start_t = DateTime.new now.year, now.month, now.day, 0, 0, 0, now.offset
    end_t = DateTime.new after1month.year, after1month.month, after1month.day, 23, 59, 59, after1month.offset
    schedule.term! start_t, end_t
    
    #test contains
    current = DateTime.new now.year, now.month, now.day, 15, 0, 0, now.offset
    assert_true schedule.cover?(current)
    
    schedule.clear!
    assert_false schedule.cover?(current)
  end
  
  def test_term_start_date
    now = DateTime.now
    after1month = now >> 1
    
    schedule = Aroundight::Schedule.new
    start_t = DateTime.new now.year, now.month, now.day, 0, 0, 0, now.offset
    end_t = DateTime.new after1month.year, after1month.month, after1month.day, 23, 59, 59, after1month.offset
    schedule.term! start_t, end_t
    
    assert_equal start_t, schedule.term_start_date
  end
  
  def test_term_end_date
    now = DateTime.now
    after1month = now >> 1
    
    schedule = Aroundight::Schedule.new
    start_t = DateTime.new now.year, now.month, now.day, 0, 0, 0, now.offset
    end_t = DateTime.new after1month.year, after1month.month, after1month.day, 23, 59, 59, after1month.offset
    schedule.term! start_t, end_t

    assert_equal end_t, schedule.term_end_date
  end
  
  def test_length
    now = DateTime.now
    
    schedule = Aroundight::Schedule.new
    start_t = DateTime.new 2016, 11, 28, 0, 0, 0, now.offset
    end_t = DateTime.new 2016, 11, 28, 23, 59, 59, now.offset
    schedule.term! start_t, end_t
    
    assert_equal schedule.length, 1
    assert_equal schedule.size, 1
    
    start_t = DateTime.new 2016, 11, 28, 0, 0, 0, now.offset
    end_t = DateTime.new 2016, 12, 3, 23, 59, 59, now.offset
    schedule.term! start_t, end_t
    
    assert_equal schedule.length, 6
    assert_equal schedule.size, 6
  end
  
  def test_simple_cover?
    now = DateTime.now
    after1month = now >> 1
    
    schedule = Aroundight::Schedule.new
    start_t = DateTime.new now.year, now.month, now.day, 0, 0, 0, now.offset
    end_t = DateTime.new after1month.year, after1month.month, after1month.day, 23, 59, 59, after1month.offset
    schedule.term! start_t, end_t
    
    #test contains
    current = DateTime.new now.year, now.month, now.day, 15, 0, 0, now.offset
    assert_true schedule.cover?(current)
    
    current = DateTime.new now.year, now.month, now.day, 0, 0, 0, now.offset
    assert_true schedule.cover?(current)
    
    current = DateTime.new after1month.year, after1month.month, after1month.day, 23, 59, 59, now.offset
    assert_true schedule.cover?(current)
    
    current = after1month + 1
    assert_false schedule.cover?(current)
    
    current = now - 1
    assert_false schedule.cover?(current)
  end
  
  def test_complex_cover?
    now = DateTime.now
    start_t = DateTime.new now.year, now.month, now.day, 0, 0, 0, now.offset
    after1month = now >> 1
    after1month = DateTime.new after1month.year, after1month.month, after1month.day, 23, 59, 59, now.offset
    schedule = Aroundight::Schedule.new
    schedule.term! start_t, after1month
    
    #ng range(date)
    #between (now + 1) to (now + 3) 
    ng_start = start_t + 1
    ng_end = start_t + 3
    schedule.out_of_term ng_start, ng_end
    
    #ng range(time)
    #between 03:00 to 05:00
    #between 12:00 to 14:00
    schedule.out_of_term "03:00", "05:00"
    schedule.out_of_term "12:01:15", "14:39:21"
    
    #test contains
    current = start_t
    assert_true schedule.cover?(current)
    
    current = after1month
    assert_true schedule.cover?(current)
    
    current = after1month + 1
    assert_false schedule.cover?(current)
    
    #check ng range(time)
    #no second
    current = DateTime.new start_t.year, start_t.month, start_t.day, 3, 0, 0, now.offset
    assert_false schedule.cover?(current)
    
    current = DateTime.new start_t.year, start_t.month, start_t.day, 5, 0, 0, now.offset
    assert_false schedule.cover?(current)
    
    current = DateTime.new start_t.year, start_t.month, start_t.day, 3, 1, 0, now.offset
    assert_false schedule.cover?(current)
    
    current = DateTime.new start_t.year, start_t.month, start_t.day, 2, 59, 59, now.offset
    assert_true schedule.cover?(current)
    
    current = DateTime.new start_t.year, start_t.month, start_t.day, 5, 1, 0, now.offset
    assert_true schedule.cover?(current)
    
    #contain second
    current = DateTime.new start_t.year, start_t.month, start_t.day, 12, 1, 14, now.offset
    assert_true schedule.cover?(current)

    current = DateTime.new start_t.year, start_t.month, start_t.day, 12, 1, 15, now.offset
    assert_false schedule.cover?(current)

    current = DateTime.new start_t.year, start_t.month, start_t.day, 13, 1, 15, now.offset
    assert_false schedule.cover?(current)

    current = DateTime.new start_t.year, start_t.month, start_t.day, 14, 39, 21, now.offset
    assert_false schedule.cover?(current)
    
    current = DateTime.new start_t.year, start_t.month, start_t.day, 14, 39, 22, now.offset
    assert_true schedule.cover?(current)
    
    #check ng range(date)
    current = DateTime.new ng_start.year, ng_start.month, ng_start.day, ng_start.hour, ng_start.min, ng_start.sec, ng_start.offset
    assert_false schedule.cover?(current)
    
    current -= Rational(1, 24 * 60 * 60)
    assert_true schedule.cover?(current)
    
    current = DateTime.new ng_end.year, ng_end.month, ng_end.day, ng_end.hour, ng_end.min, ng_end.sec, ng_end.offset
    assert_false schedule.cover?(current)
    
    current += Rational(1, 24 * 60 * 60)
    assert_true schedule.cover?(current)
  end
end