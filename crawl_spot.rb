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
      Country.create(:id=>id, :name_cn=>name_cn, :name_en=>name_en, :continent=>continent)
    end
  end
end

def fetch_city
  url = 'http://www.mafengwo.cn/mdd/base/list/pagedata_citylist'
  Country.each do |country|
    # next if country.id < 10062  # debug
    (1..999).each do |num|
      p country.name_cn, num
      @logger.info("crawling: #{country.name_cn} - #{country.id} - page: #{num}")
      data = {"page"=>num, "mddid"=>country.id}
      doc = @agent.post(url, data)
      resp = JSON.parse(doc.content)
      page = Nokogiri::HTML(resp['page'])
      list = Nokogiri::HTML(resp['list'])
      list.css('li.item').each do |item|
        begin
          id = item.css('.img a').attr('href').text.scan(/\/(\d+)\.html/).last.last
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
        rescue
          @logger.error($!)
        end
      end
      break if page.css('.pg-last').empty?
    end
  end
end


# fetch_country
fetch_city
