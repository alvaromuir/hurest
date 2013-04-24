# Some basic utils for the webapp

'use strict'
@app = window.app ? {}

define ['jquery'], ($) ->

	app.utils =
		echo: (ping) ->
			return ping

		formSerialize: (formData, e, cb) ->
			$this = formData;
			e.preventDefault()
			inputs = $this.find('input[type=text]')
			rslts = {}
			for i in inputs
				if i.name.indexOf('.') > -1
					parent = i.name.split('.')[0]
					child = i.name.split('.')[1]
					if not rslts[parent]
						rslts[parent] = {}
						rslts[parent][child] = i.value
				else
					rslts[i.name] = i.value
			if cb
				cb rslts
			return rslts