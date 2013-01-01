fs = require 'fs'
mongoose = require 'mongoose'
express = require 'express'
assets = require 'connect-assets'
routes = require './routes'

passport = require('passport')
util = require('util')
GitHubStrategy = require('passport-github').Strategy


MONGO_URL = process.env.MONGOLAB_URI or 'mongodb://localhost/static-host' 
PORT = process.env.PORT or 3000
SITE_ADDRESS = process.env.URL or "http://localhost:#{PORT}/"
console.error "MONGO": MONGO_URL

GITHUB_CLIENT_ID = "f15ae9632df15da60546"
GITHUB_CLIENT_SECRET = "c85b88930ba046f4b91dd1d5f025cefd7287527a"
GITHUB_CALLBACK_URL = "#{SITE_ADDRESS}auth/github/callback"
mongoose.connect MONGO_URL

app = module.exports = express()



#### Auth stuff

passport.serializeUser (user, done) ->
  done(null, user);

passport.deserializeUser (obj, done) ->
  done(null, obj);

passport.use(new GitHubStrategy({
    clientID: GITHUB_CLIENT_ID,
    clientSecret: GITHUB_CLIENT_SECRET,
    callbackURL: GITHUB_CALLBACK_URL
  },
  (accessToken, refreshToken, profile, done)  ->
    process.nextTick () ->
      done(null, profile)
))


app.configure () ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session({ secret: 'your secret here' })
  app.use passport.initialize()
  app.use passport.session()

  app.use (req,res,next) ->
    res.locals.baseUrl = SITE_ADDRESS
    res.locals.sitesPrefix = "sites/"
    res.locals.user = req.user
    next()
  app.use app.router 
  app.use express.static(__dirname + '/public')

app.configure 'development', () ->
  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

app.configure 'production', () ->
  app.use express.errorHandler()


ensureAuthenticated  = (req, res, next) ->
  if (req.isAuthenticated())
    return next()
  res.redirect '/auth/github'


app.get '/',  routes.home
app.get '/list', ensureAuthenticated, routes.list
app.get "/sites/:siteName/*", ensureAuthenticated, routes.siteFile
app.post '/publish', routes.publish
    
app.get '/auth/github', passport.authenticate('github')
app.get '/auth/github/callback', passport.authenticate('github', {failureRedirect:"/?login-error",successRedirect:"/"})
app.get '/logout', (req, res)->
  req.logout()
  res.redirect('/')

app.listen PORT, ()->
  return console.log "Listening on #{PORT}\nPress CTRL-C to stop server."
  

