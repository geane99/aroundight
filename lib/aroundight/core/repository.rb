require 'logger'
require File.expand_path('../yaml_repository', __FILE__)

module Aroundight
  class Repository
    def initialize
      @@yaml_repository = YamlRepository.new
      @@logger_conf = @@yaml_repository.load_yaml("config")["logger"]
      @@logger = Logger.new @@logger_conf["file"]
      @@logger.level = Logger::INFO
    end
    
    def load_yaml filename
      @@yaml_repository.load_yaml filename
    end
    
    def logger
      @@logger
    end
  end
end