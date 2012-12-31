fs = require 'fs'
mongoose = require 'mongoose'
express = require 'express'
assets = require 'connect-assets'
routes = require './routes'


MONGO_URL = process.env.MONGOLAB_URI or 'mongodb://localhost/static-host' 
PORT = process.env.PORT or 3000
SITE_ADDRESS = process.env.URL or "http://localhost:#{PORT}/"
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
  app.use (req,res,next) ->
    res.locals.siteUrl = SITE_ADDRESS
    res.locals.sitesPrefix = "sites/"
    next()

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
  

