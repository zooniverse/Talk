module Xapify
  include XapianFu
  
  module ClassMethods
    def xapify_fields(*args)
      opts = args.extract_options!
      
      class << self
        attr_accessor :xap_db, :xap_fields
      end
      
      @xap_fields = {}
      args.each do |arg|
        @xap_fields[arg.to_sym] = { :store => true, :type => keys[arg.to_s].type }
      end
      
      @xap_db = Xapify::XapianDb.new(:dir => "#{Rails.root}/index/#{name}.db", :create => true, :fields => @xap_fields)
    end
    
    def search(searchString)
       db = @xap_db
       docs=db.search(searchString)
       docs.collect do |d|
          hash ={}
          @xap_fields.each do |k|
            hash[k]=d.values[k]
          end 
          hash
       end
    end
  end

  module InstanceMethods
    def update_xapian
      db = self.class.xap_db
      inserted = nil
      
      doc_hash = {}
      doc_hash[:id] = self.xap_id
      self.class.xap_fields.each do |field|
        doc_hash[field.first.to_sym] = self.send(field.first.to_sym)
      end
      
      inserted = db.add_doc doc_hash
      self.xap_id = inserted.id
    end
  end
  
  def self.configure(base)
    base.before_save :update_xapian
    base.key :xap_id, Fixnum
  end
  
  
end

MongoMapper::Plugins.send :include, Xapify
