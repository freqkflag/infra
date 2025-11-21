class Api::V1::EventsController < ApplicationController
  def index
    events = Event.where(is_active: true).includes(:user, :attendees)
    events = events.upcoming if params[:upcoming] == 'true'
    events = events.past if params[:past] == 'true'
    
    render json: events.map { |e| EventSerializer.new(e).as_json }
  end
  
  def show
    event = Event.find(params[:id])
    render json: EventSerializer.new(event).as_json
  end
  
  def create
    event = current_user.events.build(event_params)
    event.start_time = Time.parse(params[:start_time]) if params[:start_time]
    event.end_time = Time.parse(params[:end_time]) if params[:end_time]
    
    if event.save
      attach_kink_tags(event) if params[:kink_tags]
      render json: EventSerializer.new(event).as_json, status: :created
    else
      render json: { errors: event.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def update
    event = Event.find(params[:id])
    authorize_event_owner(event)
    
    if event.update(event_params)
      render json: EventSerializer.new(event).as_json
    else
      render json: { errors: event.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def destroy
    event = Event.find(params[:id])
    authorize_event_owner(event)
    event.update(is_active: false)
    render json: { message: 'Event cancelled' }, status: :ok
  end
  
  def rsvp
    event = Event.find(params[:id])
    rsvp = event.event_rsvps.find_or_initialize_by(user: current_user)
    rsvp.status = params[:status] || 'going'
    
    if rsvp.save
      render json: { message: 'RSVP updated' }, status: :ok
    else
      render json: { errors: rsvp.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def cancel_rsvp
    event = Event.find(params[:id])
    rsvp = event.event_rsvps.find_by(user: current_user)
    rsvp&.destroy
    render json: { message: 'RSVP cancelled' }, status: :ok
  end
  
  def attendees
    event = Event.find(params[:id])
    render json: event.attendees.map { |a| UserSerializer.new(a).as_json }
  end
  
  private
  
  def event_params
    params.require(:event).permit(:title, :description, :location, :venue, :latitude, :longitude, :privacy, :max_attendees)
  end
  
  def attach_kink_tags(event)
    tag_slugs = params[:kink_tags].is_a?(Array) ? params[:kink_tags] : params[:kink_tags].split(',')
    tag_slugs.each do |slug|
      tag = KinkTag.find_by(slug: slug.strip)
      if tag
        event.kink_taggings.find_or_create_by(kink_tag: tag)
      end
    end
  end
  
  def authorize_event_owner(event)
    unless event.user == current_user
      render json: { error: 'Not authorized' }, status: :forbidden
    end
  end
end

