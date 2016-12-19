require 'date'
require File.expand_path('../../core/repository', __FILE__)
require File.expand_path('../../core/data_repository', __FILE__)
require File.expand_path('../../core/ftp_repository', __FILE__)
require File.expand_path('../bookmaker_schedule', __FILE__)
require File.expand_path('../ranking_schedule', __FILE__)
require File.expand_path('../qualifying_schedule', __FILE__)

module Aroundight
  class PublicServerRepository < Repository
    def initialize
      super
      build!
    end
    
    def build!
      conf = load_yaml "config"
      @public_server = conf["public_server"]
      @local_server = conf["local_server"]
      @local_repo = DataRepository.new
      @local_repo_dir = "#{@local_server['repo_dir']}#{@local_server['repo_dir'].end_with?("/") ? "" : "/"}"
    end
    
    def save_bookmaker_schedule bookmaker
      filename = "#{@local_repo_dir}bookmaker_#{bookmaker.id}.json"
      publish bookmaker, filename
    end
    
    def save_ranking_schedule ranking
      filename = "#{@local_repo_dir}ranking_#{ranking.id}.json"
      publish ranking, filename
    end
    
    def save_qualifying_schedule qualifying
      filename = "#{@local_repo_dir}qualifying_#{qualifying.id}.json"
      publish qualifying, filename
    end
    
    def load_bookmaker_schedule id
      hash = load_hash id, "bookmaker"
      bookmaker = BookmakerSchedule.new
      bookmaker.merge! hash
    end
        
    def load_ranking_schedule id
      hash = load_hash id, "ranking"
      ranking = RankingSchedule.new
      ranking.merge! hash
    end
            
    def load_qualifying_schedule id
      hash = load_hash id, "qualifying"
      qualifying = QualifyingSchedule.new
      qualifying.merge! hash
    end
        
    private
    def load_hash id, type
      @local_repo.load "#{@local_repo_dir}#{type}_#{id}.json"
    end
    
    def publish data, filename
      @local_repo.save data.to_hash, filename
      
      ftp = nil
      begin
        ftp = FtpRepository.new @public_server
        ftp.connect
        ftp.cd @public_server["context"]
        ftp.put filename
        ftp.close
      rescue Net::FTPPermError => ex
        p ex
        raise ex
      ensure
        ftp.close unless ftp == nil
      end
    end
  end
end