child = require 'child_process'
fs = require 'fs'

module.exports =
	generateSVG: (json, key) -> new Promise (resolve) =>
	  graph = @toDot(json, key)
	  c = child.spawn('dot', ['-Tsvg'])
	  c.stdin.write(graph)
	  c.stdin.end()

	  res = ''
	  c.stdout.on 'data', (chunk) -> res += chunk
	  c.on 'close', -> resolve(res)

	toDot: (json, key) ->
	  children = json.class_dependents[key]

	  mappings = ''
	  children.forEach (c) -> mappings += """ "#{key}" -> "#{c}";\n"""
	  dot = """
	    digraph {
	      #{mappings}
	    }"""

	readFile: (file) -> new Promise (resolve) ->
		fs.readFile file, (_, contents) ->
			console.log file, contents
			resolve JSON.parse(contents.toString())

# generateFor: (node) ->
#   @path ?= atom.project.getPath() + '/dependencies.json'
#   @json ?= @readFile @path
#
#   @generateSVG(@json, node).then (svg) =>
#     @panel.destroy() if @view
#     @view = $$ -> @div => 'f' #unless @view
#     @view.html(svg).attr('style', 'overflow: scroll;')
#
#     window.svg = svg
#     window.view = @view
#
#     @panel = atom.workspace.addTopPanel(item: @view)
#     that = this
#     @view.find('g.node').on 'click', ->
#       itemName = $(this).find('title').html()
#       that.generateFor(itemName)
#   .catch (e) ->
#     window.e = e
#     console.log(e)
#
# unGenerate: ->
#   @path = @json = undefined
#   @panel.destroy() if @panel
