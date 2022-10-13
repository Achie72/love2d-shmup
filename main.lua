-- Luacheck guards
-- Love is the main API we are using.

-- After this let's define our global variables

-- luacheck: global
io.stdout:setvbuf('no')

player = {
    x = 64,
    y = 64,
    idleSpr = nil,
    hp = 20,
    maxHp = 30,
    nextShot = 0,
    shotCooldown = 30,
    flash = 0,
    sprites = {nil,nil,nil},
    lean = 0,
    exhaust = {nil,nil,nil,nil},
    exhaustIndex = 1,
    xp = 0,
    level = 1,
    upgrades = {1,1,1,1,1,1,1,1,1,1,1,1},
    shield = 20,
    maxShield = 30,
    speed = 0,
	reloadSpeed = 0,
	dodgeChance = 0,
	pylonRange = 0,
	explosionRange = 0, 
	antiBulletRange = 0,
    nextPylon = 0,
    nextAntiBullet = 0,
    nextRockets = 0,
    hasShield = false,
    timeUntilShields = 0,
    dodgeTimer = 0,
    nextShoot = 0,
    speed = 1.5
}

numberOfUpgrades = 12
startTime = 0
enemySprites = {}
canvasWidth = 240
canvasHeight = 136

gameCanvas = nil
myFont = nil
released = false
--- collections


palette = {
    {26, 28, 44},
    {93, 39, 93},
    {177, 62, 83},
    {239, 125, 87},
    {255, 205, 117},
    {167, 240, 112},
    {56, 183, 100},
    {37, 113, 121},
    {41, 54, 111},
    {59, 93, 201},
    {65, 166, 246},
    {115, 239, 247},
    {244, 244, 244},
    {148, 176, 194},
    {86, 108, 134},
    {51, 60, 87}
}


stars = {}
particles = {}
bullets = {}

enemies = {}
enemyBullets = {}
experience = {}

playerBulletSpr = nil
rocketSprite = nil
bulletFlash = nil
enemyBulletSprite = {nil, nil}
experienceSprites = {nil, nil}

upgradeSprites = {}
explosionAreas = {}
textBubbles = {}
names = {"rocket","afterburner","Chain reloader","ion shield","repair bot","mini turrets","anit-matter ammo","improved plating","hologram module","explosive rounds","tesla pylons","bullet defense"}
effects = {"fires seeking missiles","movement speed +","attack speed +","recharging shield","hull regeneration","more bullets","increase damage","reduce incoming damage","chance to dodge attacks","AOE damage","close range zaps","kill close bullets"}
levelUpgrades = {}
upgradeIndicator = 0
upgradeSelectorSprite = nil
levelUp = false
ticks = 0

function love.conf(t)
	t.console = true
end

function love.load()

    love.graphics.setDefaultFilter('nearest','nearest',0)

    --window = {translateX = 40, translateY = 40, scale = 1, width = 1920, height = 1080}
	--width, height = love.graphics.getDimensions ()
	love.window.setMode (960, 548, {resizable=true, borderless=false})
    love.console = true
    gameCanvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
    

    -- game stuff
    player.sprites[1] = love.graphics.newImage('gfx/player/playerLeanLeft.png')
    player.sprites[2] = love.graphics.newImage('gfx/player/playerIdle.png')
    player.sprites[3] = love.graphics.newImage('gfx/player/playerLeanRight.png')

    for i=1,4 do
        local string = "gfx/player/exhaust_"..i..".png"
        player.exhaust[i] = love.graphics.newImage(string.."")
    end

    -- load enemy sprites
    for i=1,5 do
        local frame1 = love.graphics.newImage("gfx/enemies/circ_"..i.."_1.png")
        local frame2 = love.graphics.newImage("gfx/enemies/circ_"..i.."_2.png")
        local sprites = {frame1,frame2}
        enemySprites[i] = sprites
    end

    playerBulletSpr = love.graphics.newImage('gfx/particles/playerBul.png')
    bulletFlash = love.graphics.newImage('gfx/particles/bulletFlash.png')
    
    for i=1,2 do
        local enemyBulSpr = love.graphics.newImage("gfx/particles/enemyBul_"..i..".png")
        local xpSprite = love.graphics.newImage("gfx/particles/xp_"..i..".png")
        enemyBulletSprite[i] = enemyBulSpr
        experienceSprites[i] = xpSprite
    end

    for i=1,numberOfUpgrades do
        local upgradeSpr = love.graphics.newImage("gfx/upgrades/upgrade_"..i..".png")
        upgradeSprites[i] = upgradeSpr
    end

    upgradeSelectorSprite = love.graphics.newImage("gfx/ui/upgradeSelector.png")
    rocketSprite = love.graphics.newImage("gfx/particles/rocketBul.png")
    --love.graphics.setCanvas(gameCanvas)
    --love.graphics.setCanvas()

    myFont = love.graphics.newFont('BMmini.ttf', 8)
    startTime = love.timer.getTime( )
