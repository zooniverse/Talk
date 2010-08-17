module ZooniverseId
  def self.included(base)
    base.cattr_accessor :zoo_id_options
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end
  
  module ClassMethods
    def zoo_id(*args)
      self.zoo_id_options = { :prefix => "A", :site => "MZ", :sub_id => "1" }
      self.zoo_id_options = self.zoo_id_options.update(args.first) unless args.first.nil?
      self.key :zooniverse_id, String
      self.before_create :set_zoo_id
    end
  end
  
  module InstanceMethods
    private
    def set_zoo_id
      last_one = self.class.limit(1).sort(['zooniverse_id', -1]).all(:zooniverse_id => /^#{zoo_id_prefix}/).first
      last_id = last_one.nil? ? "#{zoo_id_prefix}000000" : last_one.zooniverse_id
      self.zooniverse_id = increment_zoo_id_from last_id
    end
    
    def zoo_id_prefix
      self.class.zoo_id_options.values.join
    end
    
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