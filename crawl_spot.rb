#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'logger'
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


fetch_country
