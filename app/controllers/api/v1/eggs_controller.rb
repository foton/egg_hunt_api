class Api::V1::EggsController < Api::V1::ApiController
  
  def index
    load_eggs
    respond_with(@eggs)
  end
  
  def show
    load_egg
    respond_with(@egg)
  end

  def create
    build_egg
    save_egg
  end

  def update
    load_egg
    authorize_owner_of_egg
    build_egg
    save_egg
  end

  def destroy
    load_egg
    authorize_owner_of_egg
    @egg.destroy
    respond_with(@egg)
  end

  private

    def authorized_actions_for(user=nil)
      if user.blank?
        [:index, :show] #guest
      else
        [:index, :show, :create, :update, :destroy] #user and admin
      end  
    end  

    def authorize_owner_of_egg
      raise Exceptions::UserNotAuthorized unless (current_user.admin? || (current_user.id == @egg.user_id))
    end  

    def load_eggs
      unless defined?(@eggs)
        @eggs=egg_scope
        sort_eggs
        filter_eggs
        limit_eggs
        restrict_fields
      end  
      @eggs
    end

    def load_egg
      @egg ||= egg_scope.find(params[:id])
    end

    def build_egg
      @egg ||= egg_scope.build
      @egg.attributes = egg_params
      @egg.user=current_user if @egg.user.blank?
    end

    def save_egg
      new_r = @egg.new_record?
      headers ={}
      if @egg.save
        headers= ( new_r ? {status: :created, location: api_v1_egg_url(id: @egg.id, format: (params[:format] || :json) ) }  : {status: :ok} )
      end   
      respond_with(@egg, headers)
    end

    def egg_params
      params[:egg] ? params[:egg].permit(Egg.authorized_attributes_for(current_user)) : {}
    end

    def egg_scope
      Egg.all
    end

    #set sorting according to param "sort=-name,+city" , "sort=+name", "sort=name"
    def sort_eggs
      if params[:sort].present?
        params[:sort].split(",").each {|sort_according_to| add_sorting_for(sort_according_to)}
      end  
    end  

    def add_sorting_for(sort_according_to) 
      arr_sort=sort_according_to.split("")
      if arr_sort.first=="-"
        att=arr_sort[1..-1].join("")
        dir="DESC"
        @eggs=@eggs.order(" #{arr_sort[1..-1].join("")} DESC")
      elsif arr_sort.first=="+"  
        att=arr_sort[1..-1].join("")
        dir="ASC"
      else
        att=sort_according_to
        dir="ASC"
      end  

      if ["name", "size", "location_id", "user_id", "created_at", "updated_at"].include?(att)
        @eggs=@eggs.order("#{att} #{dir}") 
      end  
    end

    #filtering selected eggs accordind to attributes values
    #eg. "/eggs?city=london&name=Eye"
    def filter_eggs
      filter_nonequality_params
      allowed_keys=["name", "size", "location_id", "user_id", "area_tl"]
      filtering_keys=allowed_keys & params.keys
      filtering_keys.each {|key| filter_by_key(key)}
    end

    def filter_nonequality_params
      #params: {"created_at>2015-03-03T08:08:08Z"=>nil, .....}
      neqp=params.keys.select {|k| k.include?("<") || k.include?(">")}
      neqp.each do |pair|
        filter_comparsion_for(pair)
      end  
    end  

    def filter_comparsion_for(pair)
      allowed_keys=["created_at", "updated_at", "size"]
      if (m=pair.match(/(.*)([<>])(.*)/) )
        key,compar,value=m[1],m[2],m[3]
        if allowed_keys.include?(key)
          add_comparsion(key,compar,value)
        end  
      end  
    end  

    def add_comparsion(key,compar,value)
      egg_tbl=Egg.arel_table
      case compar.to_s
      when "<"
        @eggs=@eggs.where(egg_tbl[key.to_sym].lt(value))
      when ">"
        @eggs=@eggs.where(egg_tbl[key.to_sym].gt(value))
      end  
    end  

    def filter_by_key(key)
      case key.to_s
      when "name" 
        @eggs=@eggs.where("name LIKE  ?","#{params[key]}%")
      when "size" 
        @eggs=@eggs.where(size: params[key]) #TODO make it accept size=1,3,5
      when "location_id" 
        @eggs=@eggs.where(location_id: params[key])
      when "user_id" 
        @eggs=@eggs.where(user_id: params[key])
      when "created_at"  

      when "area_tl" #just once  #,"area_br"
        filter_by_area
      end  
    end  
    
    #restrict returned eggs according to "limit=5" and "offset=100"
    #no default pagination implemented
    def limit_eggs
      @eggs=@eggs.offset(params[:offset]) if params[:offset].present?
      @eggs=@eggs.limit(params[:limit]) if params[:limit].present?
    end  
 
    #restrict returned attributes according to "fields=name,description"
    def restrict_fields

      allowed_fields=Egg.new.attributes.keys
      @fields=allowed_fields & (params[:fields] || "").split(",")
      if @fields.present?
        @eggs=@eggs.select(@fields) 
      else
        @fields=allowed_fields
      end  
    end  
    
    #get all known coordinates which are in this area and scope eggs to ones which use them
    def filter_by_area
      loc_ids=Area.new(params[:area_tl],params[:area_br]).locations.collect {|loc| loc.id}
      @eggs=@eggs.where(location_id: loc_ids)
    end

    def check_eggs_of_other_users
      if @egg.eggs.present? && current_user && !current_user.admin?
        raise Exceptions::OtherUsersEggsExists.new if (@egg.eggs.where.not(user_id: current_user.id).exists?)
      end  
    end  
end


