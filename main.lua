debug = false

-- Timers
-- We declare these here so we don't have to edit them multiple places
canShoot = true
canShootTimerMax = 0.2 
canShootTimer = canShootTimerMax
createSunTimerMax = 0.4
createSunTimer = createSunTimerMax

-- Player Object
panel = { x = 100, y = 540, speed = 300, img = nil }
isAlive = true
score  = 0

-- Image Storage
bulletImg = nil
sun = nil
backGround = nil

-- Entity Storage
bullets = {} -- array of current bullets being drawn and updated
enemies = {} -- array of current enemies on screen

-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

-- Loading
function love.load(arg)
	panel.img = love.graphics.newImage('assets/solarpanel.png')
	sun = love.graphics.newImage('assets/sun.png')
	backGround = love.graphics.newImage('assets/bg.jpg')
end


-- Updating
function love.update(dt)
	-- I always start with an easy way to exit the game
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

	-- Time out how far apart our shots can be.
	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer < 0 then
		canShoot = true
	end

	-- Time out enemy creation
	createSunTimer = createSunTimer - (1 * dt)
	if createSunTimer < 0 then
		createSunTimer = createSunTimerMax

		-- Create an enemy
		randomNumber = math.random(10, love.graphics.getWidth() - 10)
		newEnemy = { x = randomNumber, y = -10, img = sun }
		table.insert(enemies, newEnemy)
	end


	-- update the positions of bullets
	for i, bullet in ipairs(bullets) do
		bullet.y = bullet.y - (250 * dt)

		if bullet.y < 0 then -- remove bullets when they pass off the screen
			table.remove(bullets, i)
		end
	end

	-- update the positions of enemies
	for i, enemy in ipairs(enemies) do
		enemy.y = enemy.y + (200 * dt)

		if enemy.y > 850 then -- remove enemies when they pass off the screen
			table.remove(enemies, i)
		end
	end

	-- run our collision detection
	-- Since there will be fewer enemies on screen than bullets we'll loop them first
	-- Also, we need to see if the enemies hit our panel
	for i, enemy in ipairs(enemies) do
		for j, bullet in ipairs(bullets) do
			if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
				table.remove(bullets, j)
				table.remove(enemies, i)
				score = score + 1
			end
		end

		if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), panel.x, panel.y, panel.img:getWidth(), panel.img:getHeight())
		and isAlive then
			table.remove(enemies, i)
			score = score + 1
		end
	end


	if love.keyboard.isDown('left','a') then
		if panel.x > 0 then -- binds us to the map
			panel.x = panel.x - (panel.speed*dt)
		end
	elseif love.keyboard.isDown('right','d') then
		if panel.x < (love.graphics.getWidth() - panel.img:getWidth()) then
			panel.x = panel.x + (panel.speed*dt)
		end
	end

	if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot then
		-- Create some bullets
		newBullet = { x = panel.x + (panel.img:getWidth()/2), y = panel.y, img = bulletImg }
		table.insert(bullets, newBullet)
		canShoot = false
		canShootTimer = canShootTimerMax
	end

	if not isAlive and love.keyboard.isDown('r') then
		-- remove all our bullets and enemies from screen
		bullets = {}
		enemies = {}

		-- reset timers
		canShootTimer = canShootTimerMax
		createSunTimer = createSunTimerMax

		-- move panel back to default position
		panel.x = 50
		panel.y = 710

		-- reset our game state
		score = 0
		isAlive = true
	end
end

-- Drawing
function love.draw(dt)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(backGround, 0, 0)

	for i, bullet in ipairs(bullets) do
		love.graphics.draw(bullet.img, bullet.x, bullet.y)
	end

	for i, enemy in ipairs(enemies) do
		love.graphics.draw(enemy.img, enemy.x, enemy.y)
	end

	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Energia: " .. tostring(score) .. " kW", 380, 10)

	if isAlive then
		love.graphics.draw(panel.img, panel.x, panel.y)
	else
		love.graphics.print("Pressione 'R' para reiniciar", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
	end

	if debug then
		fps = tostring(love.timer.getFPS())
		love.graphics.print("FPS: "..fps, 9, 10)
	end
end
