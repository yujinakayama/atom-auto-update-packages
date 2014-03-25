AutoUpdatePackages = require '../lib/auto-update-packages'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "AutoUpdatePackages", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('autoUpdatePackages')

  describe "when the auto-update-packages:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.auto-update-packages')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'auto-update-packages:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.auto-update-packages')).toExist()
        atom.workspaceView.trigger 'auto-update-packages:toggle'
        expect(atom.workspaceView.find('.auto-update-packages')).not.toExist()
