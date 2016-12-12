require 'date'
require File.expand_path('../battlefield_schedule', __FILE__)

module Aroundight
  class QualifyingSchedule < BattlefieldSchedule
    def initialize start_date = nil, end_date = nil, qualifying_length = nil, interval_length = nil
      super()
      @score = []
        
      unless start_date == nil
         term! to_start_datetime(start_date), to_end_datetime(end_date, 1)
         define_qualifying! interval_length, qualifying_length
      end
    end
    
    def add_score! time, score
      if cover? time and not duplicate? @score, time
        @score << score
      end
    end
    
    def to_hash
      hash = super
      hash["score"] = @score
      hash
    end

    def merge! hash
      clear!
      super hash
      @score = hash["score"]
      self
    end
    
    def clear!
      @core = []
    end
    
    def cover? datetime
      cover_qualifying? datetime
    end    
  end
end