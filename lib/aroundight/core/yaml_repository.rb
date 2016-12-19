require 'yaml'

module Aroundight
  class YamlRepository
    def initialize
      @config_dir = "./../../../../config/"
      @config_files = ["config"]
      build!
      load_yaml_default
    end
    
    def load_yaml filename
      by_env = by_environment? filename
      f = by_env ? "#{filename}.#{@env}.yml" : "#{filename}.yml"
      unless @store.key? f
        @store[f] = YAML.load_file "#{@dir}/#{f}"
      end
      return @store[f]
    end

    private
    def load_yaml_default
      @config_files.each {|f| load_yaml f}
    end
    
    def build!
      @dir = File.expand_path(@config_dir, __FILE__)
      envhash = YAML.load_file("#{@dir}/env.yml")
      @env = envhash["environment"] if envhash != nil
      @store = {}
    end
    
    def by_environment? f
      return false if @env == nil
      File.exists? "#{@dir}/#{f}.#{@env}.yml"
    end
  end
end