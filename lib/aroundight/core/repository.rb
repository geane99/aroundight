require 'logger'
require File.expand_path('../yaml_repository', __FILE__)

module Aroundight
  class Repository
    def initialize
      @@yaml_repository = YamlRepository.new
      @@logger_conf = @@yaml_repository.load_yaml("config")["logger"]
      use_stdout = @@logger_conf["file"] == "STDOUT"
      @@logger = Logger.new @@logger_conf["file"] unless use_stdout
      @@logger = Logger.new STDOUT if use_stdout
      @@logger.level = Logger.const_get @@logger_conf["level"]
    end
    
    def load_yaml filename
      @@yaml_repository.load_yaml filename
    end
    
    def save_yaml obj, filename
      logger.debug "[yaml-save] #{filename} = #{obj}" if logger.debug?
      @@yaml_repository.save_yaml obj, filename 
    end
    
    def logger
      @@logger
    end
  end
end