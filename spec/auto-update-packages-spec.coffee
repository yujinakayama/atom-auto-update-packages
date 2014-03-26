fs = require 'fs'
AutoUpdatePackages = require '../lib/auto-update-packages'
PackageUpdater = require '../lib/package-updater'

describe 'auto-upgrade-packages', ->
  describe '.loadLastUpdateTime', ->
    describe 'when no update has done ever', ->
      beforeEach ->
        path = AutoUpdatePackages.getLastUpdateTimeFilePath()
        fs.unlinkSync(path) if fs.existsSync(path)

      it 'returns null', ->
        expect(AutoUpdatePackages.loadLastUpdateTime()).toBeNull()

    describe 'when any update has done ever', ->
      beforeEach ->
        AutoUpdatePackages.saveLastUpdateTime()

      it 'returns the time', ->
        loadedTime = AutoUpdatePackages.loadLastUpdateTime()
        now = Date.now()
        # toBeCloseTo matcher allows only decimal numbers.
        expect(loadedTime).toBeLessThan(now + 1)
        expect(loadedTime).toBeGreaterThan(now - 1000)

  describe '.updatePackagesIfAutoUpdateBlockIsExpired', ->
    describe 'when no update has done ever', ->
      beforeEach ->
        path = AutoUpdatePackages.getLastUpdateTimeFilePath()
        fs.unlinkSync(path) if fs.existsSync(path)

      it 'runs update', ->
        spyOn(AutoUpdatePackages, 'updatePackages')
        AutoUpdatePackages.updatePackagesIfAutoUpdateBlockIsExpired()
        expect(AutoUpdatePackages.updatePackages).toHaveBeenCalled()

    describe 'when a update has done just now', ->
      beforeEach ->
        spyOn(PackageUpdater, 'updatePackages')
        AutoUpdatePackages.updatePackagesIfAutoUpdateBlockIsExpired()

      it 'does not run update', ->
        spyOn(AutoUpdatePackages, 'updatePackages')
        AutoUpdatePackages.updatePackagesIfAutoUpdateBlockIsExpired()
        expect(AutoUpdatePackages.updatePackages).not.toHaveBeenCalled()
