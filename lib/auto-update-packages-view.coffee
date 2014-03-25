{View} = require 'atom'

module.exports =
class AutoUpdatePackagesView extends View
  @content: ->
    @div class: 'auto-update-packages overlay from-top', =>
      @div "The AutoUpdatePackages package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "auto-update-packages:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "AutoUpdatePackagesView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
