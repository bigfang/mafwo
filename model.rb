#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'sequel'

DB = Sequel.sqlite('db/db.sqlite')


class Country < Sequel::Model(:countries)
  unrestrict_primary_key
  one_to_many :cities
end

class City < Sequel::Model(:cities)
  unrestrict_primary_key
  many_to_one :countries
  one_to_many :spots
end

class Spot < Sequel::Model(:spots)
  unrestrict_primary_key
  many_to_one :cities
end
