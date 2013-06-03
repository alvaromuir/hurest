# Server routes
db          = require './config'
schemas     = require './schema'
render      = require './render'
sockets     = require './sockets'

_           = require 'lodash'
_str        = require 'underscore.string'


_.mixin _str.exports()
_.mixin require 'underscore.inflections'


paramsObjectify = (params, col) ->
    collection = _.rstrip col, 's'
    return params[collection] if params[collection]

    try
        JSON.parse(params)
    catch e
        rslt = {}
        params = params.split("&") unless typeof params is "object"
        for x of params
            pairs = params[x].split("=")
            rslt[pairs[0]] = decodeURIComponent(pairs[1].replace(/\+/g, " "))
        rslt

genLocals = (input) ->
    doc = undefined
    locals = {}

    if arguments.length > 1
        doc = arguments[0]
        x = 1
        while x < arguments.length
            locals[_.keys(arguments[x])[0]] = arguments[x][_.keys(arguments[x])[0]]
            x++
    else
        doc = input


    locals.title = "'"+doc.title+"' details"
    locals.header = "'"+doc.title+"'"
    locals.blurb = 'Created on ' + doc.created
    locals.results = _.pick doc, (key, val) ->
            key if typeof key == 'string'
    locals

renderPage = (view, prettyOpt, localVars, response, cb) ->
    render './views/index.jade', 
        # jade options
        pretty: prettyOpt
    ,   # locals
        localVars
    , (rendered) -> # callback
        response.write rendered
        response.end()
        cb()

