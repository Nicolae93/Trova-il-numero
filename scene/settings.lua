-- Requirements
local composer = require "composer"
local widget = require( "widget" )
local loadsave = require( "scene.loadsave" )

-- Variables local to scene
local scene = composer.newScene()
local background, yellowBoards, backButton, saveButton, texts, allButton, sounds
local onOffSwitchRange, onOffSwitchRead
local checkboxTable, checkboxTable1 = {}, {}
local textFieldRange, textFieldRepeat
local settingsTable = {}
local countCheckbox = 0
-- Configure image sheet
local sheetOptions =
{
    width = 95,
    height = 95,
    numFrames = 20,
    sheetContentWidth = 950,
    sheetContentHeight = 190
}
local checkboxSheet = graphics.newImageSheet( "scene/settings/img/Pulsanti parametri/Pulsanti.png", sheetOptions )

local sheetOptionsAll = 
{
    width = 174,
    height = 95,
    numFrames = 2,
    sheetContentWidth = 174,
    sheetContentHeight = 190
}
local checkboxAll = graphics.newImageSheet( "scene/settings/img/Pulsanti parametri/all.png", sheetOptionsAll )

--print a table
local function printTable(table)
    for i=1, #table do
        print("elemento numero "..tostring(i)..": "..tostring(table[i]))
    end
end

local function areDisableCheckbox1()
  if not settingsTable[14] and not settingsTable[15] then
    return true
  else return false end 
end

local function isRangeWrong()
  if settingsTable[13]=="" or tonumber(settingsTable[13])<=0    then
    return true
  else return false  
  end
end

local function isRepeatWrong()
  if settingsTable[17] == "" or tonumber(settingsTable[17])<=0 then
    return true
  else return false  
  end
end

local function switchRangeIsOn()
  if settingsTable[12] then
    return false
  else
    return true  
  end
end

local function countCheckbox_fn()
  local count = 0
  for i=1,10 do
    if settingsTable[i]==true then
      count = count + 1        
    end      
  end  
  return count  
end
local function isAll()
  return settingsTable[11] 
end
--verify
local function inspectSettings()
  --se all e' selezionato faccio sparire lo switch e il txtfield  
  --[[if isAll() then
    print( "sparisce switch e txtfield range" )
    onOffSwitchRange.isVisible = false
    textFieldRange.isVisible = false
    settingsTable[12] = true
  --se count>=3 allora faccio comparire lo switch e il txtfield  
  elseif countCheckbox>=3 then
    print( "appare switch range" )
    onOffSwitchRange.isVisible = true
    onOffSwitchRange:setState( {isOn = not settingsTable[12]} )  
    if not onOffSwitchRange.isOn then
        textFieldRange.isVisible = false
    end    
  end--]]

  --se all e' selezionato faccio apparire lo switch e il txtfield  
  --[[if isAll() then
    print( "appare switch range" )
    onOffSwitchRange.isVisible = true
    onOffSwitchRange:setState( {isOn = not settingsTable[12]} )  
    if not onOffSwitchRange.isOn then
        textFieldRange.isVisible = false
    end
  else
    print( "sparisce switch e txtfield range" )
    onOffSwitchRange.isVisible = false
    textFieldRange.isVisible = false
    settingsTable[12] = true  
  end --]]


  --se count e' fra 1 e 2 oppure entrambi in checkbox1 sono deselezionati oppure il range o repeat sono sbagliati  
  if not isAll() or (countCheckbox>=1 and countCheckbox<=2) or areDisableCheckbox1() or isRangeWrong() or isRepeatWrong() then
    print( "sparisce il saveButton" )
    saveButton:setEnabled( false )
    saveButton.isVisible = false
  end  
  -- se all, se almeno un bottone in checkbox1 e' stato premuto, se il repeat e' giusto allora
  if (isAll() or (countCheckbox>=3)) and not areDisableCheckbox1() and not isRepeatWrong() and not isRangeWrong() then
    print( "riappare il saveButton" )
    saveButton:setEnabled( true )
    saveButton.isVisible = true
  end
