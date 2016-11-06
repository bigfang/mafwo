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
  String :name_cn, :size=>10
  String :name_en, :size=>100
end

DB.create_table :spots do
  primary_key :id, :auto_increment=>false
  foreign_key :city_id, :cities, :null=>false
  String :name_cn, :size=>50
  String :name_en, :size=>100
end