end

function time()
    return love.timer.getTime( ) - startTime
end

function collide(a,b)
	if (a.cw == nil) then a.cw = 8 end
	if (a.ch == nil) then a.ch = 8 end
	if (b.cw == nil) then b.cw = 8 end
	if (b.ch == nil) then b.ch = 8 end
	
	local aLeft = a.x
	local aTop = a.y
	local aRight = a.x + a.cw
	local aBot = a.y + a.ch
	
	local bLeft = b.x
	local bTop = b.y
	local bRight = b.x + b.cw
	local bBot = b.y + b.ch
	
	if (aTop > bBot) then return false end
	if (bTop > aBot) then return false end
	if (aLeft > bRight) then return false end
	if (bLeft > aRight) then return false end
	
	return true
		
end

function collidec(_circ, _obj)
	local circDX = math.abs(_circ.x - _obj.x+_obj.cw/2)
	local circDY = math.abs(_circ.y - _obj.y+_obj.cw/2)
	
	if (circDX > (_obj.cw/2 + _circ.r)) then return false end
	if (circDY > (_obj.ch/2 + _circ.r)) then return false end
	
	if (circDX <= (_obj.cw/2)) then return true end
	if (circDY <= (_obj.ch/2)) then return true end
	
	
	local cornerDistSQ = math.pow((circDX - _obj.cw/2),2) + math.pow((circDY - _obj.ch/2),2)
	
	return (cornerDistSQ <= math.pow(_circ.r,2))
end

function close_enough(obj1,obj2,dist)
	if (math.abs(obj1.x-obj2.x) < dist) and (math.abs(obj1.y-obj2.y) < dist) then
		return true
	end
		return false
end

function add_text_bubble(_x,_y,_sx,_sy,_txt,_clr,_bgcolor,_maxAge)
	local text = {
		x = _x,
		y = _y,
		sx = _sx,
		sy = _sy,
		text = _txt,
		color = _clr,
		bgcolor = _bgcolor,
		age = 0,
		maxAge = _maxAge
	}
	
	table.insert(textBubbles,text)
end

function add_explosion(_x,_y,_r)
	local expl = {
		x = _x,
		y = _y,
		r = _r,
		life = 30
	}
	table.insert(explosionAreas, expl)
end


function add_xp(_x,_y,_val)
	local xp = {
		x = _x,
		y = _y,
		val = _val,
        animFrame = 1
	}
	table.insert(experience, xp)
end

function add_enemy_bul(_x,_y,_sx,_sy)
	local bul = {
		x = _x,
		y = _y,
		sx = _sx,
		sy = _sy,
		cw = 4,
		ch = 4,
        animFrame = 1
	}
	table.insert(enemyBullets,bul)
end

function add_particle(_x, _y, _sx, _sy, _clr, _tpe, _size, _maxAge)
	local part = {
		x = _x,
		y = _y,
		sx = _sx,
		sy = _sy,
		clr = _clr,
		tpe = _tpe,
		size = _size,
		age = 0,
		maxAge = _maxAge
	}

	table.insert(particles, part)
end

function add_stars(_clr)
	local star = {
		x = math.random(200),
		y = 0,
		clr = _clr
	}
	table.insert(stars, star)
end

ticks= 0

function add_player_bul(_x,_y,_sx,_sy,_tpe,_goal)
	local bul = {
		x = _x,
		y = _y,
		cw = 4,
		ch = 4,
		sx = _sx,
		sy = _sy,
		tpe = _tpe,
		target = nil,
		targetSet = false,
		goal = nil,
        spr = playerBulletSpr
	}
	
	if _tpe == 3 then bul.goal = _goal end
    if _tpe == 2 then spr = rocketSprite end
	
	table.insert(bullets, bul)
