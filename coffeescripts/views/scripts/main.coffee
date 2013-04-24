# Global RequireJS File

require.config
	paths: 
		'jquery': '/scripts/vendor/jquery/jquery.min'
		'moment': '/scripts/vendor/moment/min/moment'
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


require ['utils', 'app', 'jquery', 'underscore', 'underscore.string'], (utils, app, $) ->
	'use strict'
	$ ->
		console.log 'Peeking behind the curtains now, are you?'

		# This stuff is for the dynamic input form
		# VERY ugly, not DRY

		$submit = $('#submit')
		$btns 	= $('.btn')
		$edit 	= $('#edit')
		$approve = $('#approve')
		$cancel	= $('#cancel')
		$trash	= $('#trash')
		$labels = $('label')
		$dds	= $('dd')
		
		_.each $labels, (field) ->
			#console.log $(field).html()

		$('#submit').on 'click', (e) ->
			$form = $(this).parents 'form:first'
			e.preventDefault()
			if $form.serialize()
				$.ajax
					type: "POST"
					url: '/api/post'
					data: $form.serialize()
					success: (data) ->
						console.log data
						$(location).attr('href', '/api/post');
			else
				$('.container').append '<div class="warning"><p class="text-error">Please enter some data before your submit!<p></div>'

		$('.btn').on 'click', (e) ->
			e.preventDefault()

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
			
