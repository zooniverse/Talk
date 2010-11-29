# Zooniverse Id generator
module ZooniverseId
  # Extends a class with automatic zoo id generation
  def self.included(base)
    base.class_eval do
      class << self
        # This must be set as a class instance variable since we're using STI
        attr_accessor :zoo_id_options
      end
    end
    
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end
  
  # Adds class macros
  module ClassMethods
    # To produce a zooniverse_id of "AMZ...":
    #   zoo_id :prefix => 'A', :site => 'MZ', :sub_id => '1'
    def zoo_id(*args)
      self.zoo_id_options = { :prefix => "A", :site => "MZ", :sub_id => "1" }.update(args.extract_options!)
      self.key :zooniverse_id, String
      self.before_create :set_zoo_id
    end
  end
  
  # callback methods
  module InstanceMethods
    private
    # assigns a zooniverse_id to a new record
    def set_zoo_id
      last_one = self.class.sort(:zooniverse_id.desc).first(:zooniverse_id => /^#{zoo_id_prefix}/)
      last_id = last_one.nil? ? "#{zoo_id_prefix}000000" : last_one.zooniverse_id
      self.zooniverse_id = increment_zoo_id_from last_id
    end
    
    # prefixes the id with AMZ
    def zoo_id_prefix
      self.class.zoo_id_options.values.join
    end
    
    # increments from the last generated id on this sub_id
    def increment_zoo_id_from(id)
      incremented = false
      
      id.reverse.each_char.with_index do |b, pos|
        break if incremented
        
        if b == "9"
          id[-pos - 1] = "a"
          incremented = true
        elsif b == ?z
          id[-pos - 1] = "0"
        else
          id[-pos - 1] = b.next.chr
          incremented = true
        end
      end
      
      id
    end
  end
end