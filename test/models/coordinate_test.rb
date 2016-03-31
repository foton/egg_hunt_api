  require 'test_helper'

class CoordinateTest < ActiveSupport::TestCase

  test "can convert coordinate string into coordinate object" do
    tl="56.0N,3.0W"

    tl_crd=Coordinate.new(tl)

    assert_equal 56.0, tl_crd.latitude_number
    assert_equal 3.0, tl_crd.longitude_number
    assert_equal "N", tl_crd.latitude_hemisphere
    assert_equal "W", tl_crd.longitude_hemisphere

  end 

  test "return string representation" do
    tl="56.0N, 3.0W"
    assert_equal tl, Coordinate.new(tl).to_s
    assert_equal tl, Coordinate.new(tl.gsub(" ","")).to_s
  end  
end
