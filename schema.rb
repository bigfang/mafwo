#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'sequel'

DB = Sequel.sqlite('db/db.sqlite')


DB.create_table :countries do
  primary_key :id, :auto_increment=>false
  String :name_cn, :size=>10
  String :name_en, :size=>100
  String :continent, :size=>5
end

DB.create_table :cities do
  primary_key :id, :auto_increment=>false
  foreign_key :country_id, :countries, :null=>false
  String :name_cn, :size=>20
  String :name_en, :size=>100
  String :summary, :size=>500
  Integer :visited_num
  DateTIme :created_at, :null=>false, :default=>Sequel::CURRENT_TIMESTAMP
end

DB.create_table :spots do
  primary_key :id, :auto_increment=>false
  foreign_key :country_id, :countries, :null=>false
  String :name, :size=>100
  String :summary, :size=>1000
  DateTIme :created_at, :null=>false, :default=>Sequel::CURRENT_TIMESTAMP
end

DB.create_table :cities_spots do
  foreign_key :city_id, :cities, :null=>false
  foreign_key :spot_id, :spots, :null=>false
  primary_key [:city_id, :spot_id]
  index [:city_id, :spot_id]
end
