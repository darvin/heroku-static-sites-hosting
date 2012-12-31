fs = require 'fs'
mongoose = require 'mongoose'
express = require 'express'
assets = require 'connect-assets'
routes = require './routes'


MONGO_URL = process.env.MONGOLAB_URI or 'mongodb://localhost/static-host' 
PORT = process.env.PORT or 3000
console.error "MONGO": MONGO_URL


mongoose.connect MONGO_URL

app = module.exports = express()

app.configure () ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session({ secret: 'your secret here' })
  app.use app.router 
  app.use express.static(__dirname + '/public')

app.configure 'development', () ->
  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

app.configure 'production', () ->
  app.use express.errorHandler()


app.get '/', routes.home
    
app.get "/sites/:siteName/*", routes.siteFile

app.post '/publish', routes.publish
    
app.listen PORT, ()->
  return console.log "Listening on #{PORT}\nPress CTRL-C to stop server."


###
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
###  
