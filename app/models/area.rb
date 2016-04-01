class Area
  attr_accessor :tl_crd, :br_crd  #top_left coordinate, bottom_right coordinate

  QUADRANT_KEYS=["NE","NW","SE","SW"]

  def initialize(tl_crd, br_crd, quadrant=nil)
    @tl_crd=(tl_crd.kind_of?(Coordinate) ? tl_crd : Coordinate.new(tl_crd))
    @br_crd=(br_crd.kind_of?(Coordinate) ? br_crd : Coordinate.new(br_crd))
    @quadrant=quadrant
  end  

  def quadrant
    return @quadrant if @quadrant.present?
    if @tl_crd.long_hem == @br_crd.long_hem && @tl_crd.lat_hem == @br_crd.lat_hem
      @quadrant="#{@tl_crd.lat_hem}#{@tl_crd.long_hem}".upcase
    else
      nil
    end  
  end  

  def do_overlap_with?(area2)
    #if we have areas from same quadrant
    if self.quadrant.present? && self.quadrant == area2.quadrant
       #solution from http://www.geeksforgeeks.org/find-two-rectangles-overlap/
       #Following is a simpler approach. Two rectangles do not overlap if one of the following conditions is true.
       #1) One rectangle is above top edge of other rectangle.  (tl1.y < br2.y || tl2.y < br1.y) 
       #2) One rectangle is on left side of left edge of other rectangle. (tl1.x > br2.x || tl2.x > br1.x) 
     
       do_overlap_after_calculation?(area2)
       

    else #split and do again  
      a1_qdrnts=quadrant_areas
      a2_qdrnts=area2.quadrant_areas
      
      QUADRANT_KEYS.each do |key|
        next if a1_qdrnts[key].blank? || a2_qdrnts[key].blank?
        return true if a1_qdrnts[key].do_overlap_with?(a2_qdrnts[key])
      end    
      return false #no overlapping found
    end 
  end  

  #return all location which are (even partially) covered by area
  def locations
    unless defined?(@locations)
      @locations=[]
      for loc in Location.order("id ASC").includes(:bottom_right_coordinate, :top_left_coordinate)
        @locations << loc if do_overlap_with?(loc.area)
      end  
    end  
    @locations
  end  
  
  def quadrant_areas
    unless defined?(@quadrant_areas)
      @quadrant_areas  ={}
      split_into_quadrants.each do |a|
        @quadrant_areas[a.quadrant]=a
      end  
    end
    @quadrant_areas  
  end  

  protected
    #to be able call this method as ar.split_by_longitude it must not be private
    def split_by_longitude
      #two quadrants (W != E)
      
      if tl_crd.long_hem == 'W' 
        #going over 0 meridian W => E
        split_long_num=0.0
      else  
        #going over 180 meridian E => W
        split_long_num=180.0
      end 
      split_by_longitude_number(split_long_num)
    end

    def transform_to_ne
      return nil if quadrant.empty?
      return self if quadrant == "NE"
      
      crd_tl=tl_crd.dup  
      crd_br=br_crd.dup
      case quadrant 
        when "NW"
          crd_tl.longitude_number=br_crd.longitude_number
          crd_br.longitude_number=tl_crd.longitude_number
        when "SE"
          crd_tl.latitude_number=br_crd.latitude_number  
          crd_br.latitude_number=tl_crd.latitude_number  
        when "SW"  
          crd_tl=br_crd.dup
          crd_br=tl_crd.dup
      end  
      
      Area.new(crd_tl,crd_br)
    end  

  private 

    def split_into_quadrants
        areas=[]
        if tl_crd.lat_hem == br_crd.lat_hem
          if tl_crd.long_hem == br_crd.long_hem             #one quadrant
            areas << self
          else                                              #two quadrants (W != E)
            areas+= split_by_longitude
          end 
        else
          if tl_crd.long_hem == br_crd.long_hem             #two quadrants (N != S)
            areas+= split_by_latitude
          else                                              #four quadrants (N != S , W != E) => double split
            split_by_latitude.each do |ar|
              areas+= ar.split_by_longitude
            end 
          end 
        end 
        areas
    end

    def  do_overlap_after_calculation?(area2)
       #solution from http://www.geeksforgeeks.org/find-two-rectangles-overlap/
       #Following is a simpler approach. Two rectangles do not overlap if one of the following conditions is true.
       #1) One rectangle is above top edge of other rectangle.  (tl1.y < br2.y || tl2.y < br1.y) 
       #2) One rectangle is on left side of left edge of other rectangle. (tl1.x > br2.x || tl2.x > br1.x) 

       #we need to transform quadrants NW, SW, SE to NE fo calculations (so bigger number is UP and LEFT; and we have right TL and BR)
       a1=transform_to_ne
       a2=area2.transform_to_ne

       return false if a1.tl_crd.long_num > a2.br_crd.long_num || a2.tl_crd.long_num > a1.br_crd.long_num
       return false if a1.tl_crd.lat_num < a2.br_crd.lat_num || a2.tl_crd.lat_num < a1.br_crd.lat_num
       return true
    end   




    def split_by_longitude_number(split_long_num)  
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

      [Area.new(tl_crd1,br_crd1),Area.new(tl_crd2, br_crd2)]
    end

    def split_by_latitude
      if tl_crd.lat_hem == 'N' 
        #going over equator N => S
        split_lat_num=0.0
      else  
        #going over pole (S => N)? CANNOT!  #we can try to switch corners, but leaving it to upper method/client
        #in reallity this cannon be done, the area rectangle will not overlap pole, but will be just shorter "above pole"
        raise "Coordinates are not correcty alligned: TOP_LEFT hemisphere is '#{tl_crd.lat_hem}' and BOTTOM_RIGHT hemisphere is '#{br_crd.lat_hem}'. Coordinates: TL:#{tl_crd},  BR:{#{br_crd}}"
      end 

      split_by_latitude_number(split_lat_num)
    end 

    def split_by_latitude_number(split_lat_num)
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

      [Area.new(tl_crd1,br_crd1),Area.new(tl_crd2, br_crd2)]
    end  
end
