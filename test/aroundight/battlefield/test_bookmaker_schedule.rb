require 'test/unit'
require 'date'
require File.expand_path('../../../../lib/aroundight/battlefield/bookmaker_schedule', __FILE__)

class TestBookmakerSchedule < Test::Unit::TestCase
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
    
    @schedule = Aroundight::BookmakerSchedule.new @start_t, @end_t, 2, 1
    scored = DateTime.new 2016, 12, 26, 9, 15, 0, @now.offset
    @schedule.add_score! scored, { "east" => "100", "west" => "200", "south" => "300", "north" => "400" }
  end
  
  def teardown
  end
  
  def test_initialize
    assert_equal @schedule.instance_variable_get(:@round1)["datetime"], "2016-12-25"
    assert_equal @schedule.instance_variable_get(:@round2)["datetime"], "2016-12-26"
    assert_equal @schedule.instance_variable_get(:@round3)["datetime"], "2016-12-27"
    assert_equal @schedule.instance_variable_get(:@round4)["datetime"], "2016-12-28"
    assert_equal @schedule.instance_variable_get(:@round5)["datetime"], "2016-12-29"
    assert_equal @schedule.instance_variable_get(:@round2)["score"][0]["east"], "100"
      
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
  
  def test_cover?
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
  
  def test_to_hash
    hash = @schedule.to_hash
    assert_equal hash["round1"]["datetime"], "2016-12-25"
    assert_equal hash["round1"]["date_of_week"], "0" #sunday

    assert_equal hash["round2"]["datetime"], "2016-12-26"
    assert_equal hash["round2"]["date_of_week"], "1" #monday
    assert_equal hash["round2"]["score"][0]["east"], "100" 

    assert_equal hash["round3"]["datetime"], "2016-12-27"
    assert_equal hash["round3"]["date_of_week"], "2" #tuesday
      
    assert_equal hash["round4"]["datetime"], "2016-12-28"
    assert_equal hash["round4"]["date_of_week"], "3" #wednesday
      
    assert_equal hash["round5"]["datetime"], "2016-12-29"
    assert_equal hash["round5"]["date_of_week"], "4" #thursday
  end
  
  def test_merge!
    @schedule.clear!
    @schedule.merge!({
      "start_date" => "2016-12-22 19:00:00",
      "end_date" => "2016-12-30 00:14:59",
      "interval_length" => "1",
      "qualifying_length" => "2",
      "round1" => {
        "datetime" => "2015-12-25",
        "date_of_week" => "0",
        "score" => [
          {"time" => "2015-12-25 07:00:00", "east" => "100", "west" => "150", "south" => "200", "north" => "250"},
          {"time" => "2015-12-25 07:05:00", "east" => "150", "west" => "200", "south" => "250", "north" => "300"}
        ]
      },
      "round2" => {
        "datetime" => "2015-12-26",
        "date_of_week" => "1",
        "score" => [
          {"time" => "2015-12-26 07:00:00", "east" => "300", "west" => "350", "south" => "400", "north" => "450"},
          {"time" => "2015-12-26 07:05:00", "east" => "350", "west" => "400", "south" => "450", "north" => "500"}
        ]
      },
      "round3" => {
        "datetime" => "2016-12-27",
        "date_of_week" => "2",
        "score" => [
          {"time" => "2015-12-27 07:00:00", "east" => "400", "west" => "450", "south" => "500", "north" => "550"},
          {"time" => "2015-12-27 07:05:00", "east" => "450", "west" => "500", "south" => "550", "north" => "600"}
        ]
      },
      "round4" => {
        "datetime" => "2016-12-28",
        "date_of_week" => "3",
        "score" => [
          {"time" => "2015-12-28 07:00:00", "east" => "500", "west" => "550", "south" => "600", "north" => "650"},
          {"time" => "2015-12-28 07:05:00", "east" => "550", "west" => "600", "south" => "650", "north" => "700"}
        ]
      },
      "round5" => {
        "datetime" => "2016-12-29",
        "date_of_week" => "4",
        "score" => [
          {"time" => "2015-12-26 07:00:00", "east" => "600", "west" => "650", "south" => "700", "north" => "750"},
          {"time" => "2015-12-26 07:05:00", "east" => "650", "west" => "700", "south" => "750", "north" => "800"}
        ]
      }
    })
    assert_equal @schedule.instance_variable_get(:@round1)["datetime"], "2016-12-25"
    assert_equal @schedule.instance_variable_get(:@round1)["score"][0]["east"], "100"
    assert_equal @schedule.instance_variable_get(:@round2)["datetime"], "2016-12-26"
    assert_equal @schedule.instance_variable_get(:@round2)["score"][0]["west"], "350"
    assert_equal @schedule.instance_variable_get(:@round3)["datetime"], "2016-12-27"
    assert_equal @schedule.instance_variable_get(:@round3)["score"][1]["south"], "550"
    assert_equal @schedule.instance_variable_get(:@round4)["datetime"], "2016-12-28"
    assert_equal @schedule.instance_variable_get(:@round4)["score"][1]["north"], "700"
    assert_equal @schedule.instance_variable_get(:@round5)["datetime"], "2016-12-29"
    assert_equal @schedule.instance_variable_get(:@round5)["score"][0]["west"], "650"
      
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
  
  def test_add_score!
    scored = DateTime.new 2016, 12, 26, 9, 30, 0, @now.offset
    @schedule.add_score! scored, { "east" => "200", "west" => "300", "south" => "400", "north" => "500" }
    assert_equal @schedule.instance_variable_get(:@round2)["score"][1]["east"], "200"
      
    scored = DateTime.new 2016, 12, 26, 9, 45, 0, @now.offset
    @schedule.add_score! scored, { "east" => "200", "west" => "300", "south" => "400", "north" => "500" }
    assert_equal 2, @schedule.instance_variable_get(:@round2)["score"].length
  end
  
  def test_round_cover?
    round2 = @schedule.instance_variable_get(:@round2)

    current = DateTime.new 2016, 12, 26, 0, 0, 0, @now.offset
    assert_false round2.cover?(current)
    
    current = DateTime.new 2016, 12, 26, 6, 59, 59, @now.offset
    assert_false round2.cover?(current)

    current = DateTime.new 2016, 12, 26, 7, 0, 0, @now.offset
    assert_true round2.cover?(current)

    current = DateTime.new 2016, 12, 27, 0, 14, 59, @now.offset
    assert_true round2.cover?(current)
    
    current = DateTime.new 2016, 12, 27, 0, 15, 0, @now.offset
    assert_false round2.cover?(current)
  end
end