# DB setup

_str = require 'underscore.string'
moment = require 'moment'

module.exports = 
	Posts:
		model:
			title: String
			slug: String
			body: String
			publishedAt:
				type: Date
				default: Date.now	
			_id: false
			id: String
			draft: 
				type: Boolean
				default: false

		methods: {}
		validators: {}
		virtuals: {}
		hooks:
			pre:
				save: (next) ->
					this.id = _str.slugify this.title unless this.id
					next()

				validate: (next) ->
					# example validator
					day 	= moment().format 'MM[.]DD[.]YYYY'
					time 	= moment().format 'h:mm:ss a'
					this.title = 'Some Random Thoughts on ' + day unless this.title
					this.slug = 'A post about ' + this.title + ' at '+ time unless this.slug
					this.body = 'Fat-fingered the keybord, forgot to actually write a post!' unless this.body
					next()

			post: {}

		jsonOmit: ['_id']
		webform:
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