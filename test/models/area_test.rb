require 'test_helper'

class AreaTest < ActiveSupport::TestCase

  test "do not split area if it is all in one quadrant" do
    area=Area.new(Coordinate.new("56.0N,3.0W"),Coordinate.new("53.0N,1.0W"))
    
    assert_equal area, area.quadrant_areas["NW"]
    assert_nil area.quadrant_areas["NE"]
    assert_nil area.quadrant_areas["SE"]
    assert_nil area.quadrant_areas["SW"]

    assert_equal 56.0, area.quadrant_areas["NW"].tl_crd.lat_num
    assert_equal 3.0, area.quadrant_areas["NW"].tl_crd.long_num
    assert_equal 53.0, area.quadrant_areas["NW"].br_crd.lat_num
    assert_equal 1.0, area.quadrant_areas["NW"].br_crd.long_num

  end 


  test "do split area if it is in 2 quadrants around 0 meridian" do
    area=Area.new(Coordinate.new("56.0N,3.0W"),Coordinate.new("53.0N,1.0E"))
    
    assert area.quadrant_areas["NW"].present?
    assert area.quadrant_areas["NE"].present?
    assert_nil area.quadrant_areas["SE"]
    assert_nil area.quadrant_areas["SW"]

    assert_equal 56.0, area.quadrant_areas["NW"].tl_crd.lat_num
    assert_equal 3.0, area.quadrant_areas["NW"].tl_crd.long_num
    assert_equal 53.0, area.quadrant_areas["NW"].br_crd.lat_num
    assert_equal 0.0, area.quadrant_areas["NW"].br_crd.long_num

    assert_equal 56.0, area.quadrant_areas["NE"].tl_crd.lat_num
    assert_equal 0.0, area.quadrant_areas["NE"].tl_crd.long_num
    assert_equal 53.0, area.quadrant_areas["NE"].br_crd.lat_num
    assert_equal 1.0, area.quadrant_areas["NE"].br_crd.long_num

  end 
  
  test "do split area if it is in 2 quadrants around 180 meridian" do
    area=Area.new(Coordinate.new("56.0N,170.0E"),Coordinate.new("53.0N,175.0W"))
    
    assert area.quadrant_areas["NW"].present?
    assert area.quadrant_areas["NE"].present?
    assert_nil area.quadrant_areas["SE"]
    assert_nil area.quadrant_areas["SW"]

    assert_equal 56.0, area.quadrant_areas["NW"].tl_crd.lat_num
    assert_equal 180.0, area.quadrant_areas["NW"].tl_crd.long_num
    assert_equal 53.0, area.quadrant_areas["NW"].br_crd.lat_num
    assert_equal 175.0, area.quadrant_areas["NW"].br_crd.long_num

    assert_equal 56.0, area.quadrant_areas["NE"].tl_crd.lat_num
    assert_equal 170.0, area.quadrant_areas["NE"].tl_crd.long_num
    assert_equal 53.0, area.quadrant_areas["NE"].br_crd.lat_num
    assert_equal 180.0, area.quadrant_areas["NE"].br_crd.long_num
  end 

  test "do split area if it is 2 quadrants around equator" do
    area=Area.new(Coordinate.new("56.0N,3.0W"),Coordinate.new("53.0S,1.0W"))
    
    assert area.quadrant_areas["NW"].present?
    assert_nil area.quadrant_areas["NE"]
    assert_nil area.quadrant_areas["SE"]
    assert area.quadrant_areas["SW"].present?

    assert_equal 56.0, area.quadrant_areas["NW"].tl_crd.lat_num
    assert_equal 3.0, area.quadrant_areas["NW"].tl_crd.long_num
    assert_equal 0.0, area.quadrant_areas["NW"].br_crd.lat_num
    assert_equal 1.0, area.quadrant_areas["NW"].br_crd.long_num

    assert_equal 0.0, area.quadrant_areas["SW"].tl_crd.lat_num
    assert_equal 3.0, area.quadrant_areas["SW"].tl_crd.long_num
    assert_equal 53.0, area.quadrant_areas["SW"].br_crd.lat_num
    assert_equal 1.0, area.quadrant_areas["SW"].br_crd.long_num
  end 

  test "do split area if it is in 4 quadrants around 0,0" do
    area=Area.new(Coordinate.new("56.0N,3.0W"),Coordinate.new("53.0S,1.0E"))
    
    assert area.quadrant_areas["NW"].present?
    assert area.quadrant_areas["NE"].present?
    assert area.quadrant_areas["SE"].present?
    assert area.quadrant_areas["SW"].present?

    assert_equal 56.0, area.quadrant_areas["NW"].tl_crd.lat_num
    assert_equal 3.0, area.quadrant_areas["NW"].tl_crd.long_num
    assert_equal 0.0, area.quadrant_areas["NW"].br_crd.lat_num
    assert_equal 0.0, area.quadrant_areas["NW"].br_crd.long_num

    assert_equal 56.0, area.quadrant_areas["NE"].tl_crd.lat_num
    assert_equal 0.0, area.quadrant_areas["NE"].tl_crd.long_num
    assert_equal 0.0, area.quadrant_areas["NE"].br_crd.lat_num
    assert_equal 1.0, area.quadrant_areas["NE"].br_crd.long_num

    assert_equal 0.0, area.quadrant_areas["SW"].tl_crd.lat_num
    assert_equal 3.0, area.quadrant_areas["SW"].tl_crd.long_num
    assert_equal 53.0, area.quadrant_areas["SW"].br_crd.lat_num
    assert_equal 0.0, area.quadrant_areas["SW"].br_crd.long_num

    assert_equal 0.0, area.quadrant_areas["SE"].tl_crd.lat_num
    assert_equal 0.0, area.quadrant_areas["SE"].tl_crd.long_num
    assert_equal 53.0, area.quadrant_areas["SE"].br_crd.lat_num
    assert_equal 1.0, area.quadrant_areas["SE"].br_crd.long_num
  end 
  
  test "do split area if it is in 4 quadrants around 0,180 " do
    area=Area.new(Coordinate.new("56.0N,170.0E"),Coordinate.new("53.0S,175.0W"))
    
    assert area.quadrant_areas["NW"].present?
    assert area.quadrant_areas["NE"].present?
    assert area.quadrant_areas["SE"].present?
    assert area.quadrant_areas["SW"].present?

    assert_equal 56.0, area.quadrant_areas["NW"].tl_crd.lat_num
    assert_equal 180.0, area.quadrant_areas["NW"].tl_crd.long_num
    assert_equal 0.0, area.quadrant_areas["NW"].br_crd.lat_num
    assert_equal 175.0, area.quadrant_areas["NW"].br_crd.long_num

    assert_equal 56.0, area.quadrant_areas["NE"].tl_crd.lat_num
    assert_equal 170.0, area.quadrant_areas["NE"].tl_crd.long_num
    assert_equal 0.0, area.quadrant_areas["NE"].br_crd.lat_num
    assert_equal 180.0, area.quadrant_areas["NE"].br_crd.long_num

    assert_equal 0.0, area.quadrant_areas["SW"].tl_crd.lat_num
    assert_equal 180.0, area.quadrant_areas["SW"].tl_crd.long_num
    assert_equal 53.0, area.quadrant_areas["SW"].br_crd.lat_num
    assert_equal 175.0, area.quadrant_areas["SW"].br_crd.long_num

    assert_equal 0.0, area.quadrant_areas["SE"].tl_crd.lat_num
    assert_equal 170.0, area.quadrant_areas["SE"].tl_crd.long_num
    assert_equal 53.0, area.quadrant_areas["SE"].br_crd.lat_num
    assert_equal 180.0, area.quadrant_areas["SE"].br_crd.long_num
  end 

  def area_11_55
    @area_11_55||=Area.new(Coordinate.new("1.0S,1.0E"),Coordinate.new("5.0S,5.0E"))
  end 

  test "can detect not overlaping areas" do
    area_66_99=Area.new(Coordinate.new("6.0S,6.0E"),Coordinate.new("9.0S,9.0E"))    
    refute area_11_55.do_overlap_with?(area_66_99)
  end  

  test "can detect overlapping TL-BR" do
    area_00_22=Area.new(Coordinate.new("0.0S,0.0E"),Coordinate.new("2.0S,2.0E"))    
    assert area_11_55.do_overlap_with?(area_00_22)
  end  

  test "can detect overlapping BR-TL" do
    area_44_66=Area.new(Coordinate.new("4.0S,4.0E"),Coordinate.new("6.0S,6.0E"))    
    assert area_11_55.do_overlap_with?(area_44_66)
  end  

  test "can detect overlapping TR-BL" do
    area_04_26=Area.new(Coordinate.new("0.0S,4.0E"),Coordinate.new("2.0S,6.0E"))    
    assert area_11_55.do_overlap_with?(area_04_26)
  end  

  test "can detect overlapping BL-TR" do
    area_40_62=Area.new(Coordinate.new("4.0S,0.0E"),Coordinate.new("6.0S,2.0E"))    
    assert area_11_55.do_overlap_with?(area_40_62)
  end  

  test "can detect overlapping top border (not hiting corners)" do
    area_02_24=Area.new(Coordinate.new("0.0S,2.0E"),Coordinate.new("2.0S,4.0E"))    
    assert area_11_55.do_overlap_with?(area_02_24)
  end  

  test "can detect overlapping bottom border (not hiting corners)" do
    area_42_64=Area.new(Coordinate.new("4.0S,2.0E"),Coordinate.new("6.0S,4.0E"))    
    assert area_11_55.do_overlap_with?(area_42_64)
  end  

  test "can detect overlapping rigth border (not hiting corners)" do
    area_23_46=Area.new(Coordinate.new("2.0S,3.0E"),Coordinate.new("4.0S,6.0E"))    
    assert area_11_55.do_overlap_with?(area_23_46)
  end  

  test "can detect overlapping left border (not hiting corners)" do
    area_20_33=Area.new(Coordinate.new("2.0S,0.0E"),Coordinate.new("3.0S,3.0E"))    
    assert area_11_55.do_overlap_with?(area_20_33)
  end  

  test "can detect area completely overlapping smaller one" do
    area_22_33=Area.new(Coordinate.new("2.0S,2.0E"),Coordinate.new("3.0S,3.0E"))    
    assert area_11_55.do_overlap_with?(area_22_33)
  end  
  
  test "can detect area completely overlapping greater one" do
    area_00_66=Area.new(Coordinate.new("0.0S,0.0E"),Coordinate.new("6.0S,6.0E"))    
    assert area_11_55.do_overlap_with?(area_00_66)
  end  
   


  def setup_location_11_55_se
    @loc_11_55_se||=Location.create!( name: "location_11_55_se", 
                                  top_left_coordinate_str: "1.0S,1.0E",
                                  bottom_right_coordinate_str: "5.0S,5.0E",
                                  user: users(:admin) )
  end  

  def setup_location_55_11_nw
    @loc_55_11_nw||=Location.create!( name: "location_55_11_nw", 
                                  top_left_coordinate_str: "5.0N,5.0W",
                                  bottom_right_coordinate_str: "1.0N,1.0W",
                                  user: users(:admin) )
  end  

  test "should return empy array if area do not cover any location" do
    setup_location_11_55_se
    setup_location_55_11_nw

    assert_equal [], Area.new("6.0S,6.0E","10.0S,10.0E").locations
  end  

  test "should return locations array if area do cover some locations" do
    setup_location_11_55_se
    setup_location_55_11_nw
    
    assert_equal [@loc_11_55_se], Area.new("4.0S,4.0E","10.0S,10.0E").locations
    assert_equal [@loc_11_55_se, @loc_55_11_nw], Area.new("4.0N,4.0W","4.0S,4.0E").locations
    assert_equal [@loc_11_55_se, @loc_55_11_nw], Area.new("4.0N,4.0W","10.0S,10.0E").locations
    assert_equal [@loc_11_55_se, @loc_55_11_nw], Area.new("10.0N,10.0W","10.0S,10.0E").locations
  end  

end

