# socket.io stuff

sockets	= require 'socket.io'
setup   = require './setup'
io = undefined

module.exports =
	socket: () ->
		## warning, will return null if init is not caled with server first
		io

	init: (server) ->
		if io is undefined
			io = sockets.listen server
			io.set 'log level', 1
			io.set 'origins', 'http://localhost:'+ setup.serverPort
			io