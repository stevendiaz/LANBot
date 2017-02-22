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
        roaster = '@' + msg.message.user.name
        roastee = msg.message.text.split(' ')[1]
        roasts = [
            # Anti-roasts
            roaster + " do you really not have anything better to do with your time",
            roastee + " is actually pretty cool",
            "nah",

            # Roasts
            "leave " + roastee + " alone they've been through enough",
            "I could've guessed " + roastee + " was into CS before I ever met them based solely on appearance",
            "if \"unenthusiastic handjob\" had a face, it would be " + roastee + "'s",
            roastee + "'s life is the definition of mediocrity",
            roastee + ", I hope I can care as little about about my appearnce as you do someday",
            roastee + " you look like Zal",
            roastee + " I think I've made a Mii of you before\nhttps://media.giphy.com/media/K5zdsLmwMfCEM/giphy.gif",
            "someone give " + roastee + " a participation trophy for being roasted, it's the only thing they've ever accomplished",
            roastee + " if you were homeschooled you'd still be bullied",
            "whoeever's willing to fuck " + roastee + " is just too lazy to jerk off",
            "I'm trying to see things " + roastee + "'s way but I can't stick my head that far up my ass",
            roastee + " is the personification of comic sans",
            roastee + " is dumb as cow shit and only half as useful",
            roastee.substr(1) + "-- for being useless",
            "why would I roast " + roastee + "? they can't even read",
            
        ]
        roast = roasts[Math.floor(Math.random()*roasts.length)]
        msg.send roast
