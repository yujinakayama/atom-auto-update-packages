PackageUpdater = null

module.exports =
  activate: (state) ->
    atom.workspaceView.command 'auto-update-packages:update-now', =>
      @updatePackages(false)

  deactivate: ->
    atom.workspaceView.off 'auto-update-packages:update-now'

  updatePackages: (isAutoUpdate = true) ->
    PackageUpdater ?= require './package-updater'
    PackageUpdater.updatePackages(isAutoUpdate)
