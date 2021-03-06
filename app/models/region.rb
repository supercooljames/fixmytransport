# == Schema Information
# Schema version: 20100707152350
#
# Table name: regions
#
#  id                    :integer         not null, primary key
#  code                  :string(255)
#  name                  :text
#  creation_datetime     :datetime
#  modification_datetime :datetime
#  revision_number       :string(255)
#  modification          :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  cached_slug           :string(255)
#

class Region < ActiveRecord::Base
  extend ActiveSupport::Memoizable

  has_friendly_id :name, :use_slug => true
  has_many :admin_areas
  has_many :localities, :through => :admin_areas
  has_many :routes
  has_many :bus_routes
  has_many :train_routes, :order => 'cached_slug asc'
  has_many :coach_routes, :order => 'number asc'
  has_many :tram_metro_routes
  has_many :ferry_routes
  
  # instance methods
  def full_name
    "#{name} region" 
  end
  
  # class methods
  def self.find_all_by_full_name(name)
    name = name.downcase
    name = name.gsub(/ region$/, '')
    find(:all, :conditions => ["LOWER(name) = ?", name])
  end

  def bus_route_letters
    bus_routes_by_letter.keys.sort
  end
  memoize :bus_route_letters

  def bus_routes_by_letter
    by_letter(bus_routes){ |route| route.number }
  end
  memoize :bus_routes_by_letter

  def coach_route_letters
    coach_routes_by_letter.keys.sort
  end
  memoize :coach_route_letters

  def coach_routes_by_letter
    by_letter(coach_routes){ |route| route.number }
  end
  memoize :coach_routes_by_letter

  def train_route_letters
    train_routes_by_letter.keys.sort
  end
  memoize :train_route_letters

  # train routes get indexed by the first letter of each terminus
  def train_routes_by_letter
    by_letter(train_routes){ |route| route.terminuses.map{ |terminus| terminus.name } }
  end
  memoize :train_routes_by_letter

  def by_letter(routes)
    routes_by_first = {}
    routes.each do |route|
      descriptors = yield route
      firsts = descriptors.map{ |descriptor| descriptor.first }
      firsts.each do |first|
        if !routes_by_first[first]
          routes_by_first[first] = []
        end
        routes_by_first[first] << route
      end
    end
    routes_by_first
  end
    
end
