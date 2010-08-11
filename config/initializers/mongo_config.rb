names = {'development' => 'dev', 'production' => 'prod', 'test' => 'test'}
MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017)#, :logger => Rails.logger)
MongoMapper.database = "sellers-#{names[Rails.env]}"
