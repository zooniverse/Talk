module DiscussionsHelper
  def discussion_link_for(focus, discussion)
    case focus.class.to_s
    when "Asset"
      link_to discussion.subject, object_discussion_path(focus.zooniverse_id, discussion.zooniverse_id)
    when "Collection"
      link_to discussion.subject, collection_discussion_path(focus.zooniverse_id, discussion.zooniverse_id)
    else "LiveCollection"
      link_to discussion.subject, live_collection_discussion_path(focus.zooniverse_id, discussion.zooniverse_id)
    end
  end
end
