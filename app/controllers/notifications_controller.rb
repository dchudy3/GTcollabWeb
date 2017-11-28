class NotificationsController < ApplicationController
  def show
  	response = RestClient.get 'https://gtcollab.herokuapp.com/api/standard-notifications?recipients=13', {authorization: $token}
    objArray = JSON.parse(response.body)

    p " DAN ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    p objArray

    response = RestClient.get 'https://gtcollab.herokuapp.com/api/group-notifications', {authorization: $token}
    objArray = JSON.parse(response.body)

    p " DAN ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    p objArray

    response = RestClient.get 'https://gtcollab.herokuapp.com/api/meeting-notifications', {authorization: $token}
    objArray = JSON.parse(response.body)

    p " DAN ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    p objArray


    response = RestClient.get 'https://gtcollab.herokuapp.com/api/group-invitations', {authorization: $token}
    objArray = JSON.parse(response.body)

    p " DAN ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    p objArray


    response = RestClient.get 'https://gtcollab.herokuapp.com/api/meeting-invitations', {authorization: $token}
    objArray = JSON.parse(response.body)

    p " DAN ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    p objArray


    response = RestClient.get 'https://gtcollab.herokuapp.com/api/meeting-proposals', {authorization: $token}
    objArray = JSON.parse(response.body)

    p " DAN ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    p objArray


    response = RestClient.get 'https://gtcollab.herokuapp.com/api/meeting-proposal-results', {authorization: $token}
    objArray = JSON.parse(response.body)

    p " DAN ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    p objArray
  end

  def check
    response = RestClient.get 'https://gtcollab.herokuapp.com/api/standard-notifications?recipients=' + $user_id, {authorization: $token}
    objArray = JSON.parse(response.body)

    objArray["results"]

    @num_alerts = objArray["results"].length
    p " DAN ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    p objArray

    redirect_to courses_path
  end
end