end

function add_enemy(_x,_tpe,_family)
	local enemy = {
		x = _x,
		y = -4,
		sx = 0,
		sy = 0.2,
		cw = 8,
		ch = 8,
		sprite = enemySprites[(_family*5)+_tpe],
        animFrame = 1,
		hp = 2*(1+_tpe),
		maxHp = 2*(1+_tpe),
		tpe = _tpe,
		isTarget = false,
		nextShoot = 10,
		shoot = 0,
		shootingInterval = 0,
		isShooting = true,
		damaged = 0,
		invFrames = 0,
		elite = math.random(0,3)
	}
	
	if enemy.tpe == 4 then enemy.shootingInterval = 60 end
	table.insert(enemies, enemy)
end


local tickPeriod = 1/60
local accumulator = 0.0

function love.update(dt)

    accumulator = accumulator+dt
    
    if accumulator >= tickPeriod then
        ticks= ticks+ 1

        if (player.xp >= player.level*2) and (not levelUp) then
            for i=0,3 do
                table.insert(levelUpgrades,math.random(0,10))
            end
            levelUp = true
            player.xp = 0
            player.level = player.level+1
        end


        if levelUp then
            if love.keyboard.isDown("c") then
                levelUp = false
                
                local choosenUpgrade = levelUpgrades[upgradeIndicator]
                player.upgrades[choosenUpgrade+1] = player.upgrades[choosenUpgrade+1]+1
                levelUpgrades = {}
            elseif love.keyboard.isDown("w") or love.keyboard.isDown("up") then
                if released then
                    upgradeIndicator = upgradeIndicator-1
                    released = false
                end
            elseif love.keyboard.isDown("s") or love.keyboard.isDown("down") then
                if released then
                    upgradeIndicator = upgradeIndicator+1
                    released = false
                end
            else
                released = true
            end
            
            if upgradeIndicator < 1 then
                upgradeIndicator = 4
            end
                
            if upgradeIndicator > 4 then
                upgradeIndicator = 1
            end	
        else
            if ticks% 10 == 0 then
                add_stars(8)

                for i=0,1 do
                    add_particle(player.x+2, player.y+8, 0, 2, 2, "dot")
                    add_particle(player.x+4, player.y+8, 0, 2, 2, "dot")
                    add_particle(player.x+2, player.y+9, 0, 2, 4, "dot")
                    add_particle(player.x+4, player.y+9, 0, 2, 4, "dot")
                end
            end

            if ticks% 20 == 0 then
                add_stars(12)
            end

            if ticks% 5 == 0 then
                player.exhaustIndex = player.exhaustIndex + 1
                if player.exhaustIndex > 4 then
                    player.exhaustIndex = 1
                end
            end


            player.lean = 0
            if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
                player.y = player.y - player.speed
            end
            if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
                player.y = player.y + player.speed
            end
            if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
                player.x = player.x - player.speed
                player.lean = -1
            end
            if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
                player.x = player.x + player.speed
                player.lean = 1
            end

            if love.keyboard.isDown("x") and (player.nextShoot < ticks) then
                local extraBul = player.upgrades[6]
                
                if extraBul > 0 then
                    local step = 0
                    local edge = 0.2*extraBul
                    
                    
                    
                    for i=-edge,edge,0.2 do			
                        local radAng = (i*math.pi)/180
                        add_player_bul(player.x+2,player.y-2,math.sin(i)*2,-math.cos(i)*1.5,0,true)
                    end		
                else
                    add_player_bul(player.x+2,player.y-2,0,-2,0,true)
                end
            
                player.flash = 3
                player.nextShoot = ticks + 3 + (20-player.reloadSpeed)
        
                -- add player text
                local side = -1
                if math.random() > 0.5 then side = 1 end
                add_text_bubble(player.x-4+(side*math.random(10,15)),player.y+4+math.random(-2,2),side/2,math.random(),"pew",2,4,15)
        
            end

            if player.nextShot > 0 then
                player.nextShot = player.nextShot - 1
            end

            if player.flash > 0 then
                player.flash = player.flash - 1
            end

            if player.dodgeTimer > 0 then
                player.dodgeTimer = player.dodgeTimer -1
            end
            
            
            if ticks%60 == 0 then
                add_enemy(math.random(0, 192),math.random(1,5), 0)
            end

            for _,star in ipairs(stars) do
                local speed = 2
                if star.clr == 8 then
                    speed = 1
                end
                star.y = star.y + speed
                if star.y > 136 then
                    table.remove(stars,_)
                end
            end

            for _,xp in ipairs(experience) do
                xp.y = xp.y + 1
                if collide(player, xp) then
                    player.xp = player.xp + xp.val
                    table.remove(experience,_)
                end

                if ticks%15 == 0 then
                    xp.animFrame = xp.animFrame + 1
                    if xp.animFrame > 2 then
                        xp.animFrame = 1
                    end
                end
            end

            for _,expl in ipairs(explosionAreas) do
                if expl.life > 0 then
                    local spd = 3
                    expl.life = expl.life -1
                    add_particle(expl.x+4,expl.y+4,math.random(0,spd)*2-spd, math.random(0,spd)*2-spd,math.random(1,3),"expl",math.random(0,1),5)
                else
                    table.remove(explosionAreas,_)
                end
            end

            for _,tb in ipairs(textBubbles) do
                tb.x = tb.x + tb.sx
                tb.x = tb.x + tb.sx
            
                tb.age = tb.age + 1
                if tb.age > tb.maxAge then
                table.remove(textBubbles,_)
                end
                if tb.age > tb.maxAge * 0.8 then
                    tb.clr = 15
                end
            end

            update_particles()
            update_bullets()
            update_enemies()
            update_upgrades()
        end

        accumulator = accumulator - tickPeriod
    end -- tick accumulation
