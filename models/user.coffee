mongoose = require('mongoose')
Schema = mongoose.Schema

userSchema = new Schema( {
  name: String,
  steamid: Number
})

module.exports = mongoose.model('User', userSchema)
