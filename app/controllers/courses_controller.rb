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

    @mygroups = Hash.new
    @mymeetings = Hash.new
    course_id = ""
    ### get all classes

    ##response = RestClient.get 'https://secure-headland-60131.herokuapp.com/api/courses?subject__term=1&members=11',  {authorization: $token}


    response = RestClient.get 'https://gtcollab.herokuapp.com/api/courses?subject__term=1', {authorization: $token}
    objArray = JSON.parse(response.body)

    objArray["results"].each do |result|
      course = Course.new
      course.name = result["name"]
      course.id = result["id"]
      course.course_number = result["course_number"]
      hash = course.as_json
      @courses[hash["id"]] = hash
    end

    ## Get users specifc classes
    response = RestClient.get 'https://gtcollab.herokuapp.com/api/courses?subject__term=1&members=' + $user_id, {authorization: $token}
    objArray = JSON.parse(response.body)

    objArray["results"].each do |result|
      course = Course.new
      course.name = result["name"]
      course.id = result["id"]
      course.course_number = result["course_number"]
      hash = course.as_json
      @mycourses[hash["id"]] = hash
    end

    ### get my groups
    response = RestClient.get 'https://gtcollab.herokuapp.com/api/groups/?members=' + $user_id, {authorization: $token}
    objArray = JSON.parse(response.body)

    objArray["results"].each do |result|
      group = Group.new

      group.name = result["name"]
      group.id = result["id"]
      group.creator_firstname = result["creator"]["first_name"]
      group.creator_lastname = result["creator"]["last_name"]
      hash = group.as_json

      @mygroups[hash["id"]] = hash
    end

    ### get my meetings
    response = RestClient.get 'https://gtcollab.herokuapp.com/api/meetings/?members=' + $user_id, {authorization: $token}
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

      @mymeetings[hash["id"]] = hash
    end
  end

  def search
    @search = params["q"]
    @mycourses = Hash.new

    response = RestClient.get 'https://gtcollab.herokuapp.com/api/courses?subject__term=1', {authorization: $token}
    objArray = JSON.parse(response.body)

    objArray["results"].each do |result|
      course = Course.new
      course.name = result["name"]
      course.id = result["id"]
      course.course_number = result["course_number"]
      hash = course.as_json
      @courses[hash["id"]] = hash
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

    course_id = params[:id]

    @mygroups = Hash.new
    @groups = Hash.new

    @mymeetings = Hash.new
    @meetings = Hash.new

    ##### COURSE DATA #############
    @course = Course.new
    @course.id = params[:id]
    @course.name = params[:format]


    #Getting course members
    response = RestClient.get 'https://gtcollab.herokuapp.com/api/users/?courses_as_member=' + @course.id, {authorization: $token}
    objArray = JSON.parse(response.body)
    p "COUNTTT"
    p objArray["count"]
    @count = objArray["count"].to_s

    mem_list = Array.new

    objArray["results"].each do |member|
      mem_list << member
    end
    @course.members = mem_list
    p "TESTING COUSE!!!!"
    p @course
    #################################

    ####### MEMBER DATA ####
    @member = nil


    ############# MEETING DATA ##################
    #get the user's meetings
    response = RestClient.get 'https://gtcollab.herokuapp.com/api/meetings/?course=' + course_id + "&members=" + $user_id, {authorization: $token}
    objArray = JSON.parse(response.body)

    objArray["results"].each do |result|
      meeting = Meeting.new
      members = Array.new
      meeting.name = result["name"]
      meeting.id = result["id"]
      meeting.location = result["location"]
      meeting.description = result["description"]
      meeting.start_date = result["start_date"]
      meeting.start_time = result["start_time"]
      meeting.duration = result["duration"]

      result["members"].each do |member|
        members << member
      end
      meeting.members = members
      hash = meeting.as_json

      @mymeetings[hash["id"]] = hash
    end


    response = RestClient.get 'https://gtcollab.herokuapp.com/api/meetings/?course=' + course_id, {authorization: $token}
    objArray = JSON.parse(response.body)
    in_meeting = false

    objArray["results"].each do |result|
      @mymeetings.each do |meet| 
        if meet[1]["id"] == result["id"]
          in_meeting = true
          break
        end
      end

      meeting = Meeting.new
      members = Array.new
      meeting.name = result["name"]
      meeting.id = result["id"]
      meeting.location = result["location"]
      meeting.description = result["description"]
      meeting.start_date = result["start_date"]
      meeting.start_time = result["start_time"]
      meeting.duration = result["duration"]
      result["members"].each do |member|
        members << member
      end
      if in_meeting
        meeting.joined = true
      end
      meeting.members = members
      hash = meeting.as_json

      @meetings[hash["id"]] = hash
    end
    ###########################################

    ############# Group DATA ##################
    response = RestClient.get 'https://gtcollab.herokuapp.com/api/groups?course=' + course_id, {authorization: $token}
    objArray = JSON.parse(response.body)
    #p objArray["results"]

    response = RestClient.get 'https://gtcollab.herokuapp.com/api/groups/?course=' + course_id + "&members=" + $user_id, {authorization: $token}
    objArray = JSON.parse(response.body)

    objArray["results"].each do |result|

      group = Group.new
      members = Array.new
      group.name = result["name"]
      group.id = result["id"]
      group.creator_firstname = result["creator"]["first_name"]
      group.creator_lastname = result["creator"]["last_name"]
      
      result["members"].each do |member|
        members << member
      end
      group.members = members
      hash = group.as_json

      @mygroups[hash["id"]] = hash
    end

    #check which groups I am in
    in_group = false
    objArray["results"].each do |result|
      #make sure no duplicate groups
      @mygroups.each do |group| 
        if group[1]["id"] == result["id"]
          in_group = true
          break
        end
      end
      
      #if I am not in this group yet
      #if !(in_group)
        group = Group.new
        members = Array.new
        group.name = result["name"]
        group.id = result["id"]
        group.creator_firstname = result["creator"]["first_name"]
        group.creator_lastname = result["creator"]["last_name"]
        result["members"].each do |member|
          members << member
        end
        if in_group
          group.joined = true
        end
        group.members = members
        hash = group.as_json

        @groups[hash["id"]] = hash
      #end
      
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
    line = 'https://gtcollab.herokuapp.com/api/courses/' + id + '/join/'

    require "net/http"
    require "uri"

    parsed_url = URI.parse(line)

    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true

    req = Net::HTTP::Post.new(parsed_url.request_uri)

    req.add_field("authorization", $token)

    response = http.request(req)
    response.inspect

    #puts response.body
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

    response = RestClient.post 'https://gtcollab.herokuapp.com/api/courses/' + id +'/leave/', {authorization: $token}


    # line = 'https://secure-headland-60131.herokuapp.com/api/courses/' + id + '/leave/', 

    # require "net/http"
    # require "uri"

    # parsed_url = URI.parse(line)

    # http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    # http.use_ssl = true

    # req = Net::HTTP::Post.new(parsed_url.request_uri)

    # req.add_field("authorization", $token)

    # response = http.request(req)
    # response.inspect

    # puts response.body
    redirect_to courses_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      #@id =  params[:id]
      #@course = Course.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def course_params
      params.fetch(:course, {})
    end
end
