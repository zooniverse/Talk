module Xapify
  include XapianFu
  
  module ClassMethods
    def xapify_fields(*args)
      opts = args.extract_options!
      
      class << self
        attr_accessor :xap_db, :xap_fields
      end
      
      @xap_fields = args
      @xap_db = Xapify::XapianDb.new(:dir => "#{Rails.root}/index/#{name}.db", :create => true, :store => args)
    end
  end

  module InstanceMethods
    def update_xapian
      db = self.class.xap_db
      inserted = nil
      
      db.transaction do
        doc_hash = {}
        doc_hash[:id] = self.xap_id
        self.class.xap_fields.each do |field|
          doc_hash[field.to_sym] = self.send(field.to_sym)
        end
        
        inserted = db.add_doc doc_hash
      end
      
      self.xap_id = inserted.id
    end
  end
  
  def self.configure(base)
    base.before_save :update_xapian
    base.key :xap_id, Fixnum
  end
end

MongoMapper::Plugins.send :include, Xapify
