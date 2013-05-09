
exports.index = (req, res) ->
  res.render "index",
    title: "Expressf"
    user: req.user
