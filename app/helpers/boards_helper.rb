module BoardsHelper
  def current_board_path(*args)
    return "" unless @board
    opts = args.extract_options!
    
    case @board.title
    when "help"
      help_board_path(opts)
    when "science"
      science_board_path(opts)
    when "chat"
      chat_board_path(opts)
    end
  end
end
