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
    # this will need to loop to find full page of options
    @courses = Hash.new
    @mycourses = Hash.new

    @mygroups = Hash.new
    @mymeetings = Hash.new
    course_id = ""
    next_page = 'https://gtcollab.herokuapp.com/api/courses?subject__term=1'

    if $all_courses == nil
      while next_page != nil
        p next_page
        response = RestClient.get next_page, {authorization: $token}
        objArray = JSON.parse(response.body)

        next_page = objArray["next"] 
        # p "DAN|||||||||||||||||||| " 
        # p objArray["next"]
        objArray["results"].each do |result|
          course = Course.new
          course.name = result["name"]
          course.id = result["id"]
          course.course_number = result["course_number"]
          course.joined = false
          hash = course.as_json
          @courses[hash["id"]] = hash
        end
      end
       $all_courses = @courses
    else 
      @courses =  $all_courses
    end

   

    ## Get users specifc classes
    response = RestClient.get 'https://gtcollab.herokuapp.com/api/courses?subject__term=1&members=' + $user_id, {authorization: $token}
    objArray = JSON.parse(response.body)

    objArray["results"].each do |result|
      course = Course.new
      course.name = result["name"]
      course.id = result["id"]
      course.joined = true
      course.course_number = result["course_number"]
      hash = course.as_json
      @mycourses[hash["id"]] = hash
    end

    ### get my groups
    response = RestClient.get 'https://gtcollab.herokuapp.com/api/groups/?members=' + $user_id, {authorization: $token}
    objArray = JSON.parse(response.body)

    objArray["results"].each do |result|
      response = RestClient.get 'https://gtcollab.herokuapp.com/api/courses/' + result["course"].to_s, {authorization: $token}
      course_info = JSON.parse(response.body)
      
      group = Group.new

      group.name = result["name"]
      group.id = result["id"]
      group.creator_firstname = result["creator"]["first_name"]
      group.creator_lastname = result["creator"]["last_name"]
      group.joined = true
      group.course_id = result["course"]
      group.course_name = course_info["name"]
      hash = group.as_json

      @mygroups[hash["id"]] = hash
    end

    ### get my meetings
    response = RestClient.get 'https://gtcollab.herokuapp.com/api/meetings/?members=' + $user_id, {authorization: $token}
    objArray = JSON.parse(response.body)

    objArray["results"].each do |result|
      
      response = RestClient.get 'https://gtcollab.herokuapp.com/api/courses/' + result["course"].to_s, {authorization: $token}
      course_info = JSON.parse(response.body)
      meeting = Meeting.new

      meeting.name = result["name"]
      meeting.id = result["id"]
      meeting.location = result["location"]
      meeting.description = result["description"]
      meeting.start_date = result["start_date"]
      meeting.start_time = result["start_time"]
      meeting.duration = result["duration"]
      meeting.course_id = result["course"]
      meeting.joined = true
      meeting.course_name = course_info["name"]
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

    #p "SHOWWWWWWWWWWWW"
    #p params
    #p params[:joined]
    @in_course = params[:joined].to_s

    @mygroups = Hash.new
    @groups = Hash.new

    @mymeetings = Hash.new
    @meetings = Hash.new

    ##### COURSE DATA #############
    @course = Course.new
    @course.id = params[:id]
    @course.name = params[:name]


    @messages = Array.new
    response = RestClient.get 'https://gtcollab.herokuapp.com/api/course-messages/?course=' + @course.id, {authorization: $token}
    objArray = JSON.parse(response.body)
    objArray['results'].each do |msg|
      message = Message.new
      message.content = msg['content']
      message.time = msg['timestamp']
      message.creator = msg['creator']['username']
      message.creator_id = msg['creator']['id']
      @messages << message
    end



    #Getting course members
    response = RestClient.get 'https://gtcollab.herokuapp.com/api/users/?courses_as_member=' + @course.id, {authorization: $token}
    objArray = JSON.parse(response.body)
    #p "COUNTTT"
    #p objArray["count"]
    $user_cache = Hash.new
    @count = objArray["count"].to_s

    mem_list = Array.new

    objArray["results"].each do |member|
      mem_list << member
      $user_cache[member["id"]] = member
    end
    @course.members = mem_list
    #p "TESTING COUSE!!!!"
    #p @course
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
    objArray2 = JSON.parse(response.body)
    in_meeting = false

    objArray2["results"].each do |result|
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
      meeting.creator_username = result["creator"]["username"]
      meeting.creator_firstname = result["creator"]["first_name"]
      meeting.creator_lastname = result["creator"]["last_name"]
      meeting.creator_email = result["creator"]["email"]

      result["members"].each do |member|
        members << member
      end
      if in_meeting
        meeting.joined = true
      end
      meeting.members = members
      hash = meeting.as_json

      @meetings[hash["id"]] = hash
      in_meeting = false
    end
    ###########################################

    ############# Group DATA ##################
    response = RestClient.get 'https://gtcollab.herokuapp.com/api/groups?course=' + course_id, {authorization: $token}
    objArray1= JSON.parse(response.body)
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
    objArray1["results"].each do |result|
      #make sure no duplicate groups
      @mygroups.each do |group| 
        if group[1]["id"] == result["id"]
          in_group = true
          break
        end
      end
      
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
      in_group = false
    end
    ############################################
  end

  # GET /courses/new
  #Course Controller
  #Join a course

  def new  
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
  #Course Controller
  #Leave a course
  def destroy 
    id =  params[:id]

    line = 'https://gtcollab.herokuapp.com/api/courses/' + id + '/leave/'

    require "net/http"
    require "uri"

    parsed_url = URI.parse(line)

    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true

    req = Net::HTTP::Post.new(parsed_url.request_uri)

    req.add_field("authorization", $token)

    response = http.request(req)
    response.inspect

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
