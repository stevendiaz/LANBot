# Description:
#   Track and manage the album of the week.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   aotw current - view the current AOTW *
#   aotw help - display AOTW help
#   aotw history [length] - view all historical AOTWs, optionally limited to [length] *
#   aotw nominate <url> - nominate an album *
#   aotw nominations [length] - view all current nominations, optionally limited to [length] *
#   aotw reset - reset all AOTW data *~
#   aotw select <nomination index> - select the AOTW and reset nominations *~
#
# Author:
#   Thomas Gaubert

class Album
    constructor: (url, user) ->
        @url = url
        @user = user

    getUrl: -> @url

    getUser: -> @user

class AotwManager
    constructor: (@robot) ->
        # Define a channel to which commands denoted by an astrisk are limited.
        # If left blank, commands can be run within any channel.
        @channel = "music"
        # Restrict commands denoted by a tilde to the following users.
        # If left empty, any user can issue restricted commands.
        @admins = ["colt"]

        @history = []
        @nominations = []
        @currentAlbum

        @robot.brain.on 'loaded', =>
            if @robot.brain.data.aotwHistory
                @history = @robot.brain.data.aotwHistory
            if @robot.brain.data.aotwNoms
                @nominations = @robot.brain.data.aotwNoms
            if @robot.brain.data.aotwCurrent
                @currentAlbum = @robot.brain.data.aotwCurrent

    save: ->
        @robot.brain.data.aotwHistory = @history
        @robot.brain.data.aotwNoms = @history
        @robot.brain.data.aotwCurrent = @current

    validChannel: (msg) ->
        if @channel == "" || msg.message.user.room == @channel
            return true
        else
            msg.send "You must be in ##{@channel} to use AOTW commands"
            return false

    checkPermission: (msg) ->
        if @admins.length == 0 || msg.message.user.name in @admins
            return true
        else
            msg.send "You lack permission for this command"
            return false

    validUrl: (url) ->
        urlPattern = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[.\!\/\\w]*))?)/ig
        url.match urlPattern

    printCurrentAotw: (msg) ->
        if @validChannel msg
            if @currentAlbum
                msg.send "Current AOTW: #{@currentAlbum.getUrl()}, nominated by #{@currentAlbum.getUser()}"
            else
                msg.send "No current album of the week"

    printHistory: (msg) ->
        if @validChannel msg
            if msg.match[1] != ""
                limit = msg.match[2]
            else
                limit = 9999

            if @history && @history.length > 0
                msg.send "Total of #{@history.length} previous AOTWs"
                i = 0
                while i <= @history.length - 1 && i < limit
                    aotw = @history[i]
                    msg.send "#{i + 1} - #{aotw.getUser()} - #{aotw.getUrl()}"
                    i++
            else
                msg.send "No previous AOTWs"

    nominate: (msg) ->
        if @validChannel msg
            if msg.match[1] != ""
                if @validUrl msg.match[2]
                    msg.send "Nomination saved"
                    nomination = new Album(msg.match[2], msg.message.user.name.toLowerCase())
                    @nominations.push nomination
                    @save
                else
                    msg.send "Invalid nomination: invalid url"
            else
                msg.send "Invalid nomination: missing url"

    printNominations: (msg) ->
        if @validChannel msg
            if msg.match[1] != ""
                limit = msg.match[2]
            else
                limit = 9999

            if @nominations && @nominations.length > 0
                msg.send "Total of #{@nominations.length} nominations"
                i = 0
                while i <= @nominations.length - 1 && i < limit
                    nomination = @nominations[i]
                    msg.send "#{i + 1} - #{nomination.getUser()} - #{nomination.getUrl()}"
                    i++
            else
                msg.send "No current nominations"

    printHelp: (msg) ->
        msg.send "aotw current - view the current AOTW *"
        msg.send "aotw help - display AOTW help"
        msg.send "aotw history - view all historical AOTWs *"
        msg.send "aotw nominate <url> - nominate an album *"
        msg.send "aotw nominations - view all current nominations *"
        msg.send "aotw reset - reset all AOTW data *~"
        msg.send "aotw select <nomination index> - select the AOTW and reset nominations *~"
        if @channel != ""
            msg.send "Commands denoted by * are restricted to ##{@channel}, ~ are limited to AOTW admins"
        else
            msg.send "Commands denoted by ~ are limited to AOTW admins"

    reset: (msg) ->
        if @validChannel(msg) && @checkPermission(msg)
            @history = []
            @nominations = []
            @currentAlbum
            @save
            msg.send "All AOTW data has been reset"

    select: (msg) ->
        if @validChannel(msg) && @checkPermission(msg)
            if msg.match[1] != ""
                if msg.match[2] <= @nominations.length && msg.match[2] > 0
                    i = msg.match[2]
                    @currentAlbum = @nominations[i - 1]
                    @nominations = []
                    @history.push @currentAlbum
                    @save
                    msg.send "Selected #{@currentAlbum.getUrl()}, nominated by #{@currentAlbum.getUser()}"
                else
                    msg.send "Invalid selection: invalid nomination index"
            else
                msg.send "Invalid selection: missing nomination index"

module.exports = (robot) ->

    aotw = new AotwManager robot

    robot.hear /^\s*aotw\s*$/i, (msg) ->
        msg.send "Invalid command, say \"aotw help\" for help"

    robot.hear /^\s*aotw(.*) (.*)/i, (msg) ->
        cmd = msg.match[0].split(" ")[1]
        switch cmd
            when "current" then aotw.printCurrentAotw msg
            when "help" then aotw.printHelp msg
            when "history" then aotw.printHistory msg
            when "nominate" then aotw.nominate msg
            when "nominations" then aotw.printNominations msg
            when "reset" then aotw.reset msg
            when "select" then aotw.select msg
            else msg.send "Invalid command, say \"aotw help\" for help"
