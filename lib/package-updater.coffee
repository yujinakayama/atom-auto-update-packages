path = require 'path'
glob = require 'glob'
{BufferedProcess} = require 'atom'

ATOM_BUNDLE_IDENTIFIER = 'com.github.atom'
INSTALLATION_LINE_PATTERN = /^Installing +(\S+).+\s+(\S+)$/

titlecase = (string) ->
  string.replace(/\w+S*/g, (s) -> s[0].toUpperCase() + s[1..].toLowerCase())

undasherize = (string) ->
  string.replace(/-/g, ' ')

humanize = (string) ->
  titlecase(undasherize(string))

module.exports =
  updatePackages: (isAutoUpdate = true, blacklist = []) ->
    @runApmUpgrade blacklist, (log) =>
      entries = @parseLog(log)
      summary = @generateSummary(entries, isAutoUpdate)
      return unless summary
      @notify
        title: 'Atom Package Updates'
        message: summary
        sender: ATOM_BUNDLE_IDENTIFIER
        activate: ATOM_BUNDLE_IDENTIFIER

  runApmCommand: (args, callback) ->
    command = atom.packages.getApmPath()
    log = ''

    stdout = (data) ->
      log += data

    exit = (exitCode) ->
      callback(log)

    new BufferedProcess({command, args, stdout, exit})


  runApmUpgrade: (blacklist, callback) ->
    args = ['upgrade', '--list', '--json', '--no-color']

    @runApmCommand args, (log) =>
      packageList = JSON.parse(log)
      outdatedPackages = (pack.name for pack in packageList)

      if blacklist?.length
        outdatedPackages =
          pack for pack in outdatedPackages when humanize(pack) not in blacklist

      @runApmInstall outdatedPackages, callback

  runApmInstall: (packages, callback) ->
    args = ['install', '--no-color'].concat(packages)

    @runApmCommand args, callback

  # Parsing the output of apm is a dirty way, but using atom-package-manager directly via JavaScript
  # is probably more brittle than parsing the output since it's a private package.
  # /Applications/Atom.app/Contents/Resources/app/apm/node_modules/atom-package-manager
  parseLog: (log) ->
    lines = log.split('\n')

    for line in lines
      matches = line.match(INSTALLATION_LINE_PATTERN)
      continue unless matches?
      [_match, name, result] = matches

      'name': name
      'isInstalled': result == '\u2713'

  generateSummary: (entries, isAutoUpdate = true) ->
    successfulEntries = (entry for entry in entries when entry.isInstalled)
    return null unless successfulEntries.length > 0

    names = (humanize(entry.name) for entry in successfulEntries)

    summary =
      if successfulEntries.length <= 5
        @generateEnumerationExpression(names)
      else
        "#{successfulEntries.length} packages"

    summary += if successfulEntries.length == 1 then ' has' else ' have'
    summary += ' been updated'
    summary += ' automatically' if isAutoUpdate
    summary += '.'
    summary

  generateEnumerationExpression: (items) ->
    expression = ''

    for item, index in items
      if index > 0
        if index + 1 < items.length
          expression += ', '
        else
          expression += ', and '

      expression += item

    expression

  notify: (notification) ->
    command = @getTerminalNotifierPath()
    return console.log("terminal-notifier is not found.") unless command

    args = []
    for key, value of notification
      args.push("-#{key}", value)

    new BufferedProcess({command, args})

  getTerminalNotifierPath: ->
    unless @cachedTerminalNotifierPath?
      return @cachedTerminalNotifierPath

    pattern = path.join(__dirname, '..', 'vendor', '**', 'terminal-notifier')
    paths = glob.sync(pattern)

    @cachedTerminalNotifierPath = paths[0]
