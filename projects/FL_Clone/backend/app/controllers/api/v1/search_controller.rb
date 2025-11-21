class Api::V1::SearchController < ApplicationController
  def index
    query = params[:q]
    type = params[:type] || 'all'
    
    results = {}
    
    if type == 'all' || type == 'users'
      users = User.where(is_active: true)
        .where("username ILIKE ? OR email ILIKE ?", "%#{query}%", "%#{query}%")
        .limit(20)
      results[:users] = users.map { |u| UserSerializer.new(u).as_json }
    end
    
    if type == 'all' || type == 'groups'
      groups = Group.search_by_name_and_description(query).where(is_active: true).limit(20)
      results[:groups] = groups.map { |g| GroupSerializer.new(g).as_json }
    end
    
    if type == 'all' || type == 'events'
      events = Event.search_by_title_and_description(query).where(is_active: true).limit(20)
      results[:events] = events.map { |e| EventSerializer.new(e).as_json }
    end
    
    if type == 'all' || type == 'posts'
      posts = Post.search_by_content(query).public_posts.limit(20)
      results[:posts] = posts.map { |p| PostSerializer.new(p).as_json }
    end
    
    if params[:kink_tag].present?
      kink_tag = KinkTag.find_by(slug: params[:kink_tag])
      if kink_tag
        results[:kink_tag] = KinkTagSerializer.new(kink_tag).as_json
        results[:users_by_kink] = kink_tag.users.limit(20).map { |u| UserSerializer.new(u).as_json }
        results[:posts_by_kink] = kink_tag.posts.public_posts.limit(20).map { |p| PostSerializer.new(p).as_json }
        results[:groups_by_kink] = kink_tag.groups.where(is_active: true).limit(20).map { |g| GroupSerializer.new(g).as_json }
        results[:events_by_kink] = kink_tag.events.where(is_active: true).limit(20).map { |e| EventSerializer.new(e).as_json }
      end
    end
    
    render json: results
  end
end

