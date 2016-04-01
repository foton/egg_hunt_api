require_relative 'api_controller_test'

class Api::V1::LocationsControllerTest < Api::V1::ApiControllerTest

  def setup
    
  end


  test "should find location which are overlaped by area (by TR and BL corners)" do
    #area overlaping BottomLeft of Olomouc and TopRight of Prostejov
    
    #set_current_user(users(:admin))
    get :index, {area_tl: "49.5845683N,17.1188586E", area_br: "49.4648939N,17.2664875E", format: api_format}

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 2, assigns(:locations).size
    assert_equal [locations(:olomouc), locations(:prostejov)], assigns(:locations)
  end 

  test "should return nothing if area do not overlap any location" do
    #area covers city of Praha
    get :index, {area_tl: "50.1611800N,14.2740864E", area_br: "49.9601708N,14.6064228E", format: api_format}

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 0, assigns(:locations).size
    assert_equal [], assigns(:locations)
  end 

end
