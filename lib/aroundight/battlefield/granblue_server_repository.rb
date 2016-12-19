require 'kconv'
require 'json'
require 'uri'
require 'strscan'
require File.expand_path('../../core/repository', __FILE__)
require File.expand_path('../../core/http_repository', __FILE__)

module Aroundight
  class GranblueServerRepository < Repository
    def initialize
      super
      @conf = config
      @conf["server_url"] = "#{@conf['protocol']}://#{@conf['host']}"
      @server = create_http_repository @conf
      build!
    end
    
    def get_bookmaker_score raidid, time
      url = "#{@conf['server_url']}#{@conf['bookmaker_context']}" % raidid
      text = http_get(url)
      data = URI.decode(text["data"]).encode("UTF-8")
      scanner = StringScanner.new(data)
      index = 0
      
      parser = -> (word){
        index += scanner.scan_until(word).size
        data[index, 20].match(/([0-9]+)/)[0]
      }
      
      {
        "south"=> parser.(/<div class="lis-area area1">\n\t{6}<div class="point">/), 
        "north"=> parser.(/<div class="lis-area area2">\n\t{6}<div class="point">/), 
        "east" => parser.(/<div class="lis-area area3">\n\t{6}<div class="point">/), 
        "west" => parser.(/<div class="lis-area area4">\n\t{6}<div class="point">/), 
        "time" => time.strftime("%Y-%m-%d %H:%M:%S")
      }
    end
    
    def get_ranking_score raidid, time
      parser = -> (pagenum){
        url = "#{@conf['server_url']}#{@conf['score_individual_context']}" % [raidid, pagenum]
        data = http_get(url)
        lastid = data["list"].map{|k,v| k.to_i}.sort.last
        data["list"][lastid.to_s]["point"]
      }
      
      {
        "ranking1000"=> parser.(100), 
        "ranking3000"=> parser.(300),
        "ranking20000" => parser.(2000),
        "time"=>time.strftime("%Y-%m-%d %H:%M:%S")
      }
    end
    
    def get_qualifying_score raidid, time
      parser_base = -> base_url{
        -> (pagenum){
          url = "#{base_url}" % [raidid, pagenum]
          data = http_get(url)
          lastid = data["list"].map{|k,v| k.to_i}.sort.last
          data["list"][lastid.to_s]["point"]
        }
      }
      qualifying_parser = parser_base.("#{@conf['server_url']}#{@conf['score_qualifying_context']}")
      seed_parser = parser_base.("#{@conf['server_url']}#{@conf['score_seed_context']}")
      
      {
        "qualifying120" => qualifying_parser.(12),
        "qualifying2400"=> qualifying_parser.(240),
        "seed120"       =>       seed_parser.(12),
        "seed660"       =>       seed_parser.(66),
        "time"=>time.strftime("%Y-%m-%d %H:%M:%S")
      }
    end

    private
    def http_get url
      to_html @server.url(url).get
    end
    
    def to_html text
      jsonstr = Kconv.tosjis(text)
      data = JSON.parse(jsonstr)
      if data == nil
        logger.error data
        raise "error"
      end
      data
    end

    def config
      conf = load_yaml "config"
      conf["game_server"]
    end
    
    def create_http_repository conf
      HttpRepository.new conf
    end
    
    def build!
      @server
        .header("Accept", "application/json, text/javascript, */*; q=0.01")
        .header("Accept-Language", "ja,en-US;q=0.8,en;q=0.6")
        .header("Connection", "keep-alive")
        .header("Content-Type", "application/json")
        .header("Cookie", @conf["cookie"])
        .header("Cache-Control", "max-age=0")
        .header("Referer", "#{@conf['server_url']}")
        .header("User-Agent", "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_2 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8H7 Safari/6533.18.5")
        .header("X-Requested-With","XMLHttpRequest")
        .header("X-VERSION", @conf["xversion"])
    end
  end
end
