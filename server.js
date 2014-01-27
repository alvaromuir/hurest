// Generated by CoffeeScript 1.6.3
(function() {
  var appLogger, bunyan, config, connect, dbConfig, listenOn, restify, routes, server, setup, srvName, util;

  restify = require('restify');

  connect = require('connect');

  bunyan = require('bunyan');

  util = require('util');

  routes = require('./routes');

  config = require('./config');

  setup = require('./setup');

  listenOn = setup.serverPort;

  srvName = setup.serverName;

  dbConfig = {
    uri: setup.dataBaseURI,
    name: srvName
  };

  config.init(dbConfig);

  appLogger = bunyan.createLogger({
    name: srvName + ' Huerst Server',
    level: process.env.LOG_LEVEL || 'warn',
    stream: process.stdout,
    serializers: bunyan.stdSerializers
  });

  server = restify.createServer({
    name: srvName,
    log: appLogger,
    version: '0.0.1'
  });

  server.pre(restify.pre.sanitizePath());

  server.use(restify.acceptParser(server.acceptable));

  server.use(restify.queryParser());

  server.use(restify.bodyParser());

  server.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "X-Requested-With, Content-Type");
    res.header("Access-Control-Allow-Methods", "POST, GET, PUT, DELETE, OPTIONS");
    return next();
  });

  server.use(restify.fullResponse());

  server.on('after', restify.auditLogger({
    log: appLogger
  }));

  server.get(/\/styles\/?.*/, restify.serveStatic({
    directory: './views'
  }));

  server.get(/\/scripts\/?.*/, restify.serveStatic({
    directory: './views'
  }));

  server.get(/\/img\/?.*/, restify.serveStatic({
    directory: './views'
  }));

  routes(server);

  server.listen(listenOn, function() {
    return console.log('%s listening at %s', server.name, server.url);
  });

  module.exports = {
    models: config.models(),
    logger: appLogger,
    webapp: server,
    io: require('./sockets').init(server, listenOn, srvName)
  };

}).call(this);
