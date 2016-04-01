require 'test_helper'

class LocationTest < ActiveSupport::TestCase

  def setup
    @location=Location.new(name: "Tararinga Patamu", city: nil, description: "Bus stop in jungle", user: users(:bunny1))
    @location.top_left_coordinate_str="10.5N, 0.07W"
    @location.bottom_right_coordinate_str="10.49N, 0.06W"
    assert @location.valid?, "@location is not valid! errors: #{@location.errors.full_messages}"
  end  

  test "require name" do
    @location.name=nil
    refute @location.valid?
    assert @location.errors[:name].present?

    @location.name=""
    refute @location.valid?
    assert @location.errors[:name].present?
  end

  test "require top_left_coordinate" do
    @location.top_left_coordinate=nil
    refute @location.valid?
    assert @location.errors[:top_left_coordinate].present?
  end

  test "require bottom_right_coordinate" do
    @location.bottom_right_coordinate=nil
    refute @location.valid?
    assert @location.errors[:bottom_right_coordinate].present?
  end

  test "require user on create" do
    @location.user=nil
    assert @location.new_record?
    refute @location.valid?
    assert @location.errors[:user].present?, "@location with user_id=nil have no errors on user_id! errors: #{@location.errors.full_messages}"
  end

  test "require existing user if present" do
    assert User.find_by_id(1).blank?
    @location.user_id=1
    refute @location.valid?
    assert @location.errors[:user].present?
  end

  test "do not require user on update" do
    @location.save!
    @location.user=nil
    assert @location.valid?, "@location with user_id=nil is not valid! errors: #{@location.errors.full_messages}"
  end
  
  test "allow city" do
    @location.city=nil
    assert @location.valid?

    @location.city=""
    assert @location.valid?

    @location.city="Megacity One"
    assert @location.valid?
  end  

  test "allow description" do
    @location.description=nil
    assert @location.valid?

    @location.description=""
    assert @location.valid?

    @location.description="Megacity One is hell"
    assert @location.valid?
  end  

  test "converts coordinate string into coordinate object" do
    @location.top_left_coordinate_str="11.5N, 0.08W"
    @location.bottom_right_coordinate_str="11.49S, 0.07E"
    
    tl_crd=@location.top_left_coordinate
    br_crd=@location.bottom_right_coordinate

    assert_equal 11.5.to_s, tl_crd.latitude_number.to_s
    assert_equal 0.08.to_s, tl_crd.longitude_number.to_s
    assert_equal "N", tl_crd.latitude_hemisphere
    assert_equal "W", tl_crd.longitude_hemisphere

    assert_equal 11.49.to_s, br_crd.latitude_number.to_s
    assert_equal 0.07.to_s, br_crd.longitude_number.to_s
    assert_equal "S", br_crd.latitude_hemisphere
    assert_equal "E", br_crd.longitude_hemisphere
  end  

  test "can have eggs" do 
    assert_equal 2, locations(:olomouc).eggs.size
    assert_equal [eggs(:faberge1), eggs(:faberge2)], locations(:olomouc).eggs.to_a
  end

  test "eggs are destroyed on location.destroy" do 
    egg_ids=locations(:olomouc).eggs.pluck("id")
    assert 2, egg_ids

    locations(:olomouc).destroy

    assert Egg.where(id: egg_ids).empty?    
  end 

  test "can form it's area" do
    loc=Location.create!( name: "location_11_55_se", 
                          top_left_coordinate_str: "1.0S,1.0E",
                          bottom_right_coordinate_str: "5.0S,5.0E",
                          user: users(:admin) )
    
    assert loc.top_left_coordinate.kind_of?(Coordinate)
    assert loc.bottom_right_coordinate.kind_of?(Coordinate)

    area =loc.area

    assert_equal loc.top_left_coordinate, area.tl_crd
    assert_equal loc.bottom_right_coordinate, area.br_crd

    assert_equal "1.0S, 1.0E", area.tl_crd.to_s
    assert_equal "5.0S, 5.0E", area.br_crd.to_s
  end  
end
