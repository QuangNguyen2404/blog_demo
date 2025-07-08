class User < ApplicationRecord
    has_secure_password
    has_many :posts, foreign_key: :created_by_id
end
