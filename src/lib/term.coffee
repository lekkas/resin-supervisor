sessionUid = 0

module.exports.createServer = (options) ->
	options = options ? {}

	createPty = (socket) ->
		shell = options.shell ? 'sh'
		shellArgs = if typeof options.shellArgs is 'function' then options.shellArgs(sessionUid++) else options.shellArgs
		cols = options.cols ? 132
		rows = options.rows ? 24

		console.log('shell: ', shell)
		term = require('pty.js').fork shell, shellArgs,
			name: 'xterm'
			cols: cols
			rows: rows

		term.on 'data', (data) ->
			socket.emit('data', data)

		console.log('Created shell with pty master/slave pair (master: %d, pid: %d)', term.fd, term.pid)
		return term

	server = require('http').createServer()
	io = require('socket.io')(server)

	io.on 'connection', (socket) ->
		term = createPty(socket)

		socket.on 'data', (data) ->
			term.write(data)

		socket.on 'disconnect', ->
			term.destroy()

	return server
