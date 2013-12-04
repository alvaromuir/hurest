#!/bin/sh
(coffee -wc -o ./ coffeescripts/*.coffee & coffee -wc -o ./views/scripts coffeescripts/views/scripts/*.coffee & nodemon | bunyan -j)