# Description:
#   catme is the most important thing in life, even moreso than pugme
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot cat me - Receive a cat

module.exports = (robot) ->

  @options = {headers: {'Content-Type' : 'application/json'}}

  robot.respond /cat me/i, (msg) ->

    msg.http("http://edgecats.net/first", @options)
      .get() (err, res, body) ->
        msg.send res.headers['x-cat-link']