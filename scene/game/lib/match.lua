-- match module

local M = {}

local random = math.random
local _W = display.contentWidth 
local _H = display.contentHeight
local _X = display.contentCenterX
local _Y = display.contentCenterY
function M.new(listener, numbers, range, isNumberToDice, isDiceToNumber, read, repeatActivity)

	local topImageWidth, topImageHeight = 406, 302
	local numImageWidth, numImageHeight = 185, 185
	local diceImageWidth, diceImageHeight = 253.1, 213
	local positionsAltNumbers = {{_X-300,_H-150,1},{_X,_H-150,2},{_X+300,_H-150,3}}
	local subDir = "scene/game/img/"
	local paused = false
  	local onStatus = listener
  	local altNumbers = {}
  	local altNumInOrder = {}
  	local right, wrong = 0, 0 
  	local rightForStar = {}
  	local indexRFS = 1
  	local consecutiveRight = 0
  	-- sounds
	local sndDir = "scene/game/sfx/"
	local sounds = {}
	for i=1,10 do
		sounds[i] = audio.loadSound( sndDir .. i .. ".mp3" )
	end
	sounds.right = audio.loadSound( sndDir .. "RISPOSTA GIUSTA.mp3" )
	sounds.wrong = audio.loadSound( sndDir .. "RISPOSTA SBAGLIATA.mp3" )

  	-- Configure image sheet Top
	local sheetOptionsTop =
	{
	    width = topImageWidth,
	    height = topImageHeight,
	    numFrames = 20,
	    sheetContentWidth = 4060,
	    sheetContentHeight = 604
	}
	local topSheet = graphics.newImageSheet( subDir.."Schermo cifre scale1.png", sheetOptionsTop )
	-- Configure image sheet Num
	local sheetOptionsNum = 
	{
		width = numImageWidth,
		height = numImageHeight,
	    numFrames = 30,
	    sheetContentWidth = 1850,
	    sheetContentHeight = 555
	}
	local numSheet = graphics.newImageSheet( subDir.."Pulsanti cifre scale1.png", sheetOptionsNum)
	-- Configure image sheet Dice
	local sheetOptionsDice = 
	{
		width = diceImageWidth,
		height = diceImageHeight,
	    numFrames = 30,
	    sheetContentWidth = 2531,
	    sheetContentHeight = 639
	}
	local diceSheet = graphics.newImageSheet( subDir.."Pulsanti quantita scale.png", sheetOptionsDice)
  	-- our board display object
	local panel = display.newGroup()
	panel.x, panel.y = _X, 0	
	panel.anchorChildren = true

	function panel:rightForStar_fn()
		rightForStar[1] = math.floor(repeatActivity/3)
		rightForStar[2] = rightForStar[1]
		rightForStar[3] = math.floor(repeatActivity - rightForStar[1]*2)
		for i=1,3 do
			print("rightForStar: "..tostring(rightForStar[i]))
		end
	end
	panel:rightForStar_fn()

	if paused then board.status = "paused" end
  	function panel:play()
    	print( "play" )
    	paused = false
    	panel.status = "resume" 
    	panel:updateStatus() 
  	end 

  	function panel:pause()
    	print( "pause" )
    	paused = true
    	panel.status = "paused" 
    	panel:updateStatus() 
  	end

  	function panel:updateStatus( combination, top, button1, button2, button3, answer)
    	if onStatus then
      		onStatus({ phase = panel.status, combination = combination, top = top, button1 = button1, button2=button2, button3=button3, answer=answer} )
   		else
      	-- print it if you want
    	end
 	end
 	panel.status = "start"
  	panel:updateStatus() 

  	function panel:randomTopNumber()
  		local index
  		for i=1,3 do
  			index = random(#numbers)
  		end
  		return numbers[index]
  	end

  	function panel:loadImageTop(top)
  		print( "top2: "..tostring(top) )
  		local n
  		if isNumberToDice and isDiceToNumber then --se in abbina ho tutti e due allora
  			for i=1,3 do
				n = random(2)
			end
			if n==1 then
				top.combination = "numToDice"
			else
				top.combination = "diceToNumber"	
			end

			if top.combination == "numToDice"  then
				top[1] = display.newImageRect( topSheet, top.number, topImageWidth, topImageHeight ) 
				--top.x, top.y = _X, _Y
			else
				top[1] = display.newImageRect( topSheet, top.number+10, topImageWidth, topImageHeight ) 
				--top.x, top.y = _X, _Y
			end
		elseif isNumberToDice then
			top.combination = "numToDice"
			top[1] = display.newImageRect( topSheet, top.number, topImageWidth, topImageHeight ) 
  		else
  			top.combination = "diceToNumber"
  			top[1] = display.newImageRect( topSheet, top.number+10, topImageWidth, topImageHeight )
  		end
  		--add to group
  		panel:insert( top[1] )
  		-- arrange top
  		top[1].x = _X
		--top[1].strokeWidth = 5

		
  		--add animation
		transition.to( top[1], { time=1000, y=_Y-30, transition=easing.outBounce } )

		top[1].y = _Y-30

		print( "top[1].width: "..tostring(top[1].width) )
		print( "top[1].height: "..tostring(top[1].height) )

		local currentTop = top[1]

		function currentTop:tap()
			if paused then return false end 
			print( "play audio top" )
				if read then
				    audio.stop( )
					audio.play(sounds[top.number])	
				end  
			end

			--add listener
			currentTop:addEventListener( "tap" )
  		end

  	function panel:newTop()
  		if panel.top == nil then
  			panel.top = {}
  		end
  		local top = panel.top
  		top.number = panel:randomTopNumber()
  		panel:loadImageTop(top)
  	end

  	function panel:loadThreePossibility()
  		local alternative = panel.alternative
  		local topNumber = panel.top.number
  		local firstNum
		local secondNum
		local thirdNum
		local possibleNumbersLocal = table.copy( numbers )
		local altNumber1 = -1
		local altNumber2 = -1
		local altNumber3 = -1
		local positions = table.copy( positionsAltNumbers )
		local coordinates
		local rangeLocal = range
		local altNumbersIndex = 1 
		local altNumInOrderIndex = 1
		local diceWidth, diceHeight = diceImageWidth*0.7, diceImageHeight*0.7
		local bottom = {}

	  	local function removeElementFromTable( t, element )
	  		local pos = -1
			for i=#t,1,-1 do
				if t[i] == element then
					pos = i
					break
				end
			end
			table.remove( t, pos )
			return t
	  	end

	  	local function chooseRandomElementInTable( t )
			if #t==0 then
				return -1
			elseif #t==1 then 
				return t[1]
			else
				return t[ random( #t )]		
			end
		end

		local function isEndGame()
			if repeatActivity == 0 then
				return true
			end
			return false
		end

		altNumber1 = topNumber
		possibleNumbersLocal = removeElementFromTable( possibleNumbersLocal, altNumber1)
		if (range == -1) then --se non ho selezionato il range
			altNumber2 = chooseRandomElementInTable( possibleNumbersLocal )
			possibleNumbersLocal = removeElementFromTable( possibleNumbersLocal, altNumber2)
			altNumber3 = chooseRandomElementInTable( possibleNumbersLocal )	
		else
			if rangeLocal==1 and topNumber==1 then
				for i=1,2 do
					altNumbers[i] = 2
				end
				--table.insert(altNumbers,2)
				--table.insert(altNumbers,2)
			elseif rangeLocal==1 and topNumber==9 then
				for i=1,2 do
					altNumbers[i] = 8
				end
				--table.insert(altNumbers,8)
				--table.insert(altNumbers,8)
			else
				for i=rangeLocal,1,-1 do
					if altNumber1-i > 0  then
						--table.insert(altNumbers, altNumber1-i)
						altNumbers[altNumbersIndex] = altNumber1-i
						altNumbersIndex = altNumbersIndex+1
					end
				end
				for i=rangeLocal,1,-1 do
					if altNumber1+i <= 10 then
						--table.insert(altNumbers, altNumber1+i)
						altNumbers[altNumbersIndex] = altNumber1+i
						altNumbersIndex = altNumbersIndex+1
					end
				end
			end

			altNumber2 = chooseRandomElementInTable( altNumbers )
			altNumbers = removeElementFromTable( altNumbers, altNumber2)
			altNumber3 = chooseRandomElementInTable( altNumbers )	
		end	
		print("altNumber1: "..tostring(altNumber1)..", altNumber2: "..tostring(altNumber2)..", altNumber3: "..tostring(altNumber3))

		--load first number
		if ( panel.top.combination == "numToDice" ) then --se ho lanciato il dice allora
			firstNum = display.newImageRect( panel, diceSheet, altNumber1, diceWidth, diceHeight )
			secondNum = display.newImageRect( panel, diceSheet, altNumber2, diceWidth, diceHeight )
			thirdNum = display.newImageRect( panel,diceSheet, altNumber3, diceWidth, diceHeight )
		else
			firstNum = display.newImageRect( panel, numSheet, altNumber1, diceWidth, diceHeight )
			secondNum = display.newImageRect( panel, numSheet, altNumber2, diceWidth, diceHeight )
			thirdNum = display.newImageRect( panel ,numSheet, altNumber3, diceWidth, diceHeight )
			firstNum:scale( 0.9, 1 )
			secondNum:scale(0.9, 1)
			thirdNum:scale( 0.9, 1 )
		end

		firstNum.number = tostring(altNumber1)
		secondNum.number = tostring(altNumber2)
		thirdNum.number = tostring(altNumber3)

		--firstNum.strokeWidth = 5
		--secondNum.strokeWidth = 5
		--thirdNum.strokeWidth = 5

		coordinates = chooseRandomElementInTable(positions)
		firstNum.x = coordinates[1]
		--firstNum.y = coordinates[2]
		firstNum.position = coordinates[3]
		positions = removeElementFromTable( positions, coordinates)
		coordinates = chooseRandomElementInTable(positions)
		secondNum.x = coordinates[1]
		--secondNum.y = coordinates[2]
		secondNum.position = coordinates[3]
		positions = removeElementFromTable( positions, coordinates)
		coordinates = chooseRandomElementInTable(positions)
		thirdNum.x = coordinates[1]
		--thirdNum.y = coordinates[2]
		thirdNum.position = coordinates[3]

		transition.to( firstNum, { time=1000, y=coordinates[2], transition=easing.outBounce } )
		transition.to( secondNum, { time=1000, y=coordinates[2], transition=easing.outBounce } )
		transition.to( thirdNum, { time=1000, y=coordinates[2], transition=easing.outBounce } )
			
		if firstNum.position == 1 then
			--table.insert(altNumInOrder, firstNum)
			altNumInOrder[altNumInOrderIndex] = firstNum
			altNumInOrderIndex = altNumInOrderIndex+1
		elseif secondNum.position == 1 then
			--table.insert(altNumInOrder, secondNum)
			altNumInOrder[altNumInOrderIndex] = secondNum
			altNumInOrderIndex = altNumInOrderIndex+1
		else 
			--table.insert(altNumInOrder, thirdNum)
			altNumInOrder[altNumInOrderIndex] = thirdNum
			altNumInOrderIndex = altNumInOrderIndex+1		
		end
		if firstNum.position == 2 then
			--table.insert(altNumInOrder, firstNum)
			altNumInOrder[altNumInOrderIndex] = firstNum
			altNumInOrderIndex = altNumInOrderIndex+1
		elseif secondNum.position == 2 then
			--table.insert(altNumInOrder, secondNum)
			altNumInOrder[altNumInOrderIndex] = secondNum
			altNumInOrderIndex = altNumInOrderIndex+1
		else 
			--table.insert(altNumInOrder, thirdNum)
			altNumInOrder[altNumInOrderIndex] = thirdNum
			altNumInOrderIndex = altNumInOrderIndex+1		
		end
		if firstNum.position == 3 then
			--table.insert(altNumInOrder, firstNum)
			altNumInOrder[altNumInOrderIndex] = firstNum
			altNumInOrderIndex = altNumInOrderIndex+1
		elseif secondNum.position == 3 then
			--table.insert(altNumInOrder, secondNum)
			altNumInOrder[altNumInOrderIndex] = secondNum
			altNumInOrderIndex = altNumInOrderIndex+1
		else --table.insert(altNumInOrder, thirdNum)		
			altNumInOrder[altNumInOrderIndex] = thirdNum
			altNumInOrderIndex = altNumInOrderIndex+1
		end	
		print("altNumber1order: "..tostring(altNumInOrder[1].number)..", altNumber2order: "..tostring(altNumInOrder[2].number)..", altNumber3order: "..tostring(altNumInOrder[3].number))

		bottom = {altNumInOrder[1].number, altNumInOrder[2].number, altNumInOrder[3].number}

  		local function tapOneOfThreeNumbers(event)

  			if paused then return false end        
  			local currentButton = event.target
  			local top = panel.top
  			print( "Tap event on: " .. currentButton.number )
  		
  			panel.status = "answer"
			panel:updateStatus( top.combination, top.number, bottom[1], bottom[2], bottom[3], currentButton.number)   

			local function replunish()
				if not isEndGame() then
					panel:replunish()	
				end
			end

  			if (tonumber(event.target.number) == top.number) then
			print( "risposta esatta" )
			audio.play( sounds.right )
			paused = true
			right = right + 1	
			repeatActivity = repeatActivity - 1	 
			consecutiveRight = consecutiveRight + 1
			for i=1,3 do
				if currentButton == altNumInOrder[i] then
					local x = altNumInOrder[i].x
					altNumInOrder[i]:removeSelf( )
					altNumInOrder[i] = nil
					if panel.top.combination == "numToDice" then
						altNumInOrder[i] = display.newImageRect( panel, diceSheet, bottom[i]+10, diceWidth, diceHeight )
					else
						altNumInOrder[i] = display.newImageRect( panel, numSheet, bottom[i]+10, diceWidth, diceHeight )	
					end
					altNumInOrder[i].x = x	
					altNumInOrder[i].y = coordinates[2]	
					transition.to (altNumInOrder[i], { time=1000, xScale = 1.1, yScale = 1.2, transition=easing.outQuad, onComplete = replunish } )
				end
			end
			else
				print( "risposta sbagliata" )
				audio.play( sounds.wrong )
				wrong = wrong + 1
				repeatActivity = repeatActivity - 1	 
				consecutiveRight = 0
				print( "wrong: "..tostring(wrong) ) 
				for i=1,3 do
					if currentButton == altNumInOrder[i] then
						local x = altNumInOrder[i].x
						altNumInOrder[i]:removeSelf( )
						altNumInOrder[i] = nil
						if panel.top.combination == "numToDice" then
							altNumInOrder[i] = display.newImageRect( panel, diceSheet, bottom[i]+20, diceWidth, diceHeight )
							transition.to (altNumInOrder[i], { time=100, xScale = 0.85, yScale = 0.85, transition=easing.outQuad } )	
						else
							altNumInOrder[i] = display.newImageRect( panel, numSheet, bottom[i]+20, diceWidth, diceHeight )	
							transition.to (altNumInOrder[i], { time=100, xScale = 0.8, yScale = 0.9, transition=easing.outQuad } )	
						end
						altNumInOrder[i].x = x	
						altNumInOrder[i].y = coordinates[2]	
					end
				end
			end				

			if isEndGame() then
				panel:endGame()
			end

			if consecutiveRight == rightForStar[indexRFS] then
				panel.status = "star"
				panel:updateStatus()
				indexRFS = indexRFS + 1
				consecutiveRight = 0
			end

			--transition.from( currentPiece, { time = 233, xScale = 0.001, yScale = 0.01, transition=easing.outBounce } )
			print( "event.target: "..tostring(event.target) )
			print( "current: "..tostring(currentButton) )
			print( "altNumInOrder[1], altNumInOrder[2], altNumInOrder[3]: " .. tostring(altNumInOrder[1]), tostring(altNumInOrder[2]), tostring(altNumInOrder[3]) )
  		end

  		-- finnally, add an event listener to our button buttons
  		altNumInOrder[1]:addEventListener( "tap", tapOneOfThreeNumbers )
  		altNumInOrder[2]:addEventListener( "tap", tapOneOfThreeNumbers )
  		altNumInOrder[3]:addEventListener( "tap", tapOneOfThreeNumbers )
  	end

  	function panel:recycle()
  		local top = panel.top
  		if top == nil then return false end
  		top[1]:removeSelf( )
  		top[1] = nil	
  		for i=1,3 do
  			altNumInOrder[i]:removeSelf( )
  			altNumInOrder[i] = nil
  		end
  	end

  	function panel:replunish()
  		paused = false
  		panel:recycle()
  		panel:newTop()
  		print( "topNumber: "..tostring(panel.top.number) )
  		print( "combination: "..tostring(panel.top.combination) )
  		panel:loadThreePossibility()
  	end

  	function panel:getCombination()
  		return panel.top.combination
  	end


  	function panel:endGame()
	    panel.status = "endGame"
	    panel.right = right
	    panel.wrong = wrong
	    panel:updateStatus()
	    panel:recycle()
	end

  	--add the pieces
  	panel:replunish()

  	return panel
end

return M