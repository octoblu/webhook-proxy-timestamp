enableDestroy      = require 'server-destroy'
octobluExpress     = require 'express-octoblu'
Router             = require './router'
WebhookProxyTimestampService = require './services/webhook-proxy-timestamp-service'

class Server
  constructor: (options) ->
    { @logFn, @disableLogging, @port } = options

  address: =>
    @server.address()

  run: (callback) =>
    app = octobluExpress({ @logFn, @disableLogging })

    webhookProxyTimestampService = new WebhookProxyTimestampService
    router = new Router { webhookProxyTimestampService }
    router.route app

    @server = app.listen @port, callback
    enableDestroy @server

  stop: (callback) =>
    @server.close callback

  destroy: (done) =>
    @server.destroy(done)

module.exports = Server
