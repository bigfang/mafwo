#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'sequel'

# DB = Sequel.sqlite('db/db.sqlite')
DB = Sequel.postgres('hornet', :host=>'localhost', :user=>'bigfang', :password=>'')


DB.create_table :countries do
  Integer :id, :auto_increment=>false, :primary_key=>true
  String :name_cn, :size=>10
  String :name_en, :size=>100
  String :continent, :size=>5
end

DB.create_table :cities do
  Integer :id, :auto_increment=>false, :primary_key=>true
  foreign_key :country_id, :countries, :null=>false
  String :name_cn, :size=>20
  String :name_en, :size=>100
  String :summary, :size=>500
  Integer :visited_num
  TIme :created_at, :null=>false, :default=>Sequel::CURRENT_TIMESTAMP
end

DB.create_table :spots do
  Integer :id, :auto_increment=>false, :primary_key=>true
  foreign_key :country_id, :countries, :null=>false
  String :name, :size=>100
  String :summary, :size=>1000
  Float :lat
  Float :lng
  TIme :created_at, :null=>false, :default=>Sequel::CURRENT_TIMESTAMP
end

DB.create_table :cities_spots do
  foreign_key :city_id, :cities, :null=>false
  foreign_key :spot_id, :spots, :null=>false
  primary_key [:city_id, :spot_id]
  index [:city_id, :spot_id]
end
