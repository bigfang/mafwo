#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'sequel'

# DB = Sequel.sqlite('db/db.sqlite')
DB = Sequel.postgres('hornet', :host=>'localhost', :user=>'bigfang', :password=>'')


class Country < Sequel::Model(:countries)
  unrestrict_primary_key
  one_to_many :cities
end

class City < Sequel::Model(:cities)
  unrestrict_primary_key
  many_to_one :countries
  many_to_many :spots
end

class Spot < Sequel::Model(:spots)
  unrestrict_primary_key
  many_to_many :cities
  one_to_many :reviews
end

class User < Sequel::Model(:users)
  unrestrict_primary_key
  one_to_many :reviews
end

class Review < Sequel::Model(:reviews)
  unrestrict_primary_key
  many_to_one :spots
  many_to_one :users
  one_to_many :photos
end

class Photo < Sequel::Model(:photos)
  unrestrict_primary_key
  many_to_one :reviews
end

class PhotoReview < Sequel::Model(:photos_reviews)
  unrestrict_primary_key
  one_to_one :photos
  many_to_one :reviews
end
