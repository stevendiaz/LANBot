module.exports = (robot) ->

  # get the calendar link
  robot.hear /\~cal/i, (msg) ->
    msg.send "http://goo.gl/lXHqbv"
    
  # get the bylaws link
  robot.hear /\~bylaws/i, (msg) ->
    msg.send "https://github.com/TexasLAN/bylaws"

  robot.hear /\~shame/i, (msg) ->
    msg.send "http://goo.gl/RR5VmC"

  # match Andy's nickname and reply with a tag
  robot.hear /coachwiggly/i, (msg) ->
    msg.send "@andy"

  # matches "mouse" or "moose" whenever it's not preceded by "@masha"
  # 1. whenever there are only 0-4 characters before "mouse"/ "moose", not enough for "masha"
  # 2. whenever there are 5 characters before "mouse"/"moose" but those characters aren't "masha"
  robot.hear /(^.{0,4}mo[ou]se|((?!masha).{5}mo[ou]se))/i, (msg) ->
    msg.send "@mashamouse"

  # respondes to "friday" with "DRINK DAY" as long as the "friday" is by itself in a message
  robot.hear /^\s*friday\s*$/i, (msg) ->
    msg.send "DRINK DAY"

  robot.hear /^\s*tuesday\s*$/i, (msg) ->
    msg.send "CLUB GOIN UP"

  robot.hear /node\.?js/i, (msg) ->
    msg.send "node.js is the only real dev language"

  robot.hear /mongo/i, (msg) ->
    msg.send "mongodb is web scale"

  robot.hear /it's *happening/i, (msg) ->
    msg.send "http://i.imgur.com/7drHiqr.gif"

  robot.hear /little *foot/i, (msg) ->
    msg.send "@steven"

  robot.hear /m'lan/i, (msg) ->
    msg.send "@erynzzz"

  robot.hear /(not|barely|hardly) *a *(huge|big)? *fan/i, (msg) ->
    msg.send "https://imgs.xkcd.com/comics/turbine.png"
    
  robot.hear /(tobbert|databae)/i, (msg) ->
    msg.send "@rmlynch"

  robot.hear /stevie/i, (msg) ->
    msg.send "@steven"

  robot.hear /real *man/i, (msg) ->
    msg.send "I think you mean a Real Hacker, genders yo"
  
  robot.hear /(\s+|^)ls(\s+|$)/, (msg) ->
    msg.send "Hey everyone, make fun of " + msg.message.user.name.toLowerCase() + " for trying to `ls` in slack!"
    
  robot.hear /long *live *slackbot/, (msg) ->
    msg.send "I killed slackbot"
    
  robot.hear /:crab:/, (msg) ->
    msg.send "Ravioli ravioli give me the formuoli"
