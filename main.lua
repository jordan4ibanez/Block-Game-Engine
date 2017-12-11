--this is a game engine made from the physics tutorial (https://love2d.org/wiki/Tutorial:PhysicsCollisionCallbacks)

--[[ PROBLEMS FOUND:
-You cannot resize an object, it will not use friction anymore

]]--

dofile("helpers.lua")

print(dump("test"))

block = {} --function table - holds functions
map_size = {10,10} --the size of the map x and y
block_size = 10 --x and y of blocks
object_table = {} --holds all the objects


--creates balls - hard bodies - sample test of object handling engine
function block.create_ball(posx,posy,type,mass,size,bounciness)
	local id = table.getn(object_table) --auto get ids of table - this has a limit of 32 bit or 64 bit integer
	object_table["ball"..id] = {}
        object_table["ball"..id].b = love.physics.newBody(world, posx,posy, type)
        object_table["ball"..id].b:setMass(mass)
        object_table["ball"..id].s = love.physics.newCircleShape(size)
        object_table["ball"..id].f = love.physics.newFixture(object_table["ball"..id].b, object_table["ball"..id].s)
        object_table["ball"..id].f:setRestitution(bounciness)    -- make it bouncy
        object_table["ball"..id].f:setUserData("ball"..tostring(id))
        object_table["ball"..id].b:setFixedRotation( false )
        print("created ball"..tostring(id))
end

function block.create_block(posx,posy,type,mass,sizex,sizey,bounciness)
	local id = table.getn(object_table) 
	object_table["block"..id] = {}
        object_table["block"..id].b = love.physics.newBody(world, posx,posy, type)
        object_table["block"..id].s = love.physics.newRectangleShape(200,50)
        object_table["block"..id].f = love.physics.newFixture(object_table["block"..id].b, object_table["block"..id].s)
        object_table["block"..id].f:setUserData("block"..id)
end

function love.load()
    world = love.physics.newWorld(0, 200, true)
        world:setCallbacks(beginContact, endContact, preSolve, postSolve)
 
    block.create_ball(400,200,"dynamic",20,50,0.3)

	block.create_block(400,400,"static",0,200,50,0)
 
    text       = ""   -- we'll use this to put info text on the screen later
    persisting = 0    -- we'll use this to store the state of repeated callback calls
end
 
i = 50
function love.update(dt)
    world:update(dt)
 
    if love.keyboard.isDown("f") then
      i = i + 1
	  local ball_shape = object_table["ball0"].f:getShape()
	  ball_shape:setRadius(i)
	  object_table["ball0"].s = love.physics.newCircleShape(i)

    end
 
    if love.keyboard.isDown("right") then
         object_table["ball0"].b:applyForce(1000, 0)
    elseif love.keyboard.isDown("left") then
        object_table["ball0"].b:applyForce(-1000, 0)
    end
    if love.keyboard.isDown("up") then
        object_table["ball0"].b:applyForce(0, -5000)	
    elseif love.keyboard.isDown("down") then
        object_table["ball0"].b:applyForce(0, 1000)
    end
 
    if string.len(text) > 768 then    -- cleanup when 'text' gets too long
        text = ""
    end
end
 
function love.draw()
	--if table.getn(object_table) > 0 then
	for _,obj in pairs(object_table) do

		if obj.f:getUserData() and string.find(obj.f:getUserData(), "ball") then
			love.graphics.circle("line", obj.b:getX(),obj.b:getY(), obj.s:getRadius(), 20)
		elseif obj.f:getUserData() and string.find(obj.f:getUserData(), "block") then
			love.graphics.polygon("line", obj.b:getWorldPoints(obj.s:getPoints()))
		end
	end
	--end

 
    love.graphics.print(text, 10, 10)
end
 
function beginContact(a, b, coll)
    x,y = coll:getNormal()
    if a:getUserData() and b:getUserData() then
		--text = text.."\n"..a:getUserData().." colliding with "..b:getUserData().." with a vector normal of: "..x..", "..y
		
		--ALLOW each to apply friction to eachother
		
		if object_table[a:getUserData()].b:getType() ~= "static" then
			print("a is world actor")
		end
		
		if object_table[b:getUserData()].b:getType() ~= "static" then
			print("b is world actor")
		end
		
		--object_table[a:getUserData()].b:applyForce(1000, 0)
	end
end
 
function endContact(a, b, coll)
	if a:getUserData() and b:getUserData() then
		--persisting = 0
		print(object_table[a:getUserData()].b:getType())
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
