fs = require 'fs'
async = require 'async'
_ = require 'lodash'
moment = require 'moment'
blessed = require 'blessed'

CONFIG_NAME = '.xamsa.json'
buttonColors =
  '1': 'blue'
  '2': 'yellow'
  '3': 'green'
  '4': 'red'

cfg = null
cfgMode = false

configButton = null
configCb = null
pressedButtons = {}

configPath = "./#{CONFIG_NAME}"
try
  if fs.existsSync configPath
    cfg = JSON.parse fs.readFileSync configPath


screen = blessed.screen()
screen.key ['escape', 'C-c'], (ch, key) ->
  process.exit(0)

box = blessed.box
  top: 'center'
  left: 'center'
  width: '500'
  height: '500'
  tags: true
  content: """
    Reset: Space, Config: Tab, Exit: ESC
    ------------------------------------"""
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

print = (s) ->
  list.pushLine s
  screen.render()

reset = (noReady) ->
  pressedButtons = {}
  list.setContent ''
  if noReady
    screen.render()
  else
    print 'Ready'

screen.on 'keypress', (ch) ->
  if not ch
    return

  if ch == ' '
    reset()

  else if ch == '\t'
    readConfig()

  else if cfgMode
    if configButton == null
      return
    cfg[configButton] = ch
    list.pushLine ch
    screen.render()
    configCb?(null)

  else if (button = _.findKey cfg, (v) -> v == ch)
    if pressedButtons[button]
      return
    pressedButtons[button] = true
    color = buttonColors[button]
    time = moment().format 'HH:mm:ss.SSS'
    print "#{time} {#{color}-fg}{bold}Pressed: ##{button}{/bold}{/#{color}-fg}"

screen.append(box)
box.focus()
reset()

readConfig = ->
  cfgMode = true
  configButton = null
  configCb = null
  reset(true)

  readKey = (i, cb) ->
    configCb = cb
    configButton = i
    print ">  Press the button ##{i}: "

  finished = ->
    fs.writeFileSync configPath, JSON.stringify cfg
    cfgMode = false
    configButton = null
    configCb = null
    reset()

  print 'Running in config mode'
  async.eachSeries [1..4], readKey, finished

if not cfg
  readConfig()
