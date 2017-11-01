class Group
  include ActiveModel::Model

  attr_accessor :name
  attr_accessor :id
  attr_accessor :creater_fname
  attr_accessor :creater_lname

  validates :name, presence: true
end
