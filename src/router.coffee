WebhookProxyTimestampController = require './controllers/webhook-proxy-timestamp-controller'

class Router
  constructor: ({ @webhookProxyTimestampService }) ->
    throw new Error 'Missing webhookProxyTimestampService' unless @webhookProxyTimestampService?

  route: (app) =>
    webhookProxyTimestampController = new WebhookProxyTimestampController { @webhookProxyTimestampService }

    app.post '/proxy', webhookProxyTimestampController.proxy
    # e.g. app.put '/resource/:id', someController.update

module.exports = Router
