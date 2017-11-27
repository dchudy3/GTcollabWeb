class MeetingsController < ApplicationController
  before_action :set_meeting, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token, :only => [:joinMeeting, :createMeeting]
  # GET /meetings
  # GET /meetings.json
  def index
    @meetings = Meeting.all
  end

  # GET /meetings/1
  # GET /meetings/1.json
  def show

    # "id": 243,
# "name": "Exercise 9 Help",
# "location": "Student Center 3rd floor",
# "description": "Exercise 9 Help",
# "start_date": "2017-12-10",
# "start_time": "13:45:00",
# "duration_minutes": 30,
# "course": 612,
# "creator": {
# "id": 100,
# "username": "user99",
# "first_name": "John99",
# "last_name": "Smith99",
# "email": "jsmith99@gatech.edu",
# "profile": { }
# },
# "members": [

    @id = params[:id]

    response = RestClient.get 'https://gtcollab.herokuapp.com/api/meetings/' + @id , {authorization: $token}
    objArray = JSON.parse(response.body)
    p objArray
    members = Array.new
    @meeting = Meeting.new
    @meeting.id = objArray["id"]
    @meeting.name = objArray["name"]

    @meeting.description = objArray["description"]
    @meeting.location = objArray["location"]
    @meeting.start_date = objArray["start_date"]
    @meeting.start_time = objArray["start_time"]
    @meeting.duration = objArray["duration_minutes"]

    @meeting.course_id = objArray["course"] #id
    @meeting.creator_id = objArray["creator"]["id"]
    @meeting.creator_username = objArray["creator"]["username"]
    @meeting.creator_firstname = objArray["creator"]["first_name"]
    @meeting.creator_lastname = objArray["creator"]["last_name"]
    @meeting.creator_email = objArray["creator"]["email"]
    
    objArray["members"].each do |member|
      members << member
    end
    @meeting.members = members
  end

  # GET /meetings/new
  def new
    @meeting = Meeting.new
  end

  # GET /meetings/1/edit
  def edit
  end

  # POST /meetings
  # POST /meetings.json
  def newMeeting
    @meeting = Meeting.new(meeting_params)

    respond_to do |format|
      if @meeting.save
        format.html { redirect_to @meeting, notice: 'Meeting was successfully created.' }
        format.json { render :show, status: :created, location: @meeting }
      else
        format.html { render :new }
        format.json { render json: @meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /meetings/1
  # PATCH/PUT /meetings/1.json
  def update
    respond_to do |format|
      if @meeting.update(meeting_params)
        format.html { redirect_to @meeting, notice: 'Meeting was successfully updated.' }
        format.json { render :show, status: :ok, location: @meeting }
      else
        format.html { render :edit }
        format.json { render json: @meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meetings/1
  # DELETE /meetings/1.json
  def destroy
    require "net/http"
    require "uri"

    id =  params[:id]
    line = "https://gtcollab.herokuapp.com/api/meetings/" + id + "/leave/"
    puts line
    puts $token


    parsed_url = URI.parse(line)

    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true

    req = Net::HTTP::Post.new(parsed_url.request_uri)

    req.add_field("authorization", $token)

    response = http.request(req)
    redirect_to course_path(params[:course_id], :name => params[:name], :joined => params[:joined])
  end

  def joinMeeting
    puts params
    id =  params[:id]
    line = "https://gtcollab.herokuapp.com/api/meetings/" + id + "/join/"
    
    #puts line
    #puts $token

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
    redirect_to course_path(params[:course_id], :name => params[:name], :joined => params[:joined])
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_meeting
      #@meeting = Meeting.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def meeting_params
      params.require(:meeting).permit(:name, :email, :course_id, :creator_id, :creator_username, :creator_firstname, :creator_lastname, :creator_email, :members)
    end
end
