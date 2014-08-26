module.exports =
  titlecase: (string) ->
    string.replace(/\w+S*/g, (s) -> s[0].toUpperCase() + s[1..].toLowerCase())

  undasherize: (string) ->
    string.replace(/-/g, ' ')

  humanize: (string) ->
    @titlecase(@undasherize(string))
