class User < ApplicationRecord
    has_secure_password
    has_many :posts, foreign_key: :created_by_id, dependent: :destroy

    validates :email, presence: true, uniqueness: { case_sensitive: false }
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
end
