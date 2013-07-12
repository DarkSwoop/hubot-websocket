{Adapter,Robot,TextMessage,EnterMessage,LeaveMessage} = require 'hubot'

EventEmitter = require('events').EventEmitter
WebSocket = require('ws')

class WebsocketAdapter extends Adapter
  send: (envelope, strings...) ->
    strings.forEach (str) =>
      @bot.socket.send str

  reply: (envelope, strings...) ->
    strings.forEach (str) =>
      @bot.socket.send str

  run: ->
    self = @

    port = if process.env.HUBOT_WEBSOCKET_PORT then process.env.HUBOT_WEBSOCKET_PORT else 8081

    bot = new WebsocketServer(port)
    bot.on "message", (msg) ->
      self.receive new TextMessage { name: 'User' }, msg, 'messageId'

    @bot = bot

    self.emit "connected"

exports.use = (robot) ->
  new WebsocketAdapter robot

class WebsocketServer extends EventEmitter
  constructor: (port) ->
    @createServer port

  createServer: (port) ->
    self = @

    wss = new WebSocket.Server({ port: port })

    wss.on "connection", (ws) ->
      ws.on "message", (message) ->
        self.emit "message", message

      self.socket = ws

    console.log "Running websocket server on port %s", port
