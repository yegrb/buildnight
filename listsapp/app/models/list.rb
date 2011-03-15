class List < ActiveRecord::Base
  has_many :items

  validates_presence_of :title
end
