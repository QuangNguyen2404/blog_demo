# spec/models/post_spec.rb
require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'validations' do
    subject { build(:post) }
    
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
  end

  describe 'associations' do
    it { should belong_to(:created_by).class_name('User') }
  end

  describe 'factory' do
    it 'creates a valid post' do
      post = build(:post)
      expect(post).to be_valid
    end

    it 'creates a post with long title trait' do
      post = create(:post, :with_long_title)
      expect(post.title.split.length).to be >= 15
    end
  end

  describe 'required attributes' do
    let(:user) { create(:user) }

    it 'is invalid without a title' do
      post = build(:post, title: nil, created_by: user)
      expect(post).not_to be_valid
      expect(post.errors[:title]).to include("can't be blank")
    end

    it 'is invalid without a body' do
      post = build(:post, body: nil, created_by: user)
      expect(post).not_to be_valid
      expect(post.errors[:body]).to include("can't be blank")
    end

    it 'is invalid without a creator' do
      post = build(:post, created_by: nil)
      expect(post).not_to be_valid
      expect(post.errors[:created_by]).to include("must exist")
    end

    it 'is valid with all required attributes' do
      post = build(:post, created_by: user)
      expect(post).to be_valid
    end
  end

  describe 'title validation' do
    let(:user) { create(:user) }

    it 'accepts titles of reasonable length' do
      post = build(:post, title: 'A' * 100, created_by: user)
      expect(post).to be_valid
    end

    it 'rejects empty titles' do
      post = build(:post, title: '', created_by: user)
      expect(post).not_to be_valid
    end

    it 'rejects whitespace-only titles' do
      post = build(:post, title: '   ', created_by: user)
      expect(post).not_to be_valid
    end
  end

  describe 'body validation' do
    let(:user) { create(:user) }

    it 'accepts bodies of reasonable length' do
      post = build(:post, body: 'A' * 1000, created_by: user)
      expect(post).to be_valid
    end

    it 'rejects empty bodies' do
      post = build(:post, body: '', created_by: user)
      expect(post).not_to be_valid
    end

    it 'rejects whitespace-only bodies' do
      post = build(:post, body: '   ', created_by: user)
      expect(post).not_to be_valid
    end
  end

  describe 'user association' do
    let(:user) { create(:user) }
    let(:post) { create(:post, created_by: user) }

    it 'belongs to a user' do
      expect(post.created_by).to eq(user)
    end

    it 'is destroyed when user is destroyed' do
      post_id = post.id
      user.destroy
      expect(Post.find_by(id: post_id)).to be_nil
    end
  end

  describe 'scopes and methods' do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:post1) { create(:post, created_by: user1) }
    let!(:post2) { create(:post, created_by: user2) }

    it 'can find posts by creator' do
      user1_posts = Post.where(created_by: user1)
      expect(user1_posts).to include(post1)
      expect(user1_posts).not_to include(post2)
    end
  end
end
