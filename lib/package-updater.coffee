path = require 'path'
glob = require 'glob'
{BufferedProcess} = require 'atom'
S = require './util/string'

ATOM_BUNDLE_IDENTIFIER = 'com.github.atom'
INSTALLATION_LINE_PATTERN = /^Installing +(\S+).+\s+(\S+)$/

module.exports =
  updatePackages: (@options={}) ->
    @runApmUpgrade (log) =>
      entries = @parseLog(log)
      summary = @generateSummary(entries)
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

  runApmUpgrade: (callback) ->
    args = ['upgrade', '--list', '--json', '--no-color']

    @runApmCommand args, (log) =>
      blacklist = @options.blacklist
      packageList = JSON.parse(log)
      outdatedPackages = (pack.name for pack in packageList)

      if blacklist?.length
        outdatedPackages = @filterPackages(outdatedPackages)

      @runApmInstall outdatedPackages, callback

  runApmInstall: (packages, callback) ->
    args = ['install', '--no-color'].concat(packages)

    @runApmCommand args, callback

  filterPackages: (packages) ->
    blacklist = @options.blacklist
    pack for pack in packages when @formatPackageName(pack) not in blacklist

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

  generateSummary: (entries) ->
    successfulEntries = entries.filter (entry) ->
      entry.isInstalled
    return null unless successfulEntries.length > 0

    names = successfulEntries.map (entry) =>
      @formatPackageName(entry.name)

    summary =
      if successfulEntries.length <= 5
        @generateEnumerationExpression(names)
      else
        "#{successfulEntries.length} packages"

    summary += if successfulEntries.length == 1 then ' has' else ' have'
    summary += ' been updated'
    summary += ' automatically' if @options.auto
    summary += '.'
    summary

  formatPackageName: (packageName) ->
    if @options.humanize
      S.humanize(packageName)
    else
      packageName

  generateEnumerationExpression: (items) ->
    expression = ''

    for item, index in items
      if index > 0
        if index + 1 < items.length
          expression += ', '
        else
          expression += ',' if items.length > 2
          expression += ' and '

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
    unless @cachedTerminalNotifierPath == undefined
      return @cachedTerminalNotifierPath

    pattern = path.join(__dirname, '..', 'vendor', '**', 'terminal-notifier')
    paths = glob.sync(pattern)

    @cachedTerminalNotifierPath =
      if paths.length == 0
        null
      else
        paths[0]
