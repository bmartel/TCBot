# Description
#   Control the mopidy music server
#
# Dependencies:
#   mopidy
#
# Configuration:
#  HUBOT_MOPIDY_WEBSOCKETURL (eg. ws://localhost:8282/mopidy/ws/)
#  (For now just change the webSocketUrl to your mopidy location)
#
#
# Commands:
#   set volume <digit> - Sets the volume to <digit>
#   volume? - Outputs what the volume currently is
#   what's playing - Outputs the currently playing track
#   next track - Skips to the next track
#   mute - Mutes the volume
#   unmute - Unmutes the volume
#   pause music - Pauses the music
#   resume music - Resumes the music
#   shuffle music - Turns shuffle on the playlist
#   stop shuffle - Shuts shuffle off
#   search music <searchTerm> - Searches all the mopidy backends for <searchTerm>
#   queue <digit> - Queues the track of YOUR last search
#
# Notes:
#   None
#
# Author:
#   eriley


Mopidy = require("mopidy")

mopidy = new Mopidy(
  webSocketUrl: 'ws://192.168.141.88:6680/mopidy/ws/',
  callingConvention: 'by-position-or-by-name'
)

online = false
mopidy.on 'state:online', ->
  online = true
mopidy.on 'state:offline', ->
  online = false

module.exports = (robot) ->
  robot.respond /set volume (\d+)/i, (message) ->
    newVolume = parseInt(message.match[1])
    if online
      mopidy.playback.setVolume(newVolume)
      message.send("Set volume to #{newVolume}")
    else
      message.send('Mopidy is offline')

  robot.respond /volume\?/i, (message) ->
    if online
      printCurrentVolume = (volume) ->
        if volume
          message.send("The Current volume is #{volume}")
        else
          message.send("Sorry, can't grab current volume")
    else
      message.send('Mopidy is offline')
    mopidy.playback.getVolume().then printCurrentVolume, console.error.bind(console)


  robot.respond /what'?s playing/i, (message) ->
    if online
      printCurrentTrack = (track) ->
        if track
          message.send("Currently playing: #{track.name} by #{track.artists[0].name} from #{track.album.name}")
        else
          message.send("No track is playing")
    else
      message.send('Mopidy is offline')
    mopidy.playback.getCurrentTrack().then printCurrentTrack, console.error.bind(console)

  robot.respond /next track/i, (message) ->
    if online
      mopidy.playback.next()
      printCurrentTrack = (track) ->
        if track
          message.send("Now playing: #{track.name} by #{track.artists[0].name} from #{track.album.name}")
        else
          message.send("No track is playing")
    else
      message.send('Mopidy is offline')
    mopidy.playback.getCurrentTrack().then printCurrentTrack, console.error.bind(console)

  robot.respond /mute/i, (message) ->
    if online
      mopidy.playback.setMute(true)
      message.send('Playback muted')
    else
      message.send('Mopidy is offline')

  robot.respond /unmute/i, (message) ->
    if online
      mopidy.playback.setMute(false)
      message.send('Playback unmuted')
    else
      message.send('Mopidy is offline')

  robot.respond /pause music/i, (message) ->
    if online
      mopidy.playback.pause()
      message.send('Music paused')
    else
      message.send('Mopidy is offline')

  robot.respond /resume music/i, (message) ->
    if online
      mopidy.playback.resume()
      message.send('Music resumed')
    else
      message.send('Mopidy is offline')

  robot.respond /shuffle music/i, (message) ->
    if online
      mopidy.tracklist.setRandom(true)
      message.send('Now shuffling')
    else
      message.send('Mopidy is offline')

  robot.respond /stop shuffle/i, (message) ->
    if online
      mopidy.tracklist.setRandom(false)
      message.send('Shuffling has been stopped')
    else
      message.send('Mopidy is offline')

  robot.respond /search music (.*)/i, (message) ->
    searchTerm = message.match[1]
    if online
      trackNum = 0
      tracks = []
      mopidy.library.search(any: searchTerm).then (results) ->
        trackList = ''
        for result in results
          if result.tracks
            for track in result.tracks
              if track.name
                tracks.push track
                trackNum++
                trackList += trackNum + ': ' + track.name + "\n"
        if trackNum == 0
          trackList = "Could not find any results for " + searchTerm
        else
          robot.brain.set message.message.user.name + "_musicsearch", tracks
        message.send(trackList)
    else
      message.send('Mopidy is offline')

  robot.respond /queue ([0-9]+)/i, (message) ->
    trackNumber = parseInt(message.match[1]) - 1
    tracks = robot.brain.get message.message.user.name + "_musicsearch"
    if mopidy.tracklist.add(tracks: [tracks[trackNumber]])
      message.send('Queued up: ' + tracks[trackNumber].name)
