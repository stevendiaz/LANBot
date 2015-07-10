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

        @admins = ["greg", "stevendiaz", "thomas", "Shell"] 
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
        msg.send "ama start - pick someone for an AMA and repeat every 24 hours"
        msg.send "ama stop - stop picking AMAs every 24 hours"
        msg.send "ama current - display the current AMA celebrity"
        msg.send "ama add <name> - manually add someone to the candidates list"
        msg.send "ama remove <name> -manually remove someone from the candidates list"
        msg.send "ama list - lists all AMA candidates"

    startAMA: (msg, candidates) ->
        if @intervalID
            msg.send "sorry, an AMA is already going. try ama stop"
        else
            firstSelection = candidates[Math.floor(Math.random() * candidates.length)]
            msg.send "#{firstSelection} has been selected to be today's AMA celebrity! Ask away, and anything goes :wink:"
            @current = firstSelection
            @intervalID = setInterval( ->
                selected = candidates[Math.floor(Math.random() * candidates.length)]
                msg.send "#{selected} has been selected to be today's AMA celebrity! Ask away, and anything goes :wink:"
                @current = selected
              , 1000 * 60 * 60 * 24) #24 hours

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
    
    addCandidate: (msg, candidates, isManual = false) ->
        if msg.match[1] != ""
            msg.send "Invalid add. `ama add` does not take parameters. "
        else
            user = msg.message.user.name.toLowerCase()
            #checks to see if user is already a candidate
            if candidates.indexOf(user) < 0 
                candidates.push(newCandidate)
                @save
                msg.send "You have been added as an AMA candidate"
            else
                msg.send "You are already an AMA candidate"

    removeCandidate: (msg, candidates, isManual = false) ->
      if msg.match[1] != ""
          msg.send "Invalid remove. 'ama remove' does not take parameters."
      else
          user = msg.message.user.name.toLowerCase()
          if candidates.indexOf(user) > -1
              candidates.splice(index, 1)
              @save
              msg.send "You have been removed as an AMA candidate."
          else
              msg.send "You are not an AMA candidate."

    clearCandidates: (msg, candidates) ->
        candidates = []
        @save

    listCandidates: (msg, candidates) ->
        msg.send "There are #{candidates.length} candidates for the AMA"
        for(candidate in candidates)
            msg.send "#{candidate}"



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

    robot.hear /^\s*ama(.*) (.*)/i, (msg) ->
        cmd = msg.match[0].split(" ")[1]
        switch cmd
            when "start" then checkMessage msg, ama.startAMA, ama.storage.candidates
            when "stop" then checkMessage msg, ama.stopAMA
            when "add" then checkMessage msg, ama.addCandidate, ama.storage.candidates, true
            when "remove" then checkMessage msg, ama.removeCandidate, ama.storage.candidates, true
            when "current" then checkMessage msg, ama.currentAMA
            when "list" then checkMessage msg, ama.listCandidates, ama.storage.candidates
            when "help" then ama.printHelp msg
            when "clear" then checkRestrictedMessage msg, ama.clearCandidates, ama.storage.candidates
            else msg.send "Invalid command, say \"ama help\" for help"

    robot.enter (msg) ->
        checkMessage msg, ama.addCandidate, ama.storage.candidates

    robot.leave (msg) ->
        checkMessage msg, ama.removeCandidate, ama.storage.candidates
