debug = false

canShoot = true
canShootTimerMax = 0.2 
canShootTimer = canShootTimerMax
createSunTimerMax = 0.4
createSunTimer = createSunTimerMax

-- Painel
panel = { x = 100, y = 540, speed = 300, img = nil }
isAlive = true
score  = 0

-- Imagens
bulletImg = nil
sunImg = nil
backGround = nil

sunRays = {}
suns = {}

-- Tratamento de colisoes
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function love.load(arg)
	panel.img = love.graphics.newImage('assets/solarpanel.png')
	sunImg = love.graphics.newImage('assets/sun.png')
	backGround = love.graphics.newImage('assets/bg.jpg')
end

function love.update(dt)
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer < 0 then
		canShoot = true
	end

	createSunTimer = createSunTimer - (1 * dt)
	if createSunTimer < 0 then
		createSunTimer = createSunTimerMax

		randomNumber = math.random(10, love.graphics.getWidth() - 10)
		newEnemy = { x = randomNumber, y = -10, img = sunImg }
		table.insert(suns, newEnemy)
	end


	for i, bullet in ipairs(sunRays) do
		bullet.y = bullet.y - (250 * dt)

		if bullet.y < 0 then
			table.remove(sunRays, i)
		end
	end

	for i, sun in ipairs(suns) do
		sun.y = sun.y + (200 * dt)

		if sun.y > 850 then
			table.remove(suns, i)
		end
	end

	for i, sun in ipairs(suns) do
		for j, ray in ipairs(sunRays) do
			if CheckCollision(sun.x, sun.y, sun.img:getWidth(), sun.img:getHeight(), ray.x, ray.y, ray.img:getWidth(), ray.img:getHeight()) then
				table.remove(sunRays, j)
				table.remove(suns, i)
				score = score + 1
			end
		end

		if CheckCollision(sun.x, sun.y, sun.img:getWidth(), sun.img:getHeight(), panel.x, panel.y, panel.img:getWidth(), panel.img:getHeight())
		and isAlive then
			table.remove(suns, i)
			score = score + 1
		end
	end


	if love.keyboard.isDown('left','a') then
		if panel.x > 0 then
			panel.x = panel.x - (panel.speed*dt)
		end
	elseif love.keyboard.isDown('right','d') then
		if panel.x < (love.graphics.getWidth() - panel.img:getWidth()) then
			panel.x = panel.x + (panel.speed*dt)
		end
	end

	if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot then
		ray = { x = panel.x + (panel.img:getWidth()/2), y = panel.y, img = bulletImg }
		table.insert(sunRays, ray)
		canShoot = false
		canShootTimer = canShootTimerMax
	end

	if not isAlive and love.keyboard.isDown('r') then
		sunRays = {}
		suns = {}

		canShootTimer = canShootTimerMax
		createSunTimer = createSunTimerMax

		panel.x = 50
		panel.y = 710

		score = 0
		isAlive = true
	end
end

-- Drawing
function love.draw(dt)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(backGround, 0, 0)

	for i, bullet in ipairs(sunRays) do
		love.graphics.draw(bullet.img, bullet.x, bullet.y)
	end

	for i, sun in ipairs(suns) do
		love.graphics.draw(sun.img, sun.x, sun.y)
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