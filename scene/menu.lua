-- Requirements
local composer = require "composer"

-- Variables local to scene
local scene = composer.newScene()
local signup, play, settings, sounds, mail
local field
local w,h = 391, 103 

local function mailListener()
  print( "Button mailMenu was pressed and released" )
  audio.play(sounds.click)
  --[[local options =
  {
    to = "pierluigi.crescenzi@unifi.it",
   subject = "DB",
   body = "This is the DB",
   attachment = { baseDir=system.DocumentsDirectory, filename="data.db" }
  }
  native.showPopup("mail", options)--]]
end

local function playListener()
  print( "Button playMenu was pressed and released" )
  audio.play(sounds.click)
  composer.gotoScene( "scene.game" ) --, {time=800, effect="crossFade"} )
end

local function settingsListener()
  print( "Button settingsMenu was pressed and released" )
  audio.play(sounds.click)
  composer.gotoScene( "scene.settings", {time=800, effect="crossFade"})
end

function scene:create( event )
  local sceneGroup = self.view -- add display objects to this group

  -- sounds
  local sndDir = "sfx/"
  sounds = {
    click = audio.loadSound( sndDir .. "click.wav" )
  }

  field = display.newImage(sceneGroup, "scene/menu/img/menuCostellazioni copia.png", display.contentCenterX, display.contentCenterY)
  field.xScale, field.yScale = 1.6, 1.6
  --background
  --local background = display.newImageRect( sceneGroup, "scene/menu/img/Elementi menu-02.png", display.contentCenterX*2, display.contentCenterY*2 )
  --background.x, background.y = display.contentCenterX, display.contentCenterY

  signup = display.newImageRect( sceneGroup, "scene/menu/img/Elementi menu-04.png", w, h )
  signup.x, signup.y = display.contentCenterX, display.contentCenterY-150

  play = display.newImageRect( sceneGroup, "scene/menu/img/Elementi menu-05.png", w, h )
  play.x, play.y = display.contentCenterX, display.contentCenterY+60


  settings = display.newImageRect( sceneGroup, "scene/menu/img/Elementi menu-06.png", w, h )
  settings.x, settings.y = display.contentCenterX, display.contentCenterY+270

  mail = display.newImageRect( sceneGroup, "scene/menu/img/mail.png", 150, 150 )
  mail.x, mail.y = display.contentWidth-120, 120
  --visibility
  mail:toBack( )

  --listeners
  play:addEventListener( "tap", playListener )
  settings:addEventListener( "tap", settingsListener )
  mail:addEventListener( "tap", mailListener )

end

local function enterFrame(event)
  local elapsed = event.time
  field:rotate(0.1)
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
    for i=sceneGroup.numChildren,1,-1 do
      local child = sceneGroup[i]
      child:removeSelf() -- or display.remove( child )
      child = nil
    end
    composer.removeScene( "scene.menu" )
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