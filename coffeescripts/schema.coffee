# DB setup - uses a todo list as an example

_str = require 'underscore.string'
moment = require 'moment'

module.exports = 
	Tasks:
		model:
			title: String
			details: String
			dueDate: Date
			createdAt:
				type: Date
			_id: false
			id: String
			completed: 
				type: Boolean
				default: false

		methods: {}
		validators: 
			title: 
				fn: (val) ->
					val.length > 3
				msg: 'Invalid title length.'
		
		virtuals: {}
		hooks:
			pre:
				save: (next) ->
					this.id = _str.slugify this.title unless this.id
					this.createdAt = Date.now()
					next()

			post: {}

		jsonOmit: ['_id']
		webform:
<<<<<<< HEAD
			hide: ['id']
			txtArea: ['body']
			date: ['publishedAt']
			check: ['draft']
			radio: []
			select: []
	Tasks:
		model:
			title: String
			details: String
			dueDate: Date
			createdAt:
				type: Date
			_id: false
			id: String
			completed: 
				type: Boolean
				default: false

		methods: {}
		validators: 
			title: 
				fn: (val) ->
					val.length > 3
				msg: 'Invalid title length.'
		
		virtuals: {}
		hooks:
			pre:
				save: (next) ->
					this.id = _str.slugify this.title unless this.id
					this.createdAt = Date.now()
					next()

			post: {}

		jsonOmit: ['_id']
		webform:
=======
>>>>>>> c637fa338a1b22b6ac3b84ebedc172f8a2d86b35
			hidden: ['id', 'createdAt']
			textArea: ['details']
			date: ['dueDate']
			checkBox: []
			radioBtn: [
				'completed':
					choices: ['true', 'false']
					defaults: ['false']
				]
			select: []