end

local function CheckboxSwitchTextFieldInspection()
  --se all e' selezionato faccio apparire lo switch e il txtfield  
  if isAll() then
    print( "appare switch range" )
    onOffSwitchRange.isVisible = true
    onOffSwitchRange:setState( {isOn = not settingsTable[12]} )  
    if not onOffSwitchRange.isOn then
        textFieldRange.isVisible = false
    end
  else
    print( "sparisce switch e txtfield range" )
    onOffSwitchRange.isVisible = false
    textFieldRange.isVisible = false
    settingsTable[12] = true  
  end 
end

local function onSwitchPressAll( event )
    local switch = event.target
    local numberPressed = tonumber( switch.id )
    print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
    --switch in settingsTable
    settingsTable[11] = not settingsTable[11] 
    if switch.isOn then
      for i=1,10 do
          settingsTable[i]=false
          checkboxTable[i]:setState( {isOn=false} )
      end
      settingsTable[11] = true
      countCheckbox = 0  
      if not onOffSwitchRange.isOn then
          textFieldRange.isVisible = false
      end
    end
    CheckboxSwitchTextFieldInspection()
    printTable(settingsTable)
    --verifico
    inspectSettings()
end

-- Handle press events for the checkbox
local function onSwitchPressCheckbox( event )
    local switch = event.target
    local numberPressed = tonumber( switch.id )
    print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
    --se il numero premuto era vero allora swicho a false altrimenti viceversa
    settingsTable[numberPressed] = not settingsTable[numberPressed] 
    --se premo un numero sparisce switch e textfield
    onOffSwitchRange.isVisible = false
    textFieldRange.isVisible = false
    settingsTable[12] = true 
    --se premo un numero in true allora all = false
    if switch.isOn then
      settingsTable[11] = false 
      allButton:setState( {isOn=false} )
      countCheckbox = countCheckbox + 1    
      print( "countCheckbox: "..tostring(countCheckbox) )
      if countCheckbox==10 then

        for i=1,10 do
          settingsTable[i]=false
          checkboxTable[i]:setState( {isOn=false} )
        end
        settingsTable[11] = true
        allButton:setState( {isOn=true} )         
        countCheckbox = 0
        --setto widget facendo apparire switch e textfield
        onOffSwitchRange.isVisible = true
        onOffSwitchRange:setState( {isOn = not settingsTable[12]} )  
        if not onOffSwitchRange.isOn then
            textFieldRange.isVisible = false
        end
      end
    --ma se premo in false devo verificare se devo cambiare all in true
    else
      countCheckbox = countCheckbox - 1  
      print( "countCheckbox: "..tostring(countCheckbox) )
      if countCheckbox == 0 then
        settingsTable[11] = true 
        allButton:setState( {isOn=true} )  
        onOffSwitchRange.isVisible = true
        onOffSwitchRange:setState( {isOn = not settingsTable[12]} )  
        if not onOffSwitchRange.isOn then
            textFieldRange.isVisible = false
        end       
      end   
    end
    printTable(settingsTable)
    --verifico
    inspectSettings()
end
-- Handle press events for the checkbox
local function onSwitchPressCheckbox1( event )
    local switch = event.target
    print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
    --se il checkbox era true diventera' false e viceversa
    if (switch.id=="1") then
      settingsTable[14] = not settingsTable[14]
    else
      settingsTable[15] = not settingsTable[15]
    end
    inspectSettings()
end
-- Handle press events for the switch
local function onSwitchPressRange( event )
    local switch = event.target
    print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
    settingsTable[12] = switch.isOn
    if switch.isOn then
      textFieldRange.isVisible = false
      --------textfield2
      settingsTable[13] = 1
      textFieldRange.text = 1
    else
      textFieldRange.isVisible = true
    end
    printTable(settingsTable)
    inspectSettings()
end
-- Handle press events for the switch
local function onSwitchPressRead( event )
    local switch = event.target
    print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
    settingsTable[16] = switch.isOn
