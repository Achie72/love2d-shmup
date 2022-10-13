-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

t=0
hp = 20
maxHp = 30
rockets = 2
nextRockets = 0
nextPylon = 0
pylonRange = 0
explosionRange = 0
nextAntiBullet = 0
antiBulletRange = 0
x=96
y=24
speed = 1.5
lean = 0
idx = 0
flash = 0
enemyAnimFrame = 0
levelUp = false
lvl = 1
names = {"rocket","afterburner","Chain reloader","ion shield","repair bot","mini turrets","anit-matter ammo","improved plating","hologram module","explosive rounds","tesla pylons","bullet defense"}

effects = {"fires seeking missiles","movement speed +","attack speed +","recharging shield","hull regeneration","more bullets","increase damage","reduce incoming damage","chance to dodge attacks","AOE damage","close range zaps","kill close bullets"}
upgrades = {0,1,1,1,1,0,1,1,1,1,1,1}
levelUpgrades = {}
upgradeIndicator = 0
playerXP = 0
hasShield = false
shield = 0
maxShield = 0
timeUntilShields = 30
nextShoot = 0
reloadSpeed = 1
dodgeChance = 0
dodgeTimer = 0

experience = {}
stars = {}
particles = {}
bullets = {}
enemies = {}
enemyBullets = {}
explosionAreas = {}

textBubbles = {}


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
		val = _val
	}
	table.insert(experience, xp)
end

function add_stars(_clr)
	local star = {
		x = math.random(200),
		y = 0,
		clr = _clr
	}
	table.insert(stars, star)
end

function add_bul(_x,_y,_sx,_sy,_tpe,_player,_goal)
	local bul = {
		x = _x,
		y = _y,
		cw = 4,
		ch = 4,
		sx = _sx,
		sy = _sy,
		own = _player,
		tpe = _tpe,
		target = nil,
		targetSet = false,
		goal = nil
	}
	
	if _tpe == 3 then bul.goal = _goal end
	
	table.insert(bullets, bul)
end

