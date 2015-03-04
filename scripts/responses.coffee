module.exports = (robot) ->

  robot.hear /\~cal/i, (msg) ->
    msg.send "http://goo.gl/lXHqbv"
    
  robot.hear /\@coachwiggly/i, (msg) ->
    msg.send "@andy"
    
  # matches "mouse" whenever it's not preceded by "@masha"
  # 1. whenever there are only 0-4 characters before "mouse"/ "moose", not enough for "masha"
  # 2. whenever there are 5 characters before "mouse"/"moose" but those characters aren't "masha"
  robot.hear /(^.{0,4}mo[ou]se|((?!masha).{5}mo[ou]se))/i, (msg) ->
    msg.send "@mashamouse"
    
  robot.hear /^\s*friday\s*$/i, (msg) ->
    msg.send "DRINK DAY"

  robot.hear /node\.?js/i, (msg) ->
    msg.send "the only real dev language"
