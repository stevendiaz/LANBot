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
    constructor: (@url, @user) ->

    getUrl: -> @url

    getUser: -> @user

class AotwManager
    constructor: (@robot) ->
        # Define channels to which commands denoted by an astrisk are limited.
        # If left blank, commands can be run within any channel.
        @channels = ["bots", "music"]

        # Restrict commands denoted by a tilde to the following users.
        # If left empty, any user can issue restricted commands.
        @admins = ["colt", "thomas"]

        @history = []
        @nominations = []

        @robot.brain.on 'loaded', =>
            if @robot.brain.data.aotwHistory
                @history = @robot.brain.data.aotwHistory
            if @robot.brain.data.aotwNoms
                @nominations = @robot.brain.data.aotwNoms

    save: ->
        @robot.brain.data.aotwHistory = @history
        @robot.brain.data.aotwNoms = @nominations

    validChannel: (msg) ->
        if @channels.length == 0 || msg.message.user.room in @channels
            return true
        else
            msg.send "You must be in a valid channel to use this command"
            return false

    checkPermission: (msg) ->
        if @admins.length == 0 || msg.message.user.name in @admins
            return true
        else
            msg.send "You lack permission for this command"
            return false

    printCurrentAotw: (msg) ->
        if @history && @history.length > 0
            aotw = @history[@history.length - 1]
            msg.send "Current AOTW: #{aotw.getUrl()}, nominated by #{aotw.getUser()}"
        else
            msg.send "No current album of the week"

    printHistory: (msg) ->
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
        if msg.match[1] != ""
            urlPattern = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[.\!\/\\w]*))?)/ig
            if msg.match[2].match urlPattern
                try
                    @nominations.push new Album(msg.match[2], msg.message.user.name.toLowerCase())
                catch
                    @nominations = []
                    @nominations.push new Album(msg.match[2], msg.message.user.name.toLowerCase())
                finally
                    @save
                    msg.send "Nomination saved"
            else
                msg.send "Invalid nomination: invalid url"
        else
            msg.send "Invalid nomination: missing url"

    printNominations: (msg) ->
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
        msg.send "aotw history [length] - view all historical AOTWs, optionally limited to [length] *"
        msg.send "aotw nominate <url> - nominate an album *"
        msg.send "aotw nominations [length] - view all current nominations, optionally limited to [length] *"
        msg.send "aotw reset - reset all AOTW data *~"
        msg.send "aotw select <nomination index> - select the AOTW and reset nominations *~"
        if @channels.length > 0
            msg.send "Commands denoted by * are restricted to specific channels, ~ are limited to AOTW admins"
        else
            msg.send "Commands denoted by ~ are limited to AOTW admins"

    reset: (msg) ->
        @history = []
        @nominations = []
        @save
        msg.send "All AOTW data has been reset"

    select: (msg) ->
        if msg.match[1] != ""
            if msg.match[2] <= @nominations.length && msg.match[2] > 0
                i = msg.match[2]
                selected = @nominations[i - 1]
                try
                    @history.push selected
                catch
                    @history = []
                    @history.push selected
                finally
                    @nominations = []
                    @save
                    msg.send "Selected #{selected.getUrl()}, nominated by #{selected.getUser()}"
            else
                msg.send "Invalid selection: invalid nomination index"
        else
            msg.send "Invalid selection: missing nomination index"

module.exports = (robot) ->

    aotw = new AotwManager robot

    checkMessage = (msg, cmd) ->
        if aotw.validChannel msg
            cmd msg

    checkRestrictedMessage = (msg, cmd) ->
        if aotw.checkPermission msg
            checkMessage msg, cmd

    robot.hear /^\s*aotw\s*$/i, (msg) ->
        msg.send "Invalid command, say \"aotw help\" for help"

    robot.hear /^\s*aotw(.*) (.*)/i, (msg) ->
        cmd = msg.match[0].split(" ")[1]
        switch cmd
            when "current" then checkMessage msg, aotw.printCurrentAotw
            when "help" then aotw.printHelp msg
            when "history" then checkMessage msg, aotw.printHistory
            when "nominate" then checkMessage msg, aotw.nominate
            when "nominations" then checkMessage msg, aotw.printNominations
            when "reset" then checkRestrictedMessage msg, aotw.reset
            when "select" then checkRestrictedMessage msg, aotw.select
            else msg.send "Invalid command, say \"aotw help\" for help"
