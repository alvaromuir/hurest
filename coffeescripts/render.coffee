# views and template renderer

fs			= require 'fs'
jade 		= require 'jade'

module.exports = (file, options, locals, cb) ->
	fs.readFile file, 'utf8', (err, data) ->
		if err
			return cb err
		build  = jade.compile(data, options)
		cb build(locals) if cb