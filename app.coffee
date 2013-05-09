config = require('./config')
express = require("express")
mongoose = require('mongoose')
routes = require("./routes")
user = require("./routes/user")
User = require('./models/user')
http = require("http")
path = require("path")
passport = require('passport')
SteamStrategy = require('passport-steam').Strategy
app = express()
app.configure ->
  app.set "port", process.env.PORT or 3000
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser("your secret here")
  app.use express.session()
  app.use passport.initialize()
  app.use passport.session()
  app.use app.router
  app.use require("less-middleware")(src: __dirname + "/public")
  app.use express.static(path.join(__dirname, "public"))

app.configure "development", ->
  app.use express.errorHandler()

passport.use(new SteamStrategy({
  returnURL: config.url + '/auth/steam/callback',
  realm: config.url
  }, (identifier, f, done) ->
    console.log identifier
    steamid = identifier.slice(identifier.search(/\d*(?=\/id\/)/) + 4)
    console.log steamid
    User.findOne({steamid: steamid}, (err, user) ->
      console.log 'user'
      console.log user
      if !user
        user = new User({steamid: steamid})
        user.save( (err, user) ->
          return done(err, user)
        )
      return done(err, user)
    )
))
passport.serializeUser( (user, done) ->
  done(null, user._id)
)
passport.deserializeUser( (id, done) ->
  User.findById(id, (err, user) ->
    done(err, user)
  )
)

app.get "/", routes.index
app.get('/auth/steam', passport.authenticate('steam'))
app.get "/auth/steam/callback", passport.authenticate("steam",
  failureRedirect: "/login"
), (req, res) ->
  # Successful authentication, redirect home.
  res.redirect "/"

app.get "/users", user.list
mongoose.connect(config.mongourl, (err) ->
  if err
    throw err
  http.createServer(app).listen app.get("port"), ->
    console.log "Express server listening on port " + app.get("port")
)
