fs = require 'fs'
{Site} = require './models'
mongoose = require 'mongoose'
MONGO_URL = process.env.MONGOLAB_URI or 'mongodb://localhost/static-host' 
PORT = process.env.PORT or 3000
SITE_ADDRESS = process.env.URL or "http://localhost:#{PORT}/"

require('zappajs') PORT, ->
  console.error SITE_ADDRESS
  mongoose.connect MONGO_URL
  
  @enable 'default layout'
  @use 'bodyParser'

  @get '/': ->
    @render index: {SITE_ADDRESS:SITE_ADDRESS}
    
  sitesPrefix = "sites/"
  @get "/sites/:siteName/*": ->
    siteName = @request.params.siteName
    path = @request.url.replace "/#{sitesPrefix}#{siteName}/", ""
    if path.length==0
      path = "index.html"
    Site.fileForSiteWithPath siteName, path, (err, file) =>
      if err? or not file?
        @send 404
      else
        @response.set "Content-Type", file.mime 
        @send file.data

  @post '/publish': ->
    filename = @request.files.archive.filename
    path = @request.files.archive.path
    type = @request.files.archive.type
    site_name = @body.site_name.replace " ", "-"
    Site.upload site_name, path, () =>
      @render result: {
         site_name:site_name,
         sitesPrefix:sitesPrefix,
         SITE_ADDRESS:SITE_ADDRESS 
      }

  @view index: ->
    @title = 'Upload docs'
    h1 @title
    form method: 'post', action: '/publish', enctype:'multipart/form-data', ->
      input
        id: 'site_name'
        type: 'text'
        name: 'site_name'
        placeholder: 'Name'
        size: 50
        value: @site_name
      input
        id: 'archive'
        type: 'file'
        name: 'archive'
        placeholder: 'File'
        size: 50
        value: @archive
      button 'upload!'
    p "Or you can do that from commandline:"
    pre 'cat docs.zip |curl -F "site_name=somenamename" -F "archive=@-" '+@SITE_ADDRESS+'publish/'

  @view result: ->
    @title = 'Uploaded'
    h1 @title
    p @site_name
    a href: "#{@SITE_ADDRESS}#{@sitesPrefix}#{@site_name}/", -> "View site!"
      
