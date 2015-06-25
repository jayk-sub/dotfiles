{Disposable} = require('atom')
module.exports =
  instance: null
  config:
    lintOnFly:
      title: 'Lint on fly'
      description: 'Lint files while typing, without the need to save them'
      type: 'boolean'
      default: true
    showErrorInline:
      title: "Show Inline Tooltips"
      descriptions: "Show inline tooltips for errors"
      type: 'boolean'
      default: true

  activate: ->
    @instance = new (require './linter-plus.coffee')

  consumeLinterPlus: (linter) ->
    linter.grammarScopes = linter.scopes if linter.scopes
    @instance.linters.add linter

  consumeLinter: (linters) ->
    unless linters instanceof Array
      linters = [ linters ]
    for linter in linters
      if @_validateLinter(linter)
        @instance.linters.add linter
    new Disposable =>
      for linter in linters
        return unless @instance.linters.has(linter)
        if linter.scope is 'project'
          @instance.messagesProject.delete(linter)
        else
          @instance.eachEditorLinter (editorLinter)->
            editorLinter.messages.delete(linter)
        @instance.linters.delete(linter)
      @instance.views.render()

  consumeStatusBar: (statusBar) ->
    @instance.views.attachBottom(statusBar)

  provideLinter: ->
    @Linter

  deactivate: ->
    @instance?.deactivate()

  _validateLinter: (linter) ->
    if linter.grammarScopes instanceof Array and typeof linter.lint is 'function'
      true
    else
      err = new Error("Invalid Linter Provided")
      atom.notifications.addError err.message, {detail: err.stack}
      false
