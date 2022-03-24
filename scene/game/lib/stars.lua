-- stars module

local M = {}

local random = math.random
local _W = display.contentWidth 
local _H = display.contentHeight
local _X = display.contentCenterX
local _Y = display.contentCenterY

function M.new()
	local emptyStar, fullStar = "scene/game/img/Stelle (7).png", "scene/game/img/Stelle (1).png"
	local max = 3
	local min = 0
	local spacing = 35
	local w, h = 60, 60
	-- sounds
	local sndDir = "scene/game/sfx/"
	local sounds = { 
		audio.loadSound( sndDir .. "Ben fatto!.mp3" ), 
		audio.loadSound( sndDir .. "Continua Cosi.mp3" ), 
		audio.loadSound( sndDir .. "Esatto.mp3" ), 
		audio.loadSound( sndDir .. "Ottimo lavoro.mp3" ) 
	}

	--  create display group to hold visuals 
 	local group = display.newGroup()
  	local stars = {}

  	for i = 1, max do 
	    stars[i] = display.newImageRect( emptyStar, w,h )  
	    stars[i].x = (i-1) * ((w/2) + spacing)
	    stars[i].y = 15
	    group:insert(stars[i])
	end  
	group.count = 0

	local function supportAudio()
		audio.stop()
		local index
		for i=1,3 do
			index = random(4)
		end
		audio.play(sounds[index])
	end

	function group:getStarsNumber()
		return math.max(min,math.min(max,group.count))
	end

	function group:addStar(amount)
		supportAudio()
		group.count = math.max(min,math.min(max,group.count + (amount or 1)))
		local function bounce( star )
			for i=1,#stars do
				transition.to (stars[i], { tag="star", time=500, xScale = 1, yScale = 1, transition=easing.outQuad } )	
			end
		end
		for i = 1, max  do
			local x, y = stars[i].x, stars[i].y
	        stars[i]:removeSelf( )
	        stars[i] = nil
	      if i <= group.count then 
	        stars[i] = display.newImageRect( group, fullStar, w,h )
	        transition.to (stars[i], { tag="star", time=500, xScale = 2, yScale = 2, transition=easing.outQuad, onComplete=bounce  } )
	      else 
	        stars[i] = display.newImageRect( group, emptyStar, w,h )	        
	      end
	      stars[i].x, stars[i].y = x, y 
	      
	    end

	    return group.count
	end

	function group:finalize()
	-- on remove cleanup instance 
	end
	group:addEventListener('finalize')

	-- return instance
	return group
end

return M