end

function update_upgrades()
	
	player.speed = 1.5 + player.upgrades[2]*0.2
	player.reloadSpeed = player.upgrades[3]
	player.dodgeChance = player.upgrades[9]*0.1
	player.pylonRange = 40 + player.upgrades[11]/5
	player.explosionRange = 40 + player.upgrades[10]/5
	player.antiBulletRange = 20 + player.upgrades[12]/5
		
	if player.nextPylon > 0 then
		player.nextPylon = player.nextPylon -1
	end
	
	if player.nextAntiBullet > 0 then
		player.nextAntiBullet = player.nextAntiBullet - 1
	end

    if player.nextRockets > 0 then
        player.nextRockets = player.nextRockets -1
    end
	
	if player.upgrades[4] > 0 then
		player.hasShield = true
		player.maxShield = player.upgrades[4]*10
		player.timeUntilShields = player.timeUntilShields -1
		if player.timeUntilShields < 0 then
			if player.shield < player.maxShield then
				player.shield = player.shield + 0.5
			end
			player.timeUntilShields = 0
		end
	end
	
	if (player.nextRockets == 0) then
			if player.upgrades[1] > 0 then
				local dir = 1
				if math.random() < 0.5 then
					dir = -1
				end
				
				for i=1,player.upgrades[1] do
					add_player_bul(player.x,player.y,2*dir+math.random(3),math.random(3),1,true)
				end
			end
			player.nextRockets = 60
		end
	
		-- repair bots
		if ticks%60 == 0 then
			player.hp = player.hp + player.upgrades[5]
			if player.hp > player.maxHp then
				player.hp = player.maxHp
			end
		end
			
end

