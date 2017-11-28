class NotificationsController < ApplicationController
  def show
    p $user_cache
    @standard_messages = Array.new
    @standard_message = Message.new

    @group_messages = Array.new
    @group_message = Message.new

    @meeting_messages = Array.new
    @meeting_message = Message.new

  	response = RestClient.get 'https://gtcollab.herokuapp.com/api/standard-notifications?recipients=' + $user_id, {authorization: $token}
    objArray = JSON.parse(response.body)

    p " DAN ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    objArray["results"].each do |noti|
        @standard_message = Message.new
        @standard_message.id = noti["id"]
        @standard_message.content = noti["message"]
        @standard_message.time = noti["timestamp"]
        @standard_message.creator = noti['creator']["username"]
        @standard_message.creator_id = noti['creator']["id"]
        @standard_messages << @standard_message
    end

    # response = RestClient.get 'https://gtcollab.herokuapp.com/api/group-notifications?recipients=' + $user_id, {authorization: $token}
    # objArray = JSON.parse(response.body)

    # p " DAN ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    # objArray["results"].each do |noti|
    #     @group_message = Message.new
    #     @group_message.id = noti["id"]
    #     @group_message.group_id = noti["group"]
    #     @group_message.content = noti["message"]
    #     @group_message.time = noti["timestamp"]
    #     @group_message.creator = noti['creator']["username"]
    #     @group_message.creator_id = noti['creator']["id"]
    #     @group_messages << @group_message
    # end
    # p objArray

    # response = RestClient.get 'https://gtcollab.herokuapp.com/api/meeting-notifications?recipients=' + $user_id, {authorization: $token}
    # objArray = JSON.parse(response.body)

    # objArray["results"].each do |noti|
    #     @meeting_message = Message.new
    #     @meeting_message.id = noti["id"]
    #             @meeting_message.group_id = noti["meeting"]
    #     @meeting_message.content = noti["message"]
    #     @meeting_message.time = noti["timestamp"]
    #     @meeting_message.creator = noti['creator']["username"]
    #     @meeting_message.creator_id = noti['creator']["id"]
    #     @meeting_messages << @meeting_message
    # end


    response = RestClient.get 'https://gtcollab.herokuapp.com/api/group-invitations?recipients=' + $user_id, {authorization: $token}
    objArray = JSON.parse(response.body)
    objArray["results"].each do |noti|
        @group_message = Message.new
        @group_message.id = noti["id"]
        @group_message.group_id = noti["group"]
        @group_message.content = noti["message"]
        @group_message.time = noti["timestamp"]
        @group_message.creator = noti['creator']["username"]
        @group_message.creator_id = noti['creator']["id"]
        @group_messages << @group_message
    end


    response = RestClient.get 'https://gtcollab.herokuapp.com/api/meeting-invitations?recipients=' + $user_id, {authorization: $token}
    objArray = JSON.parse(response.body)

    objArray["results"].each do |noti|
        @meeting_message = Message.new
        @meeting_message.id = noti["id"]
                        @meeting_message.group_id = noti["meeting"]
        @meeting_message.content = noti["message"]
        @meeting_message.time = noti["timestamp"]
        @meeting_message.creator = noti['creator']["username"]
        @meeting_message.creator_id = noti['creator']["id"]
        @meeting_messages << @meeting_message
    end


    response = RestClient.get 'https://gtcollab.herokuapp.com/api/meeting-proposals?recipients=' + $user_id, {authorization: $token}
    objArray = JSON.parse(response.body)

    p " DAN ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    p objArray


    response = RestClient.get 'https://gtcollab.herokuapp.com/api/meeting-proposal-results?recipients=' + $user_id, {authorization: $token}
    objArray = JSON.parse(response.body)

    p " DAN ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    p objArray
  end

  def check
    response = RestClient.get 'https://gtcollab.herokuapp.com/api/standard-notifications?recipients=' + $user_id, {authorization: $token}
    objArray = JSON.parse(response.body)

    @num_alerts = objArray["count"]
    p " DAN ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    p objArray
    p objArray["count"]

    redirect_to courses_path
  end
end
