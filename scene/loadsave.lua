local M = {}
 
local json = require( "json" )
local defaultLocation = system.DocumentsDirectory
 
local filePath = system.pathForFile( "settings.json", system.DocumentsDirectory )
print("filePath: "..filePath)

function M.saveTable( t, filename, location )
    local loc = location
    if not location then
        loc = defaultLocation
    end
 
    -- Path for the file to write
    local path = system.pathForFile( filename, loc )
 
    -- Open the file handle
    local file, errorString = io.open( path, "w" )
 
    if not file then
        -- Error occurred; output the cause
        print( "File error: " .. errorString )
        return false
    else
        -- Write encoded JSON data to file
        local encodedTable =  json.encode( t )
        print( encodedTable ) 
        file:write( encodedTable )
        -- Close the file handle
        io.close( file )
        return true
    end
end

function M.loadTable( filename, location )
 
    local loc = location
    if not location then
        loc = defaultLocation
    end
 
    -- Path for the file to read
    local path = system.pathForFile( filename, loc )
 
    -- Open the file handle
    local file, errorString = io.open( path, "r" )
 
    if not file then
        -- Error occurred; output the cause
        print( "File error: " .. errorString )
    else
        -- Read data from file
        local contents = file:read( "*a" )
        -- Decode JSON data into Lua table
        local t = json.decode( contents )
        -- Close the file handle
        io.close( file )
        -- Return table
        return t
    end
end

function M.removeFile()
    local result, reason = os.remove( system.pathForFile( "settings.json", defaultLocation ) )
    if result then
        print( "File removed" )
    else
        print( "File does not exist", reason )  --> File does not exist    apple.txt: No such file or directory
    end
end 

function M.doesFileExists( fname ) 
    local results = false
 
    if ( filePath ) then
        local file, errorString = io.open( filePath, "r" )
 
        if not file then
            -- Error occurred; output the cause
            print( "File error: " .. errorString )
        else
            -- File exists!
            print( "File found: " .. fname )
            results = true
            -- Close the file handle
            file:close()
        end
    end
 
    return results
end

return M