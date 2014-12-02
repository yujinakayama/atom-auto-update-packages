fs = null
path = null
PackageUpdater = null

getFs = ->
  fs ?= require 'fs-plus'

NAMESPACE = 'auto-update-packages'
CONFIG_KEY_INTERVAL_MINUTES = 'intervalMinutes'
CONFIG_KEY_HUMANIZED_PACKAGE_NAMES = 'humanizedPackageNames'
CONFIG_KEY_DISABLE_NOTIFICATION = 'disableNotification'
CONFIG_KEY_BLACKLIST = 'blacklist'

CONFIG_DEFAULTS = {}
CONFIG_DEFAULTS[CONFIG_KEY_INTERVAL_MINUTES] = 6 * 60
CONFIG_DEFAULTS[CONFIG_KEY_HUMANIZED_PACKAGE_NAMES] = false
CONFIG_DEFAULTS[CONFIG_KEY_DISABLE_NOTIFICATION] = false
CONFIG_DEFAULTS[CONFIG_KEY_BLACKLIST] = []

WARMUP_WAIT = 10 * 1000
MINIMUM_AUTO_UPDATE_BLOCK_DURATION_MINUTES = 15

module.exports =
  configDefaults: CONFIG_DEFAULTS

  activate: (state) ->
    atom.workspaceView.command "#{NAMESPACE}:update-now", =>
      @updatePackages(false)

    setTimeout =>
      @enableAutoUpdate()
    , WARMUP_WAIT

  deactivate: ->
    @disableAutoUpdate()
    atom.workspaceView.off "#{NAMESPACE}:update-now"

  enableAutoUpdate: ->
    @updatePackagesIfAutoUpdateBlockIsExpired()

    @autoUpdateCheck = setInterval =>
      @updatePackagesIfAutoUpdateBlockIsExpired()
    , @getAutoUpdateCheckInterval()

    @configSubscription = atom.config.observe NAMESPACE, callNow: false, =>
      @disableAutoUpdate()
      @enableAutoUpdate()

  disableAutoUpdate: ->
    @configSubscription?.off()
    @configSubscription = null

    clearInterval(@autoUpdateCheck) if @autoUpdateCheck
    @autoUpdateCheck = null

  updatePackagesIfAutoUpdateBlockIsExpired: ->
    lastUpdateTime = @loadLastUpdateTime() || 0
    if Date.now() > lastUpdateTime + @getAutoUpdateBlockDuration()
      @updatePackages()

  updatePackages: (isAutoUpdate=true) ->
    PackageUpdater ?= require './package-updater'
    humanizedPackageNames =
      atom.config.get("#{NAMESPACE}.#{CONFIG_KEY_HUMANIZED_PACKAGE_NAMES}")
    blacklist = atom.config.get("#{NAMESPACE}.#{CONFIG_KEY_BLACKLIST}")
    disableNotification = atom.config.get("#{NAMESPACE}.#{CONFIG_KEY_DISABLE_NOTIFICATION}")
    options =
      auto: isAutoUpdate
      humanize: humanizedPackageNames
      blacklist: blacklist
      disableNotification: disableNotification

    PackageUpdater.updatePackages(options)
    @saveLastUpdateTime()

  getAutoUpdateBlockDuration: ->
    minutes = atom.config.get("#{NAMESPACE}.#{CONFIG_KEY_INTERVAL_MINUTES}")

    if minutes < MINIMUM_AUTO_UPDATE_BLOCK_DURATION_MINUTES
      minutes = MINIMUM_AUTO_UPDATE_BLOCK_DURATION_MINUTES

    minutes * 60 * 1000

  getAutoUpdateCheckInterval: ->
    @getAutoUpdateBlockDuration() / 15

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
    path.join(dotAtomPath, 'storage', "#{NAMESPACE}-last-update-time")
