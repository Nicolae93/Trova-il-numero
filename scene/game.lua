-- Requirements
local composer = require "composer"
local loadsave = require "scene.loadsave" 
local widget = require "widget" 
local match = require "scene.game.lib.match" 
local star = require "scene.game.lib.stars"
local database = require( "scene.database" )
-- Variables local to scene
local _W = display.contentWidth 
local _H = display.contentHeight
local _X = display.contentCenterX
local _Y = display.contentCenterY

local scene = composer.newScene()
local settingsTable, numbers = {}, {}
local range = -1
local isNumberToDice, isDiceToNumber, repeatActivity, panel, stars, buttonQuestion, buttonBack, scrollDownNum, scrollDownDice, buttonX
local emptyTop, pauseBackground, pauseBackground1, unlikeButton, likeButton, buttonBack1, buttonTelescope, sounds
local emptyBottomDice, emptyBottomNum = {}, {}
local events = {}
local eventsIndex = 1
local topImageWidth, topImageHeight = 706.5, 530
local numImageWidth, numImageHeight = 341.3, 260.333333333
local diceImageWidth, diceImageHeight = 370.3, 290.3333333
local positionsAltNumbers = {{_X-300,_H-150,1},{_X,_H-150,2},{_X+300,_H-150,3}}
local matchID, gameID 
local userID = composer.getVariable( "userID" )

--functions
local function printTable(table)

  local count = #table
  for i=#table,1,-1 do
    print("elemento numero "..tostring(count)..": "..tostring(table[i]))
    count= count-1
  end
end
-- audio function
local function audioCombination() 
  audio.stop( )
  if panel:getCombination() == "diceToNumber" then 
    audio.play(sounds.palliniNumeri)
  else
    audio.play(sounds.numeriPallini)
  end
end
-- Function to handle button events
local function handleButtonLike( event ) 
  if ( "ended" == event.phase ) then
    print( "likeButton was pressed and released" )
    audio.play(sounds.click)
    composer.gotoScene( "scene.menu", {time=800, effect="crossFade"} )
  end
end
-- Function to handle button events
local function handleButtonUnlike( event )
  local function front()
    buttonBack:setEnabled( true )
    buttonQuestion:setEnabled( true )
    panel:toFront( )
    panel:play()
    likeButton:setEnabled( false )
    unlikeButton:setEnabled( false )
    buttonBack1:setEnabled( false )
    buttonTelescope:setEnabled( false )
  end
  if ( "ended" == event.phase ) then
    print( "unlikeButton was pressed and released" )
    audio.play(sounds.click)
    likeButton:toBack( )
    unlikeButton:toBack( )
    buttonBack1:toBack( )
    buttonTelescope:toBack( )
    transition.to( pauseBackground, { time=700, y=-_Y, transition=easing.linear, onComplete=front} )
    transition.to( pauseBackground1, { time=700, y=3*_Y, transition=easing.linear} )
  end
end
-- Function to handle button events
local function handleButtonX( event )
  local function front()
    panel:toFront( )
    panel:play()
    buttonBack:setEnabled( true ) 
    emptyTop.isVisible = false
    for i=1,3 do
      emptyBottomDice[i]:toBack( )
      emptyBottomNum[i]:toBack( )
    end
  end
    
  if ( "ended" == event.phase ) then
    print( "Button X was pressed and released" )
    audio.play(sounds.click)
    transition.to( scrollDownNum, { time=1000, y=-display.contentHeight / 6, transition=easing.linear, onComplete=front} )
    transition.to( scrollDownDice, { time=1000, y=-display.contentHeight / 6, transition=easing.linear} )
    transition.to( buttonX, { time=1000, y=-80, transition=easing.linear} )
  end
end 
-- Function to handle button events
local function handleButtonQuestion( event )  
  local function front()
    buttonQuestion:toFront( )
    panel:toBack( )
    panel:pause()
    buttonBack:setEnabled( false )
    emptyTop.isVisible = true   
    if panel:getCombination() == "numToDice" then
      for i=1,3 do
        emptyBottomDice[i]:toFront()
      end
    else
      for i=1,3 do
        emptyBottomNum[i]:toFront()
      end     
    end   
  end
  if ( "ended" == event.phase ) then
    print( "Button question was pressed and released" )
    audio.play(sounds.click)
    audioCombination()
    local combination = panel:getCombination()
    if combination == "numToDice" then
      scrollDownNum:toFront( )
      transition.to( scrollDownNum, { time=1000, y=display.contentHeight / 8, transition=easing.linear, onComplete = front} )
    else
      scrollDownDice:toFront( )      
      transition.to( scrollDownDice, { time=1000, y=display.contentHeight / 8, transition=easing.linear, onComplete = front} )
    end
    buttonX:toFront( )
    transition.to( buttonX, { time=1000, y=80, transition=easing.linear} )      
  end
