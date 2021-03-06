# == Schema Information
# Schema version: 20100707152350
#
# Table name: alternative_names
#
#  id                    :integer         not null, primary key
#  name                  :text
#  locality_id           :integer
#  short_name            :text
#  qualifier_name        :text
#  qualifier_locality    :text
#  qualifier_district    :text
#  creation_datetime     :datetime
#  modification_datetime :datetime
#  revision_number       :string(255)
#  modification          :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#

require 'spec_helper'

describe AlternativeName do
  before(:each) do
    @valid_attributes = {
      :alternative_locality_id => 2,
      :locality_id => 1,
      :creation_datetime => Time.now,
      :modification_datetime => Time.now,
      :revision_number => "value for revision_number",
      :modification => "value for modification"
    }
  end

  it "should create a new instance given valid attributes" do
    AlternativeName.create!(@valid_attributes)
  end
end
