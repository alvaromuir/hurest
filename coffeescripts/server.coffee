# sever

restify = require 'restify'
connect = require 'connect'
bunyan	= require 'bunyan'
sockets	= require 'socket.io' 
util	= require 'util'

routes  = require './routes'
config  = require './config'

listenOn= 8124
srvName	= 'synappsλs'

dbConfig = 
	uri: '127.0.0.1'
	name: srvName

# initialize database connection
config.init dbConfig

# initialize logger
appLogger = bunyan.createLogger
	name: srvName + ' Huerst Server'
	level: process.env.LOG_LEVEL || 'warn'
	stream: process.stdout
	serializers: bunyan.stdSerializers

# intiialize and configure RESTful API
server = restify.createServer
  name: srvName
  log: appLogger
  version: '0.0.1'


server.pre restify.pre.sanitizePath()
server.use restify.acceptParser server.acceptable
server.use restify.queryParser()
server.use restify.bodyParser()
server.use (req, res, next) ->
	res.header "Access-Control-Allow-Origin", "*"
	res.header "Access-Control-Allow-Headers", "x-Requested-With, Content-Type"
	res.header "Access-Control-Allow-Methods", "POST, GET, PUT, DELETE, OPTIONS"
	return next()

server.use restify.fullResponse()
server.on 'after', restify.auditLogger log: appLogger

# intiialize Socket.io 
io = sockets.listen server
io.set 'log level', 1
io.set 'origins', 'http://localhost:9000'

io.sockets.on 'connection', (socket) ->
    socket.emit 'news', '@alvaromuir says, "The huerst server is ready."'

#Routes

server.get /\/styles\/?.*/, restify.serveStatic
	directory: './views'

server.get /\/scripts\/?.*/, restify.serveStatic
	directory: './views'

server.get /\/img\/?.*/, restify.serveStatic
	directory: './views'
	
routes server

# Here. We. Go.
server.listen listenOn, ->
	console.log '%s listening at %s', server.name, server.url


module.exports =
	models: config.models()
	logger: appLogger
	webapp: server
	sockets: io