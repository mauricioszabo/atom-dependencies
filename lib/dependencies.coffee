$ = require 'jquery'
reader = require './dependencies-dot'

promise = panel = null

createView = (json, svg) ->
    panel.destroy() if panel
    view = $('<div>')
    view.html(svg).attr('style', 'overflow: scroll;')

    panel = atom.workspace.addTopPanel(item: view)

    view.find('g.node').on 'click', ->
      itemName = $(this).find('title').html()
      reader.generateSVG(json, itemName).then (svg) -> createView(json, svg)

module.exports =
  activate: ->
    atom.commands.add 'atom-workspace', 'dependencies:hide-dependencies-view', ->
      panel.destroy() if panel

  provide: ->
    name: 'dependencies'

    onStart: -> promise = new Promise (resolve) ->
      path = atom.project.getPaths()[0] + '/dependencies.json'
      reader.readFile(path).then (json) ->
        items = for key, values of json.class_dependents
          do ->
            text = key
            displayName: text
            additionalInfo: "#{values.length} dependencies"
            queryString: "dependency for #{text}"
            function: ->
              reader.generateSVG(json, text).then (svg) -> createView(json, svg)
        console.log items
        resolve(items)

    function: -> promise
    shouldRun: (query) -> query.length > 4
