# Description:
#   coffee is the most important thing in life
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot coffee time? - Marks this room as getting a notification when it's coffeetime

cronJob = require('cron').CronJob

module.exports = (robot) ->

	coffeeTime = new cronJob('1 * * * * 1-5', () ->
		checkCoffeeTime()
	, null, true);

	checkCoffeeTime = () ->
		room = robot.brain.get "coffeeRoom"
		if room
			date = new Date()
			if date.getHours() == 14 && date.getMinutes() == 30
				robot.messageRoom(room, "It's Parlour time.")
			else if date.getHours() == 10 && date.getMinutes() == 30
				robot.messageRoom(room, "It's Tim Hortons time.")

	findRoom = (msg) ->
		room = msg.envelope.room
		if room == undefined
			room = msg.envelope.user.reply_to
		return room

	robot.respond /coffee time\?/i, (msg) ->
		room = findRoom(msg)
		robot.brain.set "coffeeRoom", room
		msg.send("I'll tell you when it's coffee time.")