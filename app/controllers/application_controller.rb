# Application-wide methods
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_or_create_zooniverse_user
  before_filter :check_for_banned_user, :except => :cas_logout
  
  rescue_from BSON::InvalidObjectId, :with => :not_found
  rescue_from MongoMapper::DocumentNotFound, :with => :not_found
  
  # Catch not found errors gracefully
  def not_found
    render :file => "#{ Rails.root }/public/404.html", :status => :not_found
  end
  
  # Handy for setting default ivar values
  # @param *args [Array] The list of key-val pairs
  def default_params(*args)
    hash = args.extract_options!
    
    hash.each_pair do |param, default|
      value = params[param] ? params[param] : default
      
      case default
      when TrueClass, FalseClass
        value = (value == "true")
      when Integer, Fixnum
        value = value.to_i
      when Float
        value = value.to_f
      end
      
      instance_variable_set "@#{ param.to_s }", value
    end
  end
  
  # Ensure Id's are stored as BSON::ObjectId's
  # @param id [String, BSON::ObjectId] The Id
  def id_for(id)
    id.is_a?(String) ? BSON::ObjectId(id) : id
  end
  
  # Render text as markdown
  # @param text [String] The markup text
  def markdown(text)
    formatted = text.gsub(/#/m, '\#').gsub(/[\r\n]/, "\n\n")
    output = BlueCloth::new(formatted, :escape_html => true, :auto_links => true).to_html
    tags = ["h1","h2","h3","h4","h5","h6"]
    tags.each do |tag|
      output.gsub!(/<#{tag}\b[^>]*>(.*?)<\/#{tag}>/im, '\1')
    end
    
    return output
  end
  helper_method :markdown
  
  # True if User is privileged, redirects with flash otherwise
  def require_privileged_user
    unless current_zooniverse_user && current_zooniverse_user.privileged?
      flash[:notice] = t 'controllers.application.not_authorised'
      redirect_to root_url
      return false
    end
    
    true
  end
  
  # True if User has read/write privileges, redirects with flash otherwise
  # @param method [Symbol] The verification method
  # @param document The document to be checked against
  def moderator_or_owner(method, document)
    unless current_zooniverse_user && current_zooniverse_user.send(method, document)
      flash[:notice] = t 'controllers.application.not_yours'
      redirect_to root_url
      return false
    end
    
    true
  end
  
  # Log out
  def cas_logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end
  helper_method :cas_logout
  
  # Log in
  def cas_login
    "#{CASClient::Frameworks::Rails::Filter.client.login_url}?service=http%3A%2F%2F#{ request.host_with_port }#{ request.fullpath }"
  end
  helper_method :cas_login
  
  # Displays flash errors for documents
  # @param *docs [Array] The list of documents being validated
  def flash_model_errors_on(*docs)
    messages = []
    docs.each do |doc|
      messages << doc.errors.full_messages.map{ |e| "<li>#{e}</li>" }.join if doc.errors.respond_to?(:full_messages) && doc.errors.any?
    end
    
    flash[:alert] = "<ul>#{ messages.join }</ul>".html_safe if messages.any?
  end
  helper_method :flash_model_errors_on
  
  protected
  # The current User (cookie)
  def zooniverse_user
    session[:cas_user]
  end
  
  # The current User Id (cookie)
  def zooniverse_user_id
    session[:cas_extra_attributes]['id']
  end
  
  # The current User email (cookie)
  def zooniverse_user_email
    session[:cas_extra_attributes]['email']
  end
  
  # The current User (Document)
  def current_zooniverse_user
    @current_zooniverse_user ||= (User.find_by_zooniverse_user_id(zooniverse_user_id) if zooniverse_user)
  end
  helper_method :current_zooniverse_user
  
  # Set the current User or create it
  def check_or_create_zooniverse_user
    if zooniverse_user
      if user = User.find_by_zooniverse_user_id(zooniverse_user_id)
        user.attributes.update(:name => zooniverse_user, :email => zooniverse_user_email)
        user.save if user.changed?
      else
        User.create(:zooniverse_user_id => zooniverse_user_id, :name => zooniverse_user, :email => zooniverse_user_email)
      end
    end
  end
  
  # Ensure the current User isn't Banned, redirect with flash if they are
  def check_for_banned_user
    if current_zooniverse_user
      if current_zooniverse_user.state == "banned"
        flash[:notice] = t 'controllers.home.banned'
        redirect_to root_url
      end
    end
  end
end
