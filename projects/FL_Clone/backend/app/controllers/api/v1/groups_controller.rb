class Api::V1::GroupsController < ApplicationController
  def index
    groups = Group.where(is_active: true).includes(:user, :members)
    render json: groups.map { |g| GroupSerializer.new(g).as_json }
  end
  
  def show
    group = Group.find(params[:id])
    render json: GroupSerializer.new(group).as_json
  end
  
  def create
    group = current_user.groups.build(group_params)
    if group.save
      group.group_memberships.create(user: current_user, role: :admin)
      attach_kink_tags(group) if params[:kink_tags]
      render json: GroupSerializer.new(group).as_json, status: :created
    else
      render json: { errors: group.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def update
    group = Group.find(params[:id])
    authorize_group_admin(group)
    
    if group.update(group_params)
      render json: GroupSerializer.new(group).as_json
    else
      render json: { errors: group.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def destroy
    group = Group.find(params[:id])
    authorize_group_admin(group)
    group.update(is_active: false)
    render json: { message: 'Group deactivated' }, status: :ok
  end
  
  def join
    group = Group.find(params[:id])
    membership = group.group_memberships.build(user: current_user)
    
    if membership.save
      render json: { message: 'Joined group successfully' }, status: :ok
    else
      render json: { errors: membership.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def leave
    group = Group.find(params[:id])
    membership = group.group_memberships.find_by(user: current_user)
    membership&.destroy
    render json: { message: 'Left group successfully' }, status: :ok
  end
  
  def members
    group = Group.find(params[:id])
    render json: group.members.map { |m| UserSerializer.new(m).as_json }
  end
  
  private
  
  def group_params
    params.require(:group).permit(:name, :description, :privacy, :cover_image)
  end
  
  def attach_kink_tags(group)
    tag_slugs = params[:kink_tags].is_a?(Array) ? params[:kink_tags] : params[:kink_tags].split(',')
    tag_slugs.each do |slug|
      tag = KinkTag.find_by(slug: slug.strip)
      if tag
        group.kink_taggings.find_or_create_by(kink_tag: tag)
      end
    end
  end
  
  def authorize_group_admin(group)
    membership = group.group_memberships.find_by(user: current_user)
    unless membership&.admin? || group.user == current_user
      render json: { error: 'Not authorized' }, status: :forbidden
    end
  end
end

