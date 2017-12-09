--this is a game engine made from the physics tutorial (https://love2d.org/wiki/Tutorial:PhysicsCollisionCallbacks)

dofile("helpers.lua")

print(dump("test"))

block = {}
map_size = {10,10}
object_table = {}


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
        print("created ball"..tostring(id))
end


function love.load()
    world = love.physics.newWorld(0, 200, true)
        world:setCallbacks(beginContact, endContact, preSolve, postSolve)
 
    block.create_ball(400,300,"dynamic",20,50,0.3)
    
    static = {}
        static.b = love.physics.newBody(world, 400,400, "static")
        static.s = love.physics.newRectangleShape(200,50)
        static.f = love.physics.newFixture(static.b, static.s)
        static.f:setUserData("Block")
 
    text       = ""   -- we'll use this to put info text on the screen later
    persisting = 0    -- we'll use this to store the state of repeated callback calls
end
 
i = 50
function love.update(dt)
    world:update(dt)
 
    if love.keyboard.isDown("f") then
      i = i + 1
      object_table.ball.s = love.physics.newCircleShape(i)
      object_table.ball.f = love.physics.newFixture(object_table.ball.b, object_table.ball.s)

      object_table.ball.f:setUserData("Ball")
      object_table.ball.f:setUserData("Ball")
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
	for _,obj in pairs(object_table) do
		if string.find(obj.f:getUserData(), "ball") then
			love.graphics.circle("line", obj.b:getX(),obj.b:getY(), obj.s:getRadius(), 20)
		end
	end
    love.graphics.polygon("line", static.b:getWorldPoints(static.s:getPoints()))
 
    love.graphics.print(text, 10, 10)
end
 
function beginContact(a, b, coll)
    x,y = coll:getNormal()
    text = text.."\n"..a:getUserData().." colliding with "..b:getUserData().." with a vector normal of: "..x..", "..y
end
 
function endContact(a, b, coll)
    persisting = 0
    text = text.."\n"..a:getUserData().." uncolliding with "..b:getUserData()
end
 
function preSolve(a, b, coll)
    if persisting == 0 then    -- only say when they first start touching
        text = text.."\n"..a:getUserData().." touching "..b:getUserData()
    elseif persisting < 20 then    -- then just start counting
        text = text.." "..persisting
    end
    persisting = persisting + 1    -- keep track of how many updates they've been touching for
end
 
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end
