desc "Load up some fake Assets"
task :load_demo_assets => :environment do
  1.upto(100) do |i|
    # Group has many Assets.  Skipping for now.
    # group = Group.first_or_create :zooniverse_id => "GMZ#{ '%06d' % i }"
    
    thumb = "http://placehold.it/220x147"
    image = "http://placehold.it/600x400"
    name = "AMZ#{ '%06d' % i }"
    
    Asset.create(:zooniverse_id =>      name,                     # assigned by the data source
                 :name =>               name,                     # assigned by the data source
                 :location =>           image,                    # full-size image url
                 :thumbnail_location => thumb,                    # thumbnail image url
                 # :group_id =>         nil,                      # group.id would be here if we used it for this
                 :kind =>               "",                       # any kind of label you want to apply
                 :coords =>             [],                       # handy for location based data
                 :size =>               [ 600,
                                          400
                                        ])                        # the size of the full-size image (width, height)
  end
end
