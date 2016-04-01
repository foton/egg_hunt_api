class Coordinate < ActiveRecord::Base
  has_many :locations, dependent: :destroy

  COORDINATES_REGEXP =/(\d*.\d*)([NSEW])\s*,\s*(\d*.\d*)([NSEW])/

  def initialize(*args)
    if args.first.kind_of?(String) && (p_match=args.first.upcase.match(COORDINATES_REGEXP))
      super({latitude_number: p_match[1].to_f, latitude_hemisphere: p_match[2], longitude_number: p_match[3].to_f, longitude_hemisphere: p_match[4]})
    else  
      super
    end
    raise "Wrong coordinate created #{args}: #{self.to_yaml}" if self.latitude_number.blank? || self.latitude_hemisphere.blank? || self.longitude_number.blank? || self.longitude_hemisphere.blank? 
  end  

  def to_s
    "#{lat_num}#{lat_hem}, #{long_num}#{long_hem}"
  end  

  def long_num
    longitude_number  
  end  

  def lat_num
    latitude_number
  end  

  def long_hem
    longitude_hemisphere.to_s.upcase
  end  

  def lat_hem
    latitude_hemisphere.to_s.upcase
  end  
end
