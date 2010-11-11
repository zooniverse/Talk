# Have to use ActiveRecord so that New Relic shows it on all graphs. 
# The push scope false stuff makes it so that you can track usage by model and overall. 
if defined?(NewRelic)
  module MongoMapperNewRelic
    def self.included(model)
      mm_class_methods = [
        :find,
        :find!,
        :paginate,
        :first,
        :last,
        :all,
        :count,
        :create,
        :create!,
        :update,
        :delete,
        :delete_all,
        :destroy,
        :destroy_all,
        :exists?,
        :find_by_id,
        :increment,
        :decrement,
        :set,
        :push,
        :push_all,
        :push_uniq,
        :pull,
        :pull_all
      ]

      model.singleton_class.class_eval do
        mm_class_methods.each do |method_name|
          add_method_tracer method_name, 'ActiveRecord/#{self.name}/' + method_name.to_s
          add_method_tracer method_name, "ActiveRecord/#{method_name}", :push_scope => false
          add_method_tracer method_name, "ActiveRecord/all", :push_scope => false
        end
      end

      model.class_eval do
        add_method_tracer :save, 'ActiveRecord/#{self.class.name}/save'
        add_method_tracer :save, 'ActiveRecord/save', :push_scope => false
        add_method_tracer :save, 'ActiveRecord/all',  :push_scope => false
      end
    end
  end

  MongoMapper::Document.append_inclusions(MongoMapperNewRelic)
end
