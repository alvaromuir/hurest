### Hu(mongously) easy RESTFul server

v.0.0.3
 
Quick node/mongoose/restify powered server for small projects.

Has socket.io and bunyan out back, lodash and underscore.string if you want to do small things in the font.


Pretty simple to use, just modify the coffeescripts/setup file.
Uses a CDN'n bootstrap for basic styling.

Has built in lightweight quick edit suite for your data, located at /input.
See coffeescripts/routes.coffee for more info

All the bells and whistles for i/o were not included - it is assumed that you really just want a quick back end.


NOTE: in the schema webform key, all attributes are expected to be string or objects within arrays.



To get started, run `npm install && bower install`.

For a test server, group a compile/watch/reload/pipe to bunyan command like:

`(coffee -wc -o ./ coffeescripts/*.coffee & coffee -wc -o ./views/scripts 
  coffeescripts/views/scripts/*.coffee & nodemon | bunyan -j)`


@alvaromuir