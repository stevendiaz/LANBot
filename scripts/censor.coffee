class ResponsesManager

  constructor: ->
    @muted = []

  isMuted: (msg) ->
    msg.user.room in @muted

  mute: (msg) ->
    replies = [':disappointed:', ':cry:', ':rip:', ':pensive:', ':no_mouth:', ':fu:']
    msg.send msg.random replies

    @muted.push msg.message.user.room

    that = this
    setTimeout( ->
      that.unmute(msg)
    , 5 * 60 * 1000) # 5 minutes

  unmute: (msg) ->
    res = []
    for room in @muted
      if room != msg.message.user.room
        res.push room

    @muted = res

module.exports = (robot) ->

  responses = new ResponsesManager

  robot.respond /stfu|mute/i, (msg) ->
    if !responses.isMuted msg.message
      responses.mute msg

  robot.hear /^(stfu|mute) lanbot$/i, (msg) ->
    if !responses.isMuted msg.message
      responses.mute msg

  isValid = (str) ->
    return str.indexOf("@channel") == -1 &&
      str.indexOf("@here") == -1 &&
      str.indexOf("@group") == -1 &&
      str.indexOf("@everyone") == -1

  robot.responseMiddleware (context, next, done) ->
    return unless isValid(context.strings) && !responses.isMuted context.response.message
    next()