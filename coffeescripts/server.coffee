# sever
restify = require 'restify'
connect = require 'connect'
bunyan	= require 'bunyan'
util	= require 'util'
routes  = require './routes'
config  = require './config'
setup   = require './setup'

listenOn= setup.serverPort
srvName	= setup.serverName

dbConfig = 
	uri: setup.dataBaseURI
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
  res.header "Access-Control-Allow-Headers", "X-Requested-With, Content-Type"
  res.header "Access-Control-Allow-Methods", "POST, GET, PUT, DELETE, OPTIONS"
  next()
server.use restify.fullResponse()


# Bunyan
server.on 'after', restify.auditLogger log: appLogger


#Routes
server.get /\/styles\/?.*/, restify.serveStatic
	directory: './views'

server.get /\/scripts\/?.*/, restify.serveStatic
	directory: './views'

server.get /\/img\/?.*/, restify.serveStatic
	directory: './views'
	
routes server

# Here. We. Go.
server.listen listenOn, () ->
	console.log '%s listening at %s', server.name, server.url

module.exports =
	models: config.models()
	logger: appLogger
	webapp: server
	# Socket.IO
	io: require('./sockets').init(server, listenOn, srvName)