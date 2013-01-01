{Site} = require './models'



module.exports =
  home: (req, res, next)->
    res.render "home" 
  
  list: (req, res, next)->
    Site.sitesForUser req.user.username, (err, sites) ->
      if err
        return next(err)
      console.error sites
      res.render "list", {sites:sites}   
  
  siteFile: (req, res, next) ->
    siteName = req.params.siteName
    path = req.url.replace "/#{res.locals.sitesPrefix}#{siteName}/", ""
    if path.length==0
      path = "index.html"
    Site.fileForSiteWithPathForUser siteName, path, req.user.username, (err, file) =>
      if err? or not file?
        res.send 404
      else
        res.set "Content-Type", file.mime 
        res.send file.data
        
  publish: (req, res, next)->
    filename = req.files.archive.filename
    path = req.files.archive.path
    type = req.files.archive.type
    siteName = req.body.siteName.replace " ", "-"

    users = (user for user in req.body.users.split /[\s|,]+/ when user.length>0)
    
    if req.body.onlyMe? 
      if not req.user?
        return res.redirect "/auth/github"
      users = [req.user.username]
    else if req.user?
      users.push req.user.username



    Site.upload siteName, path, users, () =>
      res.render "uploaded", {
          siteName:siteName
      }