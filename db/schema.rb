# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100803154356) do

  create_table "admin_areas", :force => true do |t|
    t.string   "code"
    t.string   "atco_code"
    t.text     "name"
    t.text     "short_name"
    t.string   "country"
    t.boolean  "national"
    t.datetime "creation_datetime"
    t.datetime "modification_datetime"
    t.string   "revision_number"
    t.string   "modification"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "region_id"
  end

  create_table "alternative_names", :force => true do |t|
    t.text     "name"
    t.integer  "locality_id"
    t.text     "short_name"
    t.text     "qualifier_name"
    t.text     "qualifier_locality"
    t.text     "qualifier_district"
    t.datetime "creation_datetime"
    t.datetime "modification_datetime"
    t.string   "revision_number"
    t.string   "modification"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assignments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "campaign_id"
    t.integer  "task_id"
    t.integer  "status_code"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "task_type_name"
  end

  create_table "campaigns", :force => true do |t|
    t.integer  "location_id"
    t.string   "location_type"
    t.text     "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.boolean  "confirmed"
    t.integer  "transport_mode_id"
    t.string   "category"
    t.text     "token"
    t.integer  "reporter_id"
  end

  create_table "districts", :force => true do |t|
    t.string   "code"
    t.text     "name"
    t.integer  "admin_area_id"
    t.datetime "creation_datetime"
    t.datetime "modification_datetime"
    t.string   "revision_number"
    t.string   "modification"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "localities", :force => true do |t|
    t.string   "code"
    t.text     "name"
    t.text     "short_name"
    t.boolean  "national"
    t.datetime "creation_datetime"
    t.datetime "modification_datetime"
    t.string   "revision_number"
    t.string   "modification"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "admin_area_id"
    t.string   "qualifier_name"
    t.string   "source_locality_type"
    t.string   "grid_type"
    t.float    "northing"
    t.float    "easting"
    t.point    "coords",                :srid => 27700
    t.integer  "district_id"
    t.string   "cached_slug"
  end

  add_index "localities", ["cached_slug"], :name => "index_localities_on_cached_slug"
  add_index "localities", ["coords"], :name => "index_localities_on_coords", :spatial => true

  create_table "locality_links", :force => true do |t|
    t.integer  "ancestor_id"
    t.integer  "descendant_id"
    t.boolean  "direct"
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locality_links", ["ancestor_id"], :name => "index_locality_links_on_ancestor_id"
  add_index "locality_links", ["descendant_id"], :name => "index_locality_links_on_descendant_id"

  create_table "location_searches", :force => true do |t|
    t.integer  "transport_mode_id"
    t.string   "name"
    t.string   "area"
    t.string   "route_number"
    t.string   "location_type"
    t.string   "session_id"
    t.text     "events"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "operators", :force => true do |t|
    t.string   "code"
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "short_name"
    t.text     "email"
    t.boolean  "email_confirmed"
    t.text     "notes"
  end

  create_table "regions", :force => true do |t|
    t.string   "code"
    t.text     "name"
    t.datetime "creation_datetime"
    t.datetime "modification_datetime"
    t.string   "revision_number"
    t.string   "modification"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cached_slug"
  end

  add_index "regions", ["cached_slug"], :name => "index_regions_on_cached_slug"

  create_table "route_localities", :force => true do |t|
    t.integer  "locality_id"
    t.integer  "route_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "route_localities", ["locality_id"], :name => "index_route_localities_on_locality_id"
  add_index "route_localities", ["route_id"], :name => "index_route_localities_on_route_id"

  create_table "route_operators", :force => true do |t|
    t.integer  "operator_id"
    t.integer  "route_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "route_operators", ["operator_id"], :name => "index_route_operators_on_operator_id"
  add_index "route_operators", ["route_id"], :name => "index_route_operators_on_route_id"

  create_table "route_segments", :force => true do |t|
    t.integer  "from_stop_id"
    t.integer  "to_stop_id"
    t.boolean  "from_terminus", :default => false
    t.boolean  "to_terminus",   :default => false
    t.integer  "route_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "route_segments", ["from_stop_id"], :name => "index_route_segments_on_from_stop_id"
  add_index "route_segments", ["route_id"], :name => "index_route_segments_on_route_id"
  add_index "route_segments", ["to_stop_id"], :name => "index_route_segments_on_to_stop_id"

  create_table "route_stops", :force => true do |t|
    t.integer  "route_id"
    t.integer  "stop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "terminus"
  end

  add_index "route_stops", ["route_id"], :name => "index_route_stops_on_route_id"
  add_index "route_stops", ["stop_id"], :name => "index_route_stops_on_stop_id"

  create_table "routes", :force => true do |t|
    t.integer  "transport_mode_id"
    t.string   "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "name"
    t.integer  "region_id"
    t.string   "cached_slug"
    t.string   "operator_code"
    t.boolean  "loaded"
  end

  add_index "routes", ["cached_slug"], :name => "index_routes_on_cached_slug"
  add_index "routes", ["number"], :name => "index_routes_on_number"
  add_index "routes", ["operator_code"], :name => "index_routes_on_operator_code"
  add_index "routes", ["region_id"], :name => "index_routes_on_region_id"
  add_index "routes", ["transport_mode_id"], :name => "index_routes_on_transport_mode_id"
  add_index "routes", ["type"], :name => "index_routes_on_type"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  add_index "slugs", ["sluggable_id", "sluggable_type"], :name => "index_slugs_on_sluggable_id_and_sluggable_type"
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "stop_area_links", :force => true do |t|
    t.integer  "ancestor_id"
    t.integer  "descendant_id"
    t.boolean  "direct"
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stop_area_memberships", :force => true do |t|
    t.integer  "stop_id"
    t.integer  "stop_area_id"
    t.datetime "creation_datetime"
    t.datetime "modification_datetime"
    t.integer  "revision_number"
    t.string   "modification"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stop_area_memberships", ["stop_area_id"], :name => "index_stop_area_memberships_on_stop_area_id"
  add_index "stop_area_memberships", ["stop_id"], :name => "index_stop_area_memberships_on_stop_id"

  create_table "stop_area_types", :force => true do |t|
    t.string   "code"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stop_areas", :force => true do |t|
    t.string   "code"
    t.text     "name"
    t.string   "administrative_area_code"
    t.string   "area_type"
    t.string   "grid_type"
    t.float    "easting"
    t.float    "northing"
    t.datetime "creation_datetime"
    t.datetime "modification_datetime"
    t.integer  "revision_number"
    t.string   "modification"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.point    "coords",                   :srid => 27700
    t.float    "lon"
    t.float    "lat"
    t.integer  "locality_id"
    t.boolean  "loaded"
  end

  add_index "stop_areas", ["coords"], :name => "index_stop_areas_on_coords", :spatial => true
  add_index "stop_areas", ["locality_id"], :name => "index_stop_areas_on_locality_id"

  create_table "stop_types", :force => true do |t|
    t.string   "code"
    t.string   "description"
    t.boolean  "on_street"
    t.string   "point_type"
    t.float    "version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sub_type"
  end

  create_table "stops", :force => true do |t|
    t.string   "atco_code"
    t.string   "naptan_code"
    t.string   "plate_code"
    t.text     "common_name"
    t.text     "short_common_name"
    t.text     "landmark"
    t.text     "street"
    t.text     "crossing"
    t.text     "indicator"
    t.string   "bearing"
    t.string   "town"
    t.string   "suburb"
    t.boolean  "locality_centre"
    t.string   "grid_type"
    t.float    "easting"
    t.float    "northing"
    t.float    "lon"
    t.float    "lat"
    t.string   "stop_type"
    t.string   "bus_stop_type"
    t.string   "administrative_area_code"
    t.datetime "creation_datetime"
    t.datetime "modification_datetime"
    t.integer  "revision_number"
    t.string   "modification"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.point    "coords",                   :srid => 27700
    t.integer  "locality_id"
    t.string   "cached_slug"
    t.boolean  "loaded"
  end

  add_index "stops", ["cached_slug"], :name => "index_stops_on_cached_slug"
  add_index "stops", ["coords"], :name => "index_stops_on_coords", :spatial => true
  add_index "stops", ["locality_id", "stop_type"], :name => "index_stops_on_locality_and_stop_type"
  add_index "stops", ["locality_id"], :name => "index_stops_on_locality_id"
  add_index "stops", ["naptan_code"], :name => "index_stops_on_naptan_code"
  add_index "stops", ["stop_type"], :name => "index_stops_on_stop_type"

  create_table "stories", :force => true do |t|
    t.text     "title"
    t.text     "story"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reporter_id"
    t.integer  "stop_area_id"
    t.integer  "location_id"
    t.string   "location_type"
    t.integer  "transport_mode_id"
    t.boolean  "confirmed",         :default => false
    t.text     "token"
    t.string   "category"
  end

  create_table "transport_mode_stop_area_types", :force => true do |t|
    t.integer  "transport_mode_id"
    t.integer  "stop_area_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transport_mode_stop_types", :force => true do |t|
    t.integer  "transport_mode_id"
    t.integer  "stop_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transport_modes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "naptan_name"
    t.boolean  "active"
    t.string   "route_type"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "wants_fmt_updates"
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  add_foreign_key "route_operators", "operators", :name => "route_operators_operator_id_fk", :dependent => :nullify
  add_foreign_key "route_operators", "routes", :name => "route_operators_route_id_fk", :dependent => :nullify

  add_foreign_key "route_stops", "routes", :name => "route_stops_route_id_fk"
  add_foreign_key "route_stops", "stops", :name => "route_stops_stop_id_fk"

  add_foreign_key "routes", "transport_modes", :name => "routes_transport_mode_id_fk", :dependent => :nullify

  add_foreign_key "stop_area_memberships", "stop_areas", :name => "stop_area_memberships_stop_area_id_fk"
  add_foreign_key "stop_area_memberships", "stops", :name => "stop_area_memberships_stop_id_fk"

  add_foreign_key "stories", "users", :name => "problems_reporter_id_fk", :column => "reporter_id", :dependent => :nullify

  add_foreign_key "transport_mode_stop_area_types", "transport_modes", :name => "transport_mode_stop_area_types_transport_mode_id_fk"

  add_foreign_key "transport_mode_stop_types", "stop_types", :name => "transport_mode_stop_types_stop_type_id_fk", :dependent => :nullify
  add_foreign_key "transport_mode_stop_types", "transport_modes", :name => "transport_mode_stop_types_transport_mode_id_fk", :dependent => :nullify

end
