class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy, :new]

  # GET /courses
  # GET /courses.json
  ############## TODO: call api get classes you are assigned to, get all classes
  ############## Parse and input into @mycourse and @course
  ## URL: /api/courses

  #### REST URL => https://secure-headland-60131.herokuapp.com/api/courses

  #https://secure-headland-60131.herokuapp.com/api/users

# curl --header "authorization: Token ae58c6766f9152f8ffe0a143382f4121fbf6e3cb" https://secure-headland-60131.herokuapp.com/api/courses?subject__term=1
  ###### FRONT END EXEPECTS DATA IN THIS FORMAT:
  # blah =
  # { 
  #   "id" => ["id", {"key" => "value", "key" => "value","key"=> "value", .........}],
  #   "id" => ["id", {"key" => "value", "key" => "value","key"=> "value", .........}]
  #   ................
  # }

  def index
    @courses = Hash.new
    @mycourses = Hash.new

    response = RestClient.get 'https://secure-headland-60131.herokuapp.com/api/courses?subject__term=1', {authorization: $token}
    objArray = JSON.parse(response.body)

    objArray["results"].each do |result|
      course = Course.new
      course.name = result["name"]
      course.id = result["id"]
      course.course_number = result["course_number"]
      hash = course.as_json
      @courses[hash["id"]] = hash
    end

    response = RestClient.get 'https://secure-headland-60131.herokuapp.com/api/courses?subject__term=1&members=' + $user_id, {authorization: $token}
    objArray = JSON.parse(response.body)
    puts objArray
    objArray["results"].each do |result|
      course = Course.new
      course.name = result["name"]
      course.id = result["id"]
      course.course_number = result["course_number"]
      hash = course.as_json
      @mycourses[hash["id"]] = hash
    end
  end

  # GET /courses/1
  # GET /courses/1.json

  ########### LINK SHOW SPECIFCS, GET MEETINGS AND GROUPS ASSIGNED to this course ####
  ### GEt course info (from index or api)
  ### Get groups (from api)
  ### Get meetings (from api)

  #/api/courses/:id
  def show 
    puts params
    course_id = params[:id]
    @mygroups = Hash.new
    @groups = Hash.new

    @mymeetings = Hash.new
    @meetings = Hash.new

    ##### COURSE DATA #############
    @course = Course.new
    @course.id = params[:id]
    @course.name = params[:name]
    #################################

    ############# MEETING DATA ##################

    response = RestClient.get 'https://secure-headland-60131.herokuapp.com/api/meetings/?course=' + course_id + "&members=" + $user_id, {authorization: $token}
    objArray = JSON.parse(response.body)
    p objArray["results"]
    objArray["results"].each do |result|
      meeting = Meeting.new

      meeting.name = result["name"]
      meeting.id = result["id"]
      meeting.location = result["location"]
      meeting.description = result["description"]
      meeting.start_date = result["start_date"]
      meeting.start_time = result["start_time"]
      meeting.duration = result["duration"]
      hash = meeting.as_json

      @mymeetings[hash["id"]] = hash
    end


    response = RestClient.get 'https://secure-headland-60131.herokuapp.com/api/meetings/?course=' + course_id, {authorization: $token}
    objArray = JSON.parse(response.body)

    objArray["results"].each do |result|
      meeting = Meeting.new

      meeting.name = result["name"]
      meeting.id = result["id"]
      meeting.location = result["location"]
      meeting.description = result["description"]
      meeting.start_date = result["start_date"]
      meeting.start_time = result["start_time"]
      meeting.duration = result["duration"]
      hash = meeting.as_json

      @meetings[hash["id"]] = hash
    end
    ###########################################

    ############# Group DATA ##################
    response = RestClient.get 'https://secure-headland-60131.herokuapp.com/api/groups?course=' + course_id, {authorization: $token}
    objArray = JSON.parse(response.body)
    p objArray["results"]
    objArray["results"].each do |result|
      group = Group.new

      group.name = result["name"]
      group.id = result["id"]
      group.creater_fname = result["creator"]["first_name"]
      group.creater_lname = result["creator"]["last_name"]
      hash = group.as_json

      @groups[hash["id"]] = hash
    end

    response = RestClient.get 'https://secure-headland-60131.herokuapp.com/api/groups/?course=' + course_id + "&members=" + $user_id, {authorization: $token}
    objArray = JSON.parse(response.body)
    p objArray["results"]
    objArray["results"].each do |result|
      group = Group.new

      group.name = result["name"]
      group.id = result["id"]
      group.creater_fname = result["creator"]["first_name"]
      group.creater_lname = result["creator"]["last_name"]
      hash = group.as_json

      @mygroups[hash["id"]] = hash
    end

    ############################################
  end

  # GET /courses/new
# curl --request GET \
#   --url 'https://secure-headland-60131.herokuapp.com/api/meetings/?course=677' \
#   --header 'authorization: Token ae58c6766f9152f8ffe0a143382f4121fbf6e3cb'
  ######## API call add this course to our assigned courses (API)
  # URL: /api/courses/:id/join

  def new   ## 401 not Authorized?
    id =  params[:format]
    line = 'https://secure-headland-60131.herokuapp.com/api/courses/' + id + '/join/'

    require "net/http"
    require "uri"

    parsed_url = URI.parse(line)

    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true

    req = Net::HTTP::Post.new(parsed_url.request_uri)

    req.add_field("authorization", $token)

    response = http.request(req)
    response.inspect

    puts response.body
    redirect_to courses_path
  end

  # GET /courses/1/edit
  def edit # NO USED
  end

  # POST /courses
  # POST /courses.json
  def create ## NO USED
    # @course = Course.new(course_params)

    # respond_to do |format|
    #   if @course.save
    #     format.html { redirect_to @course, notice: 'Course was successfully created.' }
    #     format.json { render :show, status: :created, location: @course }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @course.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /courses/1
  # PATCH/PUT /courses/1.json
  def update # NO USED
    # respond_to do |format|
    #   if @course.update(course_params)
    #     format.html { redirect_to @course, notice: 'Course was successfully updated.' }
    #     format.json { render :show, status: :ok, location: @course }
    #   else
    #     format.html { render :edit }
    #     format.json { render json: @course.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /courses/1
  # DELETE /urses/1.json
  # /api/courses/:id/leave
  def destroy ## 401 not Authorized?
    id =  params[:id]
    line = 'https://secure-headland-60131.herokuapp.com/api/courses/' + id + '/leave/'

    require "net/http"
    require "uri"

    parsed_url = URI.parse(line)

    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true

    req = Net::HTTP::Post.new(parsed_url.request_uri)

    req.add_field("authorization", $token)

    response = http.request(req)
    response.inspect

    puts response.body
    redirect_to courses_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @id =  params[:id]
      #@course = Course.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def course_params
      params.fetch(:course, {})
    end
end