end
-- Handle press events for the textFieldRange
local function textRangeListener( event )
    if ( event.phase == "began" ) then
        -- User begins editing "defaultField"
 
    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
        -- Output resulting text from "defaultField"
        print( event.target.text )
 
    elseif ( event.phase == "editing" ) then
        print( event.newCharacters )
        print( event.oldText )
        print( event.startPosition )
        print( event.text )
        --se il field range e' vuoto oppure 0
        if event.text == "nil" or event.text == "0" then
          saveButton.isVisible = false  
        end
        settingsTable[13] = event.text
    end
    inspectSettings()
end
-- Handle press events for the textFieldRepeat
local function textRepeatListener( event )
    if ( event.phase == "began" ) then
        -- User begins editing "defaultField"
 
    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
        -- Output resulting text from "defaultField"
        print( event.target.text )
 
    elseif ( event.phase == "editing" ) then
        print( event.newCharacters )
        print( event.oldText )
        print( event.startPosition )
        print( event.text )
        --se il field read e' vuoto oppure 0
        if event.text == "nil" or event.text <= "0" then
          saveButton.isVisible = false
        end
        settingsTable[17] = event.text
    end
    inspectSettings()
end
-- Handle press event for the back
local function onBackTap(event)
    if ( "ended" == event.phase ) then
        print( "Button Back was pressed and released" )
        audio.play(sounds.click)
        composer.gotoScene( "scene.menu", {time=800, effect="crossFade"} )
    end
end
-- Handle press event for the save
local function onSaveTap(event)
    if ( "ended" == event.phase ) then
        print( "Button Save was pressed and released" )
        audio.play(sounds.click)
        loadsave.saveTable( settingsTable, "settings.json" )
        composer.gotoScene( "scene.menu", {time=800, effect="crossFade"} )
    end
end

local function fillSettings( settingsTable )
  for i=1,10 do
    checkboxTable[i]:setState( {isOn = settingsTable[i]} )
  end
  allButton:setState( {isOn = settingsTable[11]} )
  onOffSwitchRange:setState( {isOn = not settingsTable[12]} )
  textFieldRange.text = settingsTable[13]
  for i=1,2 do
    checkboxTable1[i]:setState( {isOn = settingsTable[i+13]} )       
  end     
  onOffSwitchRead:setState( {isOn = not settingsTable[16]} )
  textFieldRepeat.text = settingsTable[17]
end

