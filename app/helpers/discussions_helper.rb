module DiscussionsHelper
  def title_for(focus)
    if focus.is_a?(Board) || focus.is_a?(SubBoard)
      link = link_to focus.pretty_title, focus_url_for(focus)
      "#{ I18n.t('discussion.board.new') } #{ link } #{ I18n.t('discussion.board.discussion') }".html_safe
    else
      link = link_to I18n.t("#{ focus.class.name.downcase }.name"), focus_url_for(focus)
      "#{ I18n.t('discussion.startnew') } #{ I18n.t('discussion.about') } #{ link }".html_safe
    end
  end
  
  def focus_url_for(focus)
    case focus.class.name
    when "Asset"
      object_path(focus.zooniverse_id)
    when "Group"
      group_path(focus.zooniverse_id)
    when "AssetSet", "KeywordSet"
      collection_path(focus.zooniverse_id)
    when "Board", "SubBoard"
      focus.path
    end
  end
end
