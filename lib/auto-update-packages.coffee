fileIO = null
PackageUpdater = null

NAMESPACE = 'auto-update-packages'
WARMUP_WAIT = 10 * 1000
MINIMUM_AUTO_UPDATE_BLOCK_DURATION_MINUTES = 15

module.exports =
  config:
    intervalMinutes:
      type: 'integer'
      minimum: MINIMUM_AUTO_UPDATE_BLOCK_DURATION_MINUTES
      default: 6 * 60
      title: 'Auto-Update Interval Minutes'

  activate: (state) ->
    fileIO ?= require './fileio_handler'

    commands = {}
    commands["#{NAMESPACE}:update-now"] = => @updatePackages(false)
    @commandSubscription = atom.commands.add('atom-workspace', commands)

    setTimeout =>
      @enableAutoUpdate()
    , WARMUP_WAIT

  deactivate: ->
    @disableAutoUpdate()
    @commandSubscription?.dispose()
    @commandSubscription = null

  enableAutoUpdate: ->
    @updatePackagesIfAutoUpdateBlockIsExpired()

    @autoUpdateCheck = setInterval =>
      @updatePackagesIfAutoUpdateBlockIsExpired()
    , @getAutoUpdateCheckInterval()

    @configSubscription = atom.config.onDidChange =>
      @disableAutoUpdate()
      @enableAutoUpdate()

  disableAutoUpdate: ->
    @configSubscription?.dispose()
    @configSubscription = null

    clearInterval(@autoUpdateCheck) if @autoUpdateCheck
    @autoUpdateCheck = null

  updatePackagesIfAutoUpdateBlockIsExpired: ->
    lastUpdateTime = fileIO.loadLastUpdateTime() || 0
    if Date.now() > lastUpdateTime + @getAutoUpdateBlockDuration()
      @updatePackages()

  updatePackages: (isAutoUpdate = true) ->
    PackageUpdater ?= require './package-updater'
    PackageUpdater.updatePackages(isAutoUpdate)
    fileIO.saveLastUpdateTime()

  getAutoUpdateBlockDuration: ->
    minutes = atom.config.get("#{NAMESPACE}.intervalMinutes")

    if isNaN(minutes) || minutes < MINIMUM_AUTO_UPDATE_BLOCK_DURATION_MINUTES
      minutes = MINIMUM_AUTO_UPDATE_BLOCK_DURATION_MINUTES

    minutes * 60 * 1000

  getAutoUpdateCheckInterval: ->
    @getAutoUpdateBlockDuration() / 15