module.exports = (server, models) ->

	server.opts /\.*/, (req, res, next) ->
  		res.send 200
  		next()

	server.get "/echo/:q", (req, res, next) ->
    	res.send 200, 'You requested ' + req.url + ' on ' + req.date()
    	next()

	server.get "/", (req, res, next) ->
    	res.send 200,
            move_along: 'nothing to see here... '
            follow_me: '@alvaromuir'
    	next()

    # Quick Input
    server.get "/input/:col", (req, res, next) ->
        collection = _str.capitalize req.params.col
        locals = 
            title: "Model request error"
            header: "Opps, a schema for '" + req.params.col + "' does not exist"
            blurb: "Check your url entry. If it's correct, you should create the model."

        if schemas[collection]
            Model   = db.models()[collection]
            models  = _.keys db.models()
            rules   = schemas[collection].webform
            schema  = _.pick db.models()[collection].schema.tree, (value, key) ->
                key.charAt(0) != '_'

            _(rules.hide).each (field) ->
                delete schema[field]

            locals = 
                title: "Create a new " + _.singularize collection
                header: "New " + _.singularize collection
                blurb: "Go 'head and create a new "+ _.singularize(collection).toLowerCase()+". Go Nuts."
                schema:  schema

                txtArea: rules.txtArea
                dateField: rules.date
                radioBtn: rules.radio
                chkBox: rules.check
                select: rules.select

            renderPage './views/index.jade', true, locals, res, next
        else
            renderPage './views/index.jade', true, locals, res, next

    server.get "/input/:col/:id", (req, res, next) ->
        if io is undefined
            io = require('./server').io
            
        collection = _str.capitalize req.params.col

        errorLocals = 
            title: "Model request error"
            header: "Whoops, a record with id '" + req.params.id + "' does not exist"
            blurb: "Check your url entry. If it's correct, you should create the record."

        if schemas[collection]
            Model   = db.models()[collection]
            models  = _.keys db.models()
            rules   = schemas[collection].webform
            schema  = _.pick db.models()[collection].schema.tree, (value, key) ->
                        key.charAt(0) != '_'

            # form field rules
            io.sockets.on 'connection', (socket) ->
                socket.emit 'getRules', rules

            if schemas[collection].model._id is false
                Model.findOne id:req.params.id, (err, doc) ->
                    if err or doc == null
                        locals = errorLocals
                    else
                        locals = genLocals doc, schema:schema

                    renderPage './views/index.jade', true, locals, res, next
                    return
                
            else
                Model.findById req.params.id, (err, doc) ->
                    if err or doc == null
                        locals = errorLocals
                    else
                        locals = genLocals(doc, schema:schema, hide:rules.hide)
                        renderPage './views/index.jade', true, locals, res, next
                        return
        else
            console.log 'bad request'
            locals = 
                title: "Model request error"
                header: "Opps, a schema for '" + req.params.col + "' does not exist"
                blurb: "Check your url entry. If it's correct, you should create the model."
            
            renderPage './views/index.jade', true, locals, res, next
        
    server.get "/kill/:col/:id", (req, res, next) ->
        collection = _str.capitalize req.params.col
        Model = db.models()[collection]

        successMessage = (rslt) ->
            msg = 
                status: 'OK'
                info: "record " + rslt._id + " destroyed"
            msg 

        if schemas[collection].model._id is false
            Model.findOneAndRemove id:req.params.id, (err, rslt) ->
                if err
                    res.send 200, error: err
                else
                    res.send 200, successMessage(rslt)          
        else
            Model.findByIdAndRemove req.params.id, (err, rslt) ->
                if err
                    res.send 200, error: err
                else
                    res.send 200, successMessage(rslt)  

    # REST
    server.post "/api/:col", (req, res, next) ->
        collection = _str.capitalize req.params.col
        Model = db.models()[collection]

        if Model
            data = paramsObjectify(req.body)
            data.created = Date.now()

            Model.create data, (err, rslt) ->
                if err
                    res.send 200, error: err
                else
                    res.send 201, rslt
                next()
        else
            res.send 200,
                error: 'Schema for ' + req.params.col + ' does not exist.'

    server.get "/api/:col", (req, res, next) ->
        collection = _str.capitalize req.params.col

        if schemas[collection]
            hideList = schemas[collection].jsonOmit

            Model = db.models()[collection]

            Model.find {}, (err, rcrds) ->
                if err
                    res.send 200, error: err
                else
                    # play nice with ember
                    rslts = {}
                    rsltsArr = []
                    _.each rcrds, (doc) ->
                        tmp = _.omit doc.toJSON(), hideList
                        rcrd = {}
                        # underscore JSON attributes
                        _.each tmp, (v, k) ->
                            rcrd[_str.underscored(k)] = v
                        rsltsArr.push rcrd
                    
                    rslts[req.params.col] = rsltsArr
                    res.send 200, rslts

        else
            res.send 405, 
                error: 405
                msg: "'"+collection+"' was not found. Please check your url or create the collection."

    server.get "/api/:col/:id", (req, res, next) ->
        collection = _str.capitalize req.params.col
        
        if schemas[collection]
            hideList = schemas[collection].jsonOmit
            Model = db.models()[collection]

            if schemas[collection].model._id is false
                Model.findOne id:req.params.id, (err, doc) ->
                    if err
                        res.send 200, error: err
                    else
                        # play nice with ember
                        if doc
                            rslts = {}
                            rslts[_.rstrip req.params.col, 's'] = _.omit doc.toJSON(), hideList
                            res.send 200, rslts
                        else 
                            res.send 405, 
                                error: 405
                                msg: "'"+collection+":"+req.params.id+"' is invalid."
               
            else
                Model.findById req.params.id, (err, doc) ->
                    if err
                        res.send 405, 
                            error: 405
                            message: "'"+collection+":"+req.params.id+"' is invalid."
                    else
                        # play nice with ember
                        if doc
                            console.log doc
                            rslts = {}
                            rslts[_.rstrip req.params.col, 's'] = _.omit doc.toJSON(), hideList
                            res.send 200, rslts
                        else 
                            res.send 405, 
                                error: 405
                                msg: "'"+collection+":"+req.params.id+"' is invalid."

        else
            res.send 405, 
                error: 405
                msg: "'"+collection+"' was not found. Please check your url or create the collection."

    server.put "/api/:col/:id", (req, res, next) ->
        collection = _str.capitalize req.params.col
        Model = db.models()[collection]
        data =  paramsObjectify(req.body, req.params.col)
        data.updated = Date.now()
        schema  = _.pick db.models()[collection].schema.tree, (value, key) ->
                    key.charAt(0) != '_'

        if schemas[collection].model._id is false
            Model.findOneAndUpdate id:req.params.id, data, null, (err, rslt) ->
                if err
                    res.send 200, error: err
                else
                    res.send 204, rslt
        else
            Model.findByIdAndUpdate req.params.id, data, null, (err, rslt) ->
                if err
                    res.send 200, error: err
                else
                    res.send 204, rslt

    server.del "/api/:col/:id", (req, res, next) ->
        collection = _str.capitalize req.params.col
        Model = db.models()[collection]
        Model.findByIdAndRemove req.params.id, (err, rslt) ->
            if err
                res.send 200, error: err
            else
                res.send 204, 
                    status: 'OK', 
                    info: "record " + rslt._id + " destroyed"