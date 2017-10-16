class Meeting
  include ActiveModel::Model

  attr_accessor :name
  attr_accessor :id
  attr_accessor :location
  attr_accessor :description
  attr_accessor :start_date
  attr_accessor :start_time
  attr_accessor :duration

  validates :name, presence: true
end