function update_enemies()
    for _,enemy in ipairs(enemies) do
        enemy.y = enemy.y + enemy.sy

        if enemy.sy > 136 then
            enemy.sy = -4
        end
    
        if enemy.hp <= 0 then
			local spd = 2
			local colorMap = {7,2,4,3,9}
			for i=0,5 do
				add_particle(enemy.x+4,enemy.y+4,math.random(0,spd)*2-spd, math.random(0,spd)*2-spd,colorMap[enemy.tpe],"expl",math.random(1,3),30)
			end
			add_xp(enemy.x, enemy.y, enemy.tpe+1)
			table.remove(enemies,_)
		end

        if ticks%15 == 0 then
            enemy.animFrame = enemy.animFrame + 1
            if enemy.animFrame > 2 then
                enemy.animFrame = 1
            end
        end

        if enemy.nextShoot > 0 then
			enemy.nextShoot = enemy.nextShoot -1
		end
		
		if enemy.damaged > 0 then
			enemy.damaged = enemy.damaged - 1
		end
		
		if enemy.shootingInterval > 0 then
			enemy.shootingInterval = enemy.shootingInterval - 1
			if enemy.shootingInterval == 0 then
				enemy.isShooting = not enemy.isShooting
				enemy.shootingInterval = 60
			end
		end
		
		if enemy.invFrames > 0 then
			enemy.invFrames = enemy.invFrames - 1
		end

        if (player.upgrades[11] > 0) and (player.nextPylon == 0) then
			if close_enough(enemy,player,player.pylonRange) then
				local angle = math.atan2(player.y - enemy.y, player.x - enemy.x)
				local bsx = -math.cos(angle)
				local bsy = -math.sin(angle)
				add_player_bul(player.x,player.y,bsx*10,bsy*10,2)
				player.nextPylon = 10
			
				local zep = {"zip","zap","zop"}
				local side = -1
				if math.random() > 0.5 then side = 1 end
				add_text_bubble(player.x-4+(side*math.random(10,15)),player.y+4+math.random(-2,2),side/2,math.random(),zep[math.random(1,3)],12,10,15)

			
			end
		end
		
		for _,bul in ipairs(bullets) do
            if collide(bul, enemy) then
                local damage = 1
                if bul.tpe == 1 then damage = 4 end
                damage_enemy(enemy, damage)
                
                -- explosive rounds
                
                table.remove(bullets,_)
                if (player.upgrades[10] > 0) and (bul.tpe == 0) then
                    add_explosion(enemy.x+4,enemy.y+4,player.explosionRange)
                    local side = -1
                    if math.random() > 0.5 then side = 1 end
                    add_text_bubble(enemy.x-4+(side*math.random(10,15)),enemy.y+4+math.random(-2,2),side/2,math.random(),"BOOM",8,2,15)
                end
            end
		end
		
		-- check explosive area		
		for id,expl in ipairs(explosionAreas) do
			if close_enough(enemy,expl,player.explosionRange) then
				if collidec(expl,enemy) then
					damage_enemy(enemy,1)
				end
			end
		end

        if enemy.shoot > 0 then
			enemy.shoot = enemy.shoot - 1
		end
		
		if enemy.tpe == 2 then
			if enemy.nextShoot == 0 then
				add_enemy_bul(enemy.x+4,enemy.y,0,1.5)
				enemy.nextShoot = 60
				enemy.shoot = 8
				--sfx(1,nil,-1,0)
			end
		end
		
		if enemy.tpe == 3 then
			if enemy.nextShoot == 0 then
				local angle = math.atan2(enemy.y - player.y, enemy.x - player.x)
				local bsx = -math.cos(angle)
				local bsy = -math.sin(angle)
				add_enemy_bul(enemy.x,enemy.y,bsx,bsy)
				enemy.nextShoot = 60
				enemy.shoot = 8
				--sfx(1,nil,-1,0)
			end
		end
		
		if enemy.tpe == 4 then
			if enemy.nextShoot == 0 then
				for i=-math.pi,math.pi,0.5 do
					add_enemy_bul(enemy.x, enemy.y+4, math.sin(i), math.cos(i))
				end
				enemy.nextShoot = 60
				enemy.shoot = 5
				--sfx(1,nil,-1,0)
			end
		end
	
		if enemy.tpe == 5 then
			if (enemy.nextShoot == 0)and (enemy.isShooting) then
				local a = math.sin(ticks*2)
				local b = math.cos(ticks*2)
				add_enemy_bul(enemy.x+4, enemy.y+4,  a/2, b/2)
				add_enemy_bul(enemy.x+4, enemy.y+4,  -a/2, -b/2) 
				enemy.nextShoot = 3
				enemy.shoot = 1
			 --sfx(1,nil,-1,0)
			end
		end
    end
end

function damage_enemy(_enemy,_damage)
	if (_enemy.invFrames == 0) then
		_enemy.hp = _enemy.hp - (_damage*(1+player.upgrades[7]/10))
		_enemy.damaged = 90
		_enemy.invFrames = 10
	end
end

