#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'logger'
require 'json'
require 'nokogiri'
require 'mechanize'
require './model'


@logger = Logger.new("log/spot.log")
@agent = Mechanize.new
@agent.user_agent_alias = Mechanize::AGENT_ALIASES.keys[1..-4].sample
@agent.log = Logger.new("log/agent_spot.log")


def fetch_country
  url = 'http://www.mafengwo.cn/mdd/'
  page = @agent.get(url)
  page.css('.row-list[data-cs-p="全球目的地"] dl.item').each do |node|
    continent = node.css('.sub-title').text
    node.css('li a').each do |city|
      id = city.attr('href').scan(/\/(\d+)\.html/).last
      fullname = city.text
      name_en = city.css('.en').text.strip
      name_cn = fullname.gsub(name_en, '').strip
      begin
        Country.create(:id=>id, :name_cn=>name_cn, :name_en=>name_en, :continent=>continent)
        @logger.info("new country #{name_cn} - #{id}")
      rescue => err
        @logger.error("#{err.message}")
      end
    end
  end
end

def fetch_city
  url = 'http://www.mafengwo.cn/mdd/base/list/pagedata_citylist'
  Country.each do |country|
    # next if country.id < 10062  # debug
    (1..999).each do |num|
      @logger.info("crawling: #{country.name_cn} - #{country.id} - page: #{num}")
      data = {"page"=>num, "mddid"=>country.id}
      doc = @agent.post(url, data)
      resp = JSON.parse(doc.content)
      page = Nokogiri::HTML(resp['page'])
      list = Nokogiri::HTML(resp['list'])
      list.css('li.item').each do |item|
        begin
          id = item.css('.img a').attr('data-id').text
          fullname = item.css('.title').text.strip
          name_en = item.css('.title .enname').text.strip
          name_cn = fullname.gsub(name_en, '').strip
          if fullname.scan(/\p{Han}/).empty?
            name_cn = nil
            name_en = fullname
          end
          summary = item.css('.caption .detail').text.strip
          visited_num = item.css('.caption .nums b').text
          City.create(:id=>id, :country_id=>country.id, :name_en=>name_en, :name_cn=>name_cn, :summary=>summary, :visited_num=>visited_num)
        rescue => err
          @logger.error(err.message)
        end
      end
      break if page.css('.pg-last').empty?
    end
  end
end

def fetch_spot
  url = 'http://www.mafengwo.cn/ajax/router.php'
  City.order(:country_id, :id).where{id > 0}.each do |city|
    @logger.debug("country:#{city.country_id} city:#{city.id} #{city.name_cn}")
    (1..9999).each do |num|
      @logger.debug("page #{num}")
      data = {"sAct"=>"KMdd_StructWebAjax|GetPoisByTag",
              "iMddid"=>city.id, "iTagId"=>0, "iPage"=>num}
      doc = @agent.post(url, data)
      resp = JSON.parse(doc.content)
      page = Nokogiri::HTML(resp['data']['page'])
      list = Nokogiri::HTML(resp['data']['list'])

      list.css('li').each do |li|
        begin
          id = li.css('a').attr('href').text.scan(/\/(\d+)\.html/).last.last
          name = li.css('a').attr('title').text
          begin
            spot = Spot.new(:id=>id, :country_id=>city.country_id, :name=>name)
            spot.save
            spot.add_city(city)
          rescue => er
            spot.add_city(city)
            @logger.error("#{er.message} :: #{city.id} - #{name} - #{id}")
          end
        rescue => err
          @logger.error("#{err.message}")
        end
      end
      break if page.css('.pg-last').empty?
    end
  end
end

def fetch_summary
  Spot.order(:id).where{id > 0}.each do |spot|
    @logger.debug("country:#{spot.country_id} spot:#{spot.id} #{spot.name}")
    url = "http://www.mafengwo.cn/poi/#{spot.id}.html"
    begin
      doc = @agent.get(url)
    rescue Mechanize::ResponseCodeError => err
      @logger.error("#{err.message}")
      next
    end

    script = doc.css('script').first.text
    txt = script.split("\n")[1]
    str = txt.scan(/window\.Env = ({.*});/).first.first
    res = JSON.parse(str)

    summary = doc.css('.mod-detail .summary').text.strip
    spot.summary = summary
    spot.lat = res['lat']
    spot.lng = res['lng']
    spot.save
  end
end


if ARGV[0] == '1'
  fetch_country
elsif ARGV[0] == '2'
  fetch_city
elsif ARGV[0] == '3'
  fetch_spot
elsif ARGV[0] == '4'
  fetch_summary
end

@logger.info('fin!')
