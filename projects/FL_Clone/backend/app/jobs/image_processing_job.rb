class ImageProcessingJob < ApplicationJob
  queue_as :default
  
  def perform(attachment_id)
    attachment = ActiveStorage::Attachment.find(attachment_id)
    
    # Process image variants
    attachment.variant(resize_to_limit: [800, 800]).processed
    attachment.variant(resize_to_limit: [400, 400]).processed
    attachment.variant(resize_to_limit: [200, 200]).processed
  end
end

