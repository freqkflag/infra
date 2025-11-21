class Api::V1::ConversationsController < ApplicationController
  def index
    conversations = Conversation.where(sender: current_user)
      .or(Conversation.where(recipient: current_user))
      .includes(:sender, :recipient, :messages)
      .order(last_message_at: :desc)
    
    render json: conversations.map { |c| ConversationSerializer.new(c, current_user: current_user).as_json }
  end
  
  def show
    conversation = Conversation.find(params[:id])
    authorize_conversation_access(conversation)
    
    conversation.messages.where.not(user: current_user).update_all(is_read: true, read_at: Time.current)
    
    render json: ConversationSerializer.new(conversation, current_user: current_user).as_json
  end
  
  def create
    recipient = User.find(params[:recipient_id])
    
    conversation = Conversation.find_or_create_by(
      sender: [current_user, recipient].min_by(&:id),
      recipient: [current_user, recipient].max_by(&:id)
    )
    
    render json: ConversationSerializer.new(conversation, current_user: current_user).as_json
  end
  
  private
  
  def authorize_conversation_access(conversation)
    unless conversation.sender == current_user || conversation.recipient == current_user
      render json: { error: 'Not authorized' }, status: :forbidden
    end
  end
end

