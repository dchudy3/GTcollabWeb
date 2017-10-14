class Course 
  include ActiveModel::Model

  attr_accessor :name
  attr_accessor :id
  attr_accessor :course_number

  validates :name, presence: true

  def make
  	course = Hash.new
  	course[:name] = self.name
  	course[:id] = self.id
  end
end