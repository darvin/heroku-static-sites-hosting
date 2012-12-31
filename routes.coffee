{Site} = require './models'



module.exports =
  home: (req, res, next)->
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
    site_name = req.body.site_name.replace " ", "-"
    Site.upload site_name, path, () =>
      res.render "uploaded", {
          newSiteUrl:"#{res.locals.siteUrl}#{res.locals.sitesPrefix}#{site_name}/"
          site_name:site_name
      }