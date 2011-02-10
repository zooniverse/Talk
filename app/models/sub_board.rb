class SubBoard < Board
  key :board_id, ObjectId, :required => true
  key :position, Integer, :default => 0
  
  validates_uniqueness_of :title, :scope => :board_id
  
  belongs_to :board
  
  alias_method :parent, :board
  alias_method :parent=, :board=
  
  def new_discussion_path(*args)
    new_board_discussion_path(self.board.title, self.title, args.extract_options!)
  end
  
  def discussion_path(*args)
    options = args.extract_options!
    raise ArgumentError unless args.first.respond_to?(:zooniverse_id)
    erase_default_options_from(options)
    
    send("#{ self.board.title }_board_discussion_path", self.title, args.first.zooniverse_id, options)
  end
  
  def path(*args)
    options = args.extract_options!
    erase_default_options_from(options)
    send("#{ self.board.title }_board_path", self.title, options)
  end
  
  def archive_and_destroy_as(destroying_user)
    archive = Archive.new({
      :kind => "SubBoard",
      :original_id => self.id,
      :zooniverse_id => nil,
      :user_id => nil,
      :destroying_user_id => destroying_user.id
    })
    
    original = self.to_mongo
    original['discussions'] = self.discussions.collect(&:to_embedded_hash)
    archive.original_document = original
    
    if archive.save
      self.discussions.each(&:destroy)
      self.destroy
      return true
    end
    
    false
  end
end
