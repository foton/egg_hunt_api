class Api::V1::ApiController < ApplicationController

	def get_coordinates_within(area_tl,area_br)
    border_params=Location.get_border_params(area_tl,area_br)
    #hairy solution 
    #TODO: rewrite using AREL
    coord_ids=[]
    crd_table=Coordinate.arel_table

    border_params.each do |bp|
      ar_lat=crd_table[:latitude_number].gteq(bp[:min_latitude]).and(crd_table[:latitude_number].lteq(bp[:max_latitude])).and(crd_table[:latitude_hemisphere].eq(bp[:lat_hemisphere]))
      ar_long=crd_table[:longitude_number].gteq(bp[:min_longitude]).and(crd_table[:longitude_number].lteq(bp[:max_longitude])).and(crd_table[:longitude_hemisphere].eq(bp[:long_hemisphere]))
      coord_ids+=Coordinate.where(ar_lat.and(ar_long)).pluck(:id)
    end
    coord_ids.uniq
  end   
end


