# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password) }
    it { should have_secure_password }
  end

  describe 'associations' do
    it { should have_many(:posts).with_foreign_key(:created_by_id) }
  end

  describe 'factory' do
    it 'creates a valid user' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'creates a user with posts using trait' do
      user = create(:user, :with_posts)
      expect(user.posts.count).to eq(3)
    end
  end

  describe 'password authentication' do
    let(:user) { create(:user, password: 'test_password') }

    it 'authenticates with correct password' do
      expect(user.authenticate('test_password')).to eq(user)
    end

    it 'does not authenticate with incorrect password' do
      expect(user.authenticate('wrong_password')).to be false
    end
  end

  describe 'email validation' do
    it 'accepts valid email formats' do
      valid_emails = %w[
        user@example.com
        test.email@example.org
        user123@test-domain.co.uk
      ]

      valid_emails.each do |email|
        user = build(:user, email: email)
        expect(user).to be_valid, "#{email} should be valid"
      end
    end

    it 'rejects invalid email formats' do
      invalid_emails = %w[
        plainaddress
        @missingdomain.com
        missing@.com
        missing.domain@.com
      ]

      invalid_emails.each do |email|
        user = build(:user, email: email)
        expect(user).not_to be_valid, "#{email} should be invalid"
      end
    end

    it 'is case insensitive for uniqueness' do
      create(:user, email: 'Test@Example.com')
      duplicate_user = build(:user, email: 'test@example.com')
      
      expect(duplicate_user).not_to be_valid
    end
  end

  describe 'password validation' do
    it 'requires minimum password length' do
      user = build(:user, password: 'short')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
    end

    it 'accepts passwords of adequate length' do
      user = build(:user, password: 'adequate_password')
      expect(user).to be_valid
    end
  end
end
