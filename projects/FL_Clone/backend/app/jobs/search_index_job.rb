class SearchIndexJob < ApplicationJob
  queue_as :default
  
  def perform(searchable_id, searchable_type)
    searchable = searchable_type.constantize.find(searchable_id)
    
    # Index for search (if using Elasticsearch or similar)
    # For now, pg_search handles this automatically
  end
end

