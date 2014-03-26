fs = null
path = null
PackageUpdater = null

getFs = ->
  fs ?= require 'fs-plus'

second = (s) -> s * 1000
minute = (m) -> second(m * 60)
hour   = (h) -> minute(h * 60)

AUTO_UPDATE_CHECK_INTERVAL = minute(15)
AUTO_UPDATE_BLOCK_DURATION = hour(6)

module.exports =
  activate: (state) ->
    atom.workspaceView.command 'auto-update-packages:update-now', =>
      @updatePackages(false)

    @updatePackagesIfAutoUpdateBlockIsExpired()

    @autoUpdateCheck = setInterval =>
      @updatePackagesIfAutoUpdateBlockIsExpired()
    , AUTO_UPDATE_CHECK_INTERVAL

  deactivate: ->
    clearInterval(@autoUpdateCheck)
    atom.workspaceView.off 'auto-update-packages:update-now'

  updatePackagesIfAutoUpdateBlockIsExpired: ->
    lastUpdateTime = @loadLastUpdateTime() || 0
    if Date.now() > lastUpdateTime + AUTO_UPDATE_BLOCK_DURATION
      @updatePackages()

  updatePackages: (isAutoUpdate = true) ->
    PackageUpdater ?= require './package-updater'
    PackageUpdater.updatePackages(isAutoUpdate)
    @saveLastUpdateTime()

  # auto-upgrade-packages runs on each Atom instance,
  # so we need to share the last updated time via a file between the instances.
  loadLastUpdateTime: ->
    try
      string = getFs().readFileSync(@getLastUpdateTimeFilePath())
      parseInt(string)
    catch
      null

  saveLastUpdateTime: ->
    getFs().writeFileSync(@getLastUpdateTimeFilePath(), Date.now().toString())

  getLastUpdateTimeFilePath: ->
    path ?= require 'path'
    dotAtomPath = getFs().absolute('~/.atom')
    path.join(dotAtomPath, 'storage', 'auto-update-packages-last-update-time')
