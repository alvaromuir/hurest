#DB setup and any external API config

mongoose  	= require 'mongoose'
appServer 	= require './server'
appSchemas 	= require './schema'
_			= require 'lodash'

module.exports =
	# init expects a setup object of a db uri, db name and db model title
	init: (setupObj) ->
		if _.keys(mongoose.models).length == 0
			models = {}
			_.forIn appSchemas, (val, key) ->
				model = new mongoose.Schema appSchemas[key].model,
					toObject: 
						virtuals: true
					toJSON:
						virtuals: true
						getters: true

				model.methods = _.cloneDeep appSchemas[key].methods

				hooks = appSchemas[key].hooks
				_.forIn hooks, (v, k) ->
					hook = k
					hookObj = hooks[k]
					_.forIn hookObj, (v, k) ->
						action = k
						method = hookObj[k]
						model[hook](action, method)


				virtuals = appSchemas[key].virtuals
				_.forIn virtuals, (v, k) ->
					model.virtual(k).get(v)

				models[key] = mongoose.model key, model


				validators = appSchemas[key].validators
				_.forIn validators, (v, k) ->
					models[key].schema.path(k).validate(v.fn, v.nsg)

		connLength = mongoose.connections.length
		mongoose.connect setupObj.uri, setupObj.name
		console.log 'Connection #' + connLength + ' to mongodb://' + setupObj.uri + '/' + setupObj.name

	models: ->
		return mongoose.models