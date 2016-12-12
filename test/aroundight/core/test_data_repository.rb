require 'test/unit'
require File.expand_path('../../../../lib/aroundight/core/data_repository', __FILE__)

class TestDataRepository < Test::Unit::TestCase
  def self.startup
  end
  
  def self.shutdown
  end
  
  def setup
    @filename = File.expand_path("../test_data_repository_file.txt", __FILE__)
  end
  
  def teardown
  end
  
  def test_save
    repo = Aroundight::DataRepository.new
    repo.save({"test-property"=>"test-value"}, @filename)
  end
  
  def test_load
    repo = Aroundight::DataRepository.new
    json = repo.load @filename
    assert_equal json["test-property"], "test-value"
  end
end