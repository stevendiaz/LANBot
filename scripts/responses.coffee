# Description:
#   List of LANBot responses
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   None
#
# Author:
#   Lambda Alpha Nu

class ResponsesManager

  constructor: ->
    @muted = []

  isMuted: (msg) ->
    msg.message.user.room in @muted

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

  sendMessage: (msg, response) ->
      if !@isMuted msg
          msg.send response

module.exports = (robot) ->

  responses = new ResponsesManager

  robot.hear /\~cal/i, (msg) ->
    msg.send "http://goo.gl/lXHqbv"

  robot.hear /\~bylaws/i, (msg) ->
    msg.send "https://github.com/TexasLAN/bylaws"

  robot.hear /\~shame/i, (msg) ->
    msg.send "http://goo.gl/RR5VmC"

  robot.hear /coachwiggly/i, (msg) ->
    responses.sendMessage msg, "@andy"

  robot.hear /(^.{0,4}mo[ou]se|((?!masha).{5}mo[ou]se))/i, (msg) ->
    responses.sendMessage msg, "@mashamouse"

  robot.hear /^\s*friday\s*$/i, (msg) ->
    responses.sendMessage msg, "DRINK DAY"

  robot.hear /^\s*tuesday\s*$/i, (msg) ->
    responses.sendMessage msg, "CLUB GOIN UP"

  robot.hear /node\.?js/i, (msg) ->
    responses.sendMessage msg, "node.js is the only real dev language"

  robot.hear /mongo/i, (msg) ->
    responses.sendMessage msg, "mongodb is web scale"

  robot.hear /it's *happening/i, (msg) ->
    responses.sendMessage msg, "http://i.imgur.com/7drHiqr.gif"

  robot.hear /little *foot/i, (msg) ->
    responses.sendMessage msg, "@steven"

  robot.hear /m'lan/i, (msg) ->
    responses.sendMessage msg, "@erynzzz"

  robot.hear /(not|barely|hardly) *a *(huge|big)? *fan/i, (msg) ->
    responses.sendMessage msg, "https://imgs.xkcd.com/comics/turbine.png"

  robot.hear /(tobbert|databae)/i, (msg) ->
    responses.sendMessage msg, "@rmlynch"

  robot.hear /(^|\s+)stevie/i, (msg) ->
    responses.sendMessage msg, "@steven"

  robot.hear /real *man/i, (msg) ->
    responses.sendMessage msg, "I think you mean a Real Hacker, genders yo"

  robot.hear /(\s+|^)ls(\s+|$)/, (msg) ->
    responses.sendMessage msg, "Hey everyone, make fun of " + msg.message.user.name.toLowerCase() + " for trying to `ls` in slack!"

  robot.hear /long *live *slackbot/i, (msg) ->
    responses.sendMessage msg, "I killed slackbot"

  robot.hear /:crab:/, (msg) ->
    responses.sendMessage msg, "Ravioli ravioli give me the formuoli"

  robot.hear /about a week ago/i, (msg) ->
    responses.sendMessage msg, "WEEK AGO"

  robot.hear /(^|\s+)lean/i, (msg) ->
    responses.sendMessage msg, ":doublecup:"

  robot.hear /cop kill(a|er) t/i, (msg) ->
    responses.sendMessage msg, "@samtallent"

  robot.hear  /lenny/i, (msg) ->
    responses.sendMessage msg, "_o u kno ( ͡° ͜ʖ ͡°)_"

  robot.hear /kanye/i, (msg) ->
    responses.sendMessage msg, ":yeezus:"

  robot.respond /stfu/i, (msg) ->
    if !responses.isMuted msg
      responses.mute msg

  robot.hear /^stfu lanbot$/i, (msg) ->
    if !responses.isMuted msg
      responses.mute msg

  robot.leave (msg) ->
    responses.sendMessage msg, ":rip:"
  
  robot.catchAll (msg) ->
    selector = 2
    
    if Math.floor(Math.random() * 10000) == selector
      responses.sendMessage msg, "http://dontecnico.com/wp-content/uploads/2014/08/1-millionth-visitor.gif"
      return 

    if Math.floor(Math.random() * 300) == selector
      responses.sendMessage msg, "same"
