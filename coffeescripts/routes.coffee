# Server routes

db          = require './config'
schemas     = require './schema'
render      = require './render'
_           = require 'lodash'
_.str       = require 'underscore.string'
_.mixin _.str.exports()

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

module.exports = (server, models) ->

	server.opts /\.*/, (req, res, next) ->
  		res.send 200
  		return next()

	server.get "/echo/:q", (req, res, next) ->
    	res.send 200, 'You requested ' + req.url + ' on ' + req.date()
    	return next()

	server.get "/", (req, res, next) ->
    	res.send 200,
            move_along: 'nothing to see here... '
            follow_me: '@alvaromuir'
    	return next()

    # Static test page
    server.get "/input", (req, res, next) ->
        render './views/index.jade', 
            # jade options
            pretty: true
        ,   # locals
            title: "Nothing to see here."
            header:"Follow Us"
            blurb: "@cbsoutdoor"
            
        , (rendered) -> # callback
            res.write rendered
            res.end()

    # Quick Input
    server.get "/input/:col", (req, res, next) ->
        collection = _.str.capitalize req.params.col
        rules   = schemas[collection].webform
        models  = _.keys db.models()
        schema  = _.pick db.models()[collection].schema.tree, (value, key) ->
                            return key.charAt(0) != '_'

        _(rules.hide).each (field) ->
            delete schema[field]

        locals = {}

        if _.contains(models, collection)
            locals = 
                title: "Create new record"
                header: "New " + collection
                blurb: "A new record will go here ..."
                schema:  schema
                txtArea: rules.txtArea
                dateField: rules.date
        else
            locals = 
                title: "Model request error"
                header: "Opps, a schema for  " + req.params.col + " does not exist"
                blurb: "Check your url entry. If it's correct, you should create the model."

        render './views/index.jade', 
                # jade options
                pretty: true
            ,   # locals
                locals
            , (rendered) -> # callback
                res.write rendered
                res.end()
                return next()

    server.get "/input/:col/:id", (req, res, next) ->
        collection = _.str.capitalize req.params.col
        Model = db.models()[collection]
        Model.findById req.params.id, (err, rslt) ->
            locals = {}
            if err or rslt == null
                locals = 
                    title: "Model request error"
                    header: "Whoops, a record with id '" + req.params.id + "' does not exist"
                    blurb: "Check your url entry. If it's correct, you should create the record."
            else
                rules = schemas[collection].webform
                models = _.keys db.models()
                schema = _.pick db.models()[collection].schema.tree, (value, key) ->
                                return key.charAt(0) != '_'
                _(rules.hide).each (field) ->
                    delete schema[field]

                locals = 
                    title: rslt.title
                    header: 'Post entry updated on ' + rslt.updated
                    blurb: 'Created on ' + rslt.created
                    schema:  schema
                    results: _.pick rslt, (key, val) ->
                                return key if typeof key == 'string'

            render './views/index.jade', 
                    # jade options
                    pretty: true
                ,   # locals
                    locals
                , (rendered) -> # callback
                    res.write rendered
                    res.end()
                    return next()

    server.get "/kill/:col/:id", (req, res, next) ->
        collection = _.str.capitalize req.params.col
        Model = db.models()[collection]
        Model.findByIdAndRemove req.params.id, (err, rslt) ->
            if err
                res.send 200, error: err
            else
                res.send 200, 
                    status: 'OK', 
                    info: "record " + rslt._id + " destroyed"


    # REST
    server.post "/api/:col", (req, res, next) ->
        collection = _.str.capitalize req.params.col
        Model = db.models()[collection]

        if Model
            data = paramsObjectify(req.body)
            data.created = Date.now()

            Model.create data, (err, rslt) ->
                if err
                    res.send 200, error: err
                else
                    res.send 200, rslt
                return next()
        else
            res.send 200,
                error: 'Schema for ' + req.params.col + ' does not exist.'

    server.get "/api/:col", (req, res, next) ->
        collection = _.str.capitalize req.params.col
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
                    rsltsArr.push _.omit doc.toJSON(), hideList
                rslts[req.params.col] = rsltsArr
                res.send 200, rslts
            return

    server.get "/api/:col/:id", (req, res, next) ->
        collection = _.str.capitalize req.params.col
        hideList = schemas[collection].jsonOmit

        Model = db.models()[collection]
        Model.findById req.params.id, (err, doc) ->
            if err
                res.send 200, error: err
            else
                # play nice with ember
                rslts = {}
                rslts[_.rstrip req.params.col, 's'] = _.omit doc.toJSON(), hideList
                res.send 200, rslts
            return

    server.put "/api/:col/:id", (req, res, next) ->
        collection = _.str.capitalize req.params.col
        Model = db.models()[collection]
        data =  paramsObjectify(req.body, req.params.col)
        data.updated = Date.now()

        Model.findByIdAndUpdate req.params.id, data, null, (err, rslt) ->
            if err
                res.send 200, error: err
            else
                res.send 200

    server.del "/api/:col/:id", (req, res, next) ->
        collection = _.str.capitalize req.params.col
        Model = db.models()[collection]
        Model.findByIdAndRemove req.params.id, (err, rslt) ->
            if err
                res.send 200, error: err
            else
                res.send 200, 
                    status: 'OK', 
                    info: "record " + rslt._id + " destroyed"
            return