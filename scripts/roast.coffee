# Description:
#     #zalandericarethebestj had been designated as a roast-safe zone.
#     There needs to be a better way to roast someone. Let's make some roasted coffee.
#     Roasts from /r/RoastMe because I'm not clever
#
# Dependencies:
#     None
#
# Configuration:
#     None
#
# Commands:
#     roast _____ - roasts the given member
#
# Author:
#     Ian Mobbs

module.exports = (robot) =>
    robot.hear /^roast @\w+/i, (msg) ->
        roastee = escape(msg.match[1])
        roasts = [
            msg.user + " do you really not have anything better to do with your time",
            "leave " + roastee + " alone they've been through enough",
        ]
        roast = roasts[Math.floor(Math.random()*roasts.length)]
        msg.send roast
