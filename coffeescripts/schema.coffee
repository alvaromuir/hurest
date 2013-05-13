# DB setup

module.exports = 
	Posts:
		model:
			title: String
			slug: String
			body: String
			publishedAt:
				type: Date
				default: Date.now
		methods: {}
		validators: {}
		virtuals: 
			id: ->
				return this._id
		jsonOmit: ['_id']
		webform:
			hide: ['id']
			txtArea: ['body']
			date: ['publishedAt']