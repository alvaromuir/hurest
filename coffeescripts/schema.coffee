# DB setup

module.exports = 
	Posts:
		model:
			title: String
			author: String
			intro: String
			extended: String
			created:
				type: Date
			updated:
				type: Date
				default: Date.now
		methods: {}
		validators: {}
		virtuals: 
			id: ->
				return this._id
		jsonOmit: ['_id']
		webform:
			hide: ['created', 'updated',]