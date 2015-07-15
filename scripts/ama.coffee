# Description:
#   daily AMA for hubot
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   ama start - start an AMA, and a new one will be started every 24 hours afterward
#   ama stop - stop the AMA
#   ama current - current person doing the AMA
#   ama add <name> - manually add someone to the candidates list
#   ama remove <name> -manually remove someone from the candidates list
#   ama list - lists all AMA candidates
#
# Author:
#   Gregory Cerna
#   Steven Diaz


class AMAManager

    constructor: (@robot) ->
        storageLoaded = =>
            @storage = @robot.brain.data.ama ||= {
                candidates: []
            }
            @robot.logger.debug "AMA data loaded: " + JSON.stringify(@storage)

        @channels = ["bots", "ama", "Shell"] # channels where AMAs can run

        @admins = ["andy", "greg", "stevendiaz", "thomas", "Shell"] 
        @intervalID = null # if not null, AMAs are currently on
        @current = null # current AMA person

        @robot.brain.on "loaded", storageLoaded
        storageLoaded()

    checkPermission: (msg) ->
      if @admins.length == 0 || msg.message.user.name in @admins
        return true
      else
        msg.send "You lack permission for this command"
        return false    

    save: ->
        @robot.logger.debug "Saving AMA data: " + JSON.stringify(@storage)
        @robot.brain.emit 'save'

    printHelp: (msg) ->
        msg.send """
                 ama start - pick someone for an AMA and repeat every 24 hours
                 ama stop - stop picking AMAs every 24 hours
                 ama current - display the current AMA celebrity
                 ama add - add yourself to the AMA list
                 ama remove - remove yourself from the AMA list
                 ama list - lists all AMA candidates
                 ama clear - clears selections (admin only)
                 """

    startAMA: (msg) ->
        if @storage.candidates
          if @intervalID
              msg.send "sorry, an AMA is already going. try ama stop"
          else
              firstSelection = @storage.candidates[Math.floor(Math.random() * @storage.candidates.length)]
              msg.send "#{firstSelection} has been selected to be today's AMA celebrity! Ask away, and anything goes :wink:"
              @current = firstSelection
              @intervalID = setInterval( ->
                  selected = @storage.candidates[Math.floor(Math.random() * @storage.candidates.length)]
                  msg.send "#{selected} has been selected to be today's AMA celebrity! Ask away, and anything goes :wink:"
                  @current = selected
                , 1000 * 60 * 60 * 24) #24 hours
        else
          msg.send "Unable to start AMA: no candidates."

    stopAMA: (msg) ->
        if @intervalID
            msg.send "the AMA is over! thank you everyone for your time."
            clearInterval(@intervalID)
            @intervalID = null
            @current = null
        else
            msg.send "there's no AMA going on right now. try \"ama start\""

    currentAMA: (msg) ->
        if @current
            msg.send "#{@current} is the current AMA celebrity! Ask them anything!"
        else
            msg.send "no one is currently doing an AMA."
    
    addCandidate: (msg) ->
        if msg.match[1] != ""
            msg.send "Invalid add. `ama add` does not take parameters. "
        else
            user = msg.message.user.name.toLowerCase()
            #checks to see if user is already a candidate
            try
                index = @storage.candidates.indexOf(user)
            catch
                @storage.candidates = []
                index = @storage.candidates.indexOf(user)
            finally
                if index < 0
                    @storage.candidates.push(user)
                    @save
                    msg.send "You have been added as an AMA candidate."
                else
                    msg.send "You are already an AMA candidate."

    removeCandidate: (msg) ->
      if msg.match[1] != ""
          msg.send "Invalid remove. 'ama remove' does not take parameters."
      else
            user = msg.message.user.name.toLowerCase()
            try
                index = @storage.candidates.indexOf(user)
            catch
                @storage.candidates = []
                index = @storage.cnadidates.indexOf(user)
            finally
                if index > -1
                    @storage.candidates.splice(index, 1)
                    @save
                    msg.send "You have been removed as an AMA candidate."
                else
                    msg.send "You are not an AMA candidate. "

    clearCandidates: (msg) ->
        if @storage.candidates.length > 0
            @storage.candidates = []
            @save
            msg.send "Candidates cleared. "
        else
            msg.send "There are no candidates to clear."

    listCandidates: (msg) ->
        str = "There are #{@storage.candidates.length} candidates for the AMA"
        for candidate in @storage.candidates
            str = str + "\n#{candidate}"
        msg.send str



    validChannel: (msg) ->
        if @channels.length == 0 || msg.message.user.room in @channels
            return true
        else
            return false

module.exports = (robot) ->

    ama = new AMAManager robot

    # super janky way to pass data to methods bc random things are undefined
    # for no apparent reason
    checkMessage = (msg, cmd, data = null, data2 = null) ->
        if ama.validChannel msg
            if data
                if data2
                    cmd msg, data, data2
                else
                    cmd msg, data
            else
                cmd msg

    checkRestrictedMessage = (msg, cmd) ->
        if ama.checkPermission msg
            checkMessage msg, cmd


    robot.hear /^\s*ama\s*$/i, (msg) ->
        msg.send "Invalid command, say \"ama help\" for help"

    robot.hear /^\s*ama (.*)/i, (msg) ->
        cmd = msg.match[1]
        switch cmd
            when "start" then checkMessage msg, ama.startAMA
            when "stop" then checkMessage msg, ama.stopAMA
            when "add" then checkMessage msg, ama.addCandidate
            when "remove" then checkMessage msg, ama.removeCandidate
            when "current" then checkMessage msg, ama.currentAMA
            when "list" then checkMessage msg, ama.listCandidates
            when "help" then ama.printHelp msg
            when "clear" then checkRestrictedMessage msg, ama.clearCandidates
            else msg.send "Invalid command, say \"ama help\" for help"
