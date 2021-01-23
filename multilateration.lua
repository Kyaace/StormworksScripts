ticks = 0
period = 0
averagePeriod = 0
GPSX = 0
GPSY = 0
distance = 0
circles = {}
zoom = 8
release = true
menu = true
locator = false
average = true
mute = false

function toggleMenu()
	menu = not menu
end

function toggleLocator()
	locator = not locator
	averagePeriod = 0
	ticks = 0
end

function zoomIn()
	zoom = zoom * .75
	if zoom < 1 then
		zoom = 1
	end
end

function zoomOut()
	zoom = zoom * 1.33
	if zoom > 50 then
		zoom = 50
	end
end

function saveCircle()
	c = {}
	c.x = GPSX
	c.y = GPSY
	c.r = distance
	table.insert(circles, c)
	averagePeriod = 0
end

function clearC()
	circles = {}
	averagePeriod = 0
end

function toggleAverage()
	average = not average
	averagePeriod = 0
end

function toggleMute()
	mute = not mute
end

function mkButton(x,y,w,h,t,f)
	b = {}
	b.x = x
	b.y = y
	b.w = w
	b.h = h
	b.t = t
	b.f = f
	table.insert(buttons, b)
end

buttons = {}
mkButton(0,0,25,8,"Menu",toggleMenu)
mkButton(0,8,25,8,"Pow",toggleLocator)
mkButton(13,16,12,8,"+",zoomIn)
mkButton(0,16,12,8,"-",zoomOut)
mkButton(0,24,25,8,"Save",saveCircle)
mkButton(0,32,25,8,"Clr",clearC)
mkButton(0,40,25,8,"Ave",toggleAverage)
mkButton(0,48,25,8,"Mute",toggleMute)


-- Tick function that will be executed every logic tick
function onTick()
	--value = input.getNumber(1)			 -- Read the first number from the script's composite input
	--output.setNumber(1, value * 10)		-- Write a number to the script's composite output
	signal = input.getBool(3)
	GPSX = input.getNumber(7)
	GPSY = input.getNumber(8)
	compass = input.getNumber(9)*-2*math.pi
	
	if signal then
		period = ticks/60
		if period >= 60 then
			period = 0
		end
		if averagePeriod <= period * .5 then
			averagePeriod = period
		else
			averagePeriod = .8 * averagePeriod + .2 * period
		end
		if average then
			period = averagePeriod
		end
		ticks = 0
	else
		ticks = ticks + 1
	end
	
	distance = period * 3000 - 150--Rough estimate to turn period into distance.
	output.setNumber(1,distance)
	output.setBool(1, locator)
	buzz = not mute and signal
	output.setBool(2, buzz)
	
	leftX = input.getNumber(3)
	leftY = input.getNumber(4)
	
	LeftClick = input.getBool(1)
	if LeftClick then
		for i, b in pairs(buttons) do
			if leftX > b.x and leftX < b.x + b.w and leftY > b.y and leftY < b.y + b.h and release then
				if b.t == "Menu" or menu then
					release = false
					if b.f then
						b.f()
					end
				end
			end
		end
	else
		release = true
	end
end

function onDraw()
	w = screen.getWidth()
	h = screen.getHeight()					
	screen.drawMap(GPSX, GPSY, zoom)
	screen.setColor(255, 255, 0)--Yellow
	for i, c in pairs(circles) do
		circleOnMap(c.x, c.y, c.r)
	end
	
	if distance > 0 then
		screen.setColor(255, 0, 0)--Red
		circleOnMap(GPSX, GPSY, distance)
	end
	
	screen.setColor(0,0,0)
	drawPointer(w/2, h/2, 16, compass)
		
	for i, b in pairs(buttons) do
		if b.t == "Menu" or menu then
			screen.setColor(0, 0, 0)
			screen.drawRect(b.x, b.y, b.w, b.h)
			screen.setColor(255, 255, 255)
			screen.drawTextBox(b.x, b.y+1, b.w, b.h, b.t, .5, .6)
		end
	end
	
	if distance > 0 then
		screen.drawTextBox(0, h-10, w, 10, math.floor(distance), .5, .5)
	end
end
	
function circleOnMap(x, y, r)
	px, py = map.mapToScreen(GPSX, GPSY, zoom, w, h, x, y)
	pr, pt = map.mapToScreen(0, 0, zoom, w, h, r, 0)--convert distance meters to pixels
	screen.drawCircle(px, py,  pr-w/2)
end
	
function drawPointer(x,y,s,r,...)--Thanks to rising.at/Stormworks/lua/framework.lua for function
	local a=...a=(a or 30)*math.pi/360;x=x+s/2*math.sin(r)y=y-s/2*math.cos(r) 	screen.drawTriangleF(x,y,x-s*math.sin(r+a),y+s*math.cos(r+a),x-s*math.sin(r-a),y+s*math.cos(r-a))
end
	-- draw an arrow at point x,y with size s and rotation r. Argument 5 is optional and specifies the width of the arrow.