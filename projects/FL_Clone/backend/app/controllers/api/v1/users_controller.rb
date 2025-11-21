class Api::V1::UsersController < ApplicationController
  def index
    users = User.where(is_active: true).limit(50)
    render json: users.map { |u| UserSerializer.new(u).as_json }
  end
  
  def show
    user = User.find(params[:id])
    render json: UserSerializer.new(user).as_json
  end
  
  def update
    if current_user.update(user_params)
      render json: UserSerializer.new(current_user).as_json
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def profile
    user = User.find(params[:id])
    render json: {
      user: UserSerializer.new(user).as_json,
      profile: ProfileSerializer.new(user.profile).as_json
    }
  end
  
  def update_profile
    if current_user.profile.update(profile_params)
      attach_kink_tags(current_user) if params[:kink_tags]
      render json: ProfileSerializer.new(current_user.profile).as_json
    else
      render json: { errors: current_user.profile.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  
  def attach_kink_tags(user)
    tag_slugs = params[:kink_tags].is_a?(Array) ? params[:kink_tags] : params[:kink_tags].split(',')
    tag_slugs.each do |slug|
      tag = KinkTag.find_by(slug: slug.strip)
      if tag
        user.kink_taggings.find_or_create_by(kink_tag: tag)
      end
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:username, :email)
  end
  
  def profile_params
    params.require(:profile).permit(:bio, :location, :website, :role, :orientation, :interests, :fetishes, :privacy_level, :show_location, :show_age)
  end
end

