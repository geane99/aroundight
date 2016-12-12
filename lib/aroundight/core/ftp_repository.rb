require 'net/ftp'
require File.expand_path('../repository', __FILE__)

module Aroundight
  class FtpRepository < Repository 
    def initialize conf
      super()
      @server = conf
      puts @server
    end
      
    def connect
      unless connect?
        @client = Net::FTP.new
        @client.passive = true
        @client.debug_mode = @server["debug"]
        @client.read_timeout = @server["timeout"]
        @client.open_timeout = @server["timeout"]
        
        begin
          @@logger.info "connect : #{@server['host']}:#{@server['port']}, [user] #{@server['user']}"
          @@logger.debug "login : #{@server['user']}, #{@server['password']}"

          @client.connect(@server["host"],  @server["port"])
          @client.login(@server["user"], @server["password"])
        rescue Net::FTPPermError => ex
          close
          raise ex
        end
      end
    end
    
    def connect?
      @client != nil and !@client.close?
    end
    
    def cd path
      @@logger.info "cd : #{path}"
      
      if path.start_with? "/"
        begin 
          @@logger.debug "cd : /"
          @client.chdir '/'
        rescue Net::FTPPermError => ex
          close
          raise ex
        rescue IOError => ex
          close
          raise ex
        end
      end
      
      path.strip.split(/\//).each do |dir|
        next if dir.empty?
        if list.select{|each| each.include? dir}.size == 0
          begin
            @@logger.debug "mkdir : #{dir}"
            @client.mkdir dir
          rescue Net::FTPPermError => ex
            close
            raise ex
          end
        end
        
        begin
          @@logger.debug "cd : #{dir}"
          @client.chdir dir
        rescue Net::FTPPermError => ex
          close
          raise ex
        end
      end
    end
    
    def put filename
      @@logger.info "puts #{filename}"
      begin
        @client.put filename
      rescue Net::FTPPermError => ex
        close
        raise ex
      end
    end
    
    def delete filename
      @@logger.info "delete #{filename}"
      begin
        @client.delete filename
      rescue Net::FTPPermError => ex
        close
        raise ex
      end
    end
    
    def list
      begin
        list = @client.list
        @@logger.debug list if @@logger.debug?
        list
      rescue Net::FTPPermError => ex
        close
        raise ex
      end
    end
    
    def get filename
      @@logger.info "get #{filename}"
      begin
        @client.get filename
      rescue Net::FTPPermError => ex
        close
        raise ex
      end
    end
      
    def close
      @@logger.info "close #{@server['host']}:#{@server['port']} [user] #{@server['user']}"
      if @client != nil
        begin
          @client.close 
        rescue Net::FTPPermError => ex
          @client = nil
        end
      end
    end
  end
end