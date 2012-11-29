{ project } = require 'lib/config'
Api = require 'zooniverse/lib/api'

class Focus
  @records = { }
  
  @findOrFetch: (focusId, callback) =>
    if @exists(focusId)
      callback @find(focusId)
    else
      @fetch focusId, callback
  
  @fetch: (focusId, callback) =>
    Api.get @urlFor(focusId), (result) =>
      @records[focusId] = new Focus(result)
      callback result
  
  @exists: (id) =>
    !!@records[id]
  
  @typeOf: (focusId) ->
    switch focusId[0]
      when 'A' then 'subjects'
      when 'B' then 'boards'
      when 'C' then 'collections'
      when 'G' then 'groups'
  
  @urlFor: (focusId) ->
    "/projects/#{ project }/talk/#{ @typeOf focusId }/#{ focusId }"
  
  constructor: (hash) ->
    for own key, val of hash
      @[key] = val
  
  url: =>
    Focus.urlFor @zooniverse_id
  
  reload: =>
    Focus.fetch @zooniverse_id, (record) =>
      Focus.records[record.zooniverse_id] = record
  
  focusType: =>
    Focus.typeOf @zooniverse_id


module.exports = Focus
