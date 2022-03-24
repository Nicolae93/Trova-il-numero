	-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
-- libraries
local composer = require( "composer" )
local loadsave = require( "scene.loadsave" )
local database = require( "scene.database" )

-- variables
local gameName = "Trova il numero"
local userID = 1

-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )

-- Seed the random number generator
math.randomseed( os.time() )

-------creazione file json nel caso non esistesse-----
--loadsave.removeFile()
if not loadsave.doesFileExists("settings.json") then
 	print( "il file non esiste" )
 	local settingsTable = {false,false,false,false,false,false,false,false,false,false,true,true, 1, true,true, false, 10}
    local isFileCreated = loadsave.saveTable( settingsTable, "settings.json" )
end
-------creazione della struttura database-------------
database.createDB()
composer.setVariable( "gameName", gameName )
database.insertGameName( gameName )
composer.setVariable( "userID", userID)
database.insertUserId( userID )

-- Go to the menu screen
composer.gotoScene( "scene.menu" )