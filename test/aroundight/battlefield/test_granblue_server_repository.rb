require 'test/unit'
require File.expand_path('../../core/extension_test_double', __FILE__)
require File.expand_path('../../../../lib/aroundight/battlefield/granblue_server_repository', __FILE__)

class TestGranblueServerRepository < Test::Unit::TestCase
  def self.startup
    Aroundight::GranblueServerRepository.send :prepend, ExtensionTestDouble
  end
  
  def self.shutdown
  end
  
  def setup
    @repo = Aroundight::GranblueServerRepository.new
    @offset = DateTime.now.offset
  end
  
  def teardown
  end
  
  def test_get_bookmaker_score
    date = DateTime.new 2016, 12, 15, 15, 0, 0, @offset
    score = @repo.get_bookmaker_score 25, date
    assert_equal score["time"], "2016-12-15 15:00:00"
    assert_equal score["north"], "596971666653"
    assert_equal score["south"], "594955795247"
    assert_equal score["east"], "618236456644"
    assert_equal score["west"], "621542941533"
  end
  
  def test_get_qualifying_score
    date = DateTime.new 2016, 12, 15, 16, 0, 0, @offset
    score = @repo.get_qualifying_score 25, date
    assert_equal score["time"], "2016-12-15 16:00:00"
    assert_equal score["qualifying120"], "872082519"
    assert_equal score["qualifying2400"], "872082519"
    assert_equal score["seed120"], "1442348035"
    assert_equal score["seed660"], "1442348035"
  end
  
  def test_get_ranking_score
    date = DateTime.new 2016, 12, 15, 17, 0, 0, @offset
    score = @repo.get_ranking_score 25, date
    assert_equal score["time"], "2016-12-15 17:00:00"
    assert_equal score["ranking1000"], "3728"
    assert_equal score["ranking3000"], "3728"
  end
end