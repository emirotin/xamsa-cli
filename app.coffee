fs = require 'fs'
async = require 'async'
blessed = require 'blessed'

CONFIG_NAME = '.xamsa.json'
cfg = null

drawInterface = ->
  screen = blessed.screen()
  screen.key ['escape', 'q', 'C-c'], (ch, key) ->
    process.exit(0)

  box = blessed.box
    top: 'center'
    left: 'center'
    width: '500'
    height: '500'
    tags: true
    style:
      fg: 'green'
      bg: '#eee'

  box.on 'click', (data) ->
    box.
    screen.render()

  box.key 'enter', (ch, key) ->
    screen.render()

  screen.append(box)
  box.focus()
  box.setContent cfg[0]
  screen.render()

readConfig = (done) ->
  cfg = {}
  stdin = process.stdin
  stdin.setRawMode(true)
  readKey = (i, cb) ->
    onKey = (data) ->
      console.log data.toString()
      stdin.removeListener 'data', onKey
      cfg[i] = data[0]
      cb null
    stdin.on 'data', onKey
    console.log "➜  Нажмите кнопку ##{i}: "
  finished = ->
    stdin.setRawMode(false)
    fs.writeFileSync configPath, JSON.stringify cfg
    done()
  async.eachSeries [1..4], readKey, finished

configPath = "./#{CONFIG_NAME}"
try
  if fs.existsSync configPath
    cfg = JSON.parse fs.readFileSync configPath

if not cfg
  readConfig drawInterface
else
  drawInterface()