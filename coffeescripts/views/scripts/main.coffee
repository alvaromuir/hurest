# Global RequireJS File

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
		console.log 'Peeking behind the curtains now, are you?'

		# This stuff is for the dynamic input form
		# VERY ugly, not DRY

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


		# error modal
		displayStatus = (sel, banner, msg)->
			$('.alert :first').addClass sel
			$('.alert :first strong').html banner
			$('.alert :first p').html msg
			$('.alert :first').fadeToggle 'slow'


		$(document).on 'click', ->
			if $('.alert :first').is ':visible'
				$('.alert :first').fadeToggle()

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

			$dds.each (val) ->
				$self = $(this)
				$label = _.str.trim $self.prev().text()
				$current = $($self[0]).find('>:first-child')
				$content = $current.text()
				
				$current.replaceWith '<input type="text" id="'+$label+'"name="'+$label+'" value="'+$content+'" />'

		$approve.on 'click', ->
			$edit.removeClass 'disabled'
			$(this).addClass 'disabled'
			$cancel.addClass 'disabled'
			$trash.removeClass 'disabled'
			$form = $(this).parents 'form:first'
			$id = $('#id').val()

			$.ajax
				type: "PUT"
				url: '/api/post/' + $id
				data: $form.serialize()
				success: (data) ->
					$dds.each (val) ->
						$self = $(this)
						$current = $($self[0]).find('>:first-child')
						$content = $current.val()

						$current.replaceWith '<p class="lead">'+$content+'</p>'
					$('.container').append '<div class="success"><p class="text-success">This record has been updated.<p></div>'

		$cancel.on 'click', ->
			$edit.removeClass 'disabled'
			$approve.addClass 'disabled'
			$(this).addClass 'disabled'
			$trash.removeClass 'disabled'

			$dds.each (val) ->
				$self = $(this)
				$current = $($self[0]).find('>:first-child')
				$content = $current.val()

				$current.replaceWith '<p class="lead">'+$content+'</p>'
			$('.container').append '<div class="info"><p class="text-info">This update has been cancelled.<p></div>'

		$trash.on 'click', ->
			console.log $(this).attr('class')
			document.location.href= window.location.pathname.replace('input', 'kill')