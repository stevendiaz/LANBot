module.exports = (robot) ->
  isValid = (str) ->
    return str.indexOf("@channel") == -1 &&
      str.indexOf("@here") == -1 &&
      str.indexOf("@group") == -1 &&
      str.indexOf("@everyone") == -1

  robot.responseMiddleware (context, next, done) ->
    return unless isValid context.strings
    next()