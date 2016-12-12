require File.expand_path('../schedule', __FILE__)

module Aroundight
  class GameSchedule < Schedule
    def initialize
      super
      @concentrate = false
    end
    
    def to_hash
      super.merge!({
        "qualifying_start_date" => _date_to_s(qualifying_start_date),
        "qualifying_end_date" => _date_to_s(qualifying_end_date),
        "interval_start_date" => _date_to_s(interval_start_date),
        "interval_end_date" => _date_to_s(interval_end_date),
        "finals_start_date" => _date_to_s(finals_start_date),
        "finals_end_date" => _date_to_s(finals_end_date),
        "interval_length" => interval_length,
        "qualifying_length" => qualifying_length,
        "finals_length" => finals_length
      })
    end
    
    def merge! hash
      clear!
      super hash
      define_qualifying! hash["interval_length"].to_i, hash["qualifying_length"].to_i
    end
    
    def define_qualifying! interval, term_of_qualifying
      @concentrate = true
      
      qualifying_end_date = _to_lasttime @term.first + term_of_qualifying - 1
      interval_start_date = _to_firsttime qualifying_end_date + 1
      interval_end_date = _to_lasttime interval_start_date + interval - 1
      final_start_date = _to_firsttime interval_end_date + 1
      
      @interval_length = interval
      @qualifying_length = term_of_qualifying
      @finals_length = length - interval - term_of_qualifying 
      
      @term_of_qualifying = (@term.first..qualifying_end_date)
      @term_of_interval = (interval_start_date..interval_end_date)
      @term_of_finals = (final_start_date..@term.last)
    end
    
    def clear!
      super
      @concentrate = false
      
      @interval_length = nil
      @qualifying_length = nil
      @finals_length = nil
      
      @term_of_qualifying = nil
      @term_of_interval = nil
      @term_of_finals = nil
      
      self
    end
    
    def cover_qualifying? date
      return false unless concentrate?
      @term_of_qualifying.cover? date
    end
    
    def cover_interval? date
      return false unless concentrate?
      @term_of_interval.cover? date
    end
    
    def cover_finals? date
      return false unless concentrate?
      @term_of_finals.cover? date
    end
    
    def qualifying_start_date
      return nil unless concentrate?
      @term_of_qualifying.first
    end
    
    def qualifying_end_date
      return nil unless concentrate?
      @term_of_qualifying.last
    end
    
    def interval_start_date
      return nil unless concentrate?
      @term_of_interval.first
    end
    
    def interval_end_date
      return nil unless concentrate?
      @term_of_interval.last
    end
    
    def finals_start_date
      return nil unless concentrate?
      @term_of_finals.first
    end
    
    def finals_end_date
      return nil unless concentrate?
      @term_of_finals.last
    end
    
    def qualifying_length
      return nil unless concentrate?
      @qualifying_length
    end
    
    def interval_length
      return nil unless concentrate?
      @interval_length
    end
    
    def finals_length
      return nil unless concentrate?
      @finals_length
    end
    
    def concentrate?
      @concentrate
    end
    
    protected
    def _to_lasttime datetime
      DateTime.new datetime.year, datetime.month, datetime.day, 23, 59, 59, datetime.offset
    end
    
    def _to_firsttime datetime
      DateTime.new datetime.year, datetime.month, datetime.day, 0, 0, 0, datetime.offset
    end
  end
end