local DB = {}

local sqlite3 = require( "sqlite3" )
local composer = require( "composer" ) 

-- Open "data.db". If the file doesn't exist, it will be created
local path = system.pathForFile( "data.db", system.DocumentsDirectory )
print("database path: " .. path)
local db = sqlite3.open( path )   

-- Handle the "applicationExit" event to close the database
local function onSystemEvent( event )
    if ( event.type == "applicationExit" ) then             
        db:close()
    end
end
-- Drop all tables
local function dropTables()
	print( "DropTables" )
	local dropTable = [[DROP TABLE IF EXISTS tableevent; DROP TABLE IF EXISTS tablematch; DROP TABLE IF EXISTS tablegame; DROP TABLE IF EXISTS tableuser;]]
	db:exec(dropTable)
end
-- Create the database structure
function DB.createDB()
	print("Create Database")
	local pragma = [[PRAGMA foreign_keys = ON;]] 
	db:exec( pragma )

	--dropTables()

	local tableUser = [[
		CREATE TABLE IF NOT EXISTS tableuser ( 
		userid INTEGER PRIMARY KEY autoincrement 
		);]]
	db:exec( tableUser )

	local tableGame = [[
		CREATE TABLE IF NOT EXISTS tablegame ( 
		gameid INTEGER PRIMARY KEY autoincrement, 
		gamename TEXT 
		);]]
	db:exec( tableGame )

	local tableMatch = [[
		CREATE TABLE IF NOT EXISTS tablematch ( 
		matchid INTEGER PRIMARY KEY autoincrement, 
		userid INTEGER, 
		gameid INTEGER, 
		correct INTEGER, 
		wrong INTEGER, 
		FOREIGN KEY(userid) REFERENCES tableuser(userid) ON DELETE CASCADE, 
		FOREIGN KEY(gameid) REFERENCES tablegame(gameid) ON DELETE CASCADE 
		);]]
	db:exec( tableMatch )

	local tableEvent = [[
		CREATE TABLE IF NOT EXISTS tableevent ( 
		matchid INTEGER, 
		eventtype TEXT, 
		eventtime INTEGER, 
		eventdice TEXT, 
		eventtop INTEGER, 
		eventbutton1 INTEGER,
		eventbutton2 INTEGER, 
		eventbutton3 INTEGER, 
		eventanswer INTEGER, 
		FOREIGN KEY(matchid) REFERENCES tablematch(matchid) ON DELETE CASCADE 
		);]]
	db:exec( tableEvent )
end

function DB.getNextUserID()
	local nextUserID
	local pragma = [[PRAGMA foreign_keys = ON;]] 
	db:exec( pragma )

	local tablefill = [[INSERT INTO tableuser VALUES (NULL); ]]
	db:exec( tablefill )

	--for x in db:urows "SELECT MAX(userid) FROM tableuser" do nextUserID = x end
	--print( "nextUserID database: "..nextUserID )

	for x in db:urows "SELECT LAST_INSERT_ROWID();" do nextUserID = x end
	print( "nextUserID database: "..nextUserID )
	
	return nextUserID 	
end

function DB.getUserID(id)
	local pragma = [[PRAGMA foreign_keys = ON;]] 
	db:exec( pragma )
    
    local query = "SELECT userid FROM tableuser WHERE userid = " .. id .. " LIMIT 1;"
    
    for row in db:nrows(query) do
        return true
    end
    
    return false    
end

function DB.insertGameName(gameName)
	local pragma = [[PRAGMA foreign_keys = ON;]] 
	db:exec( pragma )

	local function isGameName()
		local query = "SELECT gamename FROM tablegame WHERE UPPER(gamename) = UPPER('" .. gameName .. "') LIMIT 1;"
		
		for row in db:nrows(query) do
        	return true
   	 	end

    	return false 

	end
	
    if (isGameName() == false) then
    	local fillGameTable = [[INSERT INTO tablegame(gamename) VALUES (']]..gameName..[[');]]
    	db:exec(fillGameTable)
    end
end

function DB.insertUserId( id )
	local pragma = [[PRAGMA foreign_keys = ON;]] 
	db:exec( pragma )

	local function userIdExists()
		local query = "SELECT userid FROM tableuser WHERE UPPER(userid) = UPPER('" .. id .. "') LIMIT 1;"		
		for row in db:nrows(query) do
        	return true
   	 	end
    	return false 
	end
	if not userIdExists() then
    	local fill = [[INSERT INTO tableuser( userid ) VALUES (']]..id..[[');]]
    	db:exec(fill)
    end
end

function DB.dropUser(userID)
	local drop = [[DELETE FROM tableuser WHERE userid=]]..userID..[[;]]
	print( drop )
	db:exec(drop)
end

function DB.newGame(userID, gameName)
	local gameID
	local matchID
	local pragma = [[PRAGMA foreign_keys = ON;]] 
	db:exec( pragma )

	local query = "SELECT gameid FROM tablegame WHERE gamename = '"..gameName.."';"
	for x in db:nrows(query) do gameID = x.gameid end
	print( "gameID: "..gameID )

	query = [[INSERT INTO tablematch(userid,gameid) VALUES (]]..userID..","..gameID..[[); ]]
	db:exec(query)

	query = "SELECT matchid FROM tablematch WHERE userid = '"..userID.."' AND gameid = '"..gameID.."';"
	for x in db:nrows(query) do matchID = x.matchid end

	return matchID, gameID
end

function DB.fillMatchTableDB(matchID, right, wrong)
	local pragma = [[PRAGMA foreign_keys = ON;]] 
	db:exec( pragma )

	local tablefill = [[UPDATE tableMatch SET correct=]]..right..[[, wrong=]]..wrong..[[ WHERE matchid=]]..matchID..[[;]]
	db:exec( tablefill )
end

function DB.fillEventTableTwoElementsDB(matchID, events)
	local pragma = [[PRAGMA foreign_keys = ON;]] 
	db:exec( pragma )

	local tablefill = [[INSERT INTO tableevent(matchid,eventtype,eventtime) VALUES(]]..matchID..[[,']]..events[1]..[[',]]..events[2]..[[);]]
	print( "tablefill: "..tablefill )
	db:exec(tablefill)
end

function DB.fillEventTableEightElementsDB(matchID, events)
	local pragma = [[PRAGMA foreign_keys = ON;]] 
	db:exec( pragma )

	local tablefill = [[INSERT INTO tableevent VALUES(]]..matchID..[[,']]..events[1]..[[',]]..events[2]..[[,']]..events[3]..[[',]]..events[4]..[[,]]..events[5]..[[,]]..events[6]..[[,]]..events[7]..[[,]]..events[8]..[[);]]	
	print( "tablefill: "..tablefill )
	db:exec(tablefill)
end



-- Setup the event listener to catch "applicationExit"
Runtime:addEventListener( "system", onSystemEvent )

return DB