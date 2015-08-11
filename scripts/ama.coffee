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
#   Samuel Tallent


class AMAManager

    constructor: (@robot) ->
        storageLoaded = =>
            @storage = @robot.brain.data.ama ||= {
                candidates: {}
            }
            @robot.logger.debug "AMA data loaded: " + JSON.stringify(@storage)

        @channels = ["bots", "ama", "Shell"] # channels where AMAs can run

        @admins = ["andy", "greg", "stevendiaz", "thomas", "Shell", "samtallent"]
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
                 ama odds - shows odds of each candidate being chosen
                 ama pass - stops the ama and returns the selected candidate's weight to the previous value
                 """

    pass: (msg) ->
        user = msg.message.user.name
        if user.toLowerCase() == @current.toLowerCase()
            @storage.candidates[@current] = @storage.candidates[@current] * 2.0
            stopAMA(msg)
        else
            msg.send('Sorry, you do not have permission for this command')

    selectUser = () ->
        weightedUserList = @storage.candidates
        weightedUserArray = []
        resetWeights = true

        smallestWeight = 1.0
        for user, weight of weightedUserList
            if weight < smallestWeight
                smallestWeight = weight

        for user, weight of @storage.candidates
            if weight == 1.0
                resetWeights = false
                break

        if resetWeights
            for user, weight of @storage.candidates
                @storage.candidates[user] = @storage.candidates[user] * 2.0
            weightedUserList = @storage.candidates
            smallestWeight = smallestWeight * 2.0

        for user, weight of @storage.candidates
            normalizedWeight = weight / smallestWeight
            weightedUserArray.push(user) while normalizedWeight-- > 0

        selectedUser = weightedUserArray[Math.floor(Math.random() * weightedUserArray.length)]
        @storage.candidates[selectedUser] = @storage.candidates[selectedUser] / 2.0
        return selectedUser

    startAMA: (msg) ->
        if Object.keys(@storage.candidates).length > 0
          if @intervalID
              msg.send "sorry, an AMA is already going. try ama stop"
          else
              firstSelection = selectUser()
              msg.send "#{firstSelection} has been selected to be today's AMA celebrity! Ask away, and anything goes :wink:"
              @current = firstSelection
              @intervalID = setInterval( ->
                  selected = selectUser()
                  msg.send "#{selected} has been selected to be today's AMA celebrity! Ask away, and anything goes :wink:"
                  @current = selected
                , 1000 * 60 * 60 * 24) #24 hours
        else
          msg.send "Unable to start AMA: no candidates."

    stopAMA = (msg) ->
        if @intervalID
            msg.send "the AMA is over! thank you everyone for your time."
            clearInterval(@intervalID)
            @intervalID = null
            @current = null
        else
            msg.send "there's no AMA going on right now. try \"ama start\""

    #helper function for stopAMA because I couldn't call it in pass as it was for whatever reason
    stopAMA: (msg) ->
        stopAMA(msg)

    currentAMA: (msg) ->
        if @current
            msg.send "#{@current} is the current AMA celebrity! Ask them anything!"
        else
            msg.send "no one is currently doing an AMA."

    addCandidate: (msg) ->
        user = msg.message.user.name.toLowerCase()
        if hasCandidate(user)
            msg.send "You are already an AMA candidate."
        else
            @storage.candidates[user] = 1.0
            msg.send "You have been added as an AMA candidate."

    removeCandidate: (msg) ->
        user = msg.message.user.name.toLowerCase()
        if hasCandidate(user)
            delete @storage.candidates[user]
            msg.send "You have been removed as an AMA candidate."
        else
            msg.send "You are not an AMA candidate."

    clearCandidates: (msg) ->
        if Object.keys(@storage.candidates).length > 0
            @storage.candidates = {}
            @save
            msg.send "Candidates cleared. "
        else
            msg.send "There are no candidates to clear."

    listWeights: (msg) ->
        str = "There are #{Object.keys(@storage.candidates).length} candidates for the AMA"
        for candidate, weight of @storage.candidates
            str = str + "\nCandidate: " + candidate + "\tWeight: " + weight
        msg.send str

    listCandidates: (msg) ->
        str = "There are #{Object.keys(@storage.candidates).length} candidates for the AMA"
        for candidate, weight of @storage.candidates
            str = str + "\n#{candidate}"
        msg.send str

    hasCandidate = (passedUser) ->
        for user, weight of @storage.candidates
            if passedUser == user
                return true
        return false

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
            when "odds" then checkMessage msg, ama.listWeights
            when "pass" then checkMessage msg, ama.pass
            when "help" then ama.printHelp msg
            when "clear" then checkRestrictedMessage msg, ama.clearCandidates
            else msg.send "Invalid command, say \"ama help\" for help"