function add_enemy_bul(_x,_y,_sx,_sy)
	local bul = {
		x = _x,
		y = _y,
		sx = _sx,
		sy = _sy,
		cw = 4,
		ch = 4
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

function add_enemy(_x,_tpe,_family)
	local enemy = {
		x = _x,
		y = -4,
		sx = 0,
		sy = 0.2,
		cw = 8,
		ch = 8,
		sprite = 64+(_family*16) + _tpe*2,
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

function close_enough(obj1,obj2,dist)
	if (math.abs(obj1.x-obj2.x) < dist) and (math.abs(obj1.y-obj2.y) < dist) then
		return true
	end
		return false
end


function TIC()

	t=t+1
	
	if (playerXP >= lvl*2) and (not levelUp) then
		for i=0,3 do
			table.insert(levelUpgrades,math.random(0,10))
		end
		levelUp = true
		playerXP = 0
		lvl = lvl+1
	end

	if levelUp then
		if btn(4) then
			levelUp = false
			
			local choosenUpgrade = levelUpgrades[upgradeIndicator]
			upgrades[choosenUpgrade+1] = upgrades[choosenUpgrade+1]+1
			levelUpgrades = {}
		end
		if btnp(0) then
			upgradeIndicator = upgradeIndicator-1
		end
		if btnp(1) then
			upgradeIndicator = upgradeIndicator+1
		end
		
		if upgradeIndicator < 1 then
			upgradeIndicator = 4
		end
			
		if upgradeIndicator > 4 then
			upgradeIndicator = 1
		end	
			
	else
		leaning = 0
		if btn(0) then 
			y=y-speed
	 end
		if btn(1) then y=y+speed end
		if btn(2) then
			x=x-speed
			leaning = -1
		end
		if btn(3) then
		 x=x+speed
			leaning = 1
		end
		if btn(5) and (nextShoot < t) then
			
			--sfx(0,nil,-1,1)
			
			local extraBul = upgrades[6]
			
			if extraBul > 0 then
				local step = 0
				local edge = 0.2*extraBul
				
				
				
				for i=-edge,edge,0.2 do			
					local radAng = (i*math.pi)/180
					add_bul(x+2,y-2,math.sin(i)*2,-math.cos(i)*1.5,0,true)
				end		
			else
				add_bul(x+2,y-2,0,-2,0,true)
			end
		
			flash = 3
			nextShoot = t + 3 + (20-reloadSpeed)
	
			-- add player text
			local side = -1
			if math.random() > 0.5 then side = 1 end
			add_text_bubble(x-4+(side*math.random(10,15)),y+4+math.random(-2,2),side/2,math.random(),"pew",2,4,15)
	
	
		end
		
		
		if dodgeTimer > 0 then
			dodgeTimer = dodgeTimer -1
		end
		
		if flash > 0 then
			flash = flash - 1
		end
		
		if (t%5 == 0) then
			idx = idx + 1
			if idx > 3 then
				idx = 0
			end 
		end
		
		
		if (t%10 == 0 ) then
			enemyAnimFrame = enemyAnimFrame +1
			if enemyAnimFrame > 1 then
				enemyAnimFrame = 0
			end
			add_stars(12)
			for i=0,1 do
				add_particle(x+2, y+8, 0, 2, 2, "dot")
				add_particle(x+4, y+8, 0, 2, 2, "dot")
				add_particle(x+2, y+9, 0, 2, 4, "dot")
				add_particle(x+4, y+9, 0, 2, 4, "dot")
			end
		end
		if (t%20 == 0 ) then
			add_stars(8)
		end
		if (t%60 == 0) then
			add_enemy(math.random(192),math.random(0,4),math.random(0,2))
		end
			
		
		
		for _,xp in ipairs(experience) do
			xp.y = xp.y + 1
			local player = {
				x = x,
				y = y,
				cw = 8,
				ch = 8
			}
			if collide(player, xp) then
				playerXP = playerXP + xp.val
				table.remove(experience,_)
			end
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
			if tb.age > tb.maxAge then
			
			end
		end
		
		update_particles()
		update_enemies()		
		update_bullets()
		update_upgrades()
	end
	
	draw()
end

function update_upgrades()
	
	speed = 1.5 + upgrades[2]*0.2
	reloadSpeed = upgrades[3]
	dodgeChance = upgrades[9]*0.1
	pylonRange = 40 + upgrades[11]/5
	explosionRange = 40 + upgrades[10]/5
	antiBulletRange = 20 + upgrades[12]/5
		
	if nextPylon > 0 then
		nextPylon = nextPylon -1
	end
	
	if nextAntiBullet > 0 then
		nextAntiBullet = nextAntiBullet - 1
	end
	
	if upgrades[4] > 0 then
		hasShield = true
		maxShield = upgrades[4]*10
		timeUntilShields = timeUntilShields -1
		if timeUntilShields < 0 then
			if shield < maxShield then
				shield = shield + 0.5
			end
			timeUntilShields = 0
		end
	end
	
	if (time() > nextRockets) then
			if upgrades[1] > 0 then
				local dir = 1
				if math.random() < 0.5 then
					dir = -1
				end
				
				for i=1,upgrades[1] do
					add_bul(x,y,2*dir+math.random(3),math.random(3),1,true)
				end
			end
			nextRockets = time()+2000
		end
	
		-- repair bots
		if t%60 == 0 then
			hp = hp + upgrades[5]
			if hp > maxHp then
				hp = maxHp
			end
		end
			
end

function update_enemies()
	local px,py = x,y
	local player = {
		x = px,
		y = py
	}
	for _,enemy in ipairs(enemies) do
		enemy.isTarget = false
		enemy.x = enemy.x + enemy.sx
		enemy.y = enemy.y + enemy.sy
		if enemy.y > 136 then
			enemy.y = 0
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
		
		-- pylon
		if (upgrades[11] > 0) and (nextPylon == 0) then
			if close_enough(enemy,player,pylonRange) then
				local angle = math.atan2(y - enemy.y, x - enemy.x)
				local bsx = -math.cos(angle)
				local bsy = -math.sin(angle)
				add_bul(x,y,bsx*10,bsy*10,2,true)
				nextPylon = 10
			
				local zep = {"zip","zap","zop"}
				local side = -1
				if math.random() > 0.5 then side = 1 end
				add_text_bubble(x-4+(side*math.random(10,15)),y+4+math.random(-2,2),side/2,math.random(),zep[math.random(1,3)],12,10,15)

			
			end
		end
		
		for _,bul in ipairs(bullets) do
			if (bul.own) then
				if collide(bul, enemy) then
					local damage = 1
					if bul.tpe == 1 then damage = 4 end
					damage_enemy(enemy, damage)
					
					-- explosive rounds
					
					table.remove(bullets,_)
					if (upgrades[10] > 0) and (bul.tpe == 0) then
						add_explosion(enemy.x+4,enemy.y+4,explosionRange)
						local side = -1
						if math.random() > 0.5 then side = 1 end
						add_text_bubble(enemy.x-4+(side*math.random(10,15)),enemy.y+4+math.random(-2,2),side/2,math.random(),"BOOM",8,2,15)
					end
				end
			end
		end
		
		-- check explosive area		
		for id,expl in ipairs(explosionAreas) do
			if close_enough(enemy,expl,explosionRange) then
				if collidec(expl,enemy) then
					damage_enemy(enemy,1)
				end
			end
		end
		
		if enemy.hp <= 0 then
			local spd = 2
			local colorMap = {7,2,4,3,9}
			for i=0,5 do
				add_particle(enemy.x+4,enemy.y+4,math.random(0,spd)*2-spd, math.random(0,spd)*2-spd,colorMap[enemy.tpe+1],"expl",math.random(1,3),30)
			end
			add_xp(enemy.x, enemy.y, enemy.tpe+1)
			table.remove(enemies,_)
		end
	
		if enemy.shoot > 0 then
			enemy.shoot = enemy.shoot - 1
		end
		
		if enemy.tpe == 1 then
			if enemy.nextShoot == 0 then
				add_enemy_bul(enemy.x+4,enemy.y,0,1.5)
				enemy.nextShoot = 60
				enemy.shoot = 8
				--sfx(1,nil,-1,0)
			end
		end
		
		if enemy.tpe == 2 then
			if enemy.nextShoot == 0 then
				local angle = math.atan2(enemy.y - y, enemy.x - x)
				local bsx = -math.cos(angle)
				local bsy = -math.sin(angle)
				add_enemy_bul(enemy.x,enemy.y,bsx,bsy)
				enemy.nextShoot = 60
				enemy.shoot = 8
				--sfx(1,nil,-1,0)
			end
		end
		
		if enemy.tpe == 3 then
			if enemy.nextShoot == 0 then
				for i=-math.pi,math.pi,0.5 do
					add_enemy_bul(enemy.x, enemy.y+4, math.sin(i), math.cos(i))
				end
				enemy.nextShoot = 60
				enemy.shoot = 5
				--sfx(1,nil,-1,0)
			end
		end
	
		if enemy.tpe == 4 then
			if (enemy.nextShoot == 0)and (enemy.isShooting) then
				local a = math.sin(t)*2
				local b = math.cos(t)*2
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
		_enemy.hp = _enemy.hp - (_damage*(1+upgrades[7]/10))
		_enemy.damaged = 90
		_enemy.invFrames = 10
	end
end

function update_bullets()
	local player = {
				x = x,
				y = y,
				cw = 8,
				ch = 8
			}
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
		if (ebul.sy > 140) or 
					(ebul.y <0) or
		 		(ebul.x <0) or 
					(ebul.x > 200) then
			table.remove(enemyBullets,_)
		end
		
		if collide(ebul,player) then
			table.remove(enemyBullets,_)
			hit_player(2)
		end	
	end
end

function hit_player(_damage)
	local rng = math.random()
	
	if rng > dodgeChance then
		if (hasShield) and (shield > 0) then
				shield = shield - _damage
				timeUntilShields = 90
			else	
				hp = hp - _damage*(1-upgrades[8]/10)
			end
	else
		dodgeTimer = 10
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


function draw()
	cls(0)
	
	draw_text_bubbles()
	if nextAntiBullet == 0 then
		ellib(x+3,y+3,antiBulletRange,antiBulletRange,4)
	end
	--print(levelUp,20,20,5)	
		
	if dodgeTimer > 0 then
		-- do it for each y level
		for i=0,7 do
			if math.random() > 0.5 then
				local startLine = math.random(-10,0)
				local endLine = math.random(0,10)
				for j=startLine,endLine do
					-- calculate the pixel index
					local decPos = math.floor(x+4)+j+((math.floor(y)+i)*240)
					-- turn it to hexa
					local hexPos = ('%X'):format(decPos)
					-- poke
					poke4(0x0000+tonumber(hexPos,16),11)
				end
			end
		end
	else
		-- draw exhaust
		draw_outline(4+idx,x+leaning,y+8,0,8)
		-- draw ship
		draw_outline(2+leaning,x,y,0,8)
		if hasShield then
			--draw shield
			local size = 8*(shield/maxShield)
			ellib(x+3,y+4,size,size,11)
		end
	end

	line(200,0,200,140,5)
	
	print(#enemies, 0, 120, 8)
	
	-- draw lives
	print("Hull",202,2,5)
	print(hp.."/"..maxHp,202,10,2)
	local offset = 0
	if hasShield then
		offset = 16
		print("Shields",202,18,5)
		print(shield.."/"..maxShield,202,26,10)
	end

	line(200,19+offset,250,19+offset,5)
	

	-- draw rockets
	--spr(16,202,20+offset,0)
	--print(rockets,210,22+offset,7)
	
	-- draw upgades
	local upDraw = 0
	for _,up in ipairs(upgrades) do
		if not(upgrades[_] == 0) then
			local vOff = 0
			if _ > 10 then
				vOff = 20
				upDraw = (_-11)*10
			end
			spr(16+_-1,202+vOff,20+offset+upDraw,0)
			print(up,210+vOff,20+offset+upDraw,5)
			upDraw = upDraw + 10
		end
	end
	
	line(60,130,140,130,6)
	print(playerXP,40,130,6)
	line(60,130,60+(80*(playerXP/(lvl*2))),130,5)
	for _,star in ipairs(stars) do
		pix(star.x, star.y, star.clr)
		if star.clr == 12 then
			pix(star.x, star.y-1, star.clr)
		end
	end
	if flash > 0 then
		spr(9,x+1,y-2,0)
	end
	
	for _,xp in ipairs(experience) do
		spr(10+enemyAnimFrame,xp.x,xp.y,0)
	end
	
	for _,expl in ipairs(explosionAreas) do
		ellib(expl.x,expl.y,expl.r,expl.r,1)
	end
		
	
	draw_particles()
	draw_bullets()
	draw_enemies()



	-- level up dialog
	if (levelUp==true) then
		rect(20,20,180,110,0)
		--rectb(19,19,161,91,5)	
		if t%20 > 10 then	
			print("--- level up ---",60,20,5)
			spr(12,15,20+upgradeIndicator*20,0)		
			--print(levelUpgrades[upgradeIndicator],8,20+upgradeIndicator*20,3)
	
		end
		for _,up in ipairs(levelUpgrades) do
			rectb(26,18+_*20,14,14,5)
			spr(16+up, 30, 20+_*20, 0)
			print(names[up+1],50 ,18+_*20,5)
			print("> "..effects[up+1],53,26+_*20,7)
		end
	end
	
	--local decPos = math.floor(x)+((math.floor(y))*240)
	--local hexPos = ('%X'):format(decPos)
	--poke4(0x0000+tonumber(hexPos,16),11)
	--print(hexPos,20,110,11)

end

function draw_text_bubbles()
	for _,tb in ipairs(textBubbles) do
    -- draw it offset by one pixel in each cardinal and radial direction
    -- with the background color
		for i=-1,1 do
			for j=-1,1 do
				print(tb.text,tb.x+i,tb.y+j,tb.bgcolor)
			end
		end
    -- print the text in the middle
		print(tb.text,tb.x,tb.y,tb.color)
	end
end
	

function draw_bullets()
	local px,py = x,y
	local player = {
		x = px+3,
		y = py+3
	}
	for _,bul in ipairs(bullets) do
		if bul.tpe == 2 then
			line(x+4,y+4,bul.x,bul.y,11)	
		elseif bul.tpe == 3 then
			line(x+4,y+4,bul.x,bul.y,4)	
		else
			spr(28+bul.tpe,bul.x,bul.y,0)
		end
	end
	
	for _,ebul in ipairs(enemyBullets) do
		if close_enough(ebul,player,antiBulletRange) and (nextAntiBullet == 0 ) then
			line(x+4,y+4,ebul.x,ebul.y,4)
			add_particle(ebul.x,ebul.y,math.random(),math.random(),8,"expl",math.random(1,3),15)
			add_text_bubble(ebul.x,ebul.y,math.random(),math.random(),"nope",4,2,10)
			table.remove(enemyBullets,_)
			nextAntiBullet = 60
		end
		spr(240+enemyAnimFrame,ebul.x,ebul.y,0)	
	end
end

function draw_particles()
	for _,part in ipairs(particles) do
		if part.tpe == "dot" then
			pix(part.x, part.y, part.clr)
		elseif part.tpe == "circ" then
			ellib(part.x,part.y,part.size,part.size,part.clr)
		elseif (part.tpe == "circf") or (part.tpe == "expl") then
			elli(part.x,part.y,part.size,part.size,part.clr)
		end	
	end
end

function draw_enemies()
	for _,enemy in ipairs(enemies) do
		draw_outline(enemy.sprite+enemyAnimFrame,enemy.x,enemy.y,0,8,enemy.elite)
		
		if enemy.damaged > 0 then
			draw_healthbar(enemy.x-1,enemy.y-4,enemy.hp,enemy.maxHp,3,1)
		end
		
		if enemy.isTarget then
			if (t%20 > 10) then	
				spr(13,enemy.x,enemy.y,0)
			end
		end
		if enemy.shoot > 0 then
			spr(9,enemy.x,enemy.y+6,0)
		end
	end
end

function draw_outline(_spr,_x,_y,_bg,_clr,_elite)
	local palette_map = 0x3ff0
	if (_elite == nil) then _elite = 0 end
	-- elites: fire, ice, lightning, mending
	local eliteColors = {2,11,4,5}
	
	if _elite > 0 then
		for c=1,15 do
			poke4(palette_map*2+c,eliteColors[_elite])
		end
	
		for i=_x-2,_x+2,1 do
			for j=_y-2,_y+2,1 do
				spr(_spr,i,j,_bg)
			end
		end
	end
	
	
	for c=1,15 do
		poke4(palette_map*2+c,_clr)
	end
	
	for i=_x-1,_x+1,1 do
		for j=_y-1,_y+1,1 do
			spr(_spr,i,j,_bg)
		end
	end	

	for c=0,15 do
		poke4(palette_map*2+c,c)
	end
	
	spr(_spr,_x,_y,_bg)

end

function draw_healthbar(_x,_y,_hp,_maxHp,_clrHp,_clrMax)
	rect(_x,_y,10,3,12)
	rect(_x+1,_y+1,8,1,_clrMax)
	rect(_x+1,_y+1,8*(_hp/_maxHp),1,_clrHp)
end
