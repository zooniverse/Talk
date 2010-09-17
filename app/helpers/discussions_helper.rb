module DiscussionsHelper
  def title_for(focus)
    title = ""
    
    if focus.is_a? Board
      title = "#{ I18n.t('discussion.board.new') } " +
      link_to(I18n.t("discussion.board.#{ focus.title }"), focus_url_for(focus)) +
      " #{ I18n.t('discussion.board.discussion') }"
    else
      title = "#{ I18n.t('discussion.startnew') } " +
      "#{ I18n.t('discussion.about') } " +
      link_to(I18n.t("#{ focus.class.name.downcase }.name"), focus_url_for(focus))
    end
    
    title.html_safe
  end
  
  def focus_url_for(focus)
    case focus.class.name
    when "Asset"
      object_path(focus.zooniverse_id)
    when "Collection", "LiveCollection"
      collection_path(focus.zooniverse_id)
    when "Board"
      "/#{focus.title}"
    end
  end
end
