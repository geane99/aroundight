require 'date'

module Aroundight
  class Schedule
    TIME_OFFSET = Time.now.utc_offset / 60 / 60
    DEFAULT_DATEFORMAT = "%Y-%m-%d %H:%M:%S"
    DEFAULT_DATEFORMAT_WITH_TIMEZONE = "#{DEFAULT_DATEFORMAT}%z"

    attr_accessor :id
    
    def initialize
      @id = nil
      @out_of_term = []
      @out_of_termtime = []
    end
    
    def term! start_date, end_date
      @term = start_date..end_date
      @term_length = (end_date - start_date + 0.5).round
    end
    
    def term_start_date
      @term.first
    end
    
    def term_end_date
      @term.last
    end
    
    def clear!
      @out_of_term = []
      @out_of_termtime = []
      @term = nil
      @term_length = nil
      self
    end
    
    def length
      @term_length
    end
    alias :size :length

    def out_of_term from, to
      if from.instance_of? String
        froms = from.split(":")
        tos = to.split(":")

        fromi = ((froms[0].to_i * 60 * 60) + (froms[1].to_i * 60))
        if froms.size == 3
          fromi += froms[2].to_i
        end
        
        toi = ((tos[0].to_i * 60 * 60) + (tos[1].to_i * 60))
        if tos.size == 3
          toi += tos[2].to_i
        end
        @out_of_termtime << (fromi..toi)
      else
        @out_of_term << (from..to)
      end
      self
    end
    
    def cover? datetime
      return false unless @term != nil and @term.cover? datetime
      return false if out_of_term? datetime
      return true
    end
    
    def to_hash
      { "start_date"=> _date_to_s(@term.first), "end_date"=> _date_to_s(@term.last), "id" => @id }
    end

    def merge! hash
      term! _to_zone_datetime(hash['start_date']), _to_zone_datetime(hash['end_date'])
      @id = hash["id"]
    end
    
    protected
    def out_of_term? datetime
      is_out_of_term = false
      @out_of_term.each{|t|
        if t.cover? datetime
          is_out_of_term = true
          break
        end
      }
      return true if is_out_of_term
      
      unless @out_of_termtime.empty?
        target_time =  (datetime.hour * 60 * 60 ) + datetime.min * 60 + datetime.sec
        @out_of_termtime.each{|t|
          if t.cover? target_time
            is_out_of_term = true
            break
          end
        }
        return true if is_out_of_term
      end
      return false
    end    
    
    def _date_to_s date
      date.strftime DEFAULT_DATEFORMAT
    end
    
    def _to_zone_datetime strdate
      DateTime.strptime "#{strdate}+%02d00" % TIME_OFFSET, DEFAULT_DATEFORMAT_WITH_TIMEZONE
    end
  end
end