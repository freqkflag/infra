class Api::V1::KinkTagsController < ApplicationController
  def index
    tags = KinkTag.all
    tags = tags.by_category(params[:category]) if params[:category].present?
    tags = tags.popular if params[:popular] == 'true'
    tags = tags.search_by_name(params[:q]) if params[:q].present?
    tags = tags.limit(100)
    
    render json: tags.map { |t| KinkTagSerializer.new(t).as_json }
  end
  
  def show
    tag = KinkTag.find_by(slug: params[:id]) || KinkTag.find(params[:id])
    render json: KinkTagSerializer.new(tag).as_json
  end
  
  def create
    tag = KinkTag.new(kink_tag_params)
    
    if tag.save
      render json: KinkTagSerializer.new(tag).as_json, status: :created
    else
      render json: { errors: tag.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def popular
    tags = KinkTag.popular.limit(50)
    render json: tags.map { |t| KinkTagSerializer.new(t).as_json }
  end
  
  def categories
    categories = KinkTag.distinct.pluck(:category).compact
    render json: { categories: categories }
  end
  
  private
  
  def kink_tag_params
    params.require(:kink_tag).permit(:name, :description, :category, :is_nsfw)
  end
end

