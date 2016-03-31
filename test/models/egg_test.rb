require 'test_helper'

class EggTest < ActiveSupport::TestCase

    def setup
      @egg=eggs(:bricked)
      assert @egg.valid?
    end  

    test "size is required" do 
      @egg.size=nil
      refute @egg.valid?
      assert @egg.errors[:size].present?
    end

    test "size must be from defined values" do 
      Egg::SIZES.each do |size|
        @egg.size=size[:value]

        assert @egg.valid?
      end

      [Egg::SIZES.first[:value]-1, Egg::SIZES.last[:value]+1].each do |size|
        @egg.size=size

        refute @egg.valid?
        assert @egg.errors[:size].present?
      end  
    end

    test "show desc of size with egg.size_to_s" do
      @egg.size=1
      assert_equal "ant", @egg.size_to_s 

      @egg.size=2
      assert_equal "pigeon", @egg.size_to_s 

      @egg.size=3
      assert_equal "chicken", @egg.size_to_s 

      @egg.size=4
      assert_equal "goose", @egg.size_to_s 

      @egg.size=5
      assert_equal "ostrich", @egg.size_to_s 

      @egg.size=6
      assert_equal "dragon", @egg.size_to_s 
    end  

    test "name is required, must be 3-250 nonwhitespace chars long" do
      @egg.name=nil
      refute @egg.valid?

      @egg.name=""
      refute @egg.valid?

      @egg.name="       "
      refute @egg.valid?

      @egg.name="  A     "
      refute @egg.valid?

      @egg.name="  AA     "
      refute @egg.valid?

      @egg.name="  A A     "
      assert @egg.valid?

      @egg.name="ABC"
      assert @egg.valid?

      @egg.name=("A"*250)
      assert @egg.valid?

      @egg.name=("A"*251)
      refute @egg.valid?
    end  

    test "name is striped on assignment" do
      @egg.name="  A A     "
      assert_equal "A A", @egg.name
      @egg.save!
      @egg.reload
      assert_equal "A A", @egg.name
    end

    test "existing location is required" do 
      @egg.location_id=nil 
      refute @egg.valid?

      @egg.location_id=Location.last.id+1
      refute @egg.valid?
    end

    test "existing user is required" do 
      @egg.user_id=nil 
      refute @egg.valid?

      @egg.user_id=User.last.id+1
      refute @egg.valid?
    end
end
