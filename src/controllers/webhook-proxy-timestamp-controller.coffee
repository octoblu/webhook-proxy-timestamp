class WebhookProxyTimestampController
  constructor: ({@webhookProxyTimestampService}) ->
    throw new Error 'Missing webhookProxyTimestampService' unless @webhookProxyTimestampService?

  proxy: (request, response) =>
    { url }  = request.query
    { body } = request
    @webhookProxyTimestampService.proxy { url, body }, (error) =>
      return response.sendError(error) if error?
      response.sendStatus(204)

module.exports = WebhookProxyTimestampController
