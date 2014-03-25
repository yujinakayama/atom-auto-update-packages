AutoUpdatePackagesView = require './auto-update-packages-view'

module.exports =
  autoUpdatePackagesView: null

  activate: (state) ->
    @autoUpdatePackagesView = new AutoUpdatePackagesView(state.autoUpdatePackagesViewState)

  deactivate: ->
    @autoUpdatePackagesView.destroy()

  serialize: ->
    autoUpdatePackagesViewState: @autoUpdatePackagesView.serialize()
