{BufferedProcess} = require 'atom'

INSTALLATION_LINE_PATTERN = /^Installing +([^@]+)@(\S+).+\s+(\S+)$/

module.exports =
  activate: (state) ->
    atom.workspaceView.command 'auto-update-packages:update-now', =>
      @updatePackages()

  deactivate: ->

  updatePackages: ->
    command = atom.packages.getApmPath()
    args = ['upgrade', '--no-confirm', '--no-color']

    log = ''

    stdout = (data) ->
      log += data

    exit = (exitCode) =>
      entries = @parseLog(log)
      console.log(entries) # TODO

    new BufferedProcess({command, args, stdout, exit})

  # Parsing the output of apm is a dirty way, but using atom-package-manager directly via JavaScript
  # is probably more brittle than parsing the output since it's a private package.
  # /Applications/Atom.app/Contents/Resources/app/apm/node_modules/atom-package-manager
  parseLog: (log) ->
    lines = log.split('\n')

    for line in lines
      matches = line.match(INSTALLATION_LINE_PATTERN)
      continue unless matches?
      [_match, name, version, result] = matches

      'name': name
      'version': version
      'isInstalled': result == '\u2713'
