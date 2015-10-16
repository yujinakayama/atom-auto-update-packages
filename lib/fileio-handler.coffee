# auto-upgrade-packages runs on each Atom instance,
# so we need to share the last updated time via a file between the instances.

fs = null
path = null
NAMESPACE = null

getFs = ->
  fs ?= require 'fs-plus'

module.exports =
  loadLastUpdateTime: ->
    try
      string = getFs().readFileSync(@getLastUpdateTimeFilePath())
      parseInt(string)
    catch
      null

  saveLastUpdateTime: ->
    getFs().writeFileSync(@getLastUpdateTimeFilePath(), Date.now().toString())

  setStoragePath: ->
    path ?= require 'path'
    dotAtomPath = getFs().absolute('~/.atom')
    path.join(dotAtomPath, 'storage/')

  getLastUpdateTimeFilePath: ->
    NAMESPACE ?= require('./auto-update-packages').namespace
    timestampFile = @setStoragePath() + "#{NAMESPACE}-last-update-time"
    timestampFile

  saveUpdateRecord: (packageUpdaterLog) ->
    NAMESPACE ?= require('./auto-update-packages').namespace
    historyFile = @setStoragePath() + "#{NAMESPACE}-update-history"
    getFs().appendFileSync(historyFile, packageUpdaterLog)
    console.log(packageUpdaterLog)
