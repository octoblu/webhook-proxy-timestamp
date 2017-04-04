_ = require 'lodash'

class WebhookProxyTimestampController
  constructor: ({@webhookProxyTimestampService}) ->
    throw new Error 'Missing webhookProxyTimestampService' unless @webhookProxyTimestampService?

  proxy: (request, response) =>
    { body, query } = request
    { url }  = query

    return response.status(422).send error: "'url' query parameter was missing or empty" if _.isEmpty url

    try
      route = JSON.parse request.get 'x-meshblu-route' if request.get('x-meshblu-route')?
    catch error
      return response.status(422).send error: "'x-meshblu-route' contained invalid JSON: #{error.message}"

    @webhookProxyTimestampService.proxy { body, route, url }, (error) =>
      return response.sendError(error) if error?
      response.sendStatus(204)

module.exports = WebhookProxyTimestampController