function hit_player(_damage)
	local rng = math.random()
	
	if rng > player.dodgeChance then
		if (player.hasShield) and (player.shield > 0) then
				player.shield = player.shield - _damage
				player.timeUntilShields = 90
			else	
				player.hp = player.hp - _damage*(1-player.upgrades[8]/10)
			end
	else
		player.dodgeTimer = 10
	end
end

function update_particles()
	for _,part in ipairs(particles) do
        part.x = part.x + part.sx
        part.y = part.y + part.sy
        if (part.y > 136) then
            table.remove(particles, _)
        end
        
        if part.tpe == "expl" then
            part.sx = part.sx * 0.9
            part.sy = part.sy * 0.9
        end
        
        if not (part.maxAge == nil) then
            part.age = part.age + 1
            if part.age >= part.maxAge then
                table.remove(particles,_)
            end
            
            if part.age >= part.maxAge*0.9 then
                part.clr = 15
            end
        end
        
    end
end

function update_bullets ()
    for _,bul in ipairs(bullets) do
		if bul.y < 0 then
			table.remove(bullets,_)
		end
		
		
		if bul.tpe == 0 then
			bul.x = bul.x + bul.sx
			bul.y = bul.y + bul.sy
		elseif bul.tpe == 1 then	
			bul.x = bul.x + bul.sx
			bul.y = bul.y + bul.sy
			bul.sx = bul.sx * 0.9
			if (bul.sx < 0.1) and (bul.target == nil) and (#enemies > 0) then
				local randIndex = math.random(#enemies)
				bul.target = randIndex
				bul.targetSet = true
			end
			if not(enemies[bul.target] == nil) then
				local angle = math.atan2(bul.y - enemies[bul.target].y, bul.x - enemies[bul.target].x)
				bul.sx = -math.cos(angle)*3
				bul.sy = -math.sin(angle)*3
				enemies[bul.target].isTarget = true
			end
			add_particle(bul.x+1,bul.y+1,0,0,12,"dot",1,math.random(8,10))
		elseif bul.tpe == 2 then
			bul.x = bul.x + bul.sx
			bul.y = bul.y + bul.sy
			add_particle(bul.x,bul.y,math.random(),math.random(),11,"dot",math.random(1,2),10)		
		elseif bul.tpe == 3 then
			bul.x = bul.x + bul.sx
			bul.y = bul.y + bul.sy
			if close_enough(bul,bul.goal,6) then
				table.remove(bullets,_)
			end
		end
	end

    for _,ebul in ipairs(enemyBullets) do
		ebul.x = ebul.x + ebul.sx
		ebul.y = ebul.y + ebul.sy

        if ticks%15 == 0 then
            ebul.animFrame = ebul.animFrame + 1
            if ebul.animFrame > 2 then
                ebul.animFrame = 1
            end
        end

		if (ebul.sy > 140) or 
					(ebul.y <0) or
		 		(ebul.x <0) or 
					(ebul.x > 200) then
			table.remove(enemyBullets,_)
		end
		
		if collide(ebul,player) then
			table.remove(enemyBullets,_)
            print("hit")
			hit_player(2)
		end	
	end
end

function hit_player(_damage)
	local rng = math.random()
    if rng > player.dodgeChance then
		if (player.hasShield) and (player.shield > 0) then
				player.shield = player.shield - _damage
				player.timeUntilShields = 90
			else	
				player.hp = player.hp - _damage*(1-player.upgrades[8]/10)
			end
	else
		player.dodgeTimer = 10
	end
end

function love.draw()
    --love.graphics.setBackgroundColor(  )   
    love.graphics.clear()
    

    local width, height = love.graphics.getDimensions()


    local gameScale = canvasWidth / canvasHeight
    local windowScale = width / height

    local sw, sh = width/canvasWidth, height/canvasHeight

    if windowScale > gameScale then
        drawScale = sh
    else
        drawScale = sw
    end

    local hSpace = width - (canvasWidth * drawScale)
    local vSpace = height - (canvasHeight * drawScale)

    local drawOffsetHorizontal = hSpace / 2
    local drawOffsetVertical = vSpace / 2


    love.graphics.setCanvas(gameCanvas)
    draw_game(drawScale)
    love.graphics.setCanvas()

    --love.graphics.scale(drawScale,drawScale)
    love.graphics.draw(gameCanvas, drawOffsetHorizontal, drawOffsetVertical, 0, drawScale, drawScale)
    
end

function draw_color (_palCol)
    local color = palette[_palCol+1]
    love.graphics.setColor( color[1]/255, color[2]/255, color[3]/255)
end

function reset_color()
    love.graphics.setColor(1,1,1,1)
end

function printText(_txt,_posX,_posY,_clr)
    draw_color(_clr)
    love.graphics.print(_txt, myFont, _posX, _posY)
    reset_color()
end

function draw_outline(_spr,_posX,_posY,_oColor)
    local pixelData = {}
    for i=0,7 do
        for j=0,7 do
            local r,g,b,a = ImageData:getPixel(i,j)
        end
    end
end

function print_outline(_txt,_posX,_posY,_clr,_bgClr)
    for i=-1,1,1 do
        for j=-1,1,1 do
            printText(_txt, _posX+i, _posY+j, _bgClr)
        end
    end
    printText(_txt, _posX, _posY, _clr)
end

function draw_game(_ds)
   
    love.graphics.clear(26/255, 28/255, 44/255, 1)
   
    for _,expl in ipairs(explosionAreas) do
        draw_color(1)
		love.graphics.circle("line",expl.x,expl.y,expl.r/2)
        reset_color()
	end


    if player.dodgeTimer > 0 then
        for yInd=1,8 do
            local startPos = math.random(-15,0)
            local endPos = math.random(0,15)
            love.graphics.setLineStyle("rough")
            draw_color(11)
            love.graphics.line(player.x-startPos,player.y+yInd,player.x+endPos,player.y+yInd)
            reset_color()
        end
    else
        love.graphics.draw(player.sprites[2+player.lean], player.x, player.y, 0, 1, 1)
        print(player.flash)
        if player.flash > 0 then
            
            love.graphics.draw(bulletFlash, player.x, player.y-2, 0, 1, 1)
        end
        love.graphics.draw(player.exhaust[player.exhaustIndex], player.x+player.lean, player.y+8, 0, 1, 1)

        if player.hasShield then
			--draw shield
			local size = 8*(player.shield/player.maxShield)
            draw_color(11)
			love.graphics.circle("line",player.x+3,player.y+4,size/2)
            reset_color()
		end
    end


    -- setup UI
    draw_color(5)
    love.graphics.setLineStyle("rough")
    love.graphics.line(200,0,201,136)
    
    printText("Hull:", 202, 2, 5)
    printText(player.hp.."/"..player.maxHp, 204, 10, 2)

    --print_outline("close range zaps", 64,64,11,2)
    reset_color()
    local offset = 0
	if player.hasShield then
		offset = 16
		printText("Shields",202,18,5)
		printText(player.shield.."/"..player.maxShield,202,26,10)
	end

    draw_color(5)
	love.graphics.rectangle("fill",200,19+offset,50,1)
    reset_color()
    
    local upDraw = 0
	for _,up in ipairs(player.upgrades) do
		if not(player.upgrades[_] == 0) then
			local vOff = 0
			if _ > 10 then
				vOff = 20
				upDraw = (_-11)*10
			end
			love.graphics.draw(upgradeSprites[_],202+vOff,20+offset+upDraw,0)
			printText(up,210+vOff,20+offset+upDraw,5)
            upDraw = upDraw + 10
		end
	end

    -- draw xp line
    draw_color(6)
    love.graphics.rectangle("fill",60,130,80,1)
	reset_color()
	draw_color(5)
    love.graphics.rectangle("fill",60,130,(80*(player.xp/(player.level*2))),1)
    reset_color()
    for _,xp in ipairs(experience) do
		love.graphics.draw(experienceSprites[xp.animFrame],xp.x,xp.y,0)
	end


    draw_text_bubbles()
    draw_stars()
    draw_particles()
    draw_bullets()
    draw_enemies()



    if (levelUp==true) then
        draw_color(0)
		love.graphics.rectangle("fill",20,20,160,100)
        reset_color()
        draw_color(5)
        love.graphics.rectangle("fill",20,20,20,1)
        love.graphics.rectangle("fill",20,20,1,20)
        
        love.graphics.rectangle("fill",160,120,21,1)
        love.graphics.rectangle("fill",180,100,1,20)
        reset_color()
		--rectb(19,19,161,91,5)	
		if ticks%20 > 10 then	
            local lvlString = "--- level up ---"
			printText(lvlString,100-#lvlString*2,20,5)
            love.graphics.draw(upgradeSelectorSprite,15,20+upgradeIndicator*20,0, 1, 1)		
			--print(levelUpgrades[upgradeIndicator],8,20+upgradeIndicator*20,3)
	
		end
		for _,up in ipairs(levelUpgrades) do
            draw_color(5)
			love.graphics.rectangle("line",28,18+_*20,13,13)
            reset_color()
			love.graphics.draw(upgradeSprites[up+1], 30, 20+_*20, 0, 1, 1)
			printText(names[up+1],50 ,18+_*20,5)
			printText("> "..effects[up+1],53,26+_*20,7)
		end
	end

end

function draw_enemies()

    for _,enemy in ipairs(enemies) do

        if enemy.damaged > 0 then
			draw_healthbar(enemy.x-1,enemy.y-4,enemy.hp,enemy.maxHp,3,1)
		end

        love.graphics.draw(enemy.sprite[enemy.animFrame], enemy.x, enemy.y, 0, 1, 1)
        
        if enemy.shoot > 0 then
            love.graphics.draw(bulletFlash, enemy.x, enemy.y+7, 0, 1, 1)
        end
    end
    
end

function draw_particles()
	for _,part in ipairs(particles) do
        draw_color(part.clr)
		if part.tpe == "dot" then
			love.graphics.points(part.x+0.5, part.y+0.5)
		elseif part.tpe == "circ" then
			love.graphics.circle("line", part.x,part.y,part.size)
		elseif (part.tpe == "circf") or (part.tpe == "expl") then
			love.graphics.circle("fill", part.x,part.y,part.size)
		end	
	end
    reset_color()
end

function draw_stars()
    for _,star in ipairs(stars) do
        draw_color(star.clr)
		love.graphics.points(star.x+0.5, star.y+0.5)
		if star.clr == 12 then
            love.graphics.points(star.x+0.5, star.y+0.5, star.x+0.5, star.y-1.5 )
		end
	end
    reset_color()
end

function draw_text_bubbles()
	for _,tb in ipairs(textBubbles) do
    -- draw it offset by one pixel in each cardinal and radial direction
    -- with the background color
	
        print_outline(tb.text,tb.x,tb.y,tb.color,tb.bgcolor)
    -- print the text in the middle
		--printText(tb.text,tb.x,tb.y,tb.color)
	end
end

function draw_bullets()
	for _,bul in ipairs(bullets) do
		if bul.tpe == 2 then
            draw_color(11)
            love.graphics.setLineStyle("rough")
			love.graphics.line(player.x+4,player.y+4,bul.x,bul.y)	
            reset_color()
		elseif bul.tpe == 3 then
            draw_color(4)
            love.graphics.setLineStyle("rough")
			line(player.x+4,player.y+4,bul.x,bul.y)	
            reset_color()
		else
			love.graphics.draw(bul.spr,bul.x,bul.y, 0)
		end
	end

    for _,ebul in ipairs(enemyBullets) do
        love.graphics.draw(enemyBulletSprite[ebul.animFrame], ebul.x, ebul.y, 0, 1, 1)

        for _,ebul in ipairs(enemyBullets) do
            if close_enough(ebul,player,player.antiBulletRange) and (player.nextAntiBullet == 0 ) then
                draw_color(4)
                love.graphics.line(player.x+4,player.y+4,ebul.x,ebul.y)
                reset_color()
                add_particle(ebul.x,ebul.y,math.random(),math.random(),8,"expl",math.random(1,3),15)
                add_text_bubble(ebul.x,ebul.y,math.random(),math.random(),"nope",4,2,10)
                table.remove(enemyBullets,_)
                player.nextAntiBullet = 60
            end
        end
    end
end

function draw_healthbar(_x,_y,_hp,_maxHp,_clrHp,_clrMax)
    draw_color(12)
	love.graphics.rectangle("fill",_x,_y,10,3)
	draw_color(_clrMax)
    love.graphics.rectangle("fill",_x+1,_y+1,8,1)
    draw_color(_clrHp)
	love.graphics.rectangle("fill", _x+1,_y+1,8*(_hp/_maxHp),1)
    reset_color()
end
-- luacheck: pop ignore love