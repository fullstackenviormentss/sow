# Main logic for summarising entries
'use strict'

timer = require("./harvest").TimeTracking
file = require "./file"
alias = require "./alias"
crypto = require "crypto"
logger = require "loggy"
colors = require "colors"
config = file.config()
action = ""

# Initial callback to parse callback
trackCallback = (err, data) ->
    logger.success "Track!"
    if err
        logger.error err
    else
        history = file.history()
        hash = crypto.createHash("md5").update(data.notes).digest "hex"
        history.entries[data.project_id] = {} unless history.entries[data.project_id]
        history.entries[data.project_id][data.task_id] = {} unless history.entries[data.project_id][data.task_id]
        history.entries[data.project_id][data.task_id][hash] = data.id unless history.entries[data.project_id][data.task_id][hash]

        last = history.chrono.pop()
        history.chrono.push last
        if last isnt data.id
            history.chrono.push data.id

        file.save file.files.history, history

timerCallbackStop = (err, data) ->
    if err
        logger.error err
    else
        timer.toggleTimer data, toggleCallback if data.timer_started_at

timerCallbackStart = (err, data) ->
    if err
        logger.error err
    else
        timer.toggleTimer data, trackCallback unless data.timer_started_at

toggleCallback = (err, data) ->
    logger.success "Toggle!"
    if err
        logger.error err
    else
        console.log data


# Helper method to ensure project and task IDs
parseOptions = (taskString, time = "", note = "") ->
    arr = taskString.split "."
    project = alias.get arr[0], "project"
    task = alias.get arr[1], "task"
    hours = ""

    if time.match /^\+?\d+(\.|:)\d+$/
        time = time.replace "+", ""

        # convert HH:MM to HH.MM
        if time.match /:/
            time_parts = time.split ":"
            hours = time_parts[0...1].pop()
            minutes = time_parts[1...2].pop()
            time = parseInt(hours) + parseInt(minutes)/60

        hours = parseFloat time
    else if time
        # Time doesn't look like a time entry and note is empty, so assume time is a note
        if not note
            note = time
        else
            note = time + " " + note

    {
        project_id: project
        task_id: task
        spent_at: generateTimeStamp()
        hours: hours
        notes: note
    }


generateTimeStamp = (date = false) ->
    if date
        date = new Date date
    else
        date = new Date

    dayName = switch date.getDay()
        when 0 then "Sun"
        when 1 then "Mon"
        when 2 then "Tue"
        when 3 then "Wed"
        when 4 then "Thu"
        when 5 then "Fri"
        when 6 then "Sat"

    monthName = switch date.getMonth()
        when 0 then "Jan"
        when 1 then "Feb"
        when 2 then "Mar"
        when 3 then "Apr"
        when 4 then "May"
        when 5 then "Jun"
        when 6 then "Jul"
        when 7 then "Aug"
        when 8 then "Sep"
        when 9 then "Oct"
        when 10 then "Nov"
        when 11 then "Dec"

    # Tue, 17 Oct 2006
    "#{ dayName }, #{ date.getDate() } #{ monthName } #{ date.getFullYear() }"

toggleTimer = (entry, cb) ->
    if config.debug
        logger.log "Getting entry #{ entry }"
    data =
        id: entry
    timer.get data, cb

# Show the logged time for a day, defaulting to today
exports.log = logTime = (date = false) ->
    # project(.| )task [comment]
    calledMethod = "day"
    d = getDate date
    dayRange d.toDateString(), d.toDateString()


# Start a new timer
exports.start = startTimer = (task, time = "", note = "") ->
    options = parseOptions task
    cb = trackCallback
    cb = toggleCallback if time.match /^\+?\d+(\.|:)\d+$/

    if config.debug
        logger.log options

    timer.create options, cb


exports.pause = pauseTimer = ->
    if config.debug
        logger.log "Pausing"
    toggleTimer file.history().chrono.pop(), timerCallbackStop

exports.resume = resumeTimer = ->
    toggleTimer file.history().chrono.pop(), timerCallbackStart