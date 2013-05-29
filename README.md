### Hu(mongously) easy RESTFul server

v.0.0.2


 
Quick node/mongoose/restify powered server for small projects.

Has socket.io and bunyan out back, lodash and underscore.string if you want to do small things in the font.


Pretty simple to use, just modify the coffeescripts/schema file.
Uses bootstrap for basic styling.

Has built in lightweight quick edit suite for your data, located at /input.
See coffeescripts/routes.coffee for more info

All the bells and whistles for i/o were not included - it is assumed that you really just want a quick back end.

You get Socket.io, Handlebars, Twiter Boostrap, Lo-Dash, Underscore.String, and Bunyan to complete your toybox.

To get started, run `npm install` and `bower install`.
Then compile all coffeescripts


Quick Start
-----------
Create a mongoose-like model object in `coffeescripts/schema.coffee`. The current file has a block post model to get you started.

Please note the model includes methods, validors, virtuals, a key to hide a value from JSON queries, and a key to hide values from the auto-generated webform.


Optional
--------
Replace 'SERVER_NAME_HERE' with the name of your choice in server.coffee.

For a test server, something like 
`(coffee -wc -o ./ coffeescripts/*.coffee & coffee -wc -o ./views/scripts coffeescripts/views/scripts/*.coffee & nodemon | bunyan -j)`
works for me