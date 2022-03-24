-- Requirements
local composer = require "composer"
local widget = require( "widget" )
-- Variables local to scene
local scene = composer.newScene()
local background, playAgainButton, backToMissionButton

local function isMissioneCompiuta()
  local starsCount = composer.getVariable( "starsCount" )
  print( "numero di stelle: " .. tostring( starsCount ))
  if starsCount ~= 0 then
    return true
  end
  return false
end

local function handleButtonBackToMission(event)
   if ( "ended" == event.phase ) then
        print( "Button BackToMission was pressed and released" )
        composer.gotoScene( "scene.menu", {time=800, effect="crossFade"} )
  end
end

local function handleButtonPlayAgainButton(event)
  if ( "ended" == event.phase ) then
        print( "Button PlayAgain was pressed and released" )
        composer.gotoScene( "scene.game")--, {time=800, effect="crossFade"} )
  end
end


function scene:create( event )
  local sceneGroup = self.view -- add display objects to this group

  if isMissioneCompiuta() then
    background = display.newImageRect( sceneGroup, "scene/game/img/MISSIONE_COMPIUTA.png", display.contentCenterX*2, display.contentCenterY*2 )
  else 
    background = display.newImageRect( sceneGroup, "scene/game/img/RIPROVA.png", display.contentCenterX*2, display.contentCenterY*2 )  
  end
  background.x, background.y = display.contentCenterX, display.contentCenterY

  backToMissionButton = widget.newButton(
    {
      width = 180,
      height = 180,
      defaultFile = "scene/game/img/empty.png",
      overFile = "scene/game/img/empty.png",
      onEvent = handleButtonBackToMission
    }
  )
  backToMissionButton.x, backToMissionButton.y = display.contentCenterX+240, display.contentCenterY+180

  playAgainButton = widget.newButton(
    {
        width = 180,
        height = 180,
        defaultFile = "scene/game/img/empty.png",
        overFile = "scene/game/img/empty.png",
        onEvent = handleButtonPlayAgainButton
    }
)
  playAgainButton.x, playAgainButton.y = display.contentCenterX-240, display.contentCenterY+180

  sceneGroup:insert( backToMissionButton ) 
  sceneGroup:insert( playAgainButton )
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
  local phase = event.phase
  if ( phase == "will" ) then

  elseif ( phase == "did" ) then
    Runtime:removeEventListener("enterFrame", enterFrame)  
    -- Remove the object
    background:removeSelf()
    background = nil
    backToMissionButton:removeSelf( )
    backToMissionButton = nil
    playAgainButton:removeSelf( )
    playAgainButton = nil
    -- Completely remove the scene, including its scene object
    composer.removeScene( "scene.game.lib.endMission" ) 
  end
end

function scene:destroy( event )
  --collectgarbage()
end

scene:addEventListener("create")
scene:addEventListener("show")
scene:addEventListener("hide")
scene:addEventListener("destroy")

return scene