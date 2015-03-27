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
#
#
#
# Notes:
#   None
#
# Author:
#   eriley


Mopidy = require("mopidy")

mopidy = new Mopidy(
  webSocketUrl: 'ws://192.168.141.101:6680/mopidy/ws/',
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
