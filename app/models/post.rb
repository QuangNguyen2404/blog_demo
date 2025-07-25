class Post < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  
  validates :title, presence: true
  validates :body, presence: true
end
