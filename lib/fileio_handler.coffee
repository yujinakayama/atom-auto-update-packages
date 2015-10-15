# auto-upgrade-packages runs on each Atom instance,
# so we need to share the last updated time via a file between the instances.

fs = null
path = null

NAMESPACE = 'auto-update-packages'

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
    @setStoragePath() + "#{NAMESPACE}-last-update-time"

  saveUpdateRecord: (packageUpdaterLog) ->
    historyFile = @setStoragePath() + "#{NAMESPACE}-update-history"
    getFs().appendFileSync(historyFile, packageUpdaterLog)
    console.log(packageUpdaterLog)
