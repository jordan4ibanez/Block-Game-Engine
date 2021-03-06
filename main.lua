--This is a game engine made from the physics tutorial (https://love2d.org/wiki/Tutorial:PhysicsCollisionCallbacks)

--This engine is very literal. If you place your player at 0,0 (x,y) in the world, the center of them will be at 0,0

--[[ PROBLEMS FOUND:
-You cannot resize an object, it will not use friction anymore

]]--

dofile("helpers.lua")

print(dump("test"))

block = {} --function table - holds functions
map_size = {31,31} --the size of the map x and y -- starts at 0
block_size = 80 --x and y of blocks
object_table = {} --holds all the objects
id = 0
blockposx,blockposy = 0,0

posx,posy = 0,0

function love.wheelmoved(x, y)
    if y > 0 and graphics_scale < 3 then
        text = "Mouse wheel moved up"
        graphics_scale = graphics_scale + 0.1
    elseif y < 0  and graphics_scale > 0.5 then
        text = "Mouse wheel moved down"
        graphics_scale = graphics_scale - 0.1
    end
end

--creates balls - hard bodies - sample test of object handling engine
function block.create_ball(posx,posy,type,mass,size,bounciness)
	--local id = table.getn(object_table) --auto get ids of table - this has a limit of 32 bit or 64 bit integer
	object_table["ball"..id] = {}
        object_table["ball"..id].b = love.physics.newBody(world, posx,posy, type)
        object_table["ball"..id].b:setMass(mass)
        object_table["ball"..id].s = love.physics.newCircleShape(size)
        object_table["ball"..id].f = love.physics.newFixture(object_table["ball"..id].b, object_table["ball"..id].s)
        object_table["ball"..id].f:setRestitution(bounciness)    -- make it bouncy
        object_table["ball"..id].f:setUserData("ball"..tostring(id))
        object_table["ball"..id].b:setFixedRotation( false )
        --print("created ball"..tostring(id))
        id = id + 1
end

--creates blocks "rectangles"
function block.create_block(posx,posy,type,mass,sizex,sizey,bounciness,rotates)
	--local id = table.getn(object_table) 
	object_table["block"..id] = {}
        object_table["block"..id].b = love.physics.newBody(world, posx,posy, type)
        if rotates == false then
			object_table["block"..id].b:setFixedRotation(true)
		end
        object_table["block"..id].s = love.physics.newRectangleShape(sizex,sizey)
        object_table["block"..id].f = love.physics.newFixture(object_table["block"..id].b, object_table["block"..id].s)
        object_table["block"..id].f:setUserData("block"..id)
        
        
        id = id + 1
end

function love.load()
    world = love.physics.newWorld(0, 400, true) --set 400 to 980 for earth gravity
        world:setCallbacks(beginContact, endContact, preSolve, postSolve)
 
    --block.create_block(200,-200,"dynamic",20,50,0.3)
	block.create_block(400,-200,"dynamic",1,40,80,0,false)
	--create sample "chunk"
	anchor = {0,0} --this is where the chunk begins - top left -
	for x = 0,map_size[1] do
	for y = 0,map_size[2] do
		--print(anchor[1])
		--block.create_block(anchor[1],anchor[2],"static",0,5,5,0)
		block.create_block(anchor[1]+(x*block_size),anchor[2]+(y*block_size),"static",0,block_size,block_size,0,false)
	end
	end
 
    text       = ""   -- we'll use this to put info text on the screen later
    persisting = 0    -- we'll use this to store the state of repeated callback calls
end


function love.keypressed( key, scancode, isrepeat )

    -- ignore non-printable characters (see http://www.ascii-code.com/)
    if key == "e" then
		--block.create_block(posx+math.random(-30,30),posy - math.random(50,100),"dynamic",1,20,20,0,false)
    end
    --[[ typing test
    if key == "space" then
        text = text .. " "
    elseif key == "return" then
		text = text .. "\n"
	else
		text = text .. key
		
    end
    ]]--
end
 
 
i = 0
function love.update(dt)
	local mousex, mousey = love.mouse.getPosition()
	posx,posy = object_table["block0"].b:getPosition()
	local realmx,realmy = (posx+(mousex-(love.graphics.getWidth( )/2))/graphics_scale),(posy+(mousey-(love.graphics.getHeight( )/2))/graphics_scale)
	blockposx,blockposy = math.floor((realmx/block_size) + 0.5),math.floor((realmy/block_size) + 0.5)
	
	
	--print(realmx,realmy)
	
	--print(blockposx,blockposy)
	--print(mousex-(love.graphics.getWidth( )/2)+math.floor(posx),mousey-(love.graphics.getHeight( )/2)+math.floor(posy))
    world:update(dt)
 
    --if love.keyboard.isDown("f") then
     -- i = i + 1
      
	  --local ball_shape = object_table["ball0"].f:getShape()
	  --ball_shape:setRadius(i)
	  --object_table["ball0"].s = love.physics.newCircleShape(i)

    --end
 
	if  love.keyboard.isDown("e") then
		block.create_block(posx+math.random(-30,30),posy - math.random(50,100),"dynamic",1,20,20,0,true)
    end
 
    if love.keyboard.isDown("d") then
         object_table["block0"].b:applyForce(1000, 0)
    elseif love.keyboard.isDown("a") then
        object_table["block0"].b:applyForce(-1000, 0)
    end
    if love.keyboard.isDown("w") then
        object_table["block0"].b:applyForce(0, -5000)	
    elseif love.keyboard.isDown("s") then
        object_table["block0"].b:applyForce(0, 1000)
    end
 
    if string.len(text) > 768 then    -- cleanup when 'text' gets too long
        text = ""
    end
end

graphics_scale = 1

function love.draw()
	local translationx,translationy = object_table["block0"].b:getPosition()
	love.graphics.scale(graphics_scale, graphics_scale)
	love.graphics.translate(-translationx+((love.graphics.getWidth( )/2)/graphics_scale), -translationy+((love.graphics.getHeight( )/2)/graphics_scale))
	--if table.getn(object_table) > 0 then
	for _,obj in pairs(object_table) do

		if obj.f:getUserData() and string.find(obj.f:getUserData(), "ball") then
			love.graphics.circle("line", obj.b:getX(),obj.b:getY(), obj.s:getRadius(), 20)
		elseif obj.f:getUserData() and string.find(obj.f:getUserData(), "block") then
			love.graphics.polygon("line", obj.b:getWorldPoints(obj.s:getPoints()))
			
			--print(dump(obj.b:getWorldPoints(obj.s:getPoints())))
			--print("________")
		end
	end
	--end
	
	--debug selection				---x1                                   y1                                    x2                                     y2                                    x3                                      y3                                     x4                                    y4
	love.graphics.polygon('fill', (blockposx*block_size)-(block_size/2), (blockposy*block_size)-(block_size/2), (blockposx*block_size)+(block_size/2), (blockposy*block_size)-(block_size/2), (blockposx*block_size)+(block_size/2), (blockposy*block_size)+(block_size/2), (blockposx*block_size)-(block_size/2),(blockposy*block_size)+(block_size/2))
	--love.graphics.polygon('fill',10,10,50,10,50,50,10,50)
	
	love.graphics.push( )
	love.graphics.pop()   -- return to stored coordinated
	love.graphics.scale(2, 2)
	
	--begin default coordinates
	--love.graphics.translate((translationx/2)-(love.graphics.getWidth( )/4), (translationy/2)-(love.graphics.getHeight( )/4))
	love.graphics.translate((translationx/2)-(love.graphics.getWidth( )/(graphics_scale*4)), (translationy/2)-(love.graphics.getHeight( )/(graphics_scale*4)))
    love.graphics.print(text, 10, 30)
    
    love.graphics.print("FPS:"..tostring(love.timer.getFPS( )),10,10)
    love.graphics.print("MX:"..tostring(blockposx).." | MY:"..tostring(blockposy),10,20)
end
 
function beginContact(a, b, coll)
    x,y = coll:getNormal()
    if a:getUserData() and b:getUserData() then
		--text = text.."\n"..a:getUserData().." colliding with "..b:getUserData().." with a vector normal of: "..x..", "..y
		
		--allow each to apply friction to eachother
		
		if object_table[a:getUserData()].b:getType() ~= "static" then
			--print("a is world actor")
		end
		
		if object_table[b:getUserData()].b:getType() ~= "static" then
			--print("b is world actor")
		end
		
		--object_table[a:getUserData()].b:applyForce(1000, 0)
	end
end
 
function endContact(a, b, coll)
	if a:getUserData() and b:getUserData() then
		--persisting = 0
		--print(object_table[a:getUserData()].b:getType())
		--text = text.."\n"..a:getUserData().." uncolliding with "..b:getUserData()
	end
end
 
function preSolve(a, b, coll)
	if a:getUserData() and b:getUserData() then
    if persisting == 0 then    -- only say when they first start touching
        --text = text.."\n"..a:getUserData().." touching "..b:getUserData()
    elseif persisting < 20 then    -- then just start counting
        --text = text.." "..persisting
    end
    --persisting = persisting + 1    -- keep track of how many updates they've been touching for
	end
end
 
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end
