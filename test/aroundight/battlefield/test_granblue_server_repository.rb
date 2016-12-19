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
    @id = 25
  end
  
  def teardown
  end
  
  def test_get_bookmaker_score
    date = DateTime.new 2016, 12, 15, 15, 0, 0, @offset
    score = @repo.get_bookmaker_score @id, date
    assert_equal score["time"], "2016-12-15 15:00:00"
    assert_equal score["north"], "0"
    assert_equal score["south"], "0"
    assert_equal score["east"], "0"
    assert_equal score["west"], "0"
  end
  
  def test_get_qualifying_score
    date = DateTime.new 2016, 12, 15, 16, 0, 0, @offset
    score = @repo.get_qualifying_score @id, date
    assert_equal score["time"], "2016-12-15 16:00:00"
    assert_equal score["qualifying120"], "94638302"
    assert_equal score["qualifying2400"], "40254800"
    assert_equal score["seed120"], "103196931"
    assert_equal score["seed660"], "43150116"
  end
  
  def test_get_ranking_score
    date = DateTime.new 2016, 12, 15, 17, 0, 0, @offset
    score = @repo.get_ranking_score @id, date
    assert_equal score["time"], "2016-12-15 17:00:00"
    assert_equal score["ranking1000"], "11305552"
    assert_equal score["ranking3000"], "8511982"
  end
end