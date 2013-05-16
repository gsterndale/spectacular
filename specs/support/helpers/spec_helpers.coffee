
createEnv = (block, context) ->
  env = spectacular.env.clone()
  env.options.noColors = true
  spyOn(env.runner, 'loadSpecs').andCallFake -> do block
  spyOn(env.formatter, 'printExampleResult').andCallFake ->
    @formatExampleResult.apply this, arguments
  spyOn(env.formatter, 'printResults').andCallFake ->
    context.results = @buildResults.apply this, arguments
  env

runEnvExpectingNormalTermination = (env, context, async) ->
  oldEnv = spectacular.env
  env.run()
  .then (status) ->
    context.status = status
    oldEnv.load()
    async.resolve()
  .fail (reason) ->
    context.reason = reason
    oldEnv.load()
    async.reject reason

runEnvExpectingInterruption = (env, context, async) ->
  oldEnv = spectacular.env
  env.run()
  .then (status) =>
    oldEnv.load()
    async.reject new Error "run didn't failed"
  .fail (reason) =>
    context.reason = reason
    oldEnv.load()
    async.resolve()

exports.virtualEnv = (desc) ->
  setupEnv = (context, async, block) ->

  shouldFailWith: (re, block) ->
    describe desc, ->
      before (async) ->
        @env = createEnv block, this
        runEnvExpectingNormalTermination @env, this, async

      it 'status', -> @status.should be 1
      it 'results', -> @results.should match re

  shouldSucceedWith: (re, block) ->
    describe desc, ->
      before (async) ->
        @env = createEnv block, this
        runEnvExpectingNormalTermination @env, this, async

      it 'status', -> @status.should be 0
      it 'results', -> @results.should match re

  shouldStopWith: (re, block) ->
    describe desc, ->
      before (async) ->
        @env = createEnv block, this
        runEnvExpectingInterruption @env, this, async

      it 'error message', ->
        @reason.message.should match re