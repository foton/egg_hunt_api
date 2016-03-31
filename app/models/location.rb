class Location < ActiveRecord::Base
	belongs_to :user
	belongs_to :top_left_coordinate, class_name: "Coordinate"
	belongs_to :bottom_right_coordinate, class_name: "Coordinate"

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

	def self.get_border_params(tl,br)
		borders=[]
		tl_crd=Coordinate.new(tl)
		br_crd=Coordinate.new(br)
	  self.split_area(tl_crd,br_crd).each do |area|
	  	borders << self.border_for(area[:tl_crd],area[:br_crd])
	  end	
    borders
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

	  def self.border_for(tl_crd,br_crd)
	  	{ 
	  		max_latitude: [tl_crd.lat_num,br_crd.lat_num].max, 
        min_latitude: [tl_crd.lat_num,br_crd.lat_num].min,
        max_longitude: [tl_crd.long_num,br_crd.long_num].max,
        min_longitude: [tl_crd.long_num,br_crd.long_num].min,
        lat_hemisphere: tl_crd.lat_hem, 
        long_hemisphere: tl_crd.long_hem
      }
	  end	

	  def self.split_area(tl_crd,br_crd)
	  	areas=[]
	  	if tl_crd.lat_hem == br_crd.lat_hem
				if tl_crd.long_hem == br_crd.long_hem             #one quadrant
					areas << {tl_crd: tl_crd, br_crd: br_crd}
				else                                              #two quadrants (W != E)
          areas+= self.split_by_longitude( tl_crd,br_crd)
				end	
			else
	  		if tl_crd.long_hem == br_crd.long_hem	    		    #two quadrants (N != S)
          areas+= self.split_by_latitude( tl_crd,br_crd)
			  else                                              #four quadrants (N != S , W != E) => double split
					self.split_by_latitude(tl_crd,br_crd).each do |ar|
           areas+= self.split_by_longitude(ar[:tl_crd], ar[:br_crd])			
          end 
				end	
			end	
			areas
	  end	

	  def self.split_by_longitude(tl_crd, br_crd)
    	#two quadrants (W != E)
      
			if tl_crd.long_hem == 'W' 
				#going over 0 meridian W => E
				split_long_num=0.0
			else	
				#going over 180 meridian E => W
				split_long_num=180.0
			end	
      self.split_by_longitude_number(split_long_num, tl_crd, br_crd)
    end

    def self.split_by_longitude_number(split_long_num, tl_crd, br_crd)  
		  tl_crd1=tl_crd
		  br_crd1=Coordinate.new({
					latitude_number: br_crd.lat_num, 
					latitude_hemisphere: br_crd.lat_hem, 
					longitude_number: split_long_num, 
					longitude_hemisphere: tl_crd.long_hem
				})
			
			tl_crd2=Coordinate.new({
					latitude_number: tl_crd.lat_num, 
					latitude_hemisphere: tl_crd.lat_hem, 
					longitude_number: split_long_num, 
					longitude_hemisphere: br_crd.long_hem
				})
		  br_crd2=br_crd	

		  [{tl_crd: tl_crd1, br_crd: br_crd1},{tl_crd: tl_crd2, br_crd: br_crd2}]
    end

    def self.split_by_latitude(tl_crd, br_crd) 	  
			if tl_crd.lat_hem == 'N' 
				#going over equator N => S
				split_lat_num=0.0
			else	
				#going over pole (S => N)? CANNOT!  #we can try to switch corners, but leaving it to upper method/client
				#in reallity this cannon be done, the area rectangle will not overlap pole, but will be just shorter "above pole"
				raise "Coordinates are not correcty alligned: TOP_LEFT hemisphere is '#{tl_crd.lat_hem}' and BOTTOM_RIGHT hemisphere is '#{br_crd.lat_hem}'. Coordinates: TL:#{tl_crd},  BR:{#{br_crd}}"
			end	

      self.split_by_latitude_number(split_lat_num, tl_crd,br_crd)
    end	

 	  def self.split_by_latitude_number(split_lat_num, tl_crd, br_crd)
		  tl_crd1=tl_crd
			br_crd1=Coordinate.new({
					latitude_number: split_lat_num, 
					latitude_hemisphere: tl_crd.lat_hem, 
					longitude_number: br_crd.long_num, 
					longitude_hemisphere: br_crd.long_hem
				})
			
			tl_crd2=Coordinate.new({
					latitude_number: split_lat_num, 
					latitude_hemisphere: br_crd.lat_hem, 
					longitude_number: tl_crd.long_num, 
					longitude_hemisphere: tl_crd.long_hem
				})
		  br_crd2=br_crd	

		  [{tl_crd: tl_crd1, br_crd: br_crd1},{tl_crd: tl_crd2, br_crd: br_crd2}]
    end

end
