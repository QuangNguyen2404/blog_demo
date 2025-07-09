# spec/controllers/posts_controller_spec.rb
require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:user_post) { create(:post, created_by: user) }
  let!(:other_user_post) { create(:post, created_by: other_user) }

  before do
    # Mock authentication
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:authenticate_user!).and_return(true)
  end

  describe 'GET #index' do
    it 'returns success status' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'returns all posts in JSON format' do
      get :index
      
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an(Array)
      expect(json_response.length).to eq(2)
    end

    it 'includes post attributes' do
      get :index
      
      json_response = JSON.parse(response.body)
      post_json = json_response.first
      
      expect(post_json).to have_key('id')
      expect(post_json).to have_key('title')
      expect(post_json).to have_key('body')
      expect(post_json).to have_key('created_by_id')
    end

    context 'with policy scoping' do
      before do
        # Mock policy scope to return only user's posts
        allow(controller).to receive(:policy_scope).and_return(Post.where(created_by: user))
      end

      it 'applies policy scoping' do
        get :index
        
        json_response = JSON.parse(response.body)
        expect(json_response.length).to eq(1)
        expect(json_response.first['id']).to eq(user_post.id)
      end
    end
  end

  describe 'GET #show' do
    context 'with valid post id' do
      before do
        allow(controller).to receive(:authorize).and_return(true)
      end

      it 'returns success status' do
        get :show, params: { id: user_post.id }
        expect(response).to have_http_status(:ok)
      end

      it 'returns the post in JSON format' do
        get :show, params: { id: user_post.id }
        
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(user_post.id)
        expect(json_response['title']).to eq(user_post.title)
        expect(json_response['body']).to eq(user_post.body)
      end

      it 'authorizes the post' do
        expect(controller).to receive(:authorize).with(user_post)
        get :show, params: { id: user_post.id }
      end
    end

    context 'with non-existent post id' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          get :show, params: { id: 999999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when not authorized' do
      before do
        allow(controller).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      end

      it 'raises Pundit::NotAuthorizedError' do
        expect {
          get :show, params: { id: user_post.id }
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        post: {
          title: 'New Post Title',
          body: 'This is the body of the new post.'
        }
      }
    end

    context 'with valid parameters' do
      before do
        allow(controller).to receive(:authorize).and_return(true)
      end

      it 'creates a new post' do
        expect {
          post :create, params: valid_params
        }.to change(Post, :count).by(1)
      end

      it 'returns created status' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end

      it 'returns the created post in JSON format' do
        post :create, params: valid_params
        
        json_response = JSON.parse(response.body)
        expect(json_response['title']).to eq('New Post Title')
        expect(json_response['body']).to eq('This is the body of the new post.')
        expect(json_response['created_by_id']).to eq(user.id)
      end

      it 'sets the current user as the creator' do
        post :create, params: valid_params
        
        created_post = Post.last
        expect(created_post.created_by).to eq(user)
      end

      it 'authorizes the post creation' do
        expect(controller).to receive(:authorize)
        post :create, params: valid_params
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          post: {
            title: '',
            body: ''
          }
        }
      end

      before do
        allow(controller).to receive(:authorize).and_return(true)
      end

      it 'does not create a post' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Post, :count)
      end

      it 'returns unprocessable_entity status' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns validation errors' do
        post :create, params: invalid_params
        
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('title')
      end
    end

    context 'when not authorized' do
      before do
        allow(controller).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      end

      it 'raises Pundit::NotAuthorizedError' do
        expect {
          post :create, params: valid_params
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe 'PATCH #update' do
    let(:update_params) do
      {
        id: user_post.id,
        post: {
          title: 'Updated Title',
          body: 'Updated body content.'
        }
      }
    end

    context 'with valid parameters' do
      before do
        allow(controller).to receive(:authorize).and_return(true)
      end

      it 'updates the post' do
        patch :update, params: update_params
        
        user_post.reload
        expect(user_post.title).to eq('Updated Title')
        expect(user_post.body).to eq('Updated body content.')
      end

      it 'returns success status' do
        patch :update, params: update_params
        expect(response).to have_http_status(:ok)
      end

      it 'returns the updated post in JSON format' do
        patch :update, params: update_params
        
        json_response = JSON.parse(response.body)
        expect(json_response['title']).to eq('Updated Title')
        expect(json_response['body']).to eq('Updated body content.')
      end

      it 'authorizes the post update' do
        expect(controller).to receive(:authorize).with(user_post)
        patch :update, params: update_params
      end
    end

    context 'with invalid parameters' do
      let(:invalid_update_params) do
        {
          id: user_post.id,
          post: {
            title: '',
            body: 'Updated body content.'
          }
        }
      end

      before do
        allow(controller).to receive(:authorize).and_return(true)
      end

      it 'does not update the post' do
        original_title = user_post.title
        patch :update, params: invalid_update_params
        
        user_post.reload
        expect(user_post.title).to eq(original_title)
      end

      it 'returns unprocessable_entity status' do
        patch :update, params: invalid_update_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns validation errors' do
        patch :update, params: invalid_update_params
        
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('title')
      end
    end

    context 'when not authorized' do
      before do
        allow(controller).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      end

      it 'raises Pundit::NotAuthorizedError' do
        expect {
          patch :update, params: update_params
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      allow(controller).to receive(:authorize).and_return(true)
    end

    it 'deletes the post' do
      expect {
        delete :destroy, params: { id: user_post.id }
      }.to change(Post, :count).by(-1)
    end

    it 'returns no_content status' do
      delete :destroy, params: { id: user_post.id }
      expect(response).to have_http_status(:no_content)
    end

    it 'returns empty body' do
      delete :destroy, params: { id: user_post.id }
      expect(response.body).to be_empty
    end

    it 'authorizes the post deletion' do
      expect(controller).to receive(:authorize).with(user_post)
      delete :destroy, params: { id: user_post.id }
    end

    context 'when not authorized' do
      before do
        allow(controller).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      end

      it 'raises Pundit::NotAuthorizedError' do
        expect {
          delete :destroy, params: { id: user_post.id }
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe 'private methods' do
    describe '#set_post' do
      it 'finds the correct post' do
        controller.params = { id: user_post.id }
        controller.send(:set_post)
        
        expect(controller.instance_variable_get(:@post)).to eq(user_post)
      end

      it 'raises error for non-existent post' do
        controller.params = { id: 999999 }
        
        expect {
          controller.send(:set_post)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe '#post_params' do
      it 'permits title and body' do
        controller.params = ActionController::Parameters.new(
          post: { title: 'Test', body: 'Body', extra_param: 'should_be_filtered' }
        )
        
        permitted_params = controller.send(:post_params)
        expect(permitted_params.permitted?).to be true
        expect(permitted_params.keys).to include('title', 'body')
        expect(permitted_params.keys).not_to include('extra_param')
      end
    end
  end
end
