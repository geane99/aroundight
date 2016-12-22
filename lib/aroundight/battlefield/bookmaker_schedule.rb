require 'date'
require File.expand_path('../battlefield_schedule', __FILE__)

module Aroundight
  class BookmakerSchedule < BattlefieldSchedule
    def initialize start_date = nil, end_date = nil, qualifying_length = nil, interval_length = nil
      super()
      unless start_date == nil
        term! to_start_datetime(start_date), to_end_datetime(end_date, 1)
        define_qualifying! interval_length, qualifying_length
        def_round_5 finals_start_date
      end
      out_of_term "00:15:00", "06:59:59"
    end

    def add_score! datetime, score
      to_roundmap.map{|k,v| v}
        .select{|r| r.cover? datetime}
        .each{|r| r.add_score! datetime, score }
    end
    
    def to_hash
      hash = super 
      hash.merge!(to_roundmap)
    end
    
    def clear!
      @round1 = nil
      @round2 = nil
      @round3 = nil
      @round4 = nil
      @round5 = nil
    end
    
    def merge! hash
      clear!
      super hash
      def_round_5 finals_start_date
      out_of_term "00:15:00", "06:59:59"
      to_roundmap.each{|k,v| v["score"] = hash[k]["score"]}
      self
    end
    
    def cover? datetime
      return false unless cover_finals? datetime
      return false if out_of_term? datetime
      return true
    end
    
    private
    def to_roundmap
      {
        "round1" => @round1,
        "round2" => @round2,
        "round3" => @round3,
        "round4" => @round4,
        "round5" => @round5
      }
    end
    
    def to_bookmaker_starttime date
      DateTime.new date.year, date.month, date.day, 7, 0, 0, date.offset
    end
    
    def def_round_5 d
      def_round = -> (date, duplicate_delegate) {
        round = {
           "datetime" => date.strftime("%Y-%m-%d"),
           "date_of_week" => date.strftime("%w"),
           "score" => [],
           "term" => (to_bookmaker_starttime(date)..to_end_datetime(date,1)),
           "duplicate?" => duplicate_delegate
         }
         def round.cover? date
           self["term"].cover? date
         end
         
         def round.last_eql? score
           eql = true
           last_score = self["score"].last
           return false if last_score == nil or last_score.empty?  
           
           last_score.each{|k,v|
             next if k == "time"
             if score[k] != v
               eql = false
               break
             end
           }
           return eql
         end
         
         def round.add_score! time, score
           unless self["duplicate?"].call(self["score"], time)
             unless last_eql? score
               self["score"] << score 
               self["score"].sort!{|a,b| a["time"] <=> b["time"]}
             end
           end
         end
         round
      }
      delegate = -> (score, time) {
        duplicate? score, time
      }
      def delegate.to_s 
        "delegate" 
      end
      @round1 = def_round.(d    ,delegate)
      @round2 = def_round.(d + 1,delegate)
      @round3 = def_round.(d + 2,delegate)
      @round4 = def_round.(d + 3,delegate)
      @round5 = def_round.(d + 4,delegate)
    end
  end
end