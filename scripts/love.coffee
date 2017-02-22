# Description:
#     To compliment roast.coffee, I figured we needed some love in LAN too :)
#
# Dependencies:
#     None
#
# Configuration:
#     None
#
# Commands:
#     love _____ - loves the given member
#
# Author:
#     Ian Mobbs

module.exports = (robot) =>
    robot.hear /^love @\w+/i, (msg) ->
        lover = '@' + msg.message.user.name
        lovee = msg.message.text.split(' ')[1]
        loves = [
            lover + ", you're so sweet for thinking about " + lovee + "! I hope you both have a great day",
            lovee + " has the heart of an angel and the appearance to match",
            lovee + " is the reason I am constantly smiling",
            lovee + " the chance of meeting another person like you is the only reason I talk to strangers",
            lover + " and " + lovee + " are both great",
            lovee + " is my favorite",
            lovee + " is so cute that puppies send pictures of them to each other",
            "if " + lovee + " was a haircut I wouldn't wear a hat",
            lovee + " is KILLING it this semester! keep up the good work",
            "I never wished I had a sibling until I met " + lovee,
        ]
        love = loves[Math.floor(Math.random()*loves.length)] + " :)\n" + lover.substr(1) + "++ for sending love"
        msg.send love
