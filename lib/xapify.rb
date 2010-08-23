module Xapify
  include XapianFu
  
  module ClassMethods
    def xapify_fields(*args)
      opts = args.extract_options!
      
      class << self
        attr_accessor :xap_db, :xap_fields
      end
      
      @xap_fields = {:_id=>{:store=>true, :type=>String}}
      args.each do |arg|
        @xap_fields[arg.to_sym] = { :store => true, :type => keys[arg.to_s].type }
      end
      
      Dir.mkdir("#{Rails.root}/index") unless File.exists?("#{Rails.root}/index")
      Dir.mkdir("#{Rails.root}/index/#{Rails.env}") unless File.exists?("#{Rails.root}/index/#{Rails.env}")
      
      @xap_db = Xapify::XapianDb.new(:dir => "#{Rails.root}/index/#{Rails.env}/#{name}.db", :create => true, :fields => @xap_fields)
    end

    def search(string)
      db = @xap_db
      
      collected = db.search(string, opts).collect do |doc|
        hash = {}
        @xap_fields.each_key do |key|
          hash[key] = doc.values[key]
        end
        
        hash[:collapse_count] = doc.match.collapse_count if opts.has_key?(:collapse)
        hash
      end
      
      collected = collected.sort{ |a, b| b[:collapse_count] <=> a[:collapse_count] } if opts.has_key?(:collapse)
      collected = collected.map{ |doc| find(doc[:_id]) } if opts[:from_mongo]
      collected
    end
  end

  module InstanceMethods
    def update_xapian
      update_timestamps if new?
      db = self.class.xap_db
      
      doc_hash = {}
      doc_hash[:id] = self.xap_id
      self.class.xap_fields.each do |field|
        doc_hash[field.first.to_sym] = self.send(field.first.to_sym) unless field== :_id
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
