moment  = require 'moment'
request = require 'request'

class WebhookProxyTimestampService
  proxy: ({ body, url }, callback) =>
    body.timestamp = moment().utc().format()

    request.post url, {json: body}, (error, response) =>
      return callback @_createError('request error', 500) if error?
      return callback @_createError('upstream error', 502) if response.statusCode > 299
      callback()

  _createError: (message='Internal Service Error', code=500) =>
    error = new Error message
    error.code = code
    return error

module.exports = WebhookProxyTimestampService
