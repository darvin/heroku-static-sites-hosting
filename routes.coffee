{Site} = require './models'



module.exports =
  home: (req, res, next)->
    console.error req.user
    res.render "home" 
    
  
  siteFile: (req, res, next) ->
    siteName = req.params.siteName
    path = req.url.replace "/#{res.locals.sitesPrefix}#{siteName}/", ""
    if path.length==0
      path = "index.html"
    Site.fileForSiteWithPath siteName, path, (err, file) =>
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
    Site.upload siteName, path, () =>
      res.render "uploaded", {
          newSiteUrl:"#{res.locals.baseUrl}#{res.locals.sitesPrefix}#{siteName}/"
          siteName:siteName
      }