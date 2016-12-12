require 'date'
require File.expand_path('../battlefield_schedule', __FILE__)

module Aroundight
  class RankingSchedule < BattlefieldSchedule
    def initialize start_date = nil, end_date = nil, qualifying_length = nil, interval_length = nil
      super()
      @score = []
      
      unless start_date == nil
        term! to_start_datetime(start_date), to_end_datetime(end_date, 1)
        define_qualifying! interval_length, qualifying_length
        
        build_out_of_term
      end
    end
    
    def add_score! time, score
      @score << score if cover? time and not duplicate? @score, time
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
      build_out_of_term
    end
    
    def clear!
      @core = []
    end
        
    def cover? datetime
      unless @term.cover? datetime then return false end 
      if cover_interval? datetime then return false end
      if out_of_term? datetime then return false end
      return true
    end
    
    private
    def build_out_of_term
      to_finals_out_of_term_start = -> date {
        DateTime.new date.year, date.month, date.day, 0, 15, 0, date.offset
      }
      to_finals_out_of_term_end = -> date {
        DateTime.new date.year, date.month, date.day, 6, 59, 59, date.offset
      }
      
      (0...finals_length).each{|idx|
        out_of_term to_finals_out_of_term_start.(finals_start_date + idx), to_finals_out_of_term_end.(finals_start_date + idx)
      }
      self
    end
  end
end