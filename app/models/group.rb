class Group
  include ActiveModel::Model

  attr_accessor :name
  attr_accessor :id
  attr_accessor :course_id
  attr_accessor :creator_id
  attr_accessor :creator_username
  attr_accessor :creator_firstname
  attr_accessor :creator_lastname
  attr_accessor :creator_email
  attr_accessor :members
  attr_accessor :joined

  validates :name, presence: true
end
