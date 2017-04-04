{ afterEach, beforeEach, describe, it } = global
{ expect } = require 'chai'
bodyParser = require 'body-parser'
express    = require 'express'
request    = require 'request'
url        = require 'url'


Server = require '../src/server'

describe 'POST /proxy', ->
  beforeEach 'start the target', (done) ->
    @target = express()
      .use bodyParser.json()
      .use (req, res) =>
        @proxiedRequest = req
        res.sendStatus 204
      .listen 0, done

  beforeEach 'start the server', (done) ->
    @sut = new Server {disableLogging: true}
    @sut.run done

  beforeEach 'build @request', ->
    @request = request.defaults baseUrl: url.format(protocol: 'http', hostname: 'localhost', port: @sut.address().port)

  afterEach 'stop the server', (done) ->
    @sut.destroy done

  afterEach 'close the target', (done) ->
    @target.close done

  describe 'when called without a url query parameter', ->
    beforeEach (done) ->
      json = {}

      @request.post '/proxy', { json }, (error, @response) => done error

    it 'should respond with a 422', ->
      expect(@response.statusCode).to.equal 422, @response.body

    it 'should have an explanatory message', ->
      expect(@response.body).to.have.property 'error', "'url' query parameter was missing or empty"

  describe 'when called with an X-Meshblu-Route', ->
    beforeEach (done) ->
      headers = {
        'X-Meshblu-Route': JSON.stringify([{
          from: "original-sender"
          to:   "intermediary"
          type: "broadcast.sent"
        }, {
          from: "original-sender"
          to:   "guy-with-webhook"
          type: "broadcast.received"
        }, {
          from: "guy-with-webhook"
          to:   "guy-with-webhook"
          type: "broadcast.received"
        }])
      }

      qs = {
        url: url.format(protocol: 'http', hostname: 'localhost', port: @target.address().port)
      }

      json = {}

      @request.post '/proxy', { headers, qs, json }, (error, response) =>
        return done error if error?
        expect(response.statusCode).to.equal 204, response.body
        return done()

    it 'should add the "message-originally-from" attribute', ->
      expect(@proxiedRequest.body).to.have.property 'message-originally-from', 'original-sender'

  describe 'when called without an X-Meshblu-Route', ->
    beforeEach (done) ->
      qs = {
        url: url.format(protocol: 'http', hostname: 'localhost', port: @target.address().port)
      }

      json = {}

      @request.post '/proxy', { qs, json }, (error, response) =>
        return done error if error?
        expect(response.statusCode).to.equal 204, response.body
        return done()

    it 'should add a "message-originally-from" attribute with value null', ->
      expect(@proxiedRequest.body).to.have.property 'message-originally-from', null

  describe 'when called with an X-Meshblu-Route with bad JSON', ->
    beforeEach (done) ->
      headers = {
        'X-Meshblu-Route': '['
      }

      qs = {
        url: url.format(protocol: 'http', hostname: 'localhost', port: @target.address().port)
      }

      json = {}

      @request.post '/proxy', { headers, json, qs }, (error, @response) => done error

    it 'should respond with a 422', ->
      expect(@response.statusCode).to.equal 422, @response.body

    it 'should have an explanatory message', ->
      expect(@response.body).to.have.property 'error', "'x-meshblu-route' contained invalid JSON: Unexpected end of JSON input"
