class Api::V1::BroadbandsController < Api::ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  skip_before_action :authenticate_with_token, only: [:index, :claim_organization, :search, :filter, :show, :types, :search_by_location, :search_all, :all_reviews]
  before_action :set_broadband, only: [:show, :update, :acquire, :review, :faqs]

  resource_description do
    short 'Broadbands endpoints'
    description 'Endpoints used for searching broadbands'
  end

  def_param_group :broadband_params do
    param :broadband, Hash, required: true do
      param :anchorname, String, 'Name of the anchor'
      param :address, String
      param :bldgnbr, String
      param :predir, String
      param :suffdir, String
      param :streetname, String
      param :streettype, String
      param :city, String
      param :state_code, String
      param :zip5, String
      param :latitude, BigDecimal
      param :longitude, BigDecimal
      param :publicwifi, String
      param :url, String
      param :opening_hours_attributes, Array, of: Hash do
        param :day, [1, 2, 3, 4, 5, 6, 7]
        param :from, String, desc: 'Time format: hh:MM:ss'
        param :to, String, desc: 'Time format: hh:MM:ss'
        param :closed, [true, false]
      end
      param :logo, Hash, required: false do
        param :data, String, desc: 'Image content as Base64 string'
        param :filename, String, desc: 'Name of the logo file'
      end
      param :banner, Hash, required: false do
        param :data, String, desc: 'Image content as Base64 string'
        param :filename, String, desc: 'Name of the banner file'
      end
    end
  end

  api! 'List broadbands'
  formats [:json]
  def index 
    if params[:broadband_type_id]
      @broadbands = Broadband.where(broadband_type_id: params[:broadband_type_id])
    else
      @broadbands = Broadband.all
    end
    if @broadbands.first
      render json: @broadbands
    else
      render json: @broadbands
    end

  end 

  api! 'Search broadbands'
  param :q, String, 'Query to search.', required: true
  formats [:json]
  def search
    q = params[:q]
    offset = params[:offset]
    length = params[:length]
    return render json: { error: 'No query was provided!' }, status: :unprocessable_entity if q.blank?
    hits = Broadband.search(q, offset, length)
    # render json: hits, each_serializer: SimpleBroadbandSerializer
    broadbands = []
    hits.each do |hit|
      br = Broadband.find(hit[:id])
      broadbands.push(br)
    end
    if broadbands.first
      render json: broadbands, each_serializer: BroadbandSerializer
    else
      render json: broadbands
    end
  end

  api! 'Sort by distance to a central location. Add the location to a custom HTTP header called "user_location". Location format: "{latitude},{longitude}".'
  param :types, String, 'organization types', required: false
  param :radius, Integer, 'Radius in Meters', required: false
  formats [:json]
  def search_by_location
    types = params[:types].split(",")
    return render json: [] if types.blank?
    location = request.headers['HTTP_USER_LOCATION']
    radius = params[:radius]
    hits = Broadband.search_by_location(location, radius, types, current_user)
    broadbands = []
    hits.each do |hit|
      br = Broadband.find(hit[:id])
      broadbands.push(br)
    end
    if broadbands.first
      render json: broadbands, each_serializer: BroadbandSerializer
    else
      render json: broadbands
    end
  end

  api! 'Filter broadband results by type'
  param :types, String, 'Organization types', required: true
  param :offset, Integer, 'Pagination Offset', default: 0
  param :length, Integer, 'Pagination Length (Limit)', default: 500
  param :radius, Integer, 'Radius in Meters', required: false
  formats [:json]
  def filter
    q = params[:q]
    types = params[:types].split(",")
    offset = params[:offset]
    length = params[:length]
    return render json: { message: 'Length greater than 1000 not allowed!' }, status: :unprocessable_entity if length.to_i > 1000
    radius = params[:radius]
    location = request.headers['HTTP_USER_LOCATION']
    return render json: [] if types.blank?
    hits = Broadband.filter(q, types, location, offset, length, radius, current_user)
    broadbands = []
    hits.each do |hit|
      br = Broadband.find(hit[:id])
      broadbands.push(br)
    end
    if broadbands.first
      render json: broadbands, each_serializer: BroadbandSerializer
    else
      render json: broadbands
    end
  end

  api! 'Search, filter, or search by location. To search by location add the location to a custom HTTP header called "user_location". Location format: "{latitude},{longitude}".'
  param :q, String, 'Search query', required: true
  param :types, String, 'Organization types', required: true
  param :offset, Integer, 'Pagination Offset', default: 0
  param :length, Integer, 'Pagination Length (Limit)', default: 500
  param :radius, Integer, 'Radius in Meters', required: false
  formats [:json]
  def search_all
    q = params[:q]
    types = params[:types]
    offset = params[:offset]
    length = params[:length]
    return render json: { message: 'Length greater than 1000 not allowed!' }, status: :unprocessable_entity if length.to_i > 1000
    radius = params[:radius]
    location = request.headers['HTTP_USER_LOCATION']
    hits = Broadband.search_all(q, types, location, offset, length, radius, current_user)
    if hits.first
      render json: hits
    else
      render json: hits
    end
  end

  api! 'Broadband details'
  param :id, Integer, 'Broadband id', required: true
  formats [:json]
  def show
    render json: @broadband.as_json(:methods => [:total_reviews, :review, :logo, :banner], :except => [:logo_file_name, :banner_file_name, :banner_content_type, :banner_file_size, :banner_updated_at, :logo_content_type, :logo_file_size, :logo_updated_at])
  end

  def logo
    @broadband.logo.url.gsub '//s3.amazonaws.com', 'https://s3.us-east-2.amazonaws.com' if @broadband.logo.exists?
  end
  
  def banner
    @broadband.banner.url.gsub '//s3.amazonaws.com', 'https://s3.us-east-2.amazonaws.com' if @broadband.banner.exists?
  end

  api! 'Create Broadband'
  param_group :broadband_params
  formats [:json]
  def create
    request_params = broadband_params
    request_params[:logo] = process_base64(broadband_params[:logo])
    request_params[:banner] = process_base64(broadband_params[:banner])
    @broadband = Broadband.new(request_params)
    res = false
    # Broadband.without_auto_index do
      res = @broadband.save!
    # end

    if res
      current_user.broadbands << @broadband
      render json: @broadband
    else
      render json: @broadband.errors, status: :unprocessable_entity
    end

  end

  api! 'Update Broadband'
  param :id, Integer, 'Broadband id', required: true
  param_group :broadband_params
  formats [:json]
  def update
    if current_user.can_edit_broadband(@broadband)
      request_params = broadband_params
      request_params[:logo] = process_base64(request_params[:logo]) if request_params.key?(:logo)
      request_params[:banner] = process_base64(request_params[:banner]) if request_params.key?(:banner)
      res = false
      # Broadband.without_auto_index do
        res = @broadband.update!(request_params)
      # end
      if res
        render json: @broadband
      else
        render json: @broadband.errors, status: :unprocessable_entity
      end
    else
      render json: '', status: :unauthorized
    end
  end

  api! 'Broadband Types'
  formats [:json]
  def types
    render json: BroadbandType.select(:id, :name)
  end

  def acquire
    if @broadband.present?
      current_user.broadbands << @broadband unless current_user.broadbands.include?(@broadband)
      return render json: { success: true }
    end
    render json: { error: 'Broadband not found!' }
  end

  def my_broadbands
    if current_user.broadbands.first
      render json: { my_broadbands: current_user.broadbands }
    else
      render json: current_user.broadbands
    end
  end


  def claim_organization
    user = User.where(email: params[:broadband][:email]).first
    if user.nil?
      user = User.new sign_up_params.except(:manager_name, :address, :broadband_type_id, :streetname, :city, :state_code, :zip5)
      user.save
    end
    broadbands = Broadband.where(user_id: user.id)
    if broadbands.empty?
      broadband = Broadband.new(anchorname: params[:broadband][:name], manager_name: params[:broadband][:manager_name],broadband_type_id: params[:broadband][:broadband_type],streetname: params[:broadband][:streetname],city: params[:broadband][:city],state_code: params[:broadband][:state_code],zip5: params[:broadband][:zip5],detail: params[:broadband][:detail])
      broadband.user_id = user.id
      broadband.save!
      render json: {
        broadband: broadband.as_json(:except => [:password]), 
        user: user.as_json
        # access_url: request.base_url+'/organizations/'+organization.id.to_s+'/activate'.as_json
      }, status: :ok
    else
      render json: { error: 'Email has already been taken' }
    end
  end

  def review
    @review = Review.new(rating: params[:rating], comment: params[:comment], user_id: current_user.id, broadband_id: @broadband.id)
    if @review.comment && @review.rating
      if @review.rating < 0 || @review.rating > 5
        render json: { error: 'Please provide correct rating to create review' }
      else
        @review.save
        render json: {
          review: @review.as_json
        }, status: :ok
      end
    else
      render json: { error: 'Please provide comment/rating to create review' }
    end
  end

  def all_reviews
    if current_user && params[:id]
      @reviews = Review.where(user_id: current_user.id, broadband_id: params[:id])
      @broadband = Broadband.find(params[:id])
    elsif current_user
      @reviews = Review.where(user_id: current_user.id)
      @b = []
      @reviews.each do |review|
        broadband = Broadband.find(review.broadband_id)
        h = Hash.new("banner" => (broadband.banner.url.gsub '//s3.amazonaws.com', 'https://s3.us-east-2.amazonaws.com' if broadband.banner.exists?), "title" => broadband.anchorname, "city" => broadband.city, "state_code" => broadband.state_code, "streetname" => broadband.streetname, "review" => review)
        @b.push(h[''])
      end
    else
      @reviews = Review.where(broadband_id: params[:id])
      @broadband = Broadband.find(params[:id])
    end

    if @reviews.first && @broadband
      render json: {
        reviews: @reviews.as_json
      }, status: :ok
    elsif @reviews.first
      render json: {
        my_reviews: @b.as_json
      }, status: :ok
    else
      render json: { error: 'No reviews found' }
    end
  end

  def faqs
    @faqs = Faq.where(broadband_id: @broadband.id)
    if @faqs.first
      render json: {
        faqs: @faqs.as_json
      }, status: :ok
    else
      render json: { error: 'No faqs found' }
    end
  end

  private

  def set_broadband
    @broadband = Broadband.find(params[:id])
  end

  def broadband_params
      params.require(:broadband).permit(:anchorname, :address, :bldgnbr, :predir, :suffdir, :streetname, :streettype, :city, :state_code, :zip5, :latitude, :longitude, :publicwifi, :url, :detail, :broadband_type_id, :services, logo: [:data, :filename], banner: [:data, :filename], opening_hours_attributes: [:id, :day, :from, :to, :closed])
  end

  def process_base64(string_info)
    if string_info
      image = Paperclip.io_adapters.for(string_info[:data])
      image.original_filename = string_info[:filename]
      image
      # data = StringIO.new(Base64.decode64(string_info[:data]))
      # data.class.class_eval { attr_accessor :original_filename, :content_type }
      # data.original_filename = string_info[:filename]
      # data.content_type = string_info[:content_type]
      # data
    end
  end

  def record_not_found
    render json: { error: 'Record not found!' }, status: :unprocessable_entity
  end

  def sign_up_params
    params.require(:broadband).permit(:email, :password, :manager_name, :name, :phone_no, :profile_picture, :broadband_type_id, :streetname, :city, :state_code, :zip5)
  end
end
