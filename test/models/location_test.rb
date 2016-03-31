require 'test_helper'

class LocationTest < ActiveSupport::TestCase

  def setup
    @location=Location.new(name: "Tararinga Patamu", city: nil, description: "Bus stop in jungle", user: users(:bunny1))
    @location.top_left_coordinate_str="10.5N, 0.07W"
    @location.bottom_right_coordinate_str="10.49N, 0.06W"
    assert @location.valid?, "@location is not valid! errors: #{@location.errors.full_messages}"
  end  

  test "can find borders within same quadrant" do
    tl="56.0N,3.0W"
    br="53.0N,1.0W"
    
    borders=Location.get_border_params(tl,br)
    
    assert_equal 1, borders.size
    assert_equal 56.0, borders.first[:max_latitude]
    assert_equal 53.0, borders.first[:min_latitude]
    assert_equal 3.0, borders.first[:max_longitude]
    assert_equal 1.0, borders.first[:min_longitude]
    assert_equal "N", borders.first[:lat_hemisphere]
    assert_equal "W", borders.first[:long_hemisphere]
  end	

  test "can find borders within 2 quadrants around 0 meridian" do
    tl="56.0N,3.0W"
    br="53.0N,1.0E"
    
    borders=Location.get_border_params(tl,br)
    
    assert_equal 2, borders.size

    assert_equal 56.0, borders.first[:max_latitude]
    assert_equal 53.0, borders.first[:min_latitude]
    assert_equal 3.0, borders.first[:max_longitude]
    assert_equal 0.0, borders.first[:min_longitude]
    assert_equal "N", borders.first[:lat_hemisphere]
    assert_equal "W", borders.first[:long_hemisphere]

    assert_equal 56.0, borders.second[:max_latitude]
    assert_equal 53.0, borders.second[:min_latitude]
    assert_equal 1.0, borders.second[:max_longitude]
    assert_equal 0.0, borders.second[:min_longitude]
    assert_equal "N", borders.second[:lat_hemisphere]
    assert_equal "E", borders.second[:long_hemisphere]
  end	

  test "can find borders within 2 quadrants around 180 meridian" do
    tl="56.0N,170.0E"
    br="53.0N,175.0W"
    
    borders=Location.get_border_params(tl,br)
    
    assert_equal 2, borders.size

    assert_equal 56.0, borders.first[:max_latitude]
    assert_equal 53.0, borders.first[:min_latitude]
    assert_equal 180.0, borders.first[:max_longitude]
    assert_equal 170.0, borders.first[:min_longitude]
    assert_equal "N", borders.first[:lat_hemisphere]
    assert_equal "E", borders.first[:long_hemisphere]

    assert_equal 56.0, borders.second[:max_latitude]
    assert_equal 53.0, borders.second[:min_latitude]
    assert_equal 180.0, borders.second[:max_longitude]
    assert_equal 175.0, borders.second[:min_longitude]
    assert_equal "N", borders.second[:lat_hemisphere]
    assert_equal "W", borders.second[:long_hemisphere]
  end	

  test "can find borders within 2 quadrants around equator" do
    tl="56.0N,3.0W"
    br="53.0S,1.0W"
    
    borders=Location.get_border_params(tl,br)
    
    assert_equal 2, borders.size

    assert_equal 56.0, borders.first[:max_latitude]
    assert_equal 0.0, borders.first[:min_latitude]
    assert_equal 3.0, borders.first[:max_longitude]
    assert_equal 1.0, borders.first[:min_longitude]
    assert_equal "N", borders.first[:lat_hemisphere]
    assert_equal "W", borders.first[:long_hemisphere]

    assert_equal 53.0, borders.second[:max_latitude]
    assert_equal 0.0, borders.second[:min_latitude]
    assert_equal 3.0, borders.second[:max_longitude]
    assert_equal 1.0, borders.second[:min_longitude]
    assert_equal "S", borders.second[:lat_hemisphere]
    assert_equal "W", borders.second[:long_hemisphere]
  end	

  test "can find borders within 4 quadrants around equator and 0 meridian" do
    tl="56.0N,3.0W"
    br="53.0S,1.0E"
    
    borders=Location.get_border_params(tl,br)
    
    assert_equal 4, borders.size

    assert_equal 56.0, borders.first[:max_latitude]
    assert_equal 0.0, borders.first[:min_latitude]
    assert_equal 3.0, borders.first[:max_longitude]
    assert_equal 0.0, borders.first[:min_longitude]
    assert_equal "N", borders.first[:lat_hemisphere]
    assert_equal "W", borders.first[:long_hemisphere]
   
    assert_equal 56.0, borders[1][:max_latitude]
    assert_equal 0.0, borders[1][:min_latitude]
    assert_equal 1.0, borders[1][:max_longitude]
    assert_equal 0.0, borders[1][:min_longitude]
    assert_equal "N", borders[1][:lat_hemisphere]
    assert_equal "E", borders[1][:long_hemisphere]

    assert_equal 53.0, borders[2][:max_latitude]
    assert_equal 0.0, borders[2][:min_latitude]
    assert_equal 3.0, borders[2][:max_longitude]
    assert_equal 0.0, borders[2][:min_longitude]
    assert_equal "S", borders[2][:lat_hemisphere]
    assert_equal "W", borders[2][:long_hemisphere]

    assert_equal 53.0, borders[3][:max_latitude]
    assert_equal 0.0, borders[3][:min_latitude]
    assert_equal 1.0, borders[3][:max_longitude]
    assert_equal 0.0, borders[3][:min_longitude]
    assert_equal "S", borders[3][:lat_hemisphere]
    assert_equal "E", borders[3][:long_hemisphere]
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
end
