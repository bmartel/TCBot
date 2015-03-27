# Description:
#   calculates how many pizzas I need for a number of people
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot hmpdin for {n} people - Calculate how many pizzas do I need

module.exports = (robot) ->

  robot.respond /hmpdin for ([0-9]+) people/i, (msg) ->
  	people = msg.match[1]
  	people = Math.floor(0.4 * people + (Math.log(people) / Math.LN10) + 1)
  	msg.reply  "You need " + people + " pizzas"

  robot.respond /hmpogbdin for ([0-9]+) people/i, (msg) ->
  	msg.reply  "You need 20lbs of ground beef"