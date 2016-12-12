require 'test/unit'
require File.expand_path('../extension_test_double', __FILE__)
require File.expand_path('../../../../lib/aroundight/core/repository', __FILE__)
require File.expand_path('../../../../lib/aroundight/core/yaml_repository', __FILE__)

class TestRepository < Test::Unit::TestCase
  def self.startup
    self.send(:prepend, ExtensionTestDouble)
  end
  
  def self.shutdown
  end
  
  def setup
    @yaml_repo = Aroundight::YamlRepository.new
    test_setup_yaml @yaml_repo
  end
  
  def teardown
  end
  
  def test_load_yaml
    repo = Aroundight::Repository.new
    repo.class.class_variable_set(:@@yaml_repository, @yaml_repo)
    
    config = repo.load_yaml "test_yaml_repository.yml"
    
    assert_equal config["test"]["property1"], "property1-value"
    assert_equal config["test"]["property2"], "property2-value"
  end
end