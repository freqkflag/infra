class Api::V1::PostsController < ApplicationController
  def index
    posts = Post.includes(:user, :comments, :likes, :tags)
    posts = posts.public_posts unless params[:user_id]
    posts = posts.where(user_id: params[:user_id]) if params[:user_id]
    posts = posts.order(created_at: :desc).limit(50)
    
    render json: posts.map { |p| PostSerializer.new(p).as_json }
  end
  
  def show
    post = Post.find(params[:id])
    render json: PostSerializer.new(post).as_json
  end
  
  def create
    post = current_user.posts.build(post_params)
    
    if post.save
      attach_images(post) if params[:images]
      attach_tags(post) if params[:tags]
      attach_kink_tags(post) if params[:kink_tags]
      render json: PostSerializer.new(post).as_json, status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def update
    post = Post.find(params[:id])
    authorize_post_owner(post)
    
    if post.update(post_params)
      render json: PostSerializer.new(post).as_json
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def destroy
    post = Post.find(params[:id])
    authorize_post_owner(post)
    post.destroy
    render json: { message: 'Post deleted' }, status: :ok
  end
  
  def like
    post = Post.find(params[:id])
    like = post.likes.find_or_initialize_by(user: current_user)
    
    if like.persisted?
      like.destroy
      render json: { liked: false, likes_count: post.reload.likes_count }
    else
      like.save
      render json: { liked: true, likes_count: post.reload.likes_count }
    end
  end
  
  def unlike
    post = Post.find(params[:id])
    like = post.likes.find_by(user: current_user)
    like&.destroy
    render json: { liked: false, likes_count: post.reload.likes_count }
  end
  
  private
  
  def post_params
    params.require(:post).permit(:content, :privacy)
  end
  
  def attach_images(post)
    params[:images].each do |image|
      post.images.attach(image)
    end
  end
  
  def attach_tags(post)
    tag_names = params[:tags].is_a?(Array) ? params[:tags] : params[:tags].split(',')
    tag_names.each do |tag_name|
      tag = Tag.find_or_create_by(name: tag_name.strip)
      post.taggings.find_or_create_by(tag: tag)
    end
  end
  
  def attach_kink_tags(post)
    tag_slugs = params[:kink_tags].is_a?(Array) ? params[:kink_tags] : params[:kink_tags].split(',')
    tag_slugs.each do |slug|
      tag = KinkTag.find_by(slug: slug.strip)
      if tag
        post.kink_taggings.find_or_create_by(kink_tag: tag)
      end
    end
  end
  
  def authorize_post_owner(post)
    unless post.user == current_user
      render json: { error: 'Not authorized' }, status: :forbidden
    end
  end
end

