fs = require 'fs'
async = require 'async'
_ = require 'lodash'
moment = require 'moment'
blessed = require 'blessed'

CONFIG_NAME = '.xamsa.json'
cfg = null

buttonColors =
  '1': 'blue'
  '2': 'yellow'
  '3': 'green'
  '4': 'red'

drawInterface = ->
  screen = blessed.screen()
  program = screen.program
  screen.key ['escape', 'C-c'], (ch, key) ->
    process.exit(0)

  box = blessed.box
    top: 'center'
    left: 'center'
    width: '500'
    height: '500'
    tags: true
    content: "Сброс: пробел, Выход: ESC\n-------------------------"
    style:
      fg: '#eee'
      bg: 'black'

  list = blessed.box
    parent: box
    bottom: 0
    left: 0
    width: '100%'
    height: '90%'
    tags: true
    border: type: 'line'
    style:
      border: fg: 'red'

  pressedButtons = {}
  reset = ->
    pressedButtons = {}
    list.setContent ''
    screen.render()

  screen.on 'keypress', (ch) ->
    if not ch
      return
    if ch == ' '
      reset()
    else if (button = _.findKey cfg, (v) -> v == ch.charCodeAt(0))
      if pressedButtons[button]
        return
      pressedButtons[button] = true
      color = buttonColors[button]
      time = moment().format('HH:mm:ss.SSS')
      list.pushLine("#{time} {#{color}-fg}{bold}Нажата кнопка ##{button}{/bold}{/#{color}-fg}")
      screen.render()

  screen.append(box)
  box.focus()
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