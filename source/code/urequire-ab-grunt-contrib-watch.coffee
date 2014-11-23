minUrequireVersion = "0.7.0-beta.11"
_ = (_B = require 'uberscore')._
l = new _B.Logger 'urequire-ab-grunt-contrib-watch'
_.mixin (require 'underscore.string').exports()

pkg = JSON.parse require("fs").readFileSync __dirname + '/../../package.json'

isWatching = false

module.exports = watchRunner = (err, bb, options={})->
  _B.Logger.addDebugPathLevel 'urequire-ab-grunt-contrib-watch', options?.debugLevel or 0
  l.debug 10, "Entering with `build.target: #{bb.build.target}` and options=\n", options

  callback = if _.isFunction options then options else -> # need to call callback at the end (or return promise)

  {urequire} = bb

  if require('semver').lt urequire.VERSION, minUrequireVersion
    throw "`urequire` version >= '#{minUrequireVersion}' is needed for `urequire-ab-grunt-contrib-watch` version '#{pkg.version}'"

  if not isWatching
    isWatching = true
    _.extend bb.build.watch, {enabled: true, info: 'urequire-ab-grunt-contrib-watch'} # as `afterBuild`, `build.watch` might not be set

    # @param it {String} either a file pattern (eg 'some/path/*.*') or grunt task (eg `somegrunt:task` or `urequire:target`)
    #        if its a `urequire:xxx`, it finds or creates the BundleBuilder with that task and returns its `bundle.path`
    # @return files pattern if its a urequire:xxx, otherwise as-is
    getFilesFromUrequireTask = (it)->
      if _.isString it
        if _.startsWith(it, 'urequire:')
          l.debug 20, "Found urequire grunt target `#{it}`"
          target = it.replace('urequire:', '')
          if not targetBB = urequire.findBBCreated target
            l.debug 20, "Creating BundleBuilder for urequire grunt target `#{it}`."
            targetBB = new urequire.BundleBuilder urequire.getGruntConfigsForTarget(target), urequire.gruntDeriveLoader
          # enable watch features in urequire since its gonna be watched
          _.extend targetBB.build.watch, {enabled: true, info: 'urequire-ab-grunt-contrib-watch'}
          targetBB.bundle.path
        else
          it # return as-is, either 'some/path/**/*' or `somegrunt:task`
      else
        throw new Error "Unknown value type of `watch.files` #{l.prettify it}"

    watches = # our watches, an array of `watch` values that will be blended
      if _.isFunction options
        [{enabled:false}] #ignore callback as 3rd arg of afterBuild signature
      else
        if _B.isHash options # just one watch
          [ options ]
        else
          if _.isArray options # an array of watches, as is
            options
          else
            if _.isUndefined options
              []
            else
              throw new Error "urequire-ab-grunt-contrib-watch: Bad options type #{l.prettify options}."

    watch = urequire.watchBlender.blend.apply null, watches.concat(bb.build.watch).reverse()

    # add any watch.files, which might be 'some/path/**.*' or 'urequire:task', dealt in getFilesFromUrequireTask
    files = ["#{bb.bundle.path}/**/*"].concat (watch.files or []).map getFilesFromUrequireTask

    # before & after contain Strings like `somegrunt:task`
    # If its a `urequire:task`, it adds its `bundle.path` to files
    for ba in [watch.before, watch.after] when _.isArray ba
      for baTask, baIdx in ba
        if baTask isnt (taskFiles = getFilesFromUrequireTask baTask)
          l.debug 30, "Adding `#{taskFiles}/**/*` to watch files for `#{baTask}`."
          files.push "#{taskFiles}/**/*"

    tasks = (watch.before or []).concat("urequire:" + bb.build.target).concat(watch.after or [])

    taskName = "urequire-ab-grunt-contrib-watch-" + tasks.map((t)-> t.replace ':', '_').join(',')
    (gruntWatch = {})[taskName] = {files, tasks}

    l.ok "found `watch` at target `#{bb.build.target}` - queuing `grunt-contrib-watch` task `watch:#{taskName}`.",
      if l.deb(30) then gruntWatch else ''

    gruntWatch.options = _.extend {spawn: false}, _.omit watch, ['enabled', 'info', 'before', 'after', 'files', 'debugLevel']

    urequire.grunt.config.merge 'watch': gruntWatch
    urequire.grunt.task.run "watch:#{taskName}"

  callback null # if called with async nodejs style cb

watchRunner.options = (options)->
  (err, bb)-> watchRunner err, bb, options
