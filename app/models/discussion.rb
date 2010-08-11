class Discussion
  include MongoMapper::Document
  
  key :subject, String, :required => true
  key :tags, Array
  key :assets, Array # mentioned Assets, i.e. not the focus and also not a collection
  timestamps!
  
  many :comments
  belongs_to :focus, :polymorphic => true
end
