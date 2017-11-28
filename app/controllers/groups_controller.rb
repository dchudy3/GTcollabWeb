class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update]
   skip_before_action :verify_authenticity_token, :only => [:joinGroup, :create, :newGroup]
  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    #p "IN GROUP SHOW !!!!!"
    @id = params[:id]
    #p @id
    @messages = Array.new
    response = RestClient.get 'https://gtcollab.herokuapp.com/api/group-messages/?group=' + @id , {authorization: $token}
    objArray = JSON.parse(response.body)
    p " DAN!"
    objArray['results'].each do |msg|
      message = Message.new
      message.content = msg['content']
      message.time = msg['timestamp']
      message.creator = msg['creator']['username']
      message.creator_id = msg['creator']['id']
      @messages << message
    end

    response = RestClient.get 'https://gtcollab.herokuapp.com/api/groups/' + @id , {authorization: $token}
    objArray = JSON.parse(response.body)
    p "dd ||||||"
    p objArray
    members = Array.new
    @group = Group.new
    @group.id = objArray["id"]
    @group.name = objArray["name"]
    @group.course_id = objArray["course"] #id
    @group.creator_id = objArray["creator"]["id"]
    @group.creator_username = objArray["creator"]["username"]
    @group.creator_firstname = objArray["creator"]["first_name"]
    @group.creator_lastname = objArray["creator"]["last_name"]
    @group.creator_email = objArray["creator"]["email"]
    
    objArray["members"].each do |member|
      members << member
    end
    @group.members = members


    response = RestClient.get 'https://gtcollab.herokuapp.com/api/users/?courses_as_member=' + @group.course_id.to_s , {authorization: $token}
    objArray = JSON.parse(response.body)
    #p "COUNTTT"
    #p objArray["count"]
    @count = objArray["count"].to_s

    mem_list = Array.new

    objArray["results"].each do |member|
      mem_list << member
    end
    @all_members = mem_list

      #hash = group.as_json
      #@mymeetings[hash["id"]] = hash
  end
   # objArray["results"].each do |result|
   #    meeting = Meeting.new

   #    meeting.name = result["name"]
   #    meeting.id = result["id"]
   #    meeting.location = result["location"]
   #    meeting.description = result["description"]
   #    meeting.start_date = result["start_date"]
   #    meeting.start_time = result["start_time"]
   #    meeting.duration = result["duration"]
   #    hash = meeting.as_json

   #    @mymeetings[hash["id"]] = hash
   #  end
    ## make request to get message data /api/group-messages/

  # GET /groups/new

  # curl --request POST \
  # --url 'https://secure-headland-60131.herokuapp.com/api/groups/612/leave/' \
  # --header 'authorization: Token 159a73e1414173ac5f7ba14786253d45870a51df '


  def new
    puts "in add"
    id =  params[:format]
    line = "https://gtcollab.herokuapp.com/api/groups/" + id + "/join/"
    
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
    redirect_to courses_path
  end

  #create new group
  def newGroup
    p 'CREATE MAGIC--------------------'
    p group_params
    pass = true

    course_id = group_params[:course_id]
    name = group_params[:name]
    p name
    p course_id
    members = Array.new
    group_params.keys.each do |key|
      if key.include?('member')
        p 'MEMBER!:'
        members << group_params[key]
        group_params.delete(key) 
      end
      #p key
    end 

    p members

    #@group = Group.new(group_params)
    begin
    p "are we ok?"
    response = RestClient.post 'https://gtcollab.herokuapp.com/api/groups/', { :name => name, course: course_id, members: members } , {authorization: $token}
        p "are we ok?"
    objArray = JSON.parse(response.body)
    p objArray
    p "are we ok?"

    rescue => e
      p "are we not ok?"
      p e.response.body
    end

    # respond_to do |format|
    #   if @group.save
    #     format.html { redirect_to @group, notice: 'Group was successfully created.' }
    #     format.json { render :show, status: :created, location: @group }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @group.errors, status: :unprocessable_entity }
    #   end
    # end

    #puts response.body
    # IF success
    # group_path(id) ##### NEEDS TO BE CREATED FIRST
    # else
    redirect_to course_path(:id => course_id)
    # end
  end
  
  #Group Controller
  #Join a Group
  def joinGroup
    id =  params[:id]
    line = "https://gtcollab.herokuapp.com/api/groups/" + id + "/join/"
    
    require "net/http"
    require "uri"

    parsed_url = URI.parse(line)

    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true

    req = Net::HTTP::Post.new(parsed_url.request_uri)

    req.add_field("authorization", $token)

    response = http.request(req)
    response.inspect

    redirect_to course_path(params[:course_id], :name => params[:name], :joined => params[:joined])
  end

  # GET /groups/1/edit
  def edit
  end

  def editGroup
  end
  # POST /groups
  # POST /groups.json
  #def create

  #end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  #Groups Controller 
  #Leave Group

  def send_invitation
    p "HELLO?"
    p params
    course = params[:course_id]
    group = params[:meeting_id]
    recipent = params[:user_id][:id]
    p course
    p group
    p recipent
    begin
      p "are we ok?"
      # will need to change to full delete
      response = RestClient.post "https://gtcollab.herokuapp.com/api/group-invitations/", {:course => course, :group => recipent} ,{authorization: $token}
      
      p "are we ok?"
      objArray = JSON.parse(response.body)
      p objArray
      p "are we ok?"

    rescue => e
      p "are we not ok?"
      p e.response
      p e.response.body
    end

    redirect_to course_path(params[:course_id], :name => params[:name], :joined => params[:joined])
  end

  def delete
   p "WE IN DELETE"

   p params 
    begin
      p "are we ok?"
      # will need to change to full delete
      response = RestClient.post "https://gtcollab.herokuapp.com/api/groups/" + params[:id] + "/leave/", {} ,{authorization: $token}
      
      p "are we ok?"
      objArray = JSON.parse(response.body)
      p objArray
      p "are we ok?"

    rescue => e
      p "are we not ok?"
      p e.response
      p e.response.body
    end

   redirect_to course_path(params[:course_id], :name => params[:name], :joined => params[:joined])
  end

  def destroy
    require "net/http"
    require "uri"

    id =  params[:id]
    line = "https://gtcollab.herokuapp.com/api/groups/" + id + "/leave/"

    parsed_url = URI.parse(line)

    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true

    req = Net::HTTP::Post.new(parsed_url.request_uri)

    req.add_field("authorization", $token)

    response = http.request(req)
    redirect_to course_path(params[:course_id], :name => params[:name], :joined => params[:joined])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      #@group = Group.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit!
      #params.require(:group).permit(:name, :email, :course_id, :creator_id, :creator_username, :creator_firstname, :creator_lastname, :creator_email, :members)
    end
end
