moment  = require 'moment'
request = require 'request'
debug   = require('debug')('webhook-proxy-timestamp:webhook-proxy-timestamp-service')

class WebhookProxyTimestampService
  proxy: ({ body, url }, callback) =>
    body.timestamp = moment().utc().format()

    request.post url, {json: body}, (error, response) =>
      return callback @_createError('request error', 500) if error?
      return callback @_responseError response if response.statusCode > 299
      callback()

  _createError: (message='Internal Service Error', code=500) =>
    error = new Error message
    error.code = code
    return error

  _responseError: (response) =>
    debug 'responseError', JSON.stringify(response.body, null, 2)
    return @_createError("upstream error: #{response.statusCode}\n#{JSON.stringify(response.body, null, 2)}", 502)


module.exports = WebhookProxyTimestampService
