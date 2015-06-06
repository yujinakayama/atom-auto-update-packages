originalPackageConfig = atom.config.get('auto-update-packages')

window.restoreEnvironment = ->
  atom.config.set('auto-update-packages', originalPackageConfig)
