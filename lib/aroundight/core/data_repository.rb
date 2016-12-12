require 'json'
require File.expand_path('../repository', __FILE__)

module Aroundight
  class DataRepository < Repository
    def initialize
      super
    end
    
    def save obj, filename
      @@logger.info "save file : #{File.expand_path filename}"
      File.open(filename, "w"){|file|
        json = JSON.generate(obj)
        @@logger.debug "save data : #{json}"
        file.puts json
      }
      obj
    end
    
    def load filename
      @@logger.info "load file : #{File.expand_path filename}"
      File.open(filename, "r"){|file|
        data = JSON.load(file)
        @@logger.debug "load data : #{data}"
        data
      }
    end
  end
end