moment  = require 'moment'
request = require 'request'
debug   = require('debug')('webhook-proxy-timestamp:webhook-proxy-timestamp-service')

class WebhookProxyTimestampService
  proxy: ({ body, url }, callback) =>
    body.timestamp = moment().utc().format()

    request.post url, {json: body}, (error, response) =>
      return callback @_createError('request error', 500) if error?
      return callback @_responseError body, response if response.statusCode > 299
      callback()

  _createError: (message='Internal Service Error', code=500) =>
    error = new Error message
    error.code = code
    return error

  _responseError: (requestBody, response) =>
    debug 'responseError', JSON.stringify({request: requestBody, response: response.body}, null, 2)
    return @_createError("upstream error: #{response.statusCode}", 502)


module.exports = WebhookProxyTimestampService
