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

				_.forIn appSchemas[key].virtuals, (val, key) ->
					model.virtual(key).get(val)
					
				model.methods = _.cloneDeep appSchemas[key].methods
				models[key] = mongoose.model key, model

		connLength = mongoose.connections.length
		mongoose.connect setupObj.uri, setupObj.name
		console.log 'Connection #' + connLength + ' to mongodb://' + setupObj.uri + '/' + setupObj.name

	models: ->
		return mongoose.models