end
-- Function to handle button events
local function handleButtonBack( event )
  local function front()
    buttonBack1:toFront( )
    buttonTelescope:toFront( )
    buttonBack1:setEnabled( true )
    buttonTelescope:setEnabled( true )
    panel:toBack()
    panel:pause()
  end
  if ( "ended" == event.phase ) then
    print( "Button back was pressed and released" )
    audio.play(sounds.click)
    buttonBack:setEnabled( false )  
    buttonQuestion:setEnabled( false )
    pauseBackground1:toFront( )
    transition.to(pauseBackground1, { time=700, y=_Y, transition=easing.linear, onComplete=front} )       
  end
end
-- Function to handle button events
local function handleButtonBack1( event )
  local function front()
    likeButton:toFront( )
    unlikeButton:toFront( )
    likeButton:setEnabled( true )
    unlikeButton:setEnabled( true )
  end
  if ( "ended" == event.phase ) then
    print( "Button back1 was pressed and released" )
    audio.play(sounds.click)
    pauseBackground:toFront( )
    buttonBack1:setEnabled( false )
    buttonTelescope:setEnabled( false )
    transition.to( pauseBackground, { time=700, y=_Y, transition=easing.linear, onComplete=front} )
  end
end
-- Function to handle button events
 local function handleButtonTelescope( event )
   local function front()
      print( "telescopeButton was pressed and released" )
      buttonBack:setEnabled( true )
      buttonQuestion:setEnabled( true )
      panel:toFront( )
      panel:play()
      buttonBack1:setEnabled( false )
      buttonTelescope:setEnabled( false )
    end
    if ( "ended" == event.phase ) then
      print( "Button telescope was pressed and released" )
      audio.play(sounds.click)
      buttonBack1:toBack( )
      buttonTelescope:toBack( )
      transition.to( pauseBackground1, { time=700, y=3*_Y, transition=easing.linear, onComplete=front} )
    end
 end
-- Function that tell me if all numbers was selectioned in settings
local function isAll()
  if settingsTable[11] then
    return true
  end
  return false
end
-- Function that returns numbers to play
local function getNumbers()
  local numbersTable = {}
  if isAll() then
    print( "isAll" )
    for i=1,10 do
      numbersTable[i] = i 
    end
  else
    print( "is not All" )
  local index = 1  
    for i=1,10 do
      if settingsTable[i] then
        numbersTable[index] = i
        index = index + 1
      end
    end
  end
  return numbersTable
end
-- Function that returns range
local function getRange()
  local localRange
  if settingsTable[12] then
    localRange = -1
  else
    localRange = settingsTable[13]   
  end
  return localRange
end
-- Function that returns numberToDice
local function isNumberToDice()
  if settingsTable[14] then
    return true
  end
  return false
end
-- Function that returns DiceToNumber
local function isDiceToNumber()
  if settingsTable[15] then
    return true
  end
  return false
end
-- Function that tell me if read numbers or not
local function isRead()
  if not settingsTable[16] then
    return true
  end
  return false
end
-- Function that tell me how many times repeat activity
local function getRepeatActivity()
  return settingsTable[17]
