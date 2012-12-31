{Site} = require './models'

# SITE_ADDRESS = process.env.URL or "http://localhost:#{PORT}/"
sitesPrefix = "sites/"

module.exports =
  home: (req, res, next)->
    res.render "home", {SITE_ADDRESS:SITE_ADDRESS}
  
  
  siteFile: (req,res, next) ->
    siteName = req.params.siteName
    path = req.url.replace "/#{sitesPrefix}#{siteName}/", ""
    if path.length==0
      path = "index.html"
    Site.fileForSiteWithPath siteName, path, (err, file) =>
      if err? or not file?
        res.send 404
      else
        res.set "Content-Type", file.mime 
        res.send file.data
        
  publish: (req,res, next)->
    filename = req.files.archive.filename
    path = req.files.archive.path
    type = req.files.archive.type
    site_name = req.body.site_name.replace " ", "-"
    Site.upload site_name, path, () =>
      res.render "result", {
         site_name:site_name,
         sitesPrefix:sitesPrefix,
         SITE_ADDRESS:SITE_ADDRESS 
      }