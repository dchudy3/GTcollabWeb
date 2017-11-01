class Meeting
  include ActiveModel::Model

  attr_accessor :name
  attr_accessor :id
  attr_accessor :location
  attr_accessor :description
  attr_accessor :start_date
  attr_accessor :start_time
  attr_accessor :duration
  attr_accessor :course_id
  attr_accessor :creator_id
  attr_accessor :creator_username
  attr_accessor :creator_firstname
  attr_accessor :creator_lastname
  attr_accessor :creator_email
  attr_accessor :members
  
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
  validates :name, presence: true
end
