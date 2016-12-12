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
      text = http_get url
      scanner = StringScanner.new(text)
      index = 0
      
      parser = -> keyword{
        index += scanner.scan_until(keyword).size
        text[index, 20].match(/([0-9]+)/)[0]
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
      parser = -> (keyword1, keyword2, pagenum){
        url = "#{@conf['server_url']}#{@conf['score_individual_context']}" % [raidid, pagenum]
        text = http_get url
        scanner = StringScanner.new(text)
        index  = scanner.scan_until(keyword1).size
        index += scanner.scan_until(keyword2).size
        text[index, 20].match(/([0-9]+)/)[0]    
      }
      
      {
        "ranking1000"=> parser.(/<div class="ico-rank-twodigits">1000<\/div>/,/<div class="txt-total-record"><span>/, 100), 
        "ranking3000"=> parser.(/<div class="ico-rank-twodigits">3000<\/div>/,/<div class="txt-total-record"><span>/, 300),
        "time"=>time.strftime("%Y-%m-%d %H:%M:%S")
      }
    end
    
    def get_qualifying_score raidid, time
      parser_base = -> base_url{
        -> (keyword1,keyword2,pagenum){
          url = "#{base_url}" % [raidid, pagenum]
          text = http_get url
          scanner = StringScanner.new(text)
          index  = scanner.scan_until(keyword1).size
          index += scanner.scan_until(keyword2).size
          text[index, 20].match(/([0-9]+)/)[0]
        }
      }
      qualifying_parser = parser_base.("#{@conf['server_url']}#{@conf['score_qualifying_context']}")
      seed_parser = parser_base.("#{@conf['server_url']}#{@conf['score_seed_context']}")
      
      {
        "qualifying120" => qualifying_parser.(/<div class="ico-rank-twodigits">120<\/div>/,/<div class="txt-total-record"><span>/,  12),
        "qualifying2400"=> qualifying_parser.(/<div class="ico-rank-twodigits">2400<\/div>/,/<div class="txt-total-record"><span>/, 240),
        "seed120"       =>       seed_parser.(/<div class="ico-rank-twodigits">120<\/div>/,/<div class="txt-total-record"><span>/,  12),
        "seed660"       =>       seed_parser.(/<div class="ico-rank-twodigits">660<\/div>/,/<div class="txt-total-record"><span>/,  66),
        "time"=>time.strftime("%Y-%m-%d %H:%M:%S")
      }
    end

    private
    def http_get url
      to_html @server.url(url).get
    end
    
    def to_html text
      jsonstr = Kconv.tosjis(text)
      data = JSON.parse(jsonstr)["data"]
      if data == nil
        #TODO 
        raise "error"
      end 
      URI.decode(data).encode("Shift_JIS")
    end

    def config
      conf = load_yaml "config.yml"
      conf["game_server"]
    end
    
    def create_http_repository conf
      HttpRepository.new conf
    end
    
    def build!
      @server.
        header("X-VERSION", "1478071970").
        header("Accept-Language", "ja,en-US;q=0.8,en;q=0.6").
        header("User-Agent", "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_2 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8H7 Safari/6533.18.5").
        header("Accept", "application/json, text/javascript, */*; q=0.01").
        header("Referer", "#{@conf['server_url']}").
        header("X-Requested-With","XMLHttpRequest").
        header("Cookie", @conf["cookie"]).
        header("Connection", "keep-alive").
        header("Cache-Control", "max-age=0")
    end
  end
end