class SubBoard < Board
  key :board_id, ObjectId, :required => true
  
  belongs_to :board
  
  def new_discussion_path(*args)
    new_board_discussion_path(self.board.title, self.title, args.extract_options!)
  end
  
  def discussion_path(*args)
    options = args.extract_options!
    raise ArgumentError unless args.first.respond_to?(:zooniverse_id)
    
    options.delete(:page) if options[:page] == 1
    options.delete(:per_page) if options[:per_page] == 10
    send("#{ self.board.title.downcase }_board_discussion_path", self.title.downcase, args.first.zooniverse_id, options)
  end
  
  def path(*args)
    send("#{ self.board.title.downcase }_board_path", self.title.downcase, args.extract_options!)
  end
end
