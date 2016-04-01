class Location < ActiveRecord::Base
	belongs_to :user
	belongs_to :top_left_coordinate, class_name: "Coordinate"
	belongs_to :bottom_right_coordinate, class_name: "Coordinate"
  has_many :eggs, dependent: :destroy, inverse_of: :location

  validates :name, presence: true
  validates :top_left_coordinate, presence: true
  validates :bottom_right_coordinate, presence: true
  validates :user, presence: true , on: :create
  validates :user, presence:  {:if => proc{|o| o.user_id.present? }},  on: :update


  def self.authorized_attributes_for(user)
  	attrs=[]
    if user.present?
    	attrs=[:name, :city, :description, :top_left_coordinate, :bottom_right_coordinate, :top_left_coordinate_str, :bottom_right_coordinate_str]
      attrs << :user_id if user.admin?
    end
    attrs  
  end	


  def area
    @area||=Area.new(self.top_left_coordinate, self.bottom_right_coordinate)
  end  

	def top_left_coordinate_str=(str)
     @top_left_coordinate_str=str
     self.top_left_coordinate = Coordinate.new(str)
	end	

	def top_left_coordinate_str
     @top_left_coordinate_str || self.top_left_coordinate.to_s
	end	

	def bottom_right_coordinate_str=(str)
     @bottom_right_coordinate_str=str
     self.bottom_right_coordinate = Coordinate.new(str)
	end	

	def bottom_right_coordinate_str
     @bottom_right_coordinate_str || self.bottom_right_coordinate.to_s
	end	

	private


end
