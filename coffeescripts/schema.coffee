# DB setup

module.exports = 
	Post:
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
		webform:
			hide: ['created', 'updated']