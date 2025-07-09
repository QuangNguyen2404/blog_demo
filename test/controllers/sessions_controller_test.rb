require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should login with valid credentials" do
    post sessions_url, params: { 
      email: @user.email, 
      password: 'password' 
    }, as: :json
    
    assert_response :ok
    assert_not_nil response.parsed_body['token']
    assert_equal @user.email, response.parsed_body['user']['email']
  end

  test "should not login with invalid credentials" do
    post sessions_url, params: { 
      email: @user.email, 
      password: 'wrong_password' 
    }, as: :json
    
    assert_response :unauthorized
    assert_equal 'Invalid email or password', response.parsed_body['error']
  end

  test "should logout successfully" do
    # Login first to get token
    post sessions_url, params: { 
      email: @user.email, 
      password: 'password' 
    }, as: :json
    
    token = response.parsed_body['token']
    
    # Then logout
    delete sessions_url, headers: { 
      'Authorization' => "Bearer #{token}" 
    }, as: :json
    
    assert_response :ok
    assert_equal 'Logged out successfully', response.parsed_body['message']
  end

  test "should show current user when authenticated" do
    # Login first to get token
    post sessions_url, params: { 
      email: @user.email, 
      password: 'password' 
    }, as: :json
    
    token = response.parsed_body['token']
    
    # Check current user
    get sessions_url, headers: { 
      'Authorization' => "Bearer #{token}" 
    }, as: :json
    
    assert_response :ok
    assert response.parsed_body['authenticated']
    assert_equal @user.email, response.parsed_body['user']['email']
  end

  test "should return unauthorized when not authenticated" do
    get sessions_url, as: :json
    
    assert_response :unauthorized
    assert_not response.parsed_body['authenticated']
  end
end
