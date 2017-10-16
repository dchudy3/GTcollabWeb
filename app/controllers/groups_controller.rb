class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update]

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
  end

  # GET /groups/new

  # curl --request POST \
  # --url 'https://secure-headland-60131.herokuapp.com/api/groups/612/leave/' \
  # --header 'authorization: Token 159a73e1414173ac5f7ba14786253d45870a51df '


  def new
    puts "in add"
    id =  params[:format]
    line = "https://secure-headland-60131.herokuapp.com/api/groups/" + id + "/join/"
    puts line
    puts $token

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

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

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
  def destroy
    require "net/http"
    require "uri"

    id =  params[:id]
    line = "https://secure-headland-60131.herokuapp.com/api/groups/" + id + "/leave/"
    puts line
    puts $token


    parsed_url = URI.parse(line)

    http = Net::HTTP.new(parsed_url.host, parsed_url.port)
    http.use_ssl = true

    req = Net::HTTP::Post.new(parsed_url.request_uri)

    req.add_field("authorization", $token)

    response = http.request(req)
    # p "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    # p response.inspect

    # puts response.body
    redirect_to courses_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.fetch(:group, {})
    end
end
