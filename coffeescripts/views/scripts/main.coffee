# Global RequireJS File
'use strict'
@app = window.app ? {}

require.config
	paths: 
		'jquery': '/scripts/vendor/jquery/jquery.min'
		'moment': '/scripts/vendor/moment/min/moment.min'
		'underscore': '/scripts/vendor/lodash/dist/lodash.min'
		'underscore.string': '/scripts/vendor/underscore.string/dist/underscore.string.min'
		'utils': 'utils'

	shim:
		'underscore':
			exports: '_'

		'underscore.string':
			deps: ['underscore']
			init: (_) ->
				_.mixin _.str.exports()


require ['utils', 'jquery', 'moment', 'underscore', 'underscore.string'], (utils, $, moment) ->
	'use strict'
	$ ->
		console.log 'Peeking behind the curtains now, are you? @alvaromuir haz the codez.'

		# This stuff is for the dynamic input form
		# VERY ugly, not DRY

		$header = $ '#header h2'
		$labels = $ 'label'
		$submit = $ '#submit'
		$btns 	= $ '.btn'
		$clear	= $ '#clear'
		$edit 	= $ '#edit'
		$approve = $ '#approve'
		$cancel	= $ '#cancel'
		$trash	= $ '#trash'
		$dds	= $ 'dd'
		$btnNow = $ '#btnNow'


		# for label cleanup
		$labels.each ->
			$(this).html(_.str.humanize($(this).html()))

		$('form :first').css("visibility", "visible")

		# error modal
		displayStatus = (sel, banner, msg)->
			$('.alert :first').addClass sel
			$('.alert :first strong').html banner
			$('.alert :first p').html msg
			$('.alert :first').fadeToggle 'slow'

		# save current state
		app.currentFormData = {}

		$(document).on 'click', ->
			if $('.alert :first').is ':visible'
				$('.alert :first').fadeToggle(3000)

		$btns.on 'click', (e) ->
			e.preventDefault()

		$clear.on 'click', ->
    		$(this).closest('form').find("input[type=text], textarea").val("")

		$btnNow.on 'click', (e) ->
			$input= $(this).prev 'input:first'
			$input.val moment(new Date()).format('MMM DD YYYY')

		$submit.on 'click', (e) ->
			path = window.location.pathname.split('/')
			apiRoot = path[path.length-1]

			$form = $(this).parents 'form:first'
			e.preventDefault()

			if $form.serialize()
				$.ajax
					type: "POST"
					url: '/api/' + apiRoot
					data: $form.serialize()
					success: (data) ->
						$form.find("input[type=text], textarea").val("")
						if data.error
							displayStatus null, 'WARNING', data.error.message
						else
							displayStatus 'alert-success', 'All Good.', '"' + data.title + '" has been posted to the server.'
					error: (err) ->
						displayStatus 'alert-error', 'Code Red - Danger!', err.statusText

			else
				$('.container').append '<div class="warning"><p class="text-error">Please enter some data before your submit!<p></div>'

		$edit.on 'click', ->

			$(this).addClass 'disabled'
			$approve.removeClass 'disabled'
			$cancel.removeClass 'disabled'
			$trash.addClass 'disabled'
			$header.html 'Edit ' + $header.text()

			$dds.each (val) ->
				$self = $(this)
				$label = _.str.trim $self.prev().text()
				$current = $($self[0]).find('>:first-child')
				$content = $current.text()

				if $label isnt 'id'
					if _.contains app.inputRules.txtArea, $label
						app.currentFormData['txt_'+$label] = $content
						$current.replaceWith '<textarea rows="10" id="txt_'+$label+'"name="'+$label+'" class="span9"/>'
						$('#txt_'+$label).val($content)
					else
						app.currentFormData['input_'+$label] = $content
						$current.replaceWith '<input type="text" id="input_'+$label+'"name="'+$label+'" class="span8" value="'+$content+'" />'

		$approve.on 'click', ->
			$edit.removeClass 'disabled'
			$(this).addClass 'disabled'
			$cancel.addClass 'disabled'
			$trash.removeClass 'disabled'
			$form = $(this).parents 'form:first'
			$col = window.location.pathname.split('/')[window.location.pathname.split('/').length-2]
			
			if $("h3:contains(\"_id\")").length > 0
				$id = $("h3:contains(\"_id\")").parent().next().children('.lead').html()
			else
				$id = $("h3:contains(\"id\")").parent().next().children('.lead').html()

			$.ajax
				type: "PUT"
				url: '/api/'+$col+'/'+$id
				data: $form.serialize()
				success: (data) ->
					$dds.each (val) ->
						$self = $(this)
						$current = $($self[0]).find('>:first-child')
						$content = $current.val()

						if $current.is('input') or $current.is('textarea')
							$current.replaceWith '<p class="lead">'+$content+'</p>'

						if _.str.include $('#header h2').text(), "Edit"
							$('#header h2').html $('#header h2').text().split('Edit ')[1]

					displayStatus 'alert-success', 'SUCCESS', 'updated'

		$cancel.on 'click', ->
			$edit.removeClass 'disabled'
			$approve.addClass 'disabled'
			$(this).addClass 'disabled'
			$trash.removeClass 'disabled'

			if _.str.include $('#header h2').text(), "Edit"
				$('#header h2').html $('#header h2').text().split('Edit ')[1]

			$dds.each (val) ->
				$self = $(this)
				$current = $($self[0]).find('>:first-child')
				$content = app.currentFormData[$current.attr('id')]

				if $current.is('input') or $current.is('textarea')
					$current.replaceWith '<p class="lead">'+$content+'</p>'

			displayStatus null, 'WARNING', 'This update has been cancelled.'

		$trash.on 'click', ->
			console.log $(this).attr('class')
			document.location.href= window.location.pathname.replace('input', 'kill')