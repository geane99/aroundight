require 'net/http'
require 'uri'
require File.expand_path('../repository', __FILE__)

module Aroundight
  class HttpRepository < Repository
    def initialize server
      super()
      @param = {}
      @header = {}
      @server_config = server
    end
    
    def clear
      @param = {}
      @header = {}
    end
    
    def url u
      @uri = URI.parse u.strip
      self
    end
    
    def to_url
      @uri.to_s
    end
    
    def param k, v
      @param[k] = URI.escape v
      self
    end
    
    def header k, v
      @header[k] = v
      self
    end

    def post
      request = Net::HTTP::Post.new @uri
      unless @param.empty? then request.set_form_data(@param) end

      pre_send request
      execute {|http|
        http.request request
      }
    end
    
    def get
      res = get_exec
      res.body
    end
    
    def get_exec
      url = @uri.to_s.strip
      
      unless url.include? "?"
        unless @param.empty?
          url += "?" 
        end 
      end
      
      unless @param.empty?
        @param.each{|k,v| url += "#{k}=#{v}"}
      end
      
      @uri = URI.parse url.strip
      request = Net::HTTP::Get.new @uri

      pre_send request
      execute {|http|
        http.request request
      }
    end

    private
    def pre_send request
      unless @header.empty?
        @header.each{|k,v| request[k] = v}
      end
      return request
    end

    def execute
      response = Net::HTTP.start(@uri.host, @uri.port, use_ssl: @uri.scheme == 'https') do |http|
        http.open_timeout = @server_config["timeout"]
        http.read_timeout = @server_config["timeout"]
        yield http
      end
      if logger.debug?
        response.each_header{|name,val|
          logger.debug "[response header] #{name} = #{val}"
        }
        logger.debug response.body
      end
      response.body.force_encoding @server_config["encoding"]
      response
    end
    
  end
end