// Generated by CoffeeScript 1.6.2
(function() {
  require.config({
    paths: {
      'jquery': '/scripts/vendor/jquery/jquery.min',
      'moment': '/scripts/vendor/moment/min/moment',
      'underscore': '/scripts/vendor/lodash/dist/lodash.min',
      'underscore.string': '/scripts/vendor/underscore.string/dist/underscore.string.min',
      'utils': 'utils'
    },
    shim: {
      'underscore': {
        exports: '_'
      },
      'underscore.string': {
        deps: ['underscore'],
        init: function(_) {
          return _.mixin(_.str.exports());
        }
      }
    }
  });

  require(['utils', 'app', 'jquery', 'underscore', 'underscore.string'], function(utils, app, $) {
    'use strict';    return $(function() {
      var $approve, $btns, $cancel, $dds, $edit, $labels, $submit, $trash;

      console.log('Peeking behind the curtains now, are you?');
      $submit = $('#submit');
      $btns = $('.btn');
      $edit = $('#edit');
      $approve = $('#approve');
      $cancel = $('#cancel');
      $trash = $('#trash');
      $labels = $('label');
      $dds = $('dd');
      _.each($labels, function(field) {});
      $('#submit').on('click', function(e) {
        var $form;

        $form = $(this).parents('form:first');
        e.preventDefault();
        if ($form.serialize()) {
          return $.ajax({
            type: "POST",
            url: '/api/post',
            data: $form.serialize(),
            success: function(data) {
              console.log(data);
              return $(location).attr('href', '/api/post');
            }
          });
        } else {
          return $('.container').append('<div class="warning"><p class="text-error">Please enter some data before your submit!<p></div>');
        }
      });
      $('.btn').on('click', function(e) {
        return e.preventDefault();
      });
      $edit.on('click', function() {
        $(this).addClass('disabled');
        $approve.removeClass('disabled');
        $cancel.removeClass('disabled');
        $trash.addClass('disabled');
        return $dds.each(function(val) {
          var $content, $current, $label, $self;

          $self = $(this);
          $label = _.str.trim($self.prev().text());
          $current = $($self[0]).find('>:first-child');
          $content = $current.text();
          return $current.replaceWith('<input type="text" id="' + $label + '"name="' + $label + '" value="' + $content + '" />');
        });
      });
      $approve.on('click', function() {
        var $form, $id;

        $edit.removeClass('disabled');
        $(this).addClass('disabled');
        $cancel.addClass('disabled');
        $trash.removeClass('disabled');
        $form = $(this).parents('form:first');
        $id = $('#id').val();
        return $.ajax({
          type: "PUT",
          url: '/api/post/' + $id,
          data: $form.serialize(),
          success: function(data) {
            $dds.each(function(val) {
              var $content, $current, $self;

              $self = $(this);
              $current = $($self[0]).find('>:first-child');
              $content = $current.val();
              return $current.replaceWith('<p class="lead">' + $content + '</p>');
            });
            return $('.container').append('<div class="success"><p class="text-success">This record has been updated.<p></div>');
          }
        });
      });
      $cancel.on('click', function() {
        $edit.removeClass('disabled');
        $approve.addClass('disabled');
        $(this).addClass('disabled');
        $trash.removeClass('disabled');
        $dds.each(function(val) {
          var $content, $current, $self;

          $self = $(this);
          $current = $($self[0]).find('>:first-child');
          $content = $current.val();
          return $current.replaceWith('<p class="lead">' + $content + '</p>');
        });
        return $('.container').append('<div class="info"><p class="text-info">This update has been cancelled.<p></div>');
      });
      return $trash.on('click', function() {
        console.log($(this).attr('class'));
        return document.location.href = window.location.pathname.replace('input', 'kill');
      });
    });
  });

}).call(this);