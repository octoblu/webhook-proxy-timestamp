enableDestroy      = require 'server-destroy'
octobluExpress     = require 'express-octoblu'
Router             = require './router'
WebhookProxyTimestampService = require './services/webhook-proxy-timestamp-service'

class Server
  constructor: (options) ->
    { @logFn, @disableLogging, @port } = options
    { @meshbluConfig } = options
    throw new Error 'Missing meshbluConfig' unless @meshbluConfig?

  address: =>
    @server.address()

  run: (callback) =>
    app = octobluExpress({ @logFn, @disableLogging })

    webhookProxyTimestampService = new WebhookProxyTimestampService
    router = new Router {@meshbluConfig, webhookProxyTimestampService}

    router.route app

    @server = app.listen @port, callback
    enableDestroy @server

  stop: (callback) =>
    @server.close callback

  destroy: =>
    @server.destroy()

module.exports = Server