end
-- Function that save all info events in database
local function saveEventInDB()
  for i=1,#events do
    if (#events[i]==2) then
      print( "evento di dimensione 2" )
      database.fillEventTableTwoElementsDB(matchID, events[i])
    else      
      print( "evento di dimensione 8" )
      database.fillEventTableEightElementsDB(matchID, events[i])      
    end
  end
end

function scene:create( event )
  local sceneGroup = self.view -- add display objects to this group

  -- sounds
  local sndDir = "scene/game/sfx/"
  sounds = {
    click = audio.loadSound( sndDir .. "click.wav" ),
    numeriPallini = audio.loadSound( sndDir .. "Guarda-il-numero.mp3" ),
    palliniNumeri = audio.loadSound( sndDir .. "Guarda-la-quantita-di-pallini.mp3" )
  }

  local function matched(event)
    local phase = event.phase
    local combination, top, button1, button2, button3, answer = event.combination, event.top, event.button1, event.button2, event.button3, event.answer
    print( "phase, combination, top, button1, button2, button3, answer: " .. phase, combination, top, button1, button2, button3, answer )

    t = os.date( '*t' )  -- get table of current date and time
    if phase == "start" then
      events[eventsIndex] = { "start", os.time(t) }
    elseif phase == "answer" then
      events[eventsIndex] = {"answer", os.time(t), combination, top, button1, button2, button3, answer}  
    elseif phase == "paused" then
      events[eventsIndex] = {"pause", os.time(t)}
    elseif phase == "resume" then
      events[eventsIndex] = {"resume", os.time(t)}
    elseif phase == "help" then
      events[eventsIndex] = {"help", os.time(t)}
    elseif phase == "listen" then
      events[eventsIndex] = {"listen", os.time(t)}
    elseif phase == "endGame" then
      events[eventsIndex] = {"endGame", os.time(t)} 
      database.fillMatchTableDB( matchID, panel.right, panel.wrong )
      saveEventInDB()
      composer.setVariable( "starsCount", stars.getStarsNumber())
      composer.gotoScene( "scene.game.lib.endMission" , {time=800, effect="crossFade"} )
    elseif phase == "star" then return stars:addStar(1)  
    end
    eventsIndex = eventsIndex + 1
    print( "eventsIndex: "..tostring(eventsIndex) )
  end

  -- get matchId and gameId
  matchID, gameID = database.newGame(userID, composer.getVariable("gameName"))

  -- load our background sceen
  local background = display.newImageRect( sceneGroup, "scene/game/img/Sfondo attivita.png", display.contentCenterX*2, display.contentCenterY*2 )
  -- place everything
  background.x, background.y = display.contentWidth / 2, display.contentHeight / 2

  buttonQuestion = widget.newButton(
    {
        width = 93,
        height = 93,
        defaultFile = "scene/game/img/Icone attivita question.png",
        overFile = "scene/game/img/Icone attivita question.png",
        onEvent = handleButtonQuestion
    }
  )
  buttonBack = widget.newButton(
    {
        width = 93,
        height = 93,
        defaultFile = "scene/game/img/Icone back.png",
        overFile = "scene/game/img/Icone back.png",
        onEvent = handleButtonBack
    }
  )
  buttonX = widget.newButton(
    {
        width = 52,
        height = 52,
        defaultFile = "scene/game/img/Icone attivita (3).png",
        overFile = "scene/game/img/Icone attivita (3).png",
        onEvent = handleButtonX
    }
  )
  --buttonX.isVisible = false
  --add to group
  sceneGroup:insert( buttonQuestion )
  sceneGroup:insert( buttonBack )
  sceneGroup:insert( buttonX )
  -- arrange buttons
  buttonQuestion.x = 200
  buttonQuestion.y = 70
  buttonBack.x = 80
  buttonBack.y = 70
  buttonX.x = display.contentWidth - 85
  buttonX.y = -display.contentHeight / 5
  --load scroll down menu
  scrollDownDice = display.newImageRect( sceneGroup, "scene/game/img/Comando senza icone (2).png", display.contentCenterX*2, display.contentCenterY/1.5 )
  scrollDownDice.x, scrollDownDice.y = display.contentWidth / 2, -display.contentHeight / 6
  --load scroll down menu
  scrollDownNum = display.newImageRect( sceneGroup, "scene/game/img/Comando senza icone (1).png", display.contentCenterX*2, display.contentCenterY/1.5 )
  scrollDownNum.x, scrollDownNum.y = display.contentWidth / 2, -display.contentHeight / 6
  --load settingTable
  settingsTable = loadsave.loadTable("settings.json")
  printTable(settingsTable)
  
  --get numbers to play
  numbers = getNumbers()
  printTable(numbers)
  --get range
  range = getRange()
  print( "range: "..range )
  --get combination
  isNumberToDice = isNumberToDice()
  isDiceToNumber = isDiceToNumber()
  print( "isNumberToDice: "..tostring(isNumberToDice) )
  print( "isDiceToNumber: "..tostring(isDiceToNumber) )
  --is read
  read = isRead()
  print( "read: "..tostring(read) )
  --get repeat
  repeatActivity = getRepeatActivity()
  print( "repeatActivity: "..tostring(repeatActivity) )

  --create match
  panel = match.new(matched, numbers, range, isNumberToDice, isDiceToNumber, read, repeatActivity)


  -- add our stars module
  stars = star.new()
  stars.x = display.contentWidth - 170
  stars.y = display.screenOriginY + stars.contentHeight / 2 + 8  

  --add empty top and bottom 
  emptyTop = display.newImageRect( sceneGroup, "scene/game/img/emptyTop1.png", topImageWidth, topImageHeight )
  emptyTop.x, emptyTop.y = panel.top[1].x, panel.top[1].y
  emptyTop.isVisible = false
  for i=1,3 do
    emptyBottomDice[i] = display.newImageRect( sceneGroup, "scene/game/img/Pulsanti vuoti (1).png", diceImageWidth, diceImageHeight )
    emptyBottomNum[i] = display.newImageRect( sceneGroup, "scene/game/img/Pulsanti vuoti (2).png", numImageWidth, numImageHeight )
    --arrange
    emptyBottomDice[i].x, emptyBottomDice[i].y = positionsAltNumbers[i][1], positionsAltNumbers[i][2]
    emptyBottomNum[i].x, emptyBottomNum[i].y = positionsAltNumbers[i][1], positionsAltNumbers[i][2]
    --scale
    emptyBottomDice[i]:scale(0.55, 0.6)
    emptyBottomNum[i]:scale(0.5, 0.65)
    --to back
    emptyBottomDice[i]:toBack()
    emptyBottomNum[i]:toBack()
  end

  --add pause
  pauseBackground = display.newImageRect( sceneGroup, "scene/game/img/Sfondi pausa (3).png", display.contentCenterX*2, display.contentCenterY*2 )
  pauseBackground.x, pauseBackground.y = _X, -_Y
  pauseBackground1 = display.newImageRect( sceneGroup, "scene/game/img/Sfondi pausa (2).png", display.contentCenterX*2, display.contentCenterY*2 )
  pauseBackground1.x, pauseBackground1.y = _X, 3*_Y

  unlikeButton = widget.newButton(
    {
        width = 200,
        height = 200,
        defaultFile = "scene/game/img/Icone senza testo (5).png",
        overFile = "scene/game/img/Icone senza testo (5).png",
        onEvent = handleButtonUnlike
    }
  )

  likeButton = widget.newButton(
    {
        width = 200,
        height = 200,
        defaultFile = "scene/game/img/Icone senza testo (4).png",
        overFile = "scene/game/img/Icone senza testo (4).png",
        onEvent = handleButtonLike
    }
  )

  buttonBack1 = widget.newButton(
    {
        width = 200,
        height = 200,
        defaultFile = "scene/game/img/Icone senza testo (3).png",
        overFile = "scene/game/img/Icone senza testo (3).png",
        onEvent = handleButtonBack1
    }
  )

  buttonTelescope = widget.newButton(
    {
        width = 200,
        height = 200,
        defaultFile = "scene/game/img/Icone senza testo (1).png",
        overFile = "scene/game/img/Icone senza testo (1).png",
        onEvent = handleButtonTelescope
    }
  )
  --sound
  --audioCombination()

  --arrange 
  likeButton.x, likeButton.y = _X-150, _Y+50  
  unlikeButton.x, unlikeButton.y = _X+150, _Y+50
  sceneGroup:insert( likeButton )
  sceneGroup:insert( unlikeButton )
  buttonBack1.x, buttonBack1.y = _X-150, _Y+50  
  buttonTelescope.x, buttonTelescope.y = _X+150, _Y+50
  sceneGroup:insert( buttonBack1 )
  sceneGroup:insert( buttonTelescope )
  --hide and unable buttons
  likeButton:toBack( )
  unlikeButton:toBack( )
  likeButton:setEnabled( false )
  unlikeButton:setEnabled( false )
  buttonBack1:toBack( )
  buttonTelescope:toBack( )
  buttonBack1:setEnabled( false )
  buttonTelescope:setEnabled( false )
  -- insert our game items in the right order
  sceneGroup:insert( panel )
  sceneGroup:insert( stars )
end

local function enterFrame(event)
  local elapsed = event.time
end

function scene:show( event )
  local phase = event.phase
  if ( phase == "will" ) then
    Runtime:addEventListener("enterFrame", enterFrame)
  elseif ( phase == "did" ) then
    audioCombination()
  end
end

function scene:hide( event )
  local sceneGroup = self.view
  local phase = event.phase
  if ( phase == "will" ) then

  elseif ( phase == "did" ) then
    Runtime:removeEventListener("enterFrame", enterFrame) 
    for i=sceneGroup.numChildren,1,-1 do
      local child = sceneGroup[i]
      child:removeSelf() -- or display.remove( child )
      child = nil
    end
    composer.removeScene( "scene.game" ) 
  end
end

function scene:destroy( event )
  audio.stop()
  for s,v in pairs( sounds ) do
    audio.dispose( v )
    sounds[s] = nil
  end
end

scene:addEventListener("create")
scene:addEventListener("show")
scene:addEventListener("hide")
scene:addEventListener("destroy")

return scene