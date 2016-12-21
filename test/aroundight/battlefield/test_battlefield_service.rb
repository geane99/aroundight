require 'test/unit'
require 'date'
require File.expand_path('../../core/extension_test_double', __FILE__)
require File.expand_path('../../../../lib/aroundight/battlefield/battlefield_service', __FILE__)
require File.expand_path('../../../../lib/aroundight/battlefield/public_server_repository', __FILE__)
require File.expand_path('../../../../lib/aroundight/battlefield/granblue_server_repository', __FILE__)

class TestBattlefiedService < Test::Unit::TestCase
  def self.startup
    Aroundight::GranblueServerRepository.send :prepend, ExtensionTestDouble
    Aroundight::PublicServerRepository.send :prepend, ExtensionTestDouble

    game_server = Aroundight::GranblueServerRepository.new
    public_server = Aroundight::PublicServerRepository.new
    
    service = Aroundight::BattlefieldService.new
    service.instance_variable_set(:@game_server, game_server)
    service.instance_variable_set(:@publish_server, public_server)
    
    @@start_date =     DateTime.new 2016, 12, 22, 19,  0,  0, DateTime.now.offset
    @@end_date =       DateTime.new 2016, 12, 29, 23, 59, 59, DateTime.now.offset
    @@qualifying2_1 =  DateTime.new 2016, 12, 23, 10, 15,  0, DateTime.now.offset
    @@qualifying2_2 =  DateTime.new 2016, 12, 23, 10, 30,  0, DateTime.now.offset
    @@interval1 =      DateTime.new 2016, 12, 24, 15,  0,  0, DateTime.now.offset
    @@finals3_1 =      DateTime.new 2016, 12, 27, 12, 30,  0, DateTime.now.offset
    @@finals3_2 =      DateTime.new 2016, 12, 27, 12, 45,  0, DateTime.now.offset
    @@finals3_3 =      DateTime.new 2016, 12, 27, 13,  0,  0, DateTime.now.offset
    @@finals3_4 =      DateTime.new 2016, 12, 27, 13, 15,  0, DateTime.now.offset
    @@finals3_5 =      DateTime.new 2016, 12, 27, 13, 30,  0, DateTime.now.offset
    @@finals3_6 =      DateTime.new 2016, 12, 27, 13, 45,  0, DateTime.now.offset
    @@finals3_7 =      DateTime.new 2016, 12, 27, 14,  0,  0, DateTime.now.offset
    @@finals3_8 =      DateTime.new 2016, 12, 27, 14, 15,  0, DateTime.now.offset
    @@finals3_9 =      DateTime.new 2016, 12, 27, 14, 30,  0, DateTime.now.offset
    @@finals3_10 =     DateTime.new 2016, 12, 27, 14, 45,  0, DateTime.now.offset
    @@finals4_1 =      DateTime.new 2016, 12, 28, 10,  0,  0, DateTime.now.offset
    @@finals4_2 =      DateTime.new 2016, 12, 28, 10, 15,  0, DateTime.now.offset
    
    service.define_battlefield 1,@@start_date,@@end_date,2,1
  end
  
  def self.shutdown
  end
  
  def setup
    # days
    # 1  : 2016-12-22 : qualifying (1)
    # 2  : 2016-12-23 : qualifying (2)
    # 3  : 2016-12-24 : interval (1)
    # 4  : 2016-12-25 : finals (1)
    # 5  : 2016-12-26 : finals (2)
    # 6  : 2016-12-27 : finals (3)
    # 7  : 2016-12-28 : finals (4)
    # 8  : 2016-12-29 : finals (5)

    game_server = Aroundight::GranblueServerRepository.new
    public_server = Aroundight::PublicServerRepository.new
    
    def game_server.get_bookmaker_score id, time
      r = super id, time
      range_random = 0.8..1.2
      random = Random.rand()
      
      # bookmaker
      if r["north"] != nil
        ["west","north","south","east"].each{|key|
          r[key] = (r[key].to_i * Random.rand(range_random)).round.to_s
        }
      end
      r
    end
    
    @service = Aroundight::BattlefieldService.new
    @service.instance_variable_set(:@game_server, game_server)
    @service.instance_variable_set(:@publish_server, public_server)
    
    @find = -> (score, date){
      score.find(->{[]}){|each| return each if each["time"] == date.strftime("%Y-%m-%d %H:%M:%S")}.first
    }
  end
  
  def test_update_ranking_score
    results = []
    results << @service.update_ranking_score(1, @@qualifying2_1)
    results << @service.update_ranking_score(1, @@qualifying2_2)
    results << @service.update_ranking_score(1, @@interval1)
    results << @service.update_ranking_score(1, @@finals3_1)
    results << @service.update_ranking_score(1, @@finals3_2)
    results << @service.update_ranking_score(1, @@finals3_3)
    results << @service.update_ranking_score(1, @@finals3_4)
    results << @service.update_ranking_score(1, @@finals3_5)
    results << @service.update_ranking_score(1, @@finals3_6)
    results << @service.update_ranking_score(1, @@finals3_7)
    results << @service.update_ranking_score(1, @@finals3_8)
    results << @service.update_ranking_score(1, @@finals3_9)
    results << @service.update_ranking_score(1, @@finals3_10)
    results << @service.update_ranking_score(1, @@finals4_1)
    results << @service.update_ranking_score(1, @@finals4_2)
    obj = results.compact.last
    assert_not_nil @find.call(obj["score"], @@qualifying2_1)
    assert_not_nil @find.call(obj["score"], @@qualifying2_2)
    assert_nil @find.call(obj["score"], @@interval1)
    assert_not_nil @find.call(obj["score"], @@finals3_1)
    assert_not_nil @find.call(obj["score"], @@finals3_2)
    assert_not_nil @find.call(obj["score"], @@finals3_3)
    assert_not_nil @find.call(obj["score"], @@finals3_4)
    assert_not_nil @find.call(obj["score"], @@finals3_5)
    assert_not_nil @find.call(obj["score"], @@finals3_6)
    assert_not_nil @find.call(obj["score"], @@finals3_7)
    assert_not_nil @find.call(obj["score"], @@finals3_8)
    assert_not_nil @find.call(obj["score"], @@finals3_9)
    assert_not_nil @find.call(obj["score"], @@finals3_10)
    assert_not_nil @find.call(obj["score"], @@finals4_1)
    assert_not_nil @find.call(obj["score"], @@finals4_2)
  end
  
  def test_update_qualifying_score
    results = []
    results << @service.update_qualifying_score(1, @@qualifying2_1)
    results << @service.update_qualifying_score(1, @@qualifying2_2)
    results << @service.update_qualifying_score(1, @@interval1)
    results << @service.update_qualifying_score(1, @@finals3_1)
    results << @service.update_qualifying_score(1, @@finals3_2)
    results << @service.update_qualifying_score(1, @@finals3_3)
    results << @service.update_qualifying_score(1, @@finals3_4)
    results << @service.update_qualifying_score(1, @@finals3_5)
    results << @service.update_qualifying_score(1, @@finals3_6)
    results << @service.update_qualifying_score(1, @@finals3_7)
    results << @service.update_qualifying_score(1, @@finals3_8)
    results << @service.update_qualifying_score(1, @@finals3_9)
    results << @service.update_qualifying_score(1, @@finals3_10)
    results << @service.update_qualifying_score(1, @@finals4_1)
    results << @service.update_qualifying_score(1, @@finals4_2)
    obj = results.compact.last
    assert_not_nil @find.call(obj["score"], @@qualifying2_1)
    assert_not_nil @find.call(obj["score"], @@qualifying2_2)
    assert_nil @find.call(obj["score"], @@interval1)
    assert_nil @find.call(obj["score"], @@finals3_1)
    assert_nil @find.call(obj["score"], @@finals3_2)
    assert_nil @find.call(obj["score"], @@finals3_3)
    assert_nil @find.call(obj["score"], @@finals3_4)
    assert_nil @find.call(obj["score"], @@finals3_5)
    assert_nil @find.call(obj["score"], @@finals3_6)
    assert_nil @find.call(obj["score"], @@finals3_7)
    assert_nil @find.call(obj["score"], @@finals3_8)
    assert_nil @find.call(obj["score"], @@finals3_9)
    assert_nil @find.call(obj["score"], @@finals3_10)
    assert_nil @find.call(obj["score"], @@finals4_1)
    assert_nil @find.call(obj["score"], @@finals4_2)
  end
  
  def test_update_bookmaker_score
    results = []
    results << @service.update_bookmaker_score(1, @@qualifying2_1)
    results << @service.update_bookmaker_score(1, @@qualifying2_2)
    results << @service.update_bookmaker_score(1, @@interval1)
    results << @service.update_bookmaker_score(1, @@finals3_1)
    results << @service.update_bookmaker_score(1, @@finals3_2)
    results << @service.update_bookmaker_score(1, @@finals3_3)
    results << @service.update_bookmaker_score(1, @@finals3_4)
    results << @service.update_bookmaker_score(1, @@finals3_5)
    results << @service.update_bookmaker_score(1, @@finals3_6)
    results << @service.update_bookmaker_score(1, @@finals3_7)
    results << @service.update_bookmaker_score(1, @@finals3_8)
    results << @service.update_bookmaker_score(1, @@finals3_9)
    results << @service.update_bookmaker_score(1, @@finals3_10)
    results << @service.update_bookmaker_score(1, @@finals4_1)
    results << @service.update_bookmaker_score(1, @@finals4_2)
    obj = results.compact.last
    scores = (1..5).map{|each| obj["round#{each}"]["score"]}.flatten
    
    assert_nil @find.call(scores, @@qualifying2_1)
    assert_nil @find.call(scores, @@qualifying2_2)
    assert_nil @find.call(scores, @@interval1)
    assert_not_nil @find.call(scores, @@finals3_1)
    assert_not_nil @find.call(scores, @@finals3_2)
    assert_not_nil @find.call(scores, @@finals3_3)
    assert_not_nil @find.call(scores, @@finals3_4)
    assert_not_nil @find.call(scores, @@finals3_5)
    assert_not_nil @find.call(scores, @@finals3_6)
    assert_not_nil @find.call(scores, @@finals3_7)
    assert_not_nil @find.call(scores, @@finals3_8)
    assert_not_nil @find.call(scores, @@finals3_9)
    assert_not_nil @find.call(scores, @@finals3_10)
    assert_not_nil @find.call(scores, @@finals4_1)
    assert_not_nil @find.call(scores, @@finals4_2)
  end
  
  def test_correct_date
    current = DateTime.new 2016, 12, 23, 16, 39, 46, DateTime.now.offset
    expect = DateTime.new 2016, 12, 23, 16, 20, 0, DateTime.now.offset
    was = Aroundight::BattlefieldService.correct_date 20, current
    assert_equal expect, was
    
    current = DateTime.new 2016, 12, 23, 16, 59, 11, DateTime.now.offset
    expect = DateTime.new 2016, 12, 23, 16, 40, 0, DateTime.now.offset
    was = Aroundight::BattlefieldService.correct_date 20, current
    assert_equal expect, was
    
    current = DateTime.new 2016, 12, 23, 17, 1, 26, DateTime.now.offset
    expect = DateTime.new 2016, 12, 23, 17, 00, 0, DateTime.now.offset
    was = Aroundight::BattlefieldService.correct_date 20, current
    assert_equal expect, was

    current = DateTime.new 2016, 12, 23, 16, 39, 46, DateTime.now.offset
    expect = DateTime.new 2016, 12, 23, 16, 30, 0, DateTime.now.offset
    was = Aroundight::BattlefieldService.correct_date 15, current
    assert_equal expect, was
    
    current = DateTime.new 2016, 12, 23, 16, 59, 11, DateTime.now.offset
    expect = DateTime.new 2016, 12, 23, 16, 45, 0, DateTime.now.offset
    was = Aroundight::BattlefieldService.correct_date 15, current
    assert_equal expect, was
    
    current = DateTime.new 2016, 12, 23, 17, 1, 26, DateTime.now.offset
    expect = DateTime.new 2016, 12, 23, 17, 00, 0, DateTime.now.offset
    was = Aroundight::BattlefieldService.correct_date 15, current
    assert_equal expect, was   
  end
  
  def test_correct_15_date_now
    now = DateTime.now
    exp_min = now.min - now.min % 15
    expect = DateTime.new now.year, now.month, now.day, now.hour, exp_min, 0, DateTime.now.offset
    was = Aroundight::BattlefieldService.correct_15_date_now
    assert_equal expect, was
  end
  
  def test_correct_20_date_now
    now = DateTime.now
    exp_min = now.min - now.min % 20
    expect = DateTime.new now.year, now.month, now.day, now.hour, exp_min, 0, DateTime.now.offset
    was = Aroundight::BattlefieldService.correct_20_date_now
    assert_equal expect, was
  end
  
  def test_correct_60_date_now
    now = DateTime.now
    exp_min = now.min - now.min % 60
    expect = DateTime.new now.year, now.month, now.day, now.hour, exp_min, 0, DateTime.now.offset
    was = Aroundight::BattlefieldService.correct_20_date_now
    assert_equal expect, was
  end
end