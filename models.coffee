mongoose = require 'mongoose'

mime = require 'mime'

ObjectId = mongoose.Types.ObjectId
Schema = mongoose.Schema
fs = require 'fs'
AdmZip = require 'adm-zip'



# Site model
Site = new mongoose.Schema(
  _id: String,
  prefix: String
)

# File model
File = new mongoose.Schema(
  _id: String
  data: Buffer
  mime: String
,{capped:1024})


File.statics.createFromZipEntry = (zipEntry) ->
  if zipEntry.isDirectory
    return
  mimeType = mime.lookup(zipEntry.entryName)
  zipEntry.getDataAsync (data) =>
    this.create {_id:zipEntry.entryName, data:data, mime:mimeType}, (err,file) ->
      if err
        console.error err
      
      

Site.methods.fileModel = () ->
  mongoose.model "File", File, "files-#{this._id}"

Site.statics.upload = (name, filename, callback) ->
  zip = new AdmZip filename
  zipEntries = zip.getEntries()
  prefix = null
  zipEntries.forEach (entry) ->
    if not prefix? or entry.entryName.length<prefix.length
      prefix = entry.entryName

  this.findOneAndUpdate {_id:name}, {prefix:prefix}, {upsert:true}, (err,site) ->
    if err
      console.error err
      callback (err)
      return
    
    zipEntries.forEach (zipEntry) ->
      fileModel = site.fileModel()
      fileModel.collection.drop (err, result) ->  
        fileModel.createFromZipEntry(zipEntry)
            
    callback(err, site)
  
Site.statics.fileForSiteWithPath = (siteName, filepath, callback) ->
  this.findOne {_id:siteName}, (err, site) ->
    if err?
      return callback err
    else if not site?
      return callback "NotFound"
    else
      fileModel = site.fileModel()
      fileModel.findOne {_id:"#{site.prefix}#{filepath}"}, callback

module.exports.Site = mongoose.model 'Site', Site

