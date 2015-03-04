module.exports = (robot) ->

  robot.hear /\~cal/i, (msg) ->
    msg.send "http://goo.gl/lXHqbv"
    
  robot.hear /\@coachwiggly/i, (msg) ->
    msg.send "@andy"
    
  robot.hear /mouse/i, (msg) ->
    msg.send "@mashamouse"
    
  robot.hear /^\s*friday\s*$/i, (msg) ->
    msg.send "DRINK DAY"
