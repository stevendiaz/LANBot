# Description:
#   LANBot abuse prevention
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   lanbot mute - Mute LANBot for five minutes
#   mute lanbot - Mute LANBot for five minutes
#
# Author:
#   Lambda Alpha Nu

class ResponsesManager

  constructor: ->
    @muted = []

  isMuted: (msg) ->
    msg.user.room in @muted

  mute: (msg) ->
    replies = [':disappointed:', ':cry:', ':rip:', ':pensive:', ':no_mouth:', ':fu:']
    msg.send msg.random replies

    that = this

    setTimeout( ->
      that.muted.push msg.message.user.room
    , 100) # Give LANBot time to reply one last time

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

  robot.responseMiddleware (context, next, done) ->
    # Mute @channels and the like
    banned = ["@channel", "@here", "@group", "@everyone"]
    for b in banned
        context.strings = (string.replace(b, "@." + b.substring(1)) for string in context.strings)

    # Don't reply if muted
    if !responses.isMuted context.response.message
        next()
    else
        done()
