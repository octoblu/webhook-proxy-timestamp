_       = require 'lodash'
moment  = require 'moment'
request = require 'request'
debug   = require('debug')('webhook-proxy-timestamp:webhook-proxy-timestamp-service')

class WebhookProxyTimestampService
  proxy: ({ body, route, url }, callback) =>
    body.timestamp = moment().utc().format()
    body['message-originally-from'] = _.get _.first(route), 'from', null

    request.post url, { json: body }, (error, response) =>
      return callback @_createError('request error', 500, error) if error?
      return callback @_responseError body, response if response.statusCode > 299
      callback()

  _createError: (message, code, error) =>
    message = "#{message}: #{error.message}" if error?
    error = new Error message
    error.code = code
    return error

  _responseError: (requestBody, response) =>
    debug 'responseError', JSON.stringify({request: requestBody, response: response.body}, null, 2)
    return @_createError("upstream error: #{response.statusCode}", 502)

module.exports = WebhookProxyTimestampService
