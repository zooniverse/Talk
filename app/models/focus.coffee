Spine = require 'spine'
{ project } = require 'lib/config'
Api = require 'zooniverse/lib/api'

class Focus extends Spine.Model
  @configure 'Focus'
  
  @findOrFetch: (focusId, callback) ->
    if @exists(focusId)
      callback @find(focusId)
    else
      @fetch focusId, (result) =>
        callback @create(result)
  
  @fetch: (focusId, callback) =>
    Api.get @urlFor(focusId), (result) =>
      result.id = result.zooniverse_id
      callback result
  
  @typeOf: (focusId) ->
    switch focusId[0]
      when 'A' then 'subjects'
      when 'B' then 'boards'
      when 'C' then 'collections'
      when 'G' then 'groups'
  
  @urlFor: (focusId) ->
    "/projects/#{ project }/talk/#{ @typeOf focusId }/#{ focusId }"
  
  constructor: (hash) ->
    super
  
  url: =>
    Focus.urlFor @id
  
  reload: =>
    Focus.fetch @id, (record) =>
      @load record
  
  focusType: =>
    Focus.typeOf @id


module.exports = Focus
