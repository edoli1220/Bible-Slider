#Module dependencies.


express = require 'express'
routes = require './routes'
http = require 'http'

app = express()

app.configure ->
  app.set 'port', process.env.PORT || 3000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger 'dev'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static __dirname + '/public'

app.configure 'development',  ->
  app.use express.errorHandler

app.get '/'               , routes.index
app.get '/bible'          , routes.bible
app.get '/hymn'           , routes.hymn
app.get '/lord_prayer'    , routes.lordPrayer
app.get '/apostolic_creed', routes.apostolicCreed
app.get '/builder'        , routes.builder
app.get '/presentation'   , routes.presentation

http.createServer app 
app.listen app.get('port'), ->
  console.log "Express server listening on port " + app.get('port')
  console.log "브라우저에서 127.0.0.1:"  + app.get('port') + " url 로 접속해 주세요."
