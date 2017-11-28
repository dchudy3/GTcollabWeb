class Message
  include ActiveModel::Model

  attr_accessor :id
  attr_accessor :content
  attr_accessor :time
  attr_accessor :group_id
  attr_accessor :creator
  attr_accessor :creator_id
end