function scene:create( event )
  local sceneGroup = self.view -- add display objects to this group

    -- sounds
  local sndDir = "sfx/"
  sounds = {
    click = audio.loadSound( sndDir .. "click.wav" )
  }

  -- load our title sceen
  background = display.newImageRect(sceneGroup, "scene/settings/img/Sfondo.png", display.contentCenterX*2, display.contentCenterY*2 )
  yellowBoards = display.newImageRect(sceneGroup, "scene/settings/img/Barre gialle.png", display.contentCenterX*2, display.contentCenterY*2)
  texts = display.newImageRect(sceneGroup, "scene/settings/img/Testi (1) copia.png", display.contentCenterX*2, display.contentCenterY*2)
  
  backButton = widget.newButton(
    {
      width = 100,
      height = 100,
      defaultFile = "scene/settings/img/Icone parametrii (2).png",
      overFile = "scene/settings/img/Icone parametrii (2).png",
      onEvent = onBackTap
    }
  ) 

  saveButton = widget.newButton(
    {
        width = 150,
        height = 150,
        defaultFile = "scene/settings/img/Icone parametrii (1).png",
        overFile = "scene/settings/img/Icone parametrii (1) copia.png",
        onEvent = onSaveTap
    }
  )
  sceneGroup:insert(saveButton)
  sceneGroup:insert(backButton)
  
  -- buttons name
  --backButton.name = "back"
  --saveButton.name = "save"
  -- place everything
  background.x, background.y = display.contentWidth / 2, display.contentHeight / 2
  yellowBoards.x, yellowBoards.y = display.contentWidth / 2 - 100, display.contentHeight / 2 + 45
  texts.x, texts.y = display.contentWidth / 2 - 100, display.contentHeight / 2 + 65
  backButton.x, backButton.y = 80, 60
  saveButton.x, saveButton.y = display.contentWidth - 100, display.contentHeight - 100
  -- Create the widget checkboxTable
  for i=1,10 do
    checkboxTable[i] = widget.newSwitch {
        left =  i*80+40,
        top = display.contentHeight / 3 - 30 ,
        width = 60,
        height = 60,
        style = "checkbox",
        id = tostring(i),
        onPress = onSwitchPressCheckbox,
        sheet = checkboxSheet,
        frameOff = i,
        frameOn = i+10,
    }
    if i == 10 then
      allButton = widget.newSwitch {
        left =  (i+1.5)*80,
        top = display.contentHeight / 3 -25,
        width = 174*0.5,
        height = 95*0.5,
        style = "checkbox",
        id = tostring(i+1),
        onPress = onSwitchPressAll,
        sheet = checkboxAll,
        frameOff = 1,
        frameOn = 2,
      }
    end
  end
  -- Create the widget checkboxTable1
  for i=1,2 do
    checkboxTable1[i] = widget.newSwitch{
        left = display.contentCenterX + 60,
        top = display.contentCenterY +30+ i*45,
        style = "checkbox",
        id = tostring(i),
        onPress = onSwitchPressCheckbox1
      }
  end

  -- Create the widget switch Range
  onOffSwitchRange = widget.newSwitch(
      {
          left = display.contentCenterX + 100,
          top = display.contentCenterY - 80,
          style = "onOff",
          id = "onOffSwitchRange",
          onPress = onSwitchPressRange
      }
  )
  -- Create the widget switch Read
  onOffSwitchRead = widget.newSwitch(
      {
          left = display.contentCenterX - 80,
          top = display.contentCenterY + 185,
          style = "onOff",
          id = "onOffSwitchRead",
          onPress = onSwitchPressRead
      }
  )
  -- Create text field Range
  textFieldRange = native.newTextField( display.contentCenterX-165, display.contentCenterY-25, 50, 30 )
  textFieldRange.inputType = "number"
  textFieldRange:addEventListener( "userInput", textRangeListener )
  -- Create text field Repeat
  textFieldRepeat = native.newTextField( display.contentCenterX-340, display.contentHeight-70, 50, 30 )
  textFieldRepeat.inputType = "number"
  textFieldRepeat:addEventListener( "userInput", textRepeatListener )
  -- Add Listeners
  --backButton:addEventListener( "tap", onBackTap )
  --saveButton:addEventListener( "tap", onSaveTap )
  -- load settings.json
  settingsTable = loadsave.loadTable("settings.json")
  printTable(settingsTable)
  --fill settings
  fillSettings(settingsTable)
  --get countCheckbox
  countCheckbox = countCheckbox_fn()
  print( "initial countCheckbox: "..tostring(countCheckbox) )
  CheckboxSwitchTextFieldInspection()
  inspectSettings()
end

local function enterFrame(event)
  local elapsed = event.time
end

function scene:show( event )
  local phase = event.phase
  if ( phase == "will" ) then
    Runtime:addEventListener("enterFrame", enterFrame)
  elseif ( phase == "did" ) then

  end
end

function scene:hide( event )
  local sceneGroup = self.view
  local phase = event.phase
  if ( phase == "will" ) then

  elseif ( phase == "did" ) then
    Runtime:removeEventListener("enterFrame", enterFrame)  

    for i=1,10 do
      checkboxTable[i]:removeSelf()
      checkboxTable[i] = nil
    end
    for i=1,2 do
      checkboxTable1[i]:removeSelf()
      checkboxTable1[i] = nil
    end
    textFieldRange:removeSelf()
    textFieldRepeat:removeSelf()
    onOffSwitchRange:removeSelf()
    onOffSwitchRead:removeSelf()
    allButton:removeSelf( )

    textFieldRange = nil
    textFieldRepeat = nil
    onOffSwitchRange = nil
    onOffSwitchRead = nil
    allButton = nil

    composer.removeScene( "scene.settings" )
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