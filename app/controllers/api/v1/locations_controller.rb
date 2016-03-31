class Api::V1::LocationsController < Api::V1::ApiController
  
  def index
    load_locations
    respond_with(@locations)
  end
  
  def show
    load_location
    respond_with(@location)
  end

  def create
    build_location
    save_location
  end

  def update
    load_location
    build_location
    save_location
  end

  def destroy
    load_location
    @location.destroy
    respond_with(@location)
  end

  private

    def authorized_actions_for(user=nil)
      if user.blank?
        [:index, :show] #guest
      else
        [:index, :show, :create, :update, :destroy] #user and admin
      end  
    end  

    def load_locations
      unless defined?(@locations)
        @locations=location_scope
        sort_locations
        filter_locations
        limit_locations
        restrict_fields
      end  
      @locations
    end

    def load_location
      @location ||= location_scope.find(params[:id])
    end

    def build_location
      @location ||= location_scope.build
      @location.attributes = location_params
      @location.user=current_user if @location.user.blank?
    end

    #TODO: rewrite with block?
    def save_location
      new_r = @location.new_record?
      headers ={}
      if @location.save
        headers= ( new_r ? {status: :created, location: api_v1_location_url(:id => @location.id) } : {status: :ok} )
      end   
      respond_with(@location, headers)
    end

    def location_params
      params[:location] ? params[:location].permit(Location.authorized_attributes_for(current_user)) : {}
    end

    def location_scope
      Location.all
    end

    #set sorting according to param "sort=-name,+city" , "sort=+name", "sort=name"
    def sort_locations
      if params[:sort].present?
        params[:sort].split(",").each {|sort_according_to| add_sorting_for(sort_according_to)}
      end  
    end  

    def add_sorting_for(sort_according_to) 
      arr_sort=sort_according_to.split("")
      if arr_sort.first=="-"
        @locations=@locations.order(" #{arr_sort[1..-1].join("")} DESC")
      elsif arr_sort.first=="+"  
        @locations=@locations.order(" #{arr_sort[1..-1].join("")} ASC")
      else
        @locations=@locations.order(" #{sort_according_to} ASC")
      end  
    end

    #filtering selected locations accordind to attributes values
    #eg. "/locations?city=london&name=Eye"
    def filter_locations
      allowed_keys=["name", "city", "user_id", "area_tl", "area_br"]
      filtering_keys=allowed_keys & params.keys
      filtering_keys.each {|key| filter_by_key(key)}
    end

    def filter_by_key(key)
      case key.to_s
      when "name" 
        @locations=@locations.where("name LIKE  ?","#{params[key]}%")
      when "city" 
        @locations=@locations.where("city LIKE ?","#{params[key]}%")
      when "decription" 
        @locations=@locations.where("description LIKE ?","%#{params[key]}%")
      when "user_id" 
        @locations=@locations.where(user_id: params[key])
      when "area_tl" #just once  #,"area_br"
        filter_by_area
      end  
    end  
    
    #restrict returned locations according to "limit=5" and "offset=100"
    #no default pagination implemented
    def limit_locations
      @locations=@locations.offset(params[:offset]) if params[:offset].present?
      @locations=@locations.limit(params[:limit]) if params[:limit].present?
    end  
 
    #restrict returned attributes according to "fields=name,description"
    def restrict_fields

      allowed_fields=Location.new.attributes.keys
      @fields=allowed_fields & (params[:fields] || "").split(",")
      if @fields.present?
        @locations=@locations.select(@fields) 
      else
        @fields=allowed_fields
      end  
    end  
    
    #get all known coordinates which are in this area and scope locations to ones which use them
    def filter_by_area
      border_params=Location.get_border_params(params[:area_tl],params[:area_br])
      #hairy but fast solution 
      #TODO: rewrite using AREL
      locs_ids=[]
      coord_ids=[]
      crd_table=Coordinate.arel_table

      border_params.each do |bp|
        ar_lat=crd_table[:latitude_number].gteq(bp[:min_latitude]).and(crd_table[:latitude_number].lteq(bp[:max_latitude])).and(crd_table[:latitude_hemisphere].eq(bp[:lat_hemisphere]))
        ar_long=crd_table[:longitude_number].gteq(bp[:min_longitude]).and(crd_table[:longitude_number].lteq(bp[:max_longitude])).and(crd_table[:longitude_hemisphere].eq(bp[:long_hemisphere]))
        coord_ids+=Coordinate.where(ar_lat.and(ar_long)).pluck(:id)
      end
      coord_ids.uniq!

      @locations=@locations.where(Location.where(top_left_coordinate_id: coord_ids, bottom_right_coordinate_id: coord_ids).where_values.inject(:or))
    end
end

