require 'yaml'

module Aroundight
  class YamlRepository
    def initialize
      @config_dir = "./../../../../config/"
      @config_files = ["config.yml"]
      @store = {}

      load_yaml_default
    end
    
    def load_yaml filename
      unless @store.key? filename
        dir = File.expand_path(@config_dir, __FILE__)
        @store[filename] = YAML.load_file("#{dir}/#{filename}")
      end
      return @store[filename]
    end

    private
    def load_yaml_default
      @config_files.each {|f| load_yaml f }
    end
  end
end