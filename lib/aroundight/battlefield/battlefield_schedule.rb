require 'date'
require File.expand_path('../../core/game_schedule', __FILE__)

module Aroundight
  class BattlefieldSchedule < GameSchedule
    def initialize
      super
    end
    
    def duplicate? score, datetime
      date_s = _date_to_s datetime
      r = score.find(->{[]}){|each| each["time"] == date_s}.length > 0
    end
    
    def to_start_datetime d
      DateTime.new d.year, d.month, d.day, 19, 0, 0, d.offset
    end
    
    def to_end_datetime d, t
      end_date = d + t
      DateTime.new end_date.year, end_date.month, end_date.day, 0, 14, 59, end_date.offset
    end
  end
end