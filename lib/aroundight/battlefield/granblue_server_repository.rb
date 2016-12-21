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
        "north"=> parser.(/<div class="lis-area area1">\n\t{6}<div class="point">/), 
        "west"=> parser.(/<div class="lis-area area2">\n\t{6}<div class="point">/), 
        "east" => parser.(/<div class="lis-area area3">\n\t{6}<div class="point">/), 
        "south" => parser.(/<div class="lis-area area4">\n\t{6}<div class="point">/), 
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
    
    def update_connect
      url = "#{@conf['server_url']}#{@conf["update_cookie_context"]}"
      logger.info "[session-update] #{url}"
      res = @server.url(url).get_exec
      update_cookie @conf["cookie"], res.cookie, url
    end

    private
    def to_html text
      jsonstr = Kconv.tosjis(text)
      JSON.parse(jsonstr)
    end

    def http_get url
      logger.info "[http-get] #{url}"
      res = @server.url(url).get_exec
      update_cookie @conf["cookie"], res.cookie, url
      data = to_html res.body
      
      return data if data["error"] == nil and data["redirect"] == nil
      
      if data["error"] != nil
        upgrade_connection_info "#{@conf['server_url']}#{@conf['xversion_context']}"
      end

      if data["redirect"] != nil
        redirect_url = mobage_json_redirect data["redirect"]
        if redirect_url.include? @conf["host"]
          upgrade_connection_info redirect_url
        else
          tokenurl = mobage_platform_redirect redirect_url
          upgrade_connection_info tokenurl
        end
      end
      
      logger.info "[http-get] #{url}"
      build!
      res = @server.url(url).get_exec
      update_cookie @conf["cookie"], res.cookie, url
      data = to_html res.body
    end
    
    def mobage_json_redirect url
      logger.info "[redirect(json)] #{url}"
      @server = create_http_repository @conf
      @server
        .header("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8")
        .header("Accept-Language", "ja,en-US;q=0.8,en;q=0.6")
        .header("Connection", "keep-alive")
        .header("Cookie", get_cookie(url))
        .header("Upgrade-Insecure-Requests", "1")
        .header("User-Agent", "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_2 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8H7 Safari/6533.18.5")
      response = @server.url(url).get_exec
      redirect_url = response.location
    end
    
    def mobage_platform_redirect url
      redirect_url = url
      count = 0
      while redirect_url != nil and count < 4 do
        logger.info "[redirect(mobage)] #{redirect_url}"
        @server = create_http_repository @conf
        response = @server
          .header("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8")
          .header("Accept-Language", "ja,en-US;q=0.8,en;q=0.6")
          .header("Connection", "keep-alive")
          .header("Cookie", get_cookie(redirect_url))
          .header("Upgrade-Insecure-Requests", "1")
          .header("Host", redirect_url.split("/")[2])
          .header("User-Agent", "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_2 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8H7 Safari/6533.18.5")
          .url(url)
          .get_exec
        update_cookie @conf["platform_cookie"], response.cookie, redirect_url
        re_redirect_url = response.location
        break if redirect_url.split("?")[0] == re_redirect_url.split("?")[0]
        redirect_url = re_redirect_url

        count += 1
      end
    end
    
    def upgrade_connection_info url
      logger.info "[redirect(upgrade)] #{url}"
      @server = create_http_repository @conf
      @server
        .header("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8")
        .header("Accept-Language", "ja,en-US;q=0.8,en;q=0.6")
        .header("Cache-Control", "max-age=0")
        .header("Connection", "keep-alive")
        .header("Cookie", get_cookie(url))
        .header("Upgrade-Insecure-Requests", "1")
        .header("User-Agent", "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_2 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8H7 Safari/6533.18.5")
      response = @server.url(url).get_exec
      cookie_str = response.cookie

      parser = -> (data, word){
        scanner = StringScanner.new(data)
        index = scanner.scan_until(word).size
        data[index, 20].match(/([0-9]+)/)[0]
      }
      xversion = parser.(response.body, /Game\.version = /)
      logger.info "[upgrade(cookie)] #{cookie_str}"
      logger.info "[upgrade(xversion)] #{xversion}"
      
      @conf["xversion"] = xversion
      update_cookie @conf["cookie"], cookie_str, url
    end

    def build!
      @server
        .header("Accept", "application/json, text/javascript, */*; q=0.01")
        .header("Accept-Language", "ja,en-US;q=0.8,en;q=0.6")
        .header("Connection", "keep-alive")
        .header("Content-Type", "application/json")
        .header("Cookie", get_cookie(@conf["host"]))
        .header("Cache-Control", "max-age=0")
        .header("Host", @conf["host"])
        .header("Referer", "#{@conf['server_url']}")
        .header("User-Agent", "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_2 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8H7 Safari/6533.18.5")
        .header("X-Requested-With","XMLHttpRequest")
        .header("X-VERSION", @conf["xversion"])
    end
    
    def config
      conf = load_yaml "config"
      conf["game_server"]
    end
    
    def create_http_repository conf
      HttpRepository.new conf
    end
    
    def get_cookie url
      host = url.split("/")[2]
      if host == @conf["platform_host"]
        return @conf["platform_cookie"]
      elsif host == @conf["auth_host"]
        return @conf["auth_cookie"]
      else
        return @conf["cookie"]
      end
    end
    
    def update_cookie cookiebase, cookienew, url
      procmap = -> e {
        i = e.index("=")
        [e[0,i].strip,e[1+i,e.length] != nil ? e[1+i,e.length].strip : ""] if e.include? "="
      }
      a1 = cookiebase.split(";").map(&procmap).compact
      a2 = cookienew.split("; ").map(&procmap).compact
      hash = Hash[a1].merge Hash[a2]
      cookie = hash.map{|k,v| "#{k}=#{v}"}.join("; ")
      
      host = url.split("/")[2]
      if host == @conf["platform_host"]
        @conf["platform_cookie"] = cookie
      elsif host == @conf["auth_host"]
        @conf["auth_cookie"] = cookie
      else
        @conf["cookie"] = cookie
      end
      update_conf
    end
    
    def update_conf
      conf = load_yaml "config"
      conf["game_server"] = @conf
      save_yaml conf, "config"
    end
  end
end
