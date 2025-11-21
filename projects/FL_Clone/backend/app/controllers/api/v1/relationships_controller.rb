class Api::V1::RelationshipsController < ApplicationController
  def create
    followed = User.find(params[:followed_id])
    relationship = current_user.active_relationships.build(followed: followed)
    
    if relationship.save
      render json: { message: 'Following user' }, status: :created
    else
      render json: { errors: relationship.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def destroy
    followed = User.find(params[:followed_id])
    relationship = current_user.active_relationships.find_by(followed: followed)
    relationship&.destroy
    render json: { message: 'Unfollowed user' }, status: :ok
  end
  
  def followers
    user = User.find(params[:user_id])
    render json: user.followers.map { |f| UserSerializer.new(f).as_json }
  end
  
  def following
    user = User.find(params[:user_id])
    render json: user.following.map { |f| UserSerializer.new(f).as_json }
  end
end

