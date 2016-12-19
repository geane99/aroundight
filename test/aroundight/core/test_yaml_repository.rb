require 'test/unit'
require File.expand_path('../../../../lib/aroundight/core/repository', __FILE__)

class TestYamlRepository < Test::Unit::TestCase
  def self.startup
  end
  
  def self.shutdown
  end
  
  def setup
  end
  
  def teardown
  end
  
  def test_load_yaml
    repo = Aroundight::YamlRepository.new
    repo.instance_variable_set(:@config_dir, File.expand_path("../", __FILE__))
    
    repo.send(:build!)
    config = repo.load_yaml "test_yaml_repository"
    
    assert_equal config["test"]["property1"], "property1-value"
    assert_equal config["test"]["property2"], "property2-value"
  end
  
  def test_load_yaml_default
    repo = Aroundight::YamlRepository.new
    repo.instance_variable_set(:@config_dir, File.expand_path("../", __FILE__))

    repo.send(:build!)
    repo.send(:load_yaml_default)
    
    config = repo.load_yaml "config"
    game_server = config["game_server"]
    assert_equal game_server["host"], "test.game.server"
  end
  
end