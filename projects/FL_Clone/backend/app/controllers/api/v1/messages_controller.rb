class Api::V1::MessagesController < ApplicationController
  def index
    conversation = Conversation.find(params[:conversation_id])
    authorize_conversation_access(conversation)
    
    messages = conversation.messages.includes(:user).order(created_at: :asc)
    render json: messages.map { |m| MessageSerializer.new(m).as_json }
  end
  
  def create
    conversation = find_or_create_conversation
    
    message = conversation.messages.build(
      user: current_user,
      content: params[:content]
    )
    
    if message.save
      render json: MessageSerializer.new(message).as_json, status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  
  def find_or_create_conversation
    recipient = User.find(params[:recipient_id])
    
    Conversation.find_or_create_by(
      sender: [current_user, recipient].min_by(&:id),
      recipient: [current_user, recipient].max_by(&:id)
    ) do |conv|
      conv.last_message_at = Time.current
    end
  end
  
  def authorize_conversation_access(conversation)
    unless conversation.sender == current_user || conversation.recipient == current_user
      render json: { error: 'Not authorized' }, status: :forbidden
    end
  end
end

