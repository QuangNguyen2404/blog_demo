# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  before_action :set_post, only: [:show, :update, :destroy]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @posts = policy_scope(Post)
    render json: @posts
  end

  def show
    authorize @post
    render json: @post
  end

  def create
    @post = Post.new(post_params)
    @post.created_by = current_user
    authorize @post

    if @post.save
      render json: @post, status: :created
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def update
    authorize @post
    if @post.update(post_params)
      render json: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @post
    @post.destroy
    head :no_content
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body)
  end
end
