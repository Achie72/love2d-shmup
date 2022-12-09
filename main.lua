-- Luacheck guards
-- Love is the main API we are using.

-- After this let's define our global variables

-- luacheck: global
io.stdout:setvbuf('no')

player = {
    x = 64,
    y = 64,
    idleSpr = nil,
    hp = 100,
    maxHp = 100,
    nextShot = 0,
    shotCooldown = 30,
    flash = 0,
    sprites = {nil,nil,nil},
    lean = 0,
    exhaust = {nil,nil,nil,nil},
    exhaustIndex = 1,
    xp = 0,
    level = 1,
    upgrades = {0,0,0,0,0,0,0,0,0,0,0,0},
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
    timeUntilHeal = 0,
    dodgeTimer = 0,
    nextShoot = 0,
    speed = 1.5,
    cw = 8,
    ch = 8,
    invFrames = 0,
    frozenTime = 0,
    laserSfx = nil,
    kills = 0,
    killedBy = 0,
    survived = 0,
    score = 0,
    pilotStyle = ""
}

director = {
    maximumCredits = 0,
    credits = 8,
    difficulty = 1,
    enemyCredits = {1, 1, 2, 3, 4},
    eliteMultiplier = {0, 1, 2, 1},
    difficultyRating = {"Easy","Normal","Hard","Very Hard","Insane","Impossible","BRUTAL","HELLISH","APOCALYPSE"}
}

statistics = {
    low = 0,
    mid = 0,
    high = 0,
    shot = 0,
    missed = 0
}

gameMode = 1
menuSelector = 1
nameSelector = {65,65,65}
nameLetterSelector = 1
highScoreAchieved = false
newHighScoreIndex = 0
newHighScoreSet = false


buttonHeld = false
menuProp = {
    x = 0,
    y = 0,
    spr = 0,
    animFrame = 1
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
    {26, 28, 44}, -- black - 1
    {93, 39, 93}, -- dark red - 2
    {177, 62, 83}, -- red - 3 
    {239, 125, 87}, -- orange - 4
    {255, 205, 117}, -- yellow - 5
    {167, 240, 112}, -- bright green - 6
    {56, 183, 100}, -- green - 7
    {37, 113, 121}, -- khaki green - 8
    {41, 54, 111}, -- navy blue - 9
    {59, 93, 201}, -- blue - 10
    {65, 166, 246}, --light blue - 11
    {115, 239, 247}, -- cyan - 12
    {244, 244, 244}, -- white - 13
    {148, 176, 194}, -- light gray - 14
    {86, 108, 134}, -- gray - 15
    {51, 60, 87} -- dark gray - 16
}

eliteColors = {
    5, -- yellow
    4, -- orange
    10 --light blue
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
enemyShootSfx = nil
experienceSprites = {nil, nil}
eliteIndicator = {nil, nil, nil}
selectorSprite = {nil, nil}
frozenBulSprite = nil

upgradeSprites = {}
explosionAreas = {}
textBubbles = {}
hazards = {}
names = {"rocket","afterburner","Chain reloader","ion shield","repair bot","mini turrets","anit-matter ammo","improved plating","hologram module","explosive rounds","tesla pylons","bullet defense"}
effects = {"fires seeking missiles","movement speed +","attack speed +","recharging shield","hull regeneration","more bullets","increase damage","reduce incoming damage","chance to dodge attacks","AOE damage","close range zaps","kill close bullets"}
levelUpgrades = {}
upgradeIndicator = 0
upgradeSelectorSprite = nil
levelUp = false
ticks = 0
webBuild = false

highScores = {}
 
audioManager = {
    backgroundMusic = nil,
    menu = {
        open = false,
        step = nil,
        upgradeActivated = nil,
        xpReached = nil
    }
}

function love.load()

    love.graphics.setDefaultFilter('nearest','nearest',0)

    --window = {translateX = 40, translateY = 40, scale = 1, width = 1920, height = 1080}
	--width, height = love.graphics.getDimensions ()
    love.window.setMode (960, 548, {resizable=true, borderless=false})
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

    menuProp.spr = enemySprites[math.random(1,5)]

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
    frozenBulSprite = love.graphics.newImage("gfx/particles/frozenBul.png")

    for i=1,3 do
        eliteIndicator[i] = love.graphics.newImage("gfx/ui/eliteInd_"..i..".png")
    end

    selectorSprite[1] = love.graphics.newImage("gfx/ui/selectorUp.png")
    selectorSprite[2] = love.graphics.newImage("gfx/ui/selectorDown.png")
    --love.graphics.setCanvas(gameCanvas)
    --love.graphics.setCanvas()

    -- load sounds
    player.laserSfx = love.audio.newSource("sfx/player/sfx.wav", "static")
    enemyShootSfx = love.audio.newSource("sfx/enemies/enemy_shoot.wav", "static")

    myFont = love.graphics.newFont('gfx/BMmini.TTF', 8)

    startTime = love.timer.getTime( )
    load_high_scores()
    setAudio()
end

function setAudio()
    audioManager.backgroundMusic = love.audio.newSource("sfx/bg_music/mainTheme.wav", "stream")
    audioManager.backgroundMusic:setVolume(0.2)

    audioManager.menu.step = love.audio.newSource("sfx/ui/menuStep.wav", "static")
    audioManager.menu.step:setVolume(0.2)
    audioManager.menu.upgradeActivated = love.audio.newSource("sfx/ui/upgradeActivated.wav", "static")
    audioManager.menu.upgradeActivated:setVolume(0.2)
    audioManager.menu.xpReached = love.audio.newSource("sfx/ui/xpReached.wav", "static")
    audioManager.menu.xpReached:setVolume(0.2)


    love.audio.setEffect("effectsOFF", {type="compressor", enable=false})
    love.audio.setEffect("chorusEffect", {type="chorus", waveform="sine", rate=5, depth=.5})
    love.audio.setEffect("bandPass", {
        type="equalizer",
        lowgain=0,
        lowcut=500,
        lowmidgain=1,
        --lowmidfrequency=1,
        --lowmidbandwidth=1,
        highmidgain=0,
        --highmidfrequency=1,
        highmidfrequency=2000,
        highgain=0,
        highcut=4000,
    })
    --audioManager.backgroundMusic:setEffect("bandPass")
    --audioManager.backgroundMusic:setFilter{ type="bandpass", highgain=.2, volume=0.5 } -- This volume 
    --audioManager.backgroundMusic:setFilter( )
    --only affects the dry sound.
end


function xpMenuOpen()
    audioManager.backgroundMusic:setFilter{ type="bandpass", highgain=.2, volume=0.5 }
    audioManager.menu.xpReached:play()
    audioManager.menu.open = true
end

function xpMenuClosed()
    audioManager.backgroundMusic:setFilter( )
    audioManager.menu.upgradeActivated:play()
    audioManager.menu.open = false
end

function split(source, delimiters)
    local elements = {}
    local pattern = '([^'..delimiters..']+)'
    string.gsub(source, pattern, function(value) elements[#elements + 1] =     value;  end);
    return elements
end

function load_high_scores()
    if not (webBuild) then
        local returnInfo = love.filesystem.getInfo("save/data.sav","file")
        
        if not (returnInfo == nil) then
            local hsArray = {}
            local highScoresString = love.filesystem.read("save/data.sav", returnInfo.size)
            hsArray = split(highScoresString, ';')
            for _,hs in ipairs(hsArray) do
                local individualHighScore = split(hs, ',')
                local highScoreVal = {
                    name = individualHighScore[1],
                    score = tonumber(individualHighScore[2]),
                    style = individualHighScore[3]
                }
                table.insert(highScores, highScoreVal)
            end
        else
            for i=1,5 do
                local hs = {
                    name = "empty",
                    score = 0,
                    style = "unknown style"
                }
                table.insert(highScores, hs)
            end
        end

        save_high_score()
    else
        for i=1,5 do
            local hs = {
                name = "EMP",
                score = 0,
                style = "unknown style"
            }
            table.insert(highScores, hs)
        end
    end
end

function compare(a,b)
    return a.score > b.score
end

function save_high_score()
    table.sort(highScores, compare)
    local hsText = ""
    for _,hs in ipairs(highScores) do
        hsText = hsText..hs.name..","..hs.score..","..hs.style..";"
    end
   
    local suc = love.filesystem.createDirectory("save")

    suc,msg = love.filesystem.write("save/data.sav", hsText)
    if suc then
        print("done")
    else
        print("Error: "..msg)
    end
end

function reset()
    player.x = 64
    player.y = 64
    player.hp = 100
    player.maxHp = 100
    player.nextShot = 0
    player.shotCooldown = 30
    player.flash = 0
    player.lean = 0
    player.exhaustIndex = 1
    player.xp = 0
    player.level = 1
    player.upgrades = {0,0,0,0,0,0,0,0,0,0,0,0}
    player.reloadSpeed = 0
    player.dodgeChance = 0
    player.pylonRange = 0
    player.explosionRange = 0 
    player.antiBulletRange = 0
    player.nextPylon = 0
    player.nextAntiBullet = 0
    player.nextRockets = 0
    player.hasShield = false
    player.timeUntilShields = 0
    player.dodgeTimer = 0
    player.nextShoot = 0
    player.invFrames = 0
    player.frozenTime = 0
    player.kills = 0
    player.killedBy = 0
    player.survived = 0
    score = 0
    pilotStyle = ""

    director.maximumCredits = 0
    director.credits = 8
    director.difficulty = 1
    

    statistics.low = 0
    statistics.mid = 0
    statistics.high = 0
    statistics.shot = 0
    statistics.missed = 0

    nameSelector = {65,65,65}
    nameLetterSelector = 1
    highScoreAchieved = false
    newHighScoreIndex = 0
    newHighScoreSet = false

    startTime = love.timer.getTime( )
    particles = {}
    bullets = {}

    enemies = {}
    enemyBullets = {}
    experience = {}

    explosionAreas = {}
    textBubbles = {}
    hazards = {}
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
	local circDX = math.abs(_circ.x - _obj.x - _obj.cw/2)
	local circDY = math.abs(_circ.y - _obj.y - _obj.ch/2)
	
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

function add_enemy_bul(_x,_y,_sx,_sy, _tpe, _source, _damage)
    if _tpe == nil then _tpe = 0 end
	local bul = {
		x = _x,
		y = _y,
		sx = _sx,
		sy = _sy,
		cw = 4,
		ch = 4,
        animFrame = 1,
        tpe = _tpe,
        source = _source,
        damage = _damage
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
		x = love.math.random(200),
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

function add_enemy(_x,_tpe,_family, _elite)
    local movements = {"downward", "sinus", "left-right", "downward", "left-right"}
    local bulDamages = {2,3,4,2,2}
    local shotCooldowns = {240, 60, 50, 90, 5}
    local hpNumber =  math.floor(2*(1+_tpe)*(1+director.difficulty))*10
    local shotCalc = math.floor(shotCooldowns[_tpe]/math.max((1+(director.difficulty)),0.15))
	local enemy = {
		x = _x,
		y = -4,
		sx = 0,
		sy = 0.2,
		cw = 8,
		ch = 8,
		sprite = enemySprites[(_family*5)+_tpe],
        animFrame = 1,
		maxHp = hpNumber,
        hp = hpNumber,
		tpe = _tpe,
		isTarget = false,
		nextShoot = 0,
		shoot = 0,
		shootingInterval = 0,
        shotCooldown = shotCalc,
		isShooting = false,
		damaged = 0,
        bulDamage = math.floor(bulDamages[_tpe] * director.difficulty),
		invFrames = 0,
		elite = _elite,
        movement = movements[_tpe],
        dir = "",
        credits = director.enemyCredits[_tpe] * (1+director.eliteMultiplier[_elite+1]) 
	}

	
	if enemy.tpe == 5 then enemy.shootingInterval = 60 end
    if enemy.movement == "left-right" then
        if love.math.random() > 0.5 then
            enemy.dir = "left"
        else
            enemy.dir = "right"
        end
    end
	table.insert(enemies, enemy)
end

function add_enemy_hazard (_x, _y, _r, _tpe, _age, _damage, _source)
    local hazard = {
        x = _x,
        y = _y,
        r = _r,
        tpe = _tpe,
        age = _age,
        damage = _damage*10,
        source = _source
    }
    table.insert(hazards, hazard)
end

function add_background()
    if ticks% 10 == 0 then
        add_stars(8)
    end

    if ticks% 20 == 0 then
        add_stars(13)
    end
end

local tickPeriod = 1/60
local accumulator = 0.0

function love.update(dt)

    accumulator = accumulator+dt
    
    if not audioManager.backgroundMusic:isPlaying( ) then 
        audioManager.backgroundMusic:play()
    end

    if accumulator >= tickPeriod then
        ticks= ticks+ 1
        if gameMode == 1 then
            update_menu()
        elseif gameMode == 2 then
            update_game()
        elseif gameMode == 3 then
            update_tutorial()
        elseif gameMode == 4 then
            update_highscores()
        elseif gameMode == 5 then
            update_credits()
        elseif gameMode == 6 then
            love.event.quit(0)
        elseif gameMode == 7 then
            update_game_over()
        elseif gameMode == 8 then
            update_new_highscore()
        end

        accumulator = accumulator - tickPeriod
    end -- tick accumulation
end

function update_credits()
    add_background()
    if love.keyboard.isDown("c") then
        gameMode = 1
        buttonHeld = true
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
end

function update_menu()

    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        if buttonHeld == false then
            menuSelector = menuSelector - 1
        end
        buttonHeld = true
    elseif love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        if buttonHeld == false then
            menuSelector = menuSelector + 1
        end
        buttonHeld = true
    else
        buttonHeld = false
    end

    if menuSelector > 5 then menuSelector = 1 end
    if menuSelector < 1 then menuSelector = 5 end

    if love.keyboard.isDown("x") then
        gameMode = menuSelector + 1 
    end

    add_background()
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

    menuProp.x = menuProp.x + math.sin(math.rad(ticks))/2
    menuProp.y = menuProp.y + 1
    if ticks%15 == 0 then
        menuProp.animFrame = menuProp.animFrame + 1
        if menuProp.animFrame > 2 then
            menuProp.animFrame = 1
        end
    end
    if menuProp.y > 140 then
        menuProp.y = -2
        menuProp.x = math.random(20,200)
        menuProp.spr = enemySprites[math.random(1,5)]
    end
end

function update_tutorial()
    add_background()

    if love.keyboard.isDown("c") then
        if not buttonHeld then
            gameMode = 1
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
end

function update_new_highscore()
    add_background()
    if love.keyboard.isDown("left") then
        if buttonHeld == false then
            nameLetterSelector = nameLetterSelector - 1
            buttonHeld = true
        end
    elseif love.keyboard.isDown("right") then
        if buttonHeld == false then
            nameLetterSelector = nameLetterSelector + 1
            buttonHeld = true
        end
    elseif love.keyboard.isDown("up") then
        if buttonHeld == false then
            nameSelector[nameLetterSelector] = nameSelector[nameLetterSelector] - 1
            buttonHeld = true
        end
    elseif love.keyboard.isDown("down") then
        if buttonHeld == false then    
            nameSelector[nameLetterSelector] = nameSelector[nameLetterSelector] + 1
            buttonHeld = true
        end
    elseif love.keyboard.isDown("c") then
        if not buttonHeld then
            local name = string.char(nameSelector[1])..string.char(nameSelector[2])..string.char(nameSelector[3])
            highScores[newHighScoreIndex].name = name
            gameMode = 1
            if not (webBuild) then
                save_high_score()  
            end
            reset()
        end
    else
        buttonHeld = false
    end 

    if nameLetterSelector > 3 then
        nameLetterSelector = 1
    elseif nameLetterSelector < 1 then
        nameLetterSelector = 3
    end

    if nameSelector[nameLetterSelector] > 90 then
        nameSelector[nameLetterSelector] = 65
    elseif nameSelector[nameLetterSelector] < 65 then
        nameSelector[nameLetterSelector] = 90
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
end

function update_highscores()
    add_background()
    if love.keyboard.isDown("c") then
        gameMode = 1
        buttonHeld = true
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
end

function update_game_over()
    add_background()
    if love.keyboard.isDown("c")then
        if buttonHeld == false then
            if highScoreAchieved then
                gameMode = 8
            else
                gameMode = 1
                reset()
            end
            buttonHeld = true
        end
    end
    if ticks%15 == 0 then
        menuProp.animFrame = menuProp.animFrame + 1
        if menuProp.animFrame > 2 then
            menuProp.animFrame = 1
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
end

function update_game()
    if ticks % 600 == 0 then
        director.difficulty = director.difficulty + 0.1
    end

    if ticks % 1200 == 0 then
        director.credits = director.credits + 1
    end

    if (player.xp >= player.level*2) and (not levelUp) then
        for i=0,3 do
            table.insert(levelUpgrades,love.math.random(0,10))
        end
        levelUp = true
        player.xp = 0
        player.level = player.level+1
    end


    if levelUp then
        if(not audioManager.menu.open) then
            xpMenuOpen()
        end
        if love.keyboard.isDown("c") then
            if(audioManager.menu.open) then
                xpMenuClosed()
            end
            levelUp = false
            
            local choosenUpgrade = levelUpgrades[upgradeIndicator]
            player.upgrades[choosenUpgrade+1] = player.upgrades[choosenUpgrade+1]+1
            levelUpgrades = {}
        elseif love.keyboard.isDown("w") or love.keyboard.isDown("up") then
            if released then
                upgradeIndicator = upgradeIndicator-1
                audioManager.menu.step:play()
                released = false
            end
        elseif love.keyboard.isDown("s") or love.keyboard.isDown("down") then
            if released then
                upgradeIndicator = upgradeIndicator+1
                audioManager.menu.step:play()
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

        add_background()

        if (ticks% 10 == 0) and (not (player.frozenTime > 0)) then
            for i=0,1 do
                add_particle(player.x+2, player.y+8, 0, 2, 2, "dot")
                add_particle(player.x+4, player.y+8, 0, 2, 2, "dot")
                add_particle(player.x+2, player.y+9, 0, 2, 4, "dot")
                add_particle(player.x+4, player.y+9, 0, 2, 4, "dot")
            end
        end

        if ticks% 5 == 0 then
            player.exhaustIndex = player.exhaustIndex + 1
            if player.exhaustIndex > 4 then
                player.exhaustIndex = 1
            end
        end

        local newPx, newPy = player.x,player.y
        local frozenMod = 1
        if player.frozenTime > 0 then frozenMod = 5 end
        player.lean = 0
        if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
            newPy = player.y - player.speed / frozenMod
        end
        if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
            newPy = player.y + player.speed / frozenMod
        end
        if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
            newPx = player.x - player.speed / frozenMod
            player.lean = -1
        end
        if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
            newPx = player.x + player.speed / frozenMod
            player.lean = 1
        end
        if love.keyboard.isDown("g") then
            player.xp = player.level*2
        end

        local newLoc = {
            x = newPx,
            y = newPy,
            cw = 8,
            ch = 8
        }
        if (not out_of_bounds(newLoc)) then
            player.x = newPx
            player.y = newPy
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
            if love.math.random() > 0.5 then side = 1 end
            add_text_bubble(player.x-4+(side*love.math.random(10,15)),player.y+4+love.math.random(-2,2),side/2,love.math.random(),"pew",2,4,15)
            --player.laserSfx:setPitch(math.random(0.5,1))
            player.laserSfx:play()

            statistics.shot = statistics.shot + 1
        end

        if player.nextShot > 0 then
            player.nextShot = player.nextShot - 1
        end

        if player.flash > 0 then
            player.flash = player.flash - 1
        end

        if player.dodgeTimer > 0 then
            player.dodgeTimer = player.dodgeTimer - 1
        end
        
        if player.invFrames > 0 then
            player.invFrames = player.invFrames - 1
        end

        if player.frozenTime > 0 then
            player.frozenTime = player.frozenTime - 1
        end
        
        if ticks%60 == 0 then
            spawn_enemy()

            --statistics check
            if player.y < 45 then
                statistics.low = statistics.low + 1
            elseif (45 < player.y) and (player.y < 90) then
                statistics.mid = statistics.mid + 1
            else
                statistics.high = statistics.high + 1
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

        for _,xp in ipairs(experience) do
            xp.y = xp.y + 1
            if collide(player, xp) then
                player.xp = player.xp + xp.val
                player.score = player.score + xp.val * 10
                table.remove(experience,_)
            end
            
            if xp.y > 140 then
                xp.y = -4
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
                add_particle(expl.x+4,expl.y+4,love.math.random(0,spd)*2-spd, love.math.random(0,spd)*2-spd,love.math.random(1,3),"expl",love.math.random(0,1),5)
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

        if (ticks%10 == 0) and (math.random() > 0.3) and (player.frozenTime > 0) then
            local side = -1
            if love.math.random() > 0.5 then side = 1 end
            add_text_bubble(player.x-4+(side*love.math.random(10,15)),player.y+4+love.math.random(-2,2),side/2,love.math.random(),"brrr",8,11,15)
        end

        update_particles()
        update_bullets()
        update_enemies()
        update_upgrades()
        update_hazards()
    end
end

function spawn_enemy()
    local tryNumber = 5
    local tries = 0
    local elite = 0
    local randomEnemyToSpawn = 0
    repeat
        elite = love.math.random(0,3)
        randomEnemyToSpawn = love.math.random(1,5)
        tries = tries + 1
    until (director.credits - (director.enemyCredits[randomEnemyToSpawn] * (1+director.eliteMultiplier[elite+1]))  > 0) or (tries > tryNumber)

    if not (tries > tryNumber) then
        director.credits = director.credits - director.enemyCredits[randomEnemyToSpawn] * (1+director.eliteMultiplier[elite+1]) 

        add_enemy(love.math.random(0, 192),randomEnemyToSpawn, 0, elite)
    end
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
	
    if player.timeUntilHeal > 0 then
        player.timeUntilHeal = player.timeUntilHeal - 1
    end

	if player.upgrades[4] > 0 then
		player.hasShield = true
		player.maxShield = player.upgrades[4]*10
		player.timeUntilShields = player.timeUntilShields -1
		if player.timeUntilShields < 0 then
			if player.shield < player.maxShield then
				player.shield = player.shield + 0.1
			end
            if player.shield > player.maxShield then
                player.shield = player.maxShield
            end
			player.timeUntilShields = 0
		end
        if player.shield < 0 then
            player.shield = 0
        end
	end
	
    -- rockets
	if (player.nextRockets == 0) then
        if player.upgrades[1] > 0 then
            local dir = 1
            if love.math.random() < 0.5 then
                dir = -1
            end
            
            for i=1,player.upgrades[1] do
                add_player_bul(player.x,player.y,2*dir+love.math.random(3),love.math.random(3),1,true)
            end
        end
        player.nextRockets = 90
    end
	
    -- repair bots
    if (player.timeUntilHeal == 0) then
        local nanoBotHeal = 1
        if player.upgrades[5] > 0 then
            nanoBotHeal = nanoBotHeal + player.upgrades[5]
        end
        if ticks%60 == 0 then
            player.hp = player.hp + nanoBotHeal
            if player.hp > player.maxHp then
                player.hp = player.maxHp
            end
        end
    end               
end

--[[
    Enemy elite types:
    0 - normal
    1 - lightning -> attack and movement speed
    2 - flaming -> flaming trail
    3 - freezing -> bullets slow player

]]--

function update_enemies()
    for _,enemy in ipairs(enemies) do
        local status = 0
        
        if (enemy.elite == 3) then
            status = 1
        end

        move_enemy(enemy)

        if enemy.y > 136 then
            enemy.y = -2
        end
    
        if enemy.hp <= 0 then
			local spd = 2
			local colorMap = {7,2,4,3,9}
			for i=0,5 do
				add_particle(enemy.x+4,enemy.y+4,love.math.random(0,spd)*2-spd, love.math.random(0,spd)*2-spd,colorMap[enemy.tpe],"expl",love.math.random(1,3),30)
			end
			add_xp(enemy.x, enemy.y, enemy.tpe+1)
            director.credits = director.credits + enemy.credits
			table.remove(enemies,_)
            player.kills = player.kills+1
            player.score = player.score + enemy.tpe*10
		end

        if ticks%15 == 0 then
            enemy.animFrame = enemy.animFrame + 1
            if enemy.animFrame > 2 then
                enemy.animFrame = 1
            end
        end

        if enemy.nextShoot > 0 then
            local multiplier = 1
            if enemy.elite == 1 then
                multiplier = 2
            end

			enemy.nextShoot = enemy.nextShoot - 1 * multiplier
            if enemy.nextShoot < 0 then
                enemy.nextShoot = 0
            end
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

       
		
		for _,bul in ipairs(bullets) do
            if collide(bul, enemy) then
                local damage = 10
                if bul.tpe == 10 then damage = 20 end
                damage_enemy(enemy, damage)
                
                -- explosive rounds
                
                table.remove(bullets,_)
                if (player.upgrades[10] > 0) and (bul.tpe == 0) then
                    add_explosion(enemy.x+4,enemy.y+4,player.explosionRange)
                    local side = -1
                    if love.math.random() > 0.5 then side = 1 end
                    add_text_bubble(enemy.x-4+(side*love.math.random(10,15)),enemy.y+4+love.math.random(-2,2),side/2,love.math.random(),"BOOM",8,2,15)
                end
            end
		end
		
		-- check explosive area		
		for id,expl in ipairs(explosionAreas) do
			if close_enough(enemy,expl,player.explosionRange) then
				if collidec(expl,enemy) then
					damage_enemy(enemy,5)
				end
			end
		end

        if enemy.shoot > 0 then
			enemy.shoot = enemy.shoot - 1
		end
		
        if enemy.tpe == 1 then
            if enemy.nextShoot == 0 then
                add_enemy_bul(enemy.x+4,enemy.y,0,1, status, enemy.tpe, enemy.bulDamage)
                enemy.nextShoot = enemy.shotCooldown
				enemy.shoot = 10
                enemyShootSfx:play()
            end
        end

		if enemy.tpe == 2 then
			if enemy.nextShoot == 0 then
				add_enemy_bul(enemy.x+4,enemy.y,0,1.5, status, enemy.tpe, enemy.bulDamage)
				enemy.nextShoot = enemy.shotCooldown
				enemy.shoot = 3
                enemyShootSfx:play()
				--sfx(1,nil,-1,0)
			end
		end
		
		if enemy.tpe == 3 then
			if enemy.nextShoot == 0 then
				local angle = math.atan2(enemy.y - player.y, enemy.x - player.x)
				local bsx = -math.cos(angle)
				local bsy = -math.sin(angle)
				add_enemy_bul(enemy.x,enemy.y,bsx,bsy, status, enemy.tpe, enemy.bulDamage)
				enemy.nextShoot = enemy.shotCooldown
				enemy.shoot = 3
                enemyShootSfx:play()
				--sfx(1,nil,-1,0)
			end
		end
		
		if enemy.tpe == 4 then
			if enemy.nextShoot == 0 then
				for i=-math.pi,math.pi,0.5 do
					add_enemy_bul(enemy.x, enemy.y+4, math.sin(i), math.cos(i), status, enemy.tpe, enemy.bulDamage)
				end
				enemy.nextShoot = enemy.shotCooldown
				enemy.shoot = 3
                enemyShootSfx:play()
				--sfx(1,nil,-1,0)
			end
		end
	
		if enemy.tpe == 5 then
			if (enemy.nextShoot == 0)and (enemy.isShooting) then
				local a = math.sin(math.rad(ticks*2))
				local b = math.cos(math.rad(ticks*2))
				add_enemy_bul(enemy.x+4, enemy.y+4,  a/2, b/2, status, enemy.tpe, enemy.bulDamage)
				add_enemy_bul(enemy.x+4, enemy.y+4,  -a/2, -b/2, status, enemy.tpe, enemy.bulDamage) 
				enemy.nextShoot = 3
				enemy.shoot = 2
                enemyShootSfx:play()
			 --sfx(1,nil,-1,0)
			end
		end

        -- flaming elite
        if (enemy.elite == 2) and (love.math.random() > 0.7) then
            add_enemy_hazard(enemy.x+4, enemy.y, 1.5, 1, 300, 1, enemy.tpe)
        end
        -- lightning elite
        if enemy.elite == 1 and (love.math.random() > 0.8) then
            add_particle(enemy.x+4, enemy.y+4, love.math.random(-2,2), love.math.random(-2,2), 4, "expl", love.math.random(0.1,0.5), 10)
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

function move_enemy(enemy)
    -- {"downward", "follow", "left-right", "downward", "left-right"}
    local movement = enemy.movement
    local eliteMultiplier = 1
    if enemy.elite == 1 then
        eliteMultiplier = 1.5
    end
    if movement == "downward" then
        enemy.sy = 0.5
        enemy.sx = math.sin(math.rad(ticks))/5
    elseif movement == "left-right" then
        if enemy.dir == "left" then
            enemy.sx = 0.5
            if enemy.x+enemy.sx >= 192 then
                enemy.dir = "right"
            end
        else
            enemy.sx = -0.5
            if enemy.x+enemy.sx <= 0 then
                enemy.dir = "left"
            end
        end
        enemy.sy = 0.1
    elseif movement == "sinus" then
        enemy.sx = math.sin(math.rad(ticks))/2
    end

    if not (enemy.shotCooldown < 0.5) then
        if not (enemy.shoot > 0) and (not enemy.isShooting) then
            if not ((enemy.x + enemy.sx <= 0) or (enemy.x+enemy.sx > 192)) then
                enemy.x = enemy.x + enemy.sx*eliteMultiplier
            end
            enemy.y = enemy.y + enemy.sy*eliteMultiplier
        end
    else
        if not ((enemy.x + enemy.sx <= 0) or (enemy.x+enemy.sx > 192)) then
            enemy.x = enemy.x + enemy.sx*eliteMultiplier
        end
        enemy.y = enemy.y + enemy.sy*eliteMultiplier
    end
end

function update_hazards()
    for _,hazard in ipairs(hazards) do
        hazard.age = hazard.age - 1
        if hazard.age <= 0 then
            table.remove(hazards,_)
        end

        -- flame trail
        if hazard.tpe == 1 then
            if collidec(hazard, player) then
                hit_player(math.floor(hazard.damage*director.difficulty),"",hazard.source)
            end
            if love.math.random() > 0.8 then
                add_particle(hazard.x, hazard.y, 0.2, 0.2, love.math.random(1,3), "expl", hazard.r, 2)
            end
        end

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

function out_of_bounds(obj)
    if (obj.y+obj.ch > 140) or 
       (obj.y <0) or
       (obj.x <0) or 
       (obj.x+obj.cw > 200) then
        return true
    end
    return false
end

function update_bullets ()
    for _,bul in ipairs(bullets) do
		if bul.tpe == 0 then
			bul.x = bul.x + bul.sx
			bul.y = bul.y + bul.sy
		elseif bul.tpe == 1 then	
			bul.x = bul.x + bul.sx
			bul.y = bul.y + bul.sy
			bul.sx = bul.sx * 0.9
			if (bul.sx < 0.1) and (bul.target == nil) and (#enemies > 0) then
				local randIndex = love.math.random(#enemies)
				bul.target = randIndex
				bul.targetSet = true
			end
			if not(enemies[bul.target] == nil) then
				local angle = math.atan2(bul.y - enemies[bul.target].y, bul.x - enemies[bul.target].x)
				bul.sx = -math.cos(angle)*3
				bul.sy = -math.sin(angle)*3
				enemies[bul.target].isTarget = true
			end
			add_particle(bul.x+1,bul.y+1,0,0,12,"dot",1,love.math.random(8,10))
		elseif bul.tpe == 2 then
			bul.x = bul.x + bul.sx
			bul.y = bul.y + bul.sy
			add_particle(bul.x,bul.y,love.math.random(),love.math.random(),11,"dot",love.math.random(1,2),10)		
		elseif bul.tpe == 3 then
			bul.x = bul.x + bul.sx
			bul.y = bul.y + bul.sy
			if close_enough(bul,bul.goal,6) then
				table.remove(bullets,_)
			end
		end
        if out_of_bounds(bul) and (not (bul.tpe == 1)) then
			table.remove(bullets,_)
            statistics.missed = statistics.missed + 1
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

		if out_of_bounds(ebul) then
			table.remove(enemyBullets,_)
		end
		
        if ebul.tpe == 1 then
            add_particle(ebul.x+2,ebul.y+2,love.math.random()/10,0,8,"dot",love.math.random(1,2),15)
        end

		if collide(ebul,player) then
			table.remove(enemyBullets,_)
            local status = ""
            if ebul.tpe == 1 then status = "frozen" end
			hit_player(ebul.damage, status, ebul.source)
		end	
	end
end

function hit_player(_damage, _status, _source)
    if _status == nil then _status = "" end

    if player.invFrames == 0 then
        local rng = love.math.random()
        if rng > player.dodgeChance then
            if (player.hasShield) and (player.shield > 0) then
                player.shield = player.shield - _damage
                player.timeUntilShields = 150
            else	
                player.hp = player.hp - _damage*(1-player.upgrades[8]/10)
            end
            player.invFrames = 10
            player.timeUntilHeal = 60
            if _status == "frozen" then
                player.frozenTime = 90
                 local side = -1
                if love.math.random() > 0.5 then side = 1 end
                add_text_bubble(player.x-4+(side*love.math.random(10,15)),player.y+4+love.math.random(-2,2),side/2,love.math.random(),"FROZEN",10,1,15)
            end
        else
            player.dodgeTimer = 10
        end
    end

    if player.hp <= 0 then
        gameMode = 7
        menuProp.spr = enemySprites[_source]
        player.survived = time()
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
    love.graphics.clear(26/255, 28/255, 44/255, 1)
     if gameMode == 1 then
        draw_menu()
    elseif gameMode == 2 then
        draw_game()
    elseif gameMode == 3 then
        draw_tutorial()
    elseif gameMode == 4 then
        draw_highscores()
    elseif gameMode == 5 then
        draw_credits()
    elseif gameMode == 7 then
        draw_game_over()
    elseif gameMode == 8 then
        draw_new_highscore()
    end
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

function printTextCentered(_txt,_posX,_posY,_clr)
    draw_color(_clr)
    love.graphics.printf(_txt, _posX, _posY, 999, "center")
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

function draw_game_over()
    draw_stars()
    
    if ticks%20 > 10 then
        draw_color(1)
        love.graphics.print("Game Over", myFont, 10, 10, 0, 2, 2)
        reset_color()
    end

    -- stats
    local positionStyleText = {"Eager","Brave","Cautious"}
    local shootingStyleText = {"Trainee","Marksman","Deadeye"}
    local positionStyle = 1
    if (statistics.mid > statistics.low) and (statistics.mid >= statistics.high) then
        positionStyle = 2
    elseif (statistics.high > statistics.low) and (statistics.high > statistics.mid) then
        positionStyle = 3
    end
    local shootStyle = 1
    local shootStyleRatio = statistics.missed / statistics.shot
    if  shootStyleRatio < 0.2 then
        shootStyle = 3
    elseif shootStyleRatio < 0.5 then
        shootStyle = 2
    end

    player.pilotStyle = positionStyleText[positionStyle].." "..shootingStyleText[shootStyle]
    printText("Pilot Style: "..player.pilotStyle, 20, 30, 5)
    printText("Pews Pewed: "..statistics.shot, 20, 38, 5)
    printText("Parsecs Travelled: "..(math.floor(player.survived*math.pi)), 20, 46, 5)
    printText("Enemeis Defeated: "..player.kills, 20, 54, 5)
    printText("Survived: "..math.floor(player.survived).." s", 20, 62, 5)




    -- TODO
    -- Pews Pewed
    -- parsecs travelled -> number of stars rendered counted somehow
    -- https://shmups.wiki/library/Progear_no_Arashi

    -- ugprade list
    local upDraw = 0
	for _,up in ipairs(player.upgrades) do
		if not(player.upgrades[_] == 0) then
			local vOff = 0
			if _ > 10 then
				vOff = 20
				upDraw = (_-11)*10
			end
			love.graphics.draw(upgradeSprites[_],202+vOff,20+upDraw,0)
			printText(up,210+vOff,20+upDraw,5)
            upDraw = upDraw + 10
		end
	end

    printText("Killed by: ", 170, 6, 2)
    menuProp.x = 220
    menuProp.y = 6
    love.graphics.draw(menuProp.spr[menuProp.animFrame], 220, 6, 0, 1, 1)
    printText("Press C to menu", 160, 114, 5)

    if (not newHighScoreSet) then
        highScoreAchieved = false
    end
    for _,hs in ipairs(highScores) do
        if (player.score > hs.score) and (not newHighScoreSet) then
          
            highScoreAchieved = true
            newHighScoreIndex = _
            
            newHighScores = highScores
            for i=#newHighScores,newHighScoreIndex do
                if i > 1 then
                    newHighScores[i] = newHighScores[i-1]
                end
            end
            highScores = newHighScores
            
            newHighScoreSet = true
            hs.score = player.score
            hs.style = player.pilotStyle
            
            break
        end
    end
    if not (newHighScoreSet) then
        printText("Final Score: "..player.score, 10, 114, 5)
    else
        if ticks%60 > 30 then
            printText("New High Score! "..player.score, 10, 114, 5)
        end
    end
end

function draw_tutorial()
    draw_stars()
    printText("Coming soon", 10, 10, 5)
    printText("Press C to menu", 160, 114, 5)
end

function draw_new_highscore()
    draw_stars()
    draw_color(5)
    love.graphics.print("New HighScore!!!", myFont, 10, 10, 0, 2, 2)
    reset_color()

    printText("Enter Pilot Name:", 20, 30, 5)

    for _,hs in ipairs(highScores) do

        if not (_==newHighScoreIndex) then
            printText(_..". "..hs.name.." - "..hs.score.." - "..hs.style, 20, 30+_*15, 7)
        else
            if ticks%20 > 10 then
                printText(_..". ", 20,30+_*15, 5)
            end
            for i=1,3 do
                printText(string.char(nameSelector[i]), 22+i*10, 30+_*15, 5)
            end
            printText(" - "..player.score.." - "..player.pilotStyle, 58, 30+_*15, 5)
            love.graphics.draw(selectorSprite[1], 20+nameLetterSelector*10, 22+_*15)
            love.graphics.draw(selectorSprite[2], 20+nameLetterSelector*10, 36+_*15)
        end
    end
    printText("Press C to confirm", 160, 114, 5)
end

function draw_menu()
    -- draw menu points
    draw_stars()
    love.graphics.draw(menuProp.spr[menuProp.animFrame], menuProp.x, menuProp.y, 0, 1, 1)

    local title = "Rogala"
    draw_color(5)
    love.graphics.print(title, myFont, 20, 40, 0, 2, 2)
    reset_color()

    local menuText = {"Start Game", "Tutorial", "HighScores", "Credits", "Quit Game"}
    for i=1,#menuText do
        local color = 5
        if (i == 5 ) then color = 2 end
        if (i == menuSelector) then
            if ticks%20 > 10 then
                printText(menuText[i], 40, 60+i*10, color)
            end
        else
            printText(menuText[i], 40, 60+i*10, color)
        end
    end
    
    local gameOptionIndex = (menuSelector + 1) - 2
    love.graphics.draw(upgradeSelectorSprite, 28, 60+menuSelector*10, 0, 1, 1)

    printText("Press X to select", 160, 114, 5)
end

function draw_highscores()
    draw_stars()
    printText("High Scores:", 10, 10, 5)
    for _,hs in ipairs(highScores) do
        printText(_..". "..hs.name.." - "..hs.score.." - "..hs.style, 20, 20+_*10, 5)
    end
    printText("Press C to menu", 160, 114, 5)
end

function draw_credits()
    draw_stars()
    draw_color(5)
    love.graphics.print("Credits", myFont, 10, 10, 0, 2, 2)
    reset_color()  

    printText("Thanks to my Kofi Supporters:", 20, 30, 5)
    printText("Csondi", 30, 40, 5)

    printText("Thanks to all the peeps from:", 20, 50, 5)
    printText("Lazy Devs Academy Community", 30, 60, 5)
    printText("Devtober 2022 Community", 30, 70, 5)
    printText("Love Community", 30, 80, 5)
    printText("Press C to menu", 160, 114, 5)
end

function draw_game(_ds)
   
    printText(director.difficultyRating[math.floor(director.difficulty)], 1, 128, 8)
    printText(player.score, 196-#tostring(player.score)*4, 128, 8)
   
    for _,expl in ipairs(explosionAreas) do
        draw_color(1)
		love.graphics.circle("line",expl.x,expl.y,expl.r/2)
        reset_color()
	end


    if player.dodgeTimer > 0 then
        for yInd=1,8 do
            local startPos = love.math.random(-15,0)
            local endPos = love.math.random(0,15)
            love.graphics.setLineStyle("rough")
            draw_color(11)
            love.graphics.line(player.x-startPos,player.y+yInd,player.x+endPos,player.y+yInd)
            reset_color()
        end
    else
        if player.frozenTime > 0 then
            draw_color(10)
            love.graphics.draw(player.sprites[2+player.lean], player.x+math.sin(math.random())*2, player.y, 0, 1, 1)
        else
            love.graphics.draw(player.sprites[2+player.lean], player.x, player.y, 0, 1, 1)
        end
        if player.flash > 0 then
            love.graphics.draw(bulletFlash, player.x, player.y-2, 0, 1, 1)
        end

        if not (player.frozenTime > 0) then
            love.graphics.draw(player.exhaust[player.exhaustIndex], player.x+player.lean, player.y+8, 0, 1, 1)
        end

        if player.frozenTime > 0 then
            reset_color()
        end
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
    draw_color(7)
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
		if ticks%20 > 10 then	
            local lvlString = "--- level up ---"
			printText(lvlString,100-#lvlString*2,20,5)
            love.graphics.draw(upgradeSelectorSprite,15,20+upgradeIndicator*20,0, 1, 1)		
	
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

function draw_health_bars()
    draw_color(5)
    love.graphics.rectangle("fill", 0, 124, 10, 1)
    love.graphics.rectangle("fill", 10, 120, 32, 8)
    draw_color(1)
    love.graphics.rectangle("fill", 11, 121, 30, 6)
    draw_color(2)
    love.graphics.rectangle("fill", 11, 121, 30*(player.hp/player.maxHp), 6)
    printText(player.hp.."/"..player.maxHp, 12, 121, 12)
    reset_color()
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

        -- draw elite indicator
        if enemy.elite > 0 then
            love.graphics.draw(eliteIndicator[enemy.elite], enemy.x-3, enemy.y-5, 0, 1, 1)
        end

        -- tesla plyon
        if (player.upgrades[11] > 0) and (player.nextPylon == 0) then
            if close_enough(enemy,player,player.pylonRange) then
                draw_color(11)
                love.graphics.setLineStyle("rough")
                love.graphics.line(player.x+4, player.y+4, enemy.x+4, enemy.y+4)
                reset_color()
                player.nextPylon = 10
                
                damage_enemy(enemy, 5 + player.upgrades[11])

                local zep = {"zip","zap","zop"}
                local side = -1
                if love.math.random() > 0.5 then side = 1 end
                add_text_bubble(player.x-4+(side*love.math.random(10,15)),player.y+4+love.math.random(-2,2),side/2,love.math.random(),zep[love.math.random(1,3)],12,10,15)

            
            end
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
        if ebul.tpe == 1 then
            love.graphics.draw(frozenBulSprite, ebul.x, ebul.y, 0, 1, 1)
        else
            love.graphics.draw(enemyBulletSprite[ebul.animFrame], ebul.x, ebul.y, 0, 1, 1)
        end
        for _,ebul in ipairs(enemyBullets) do

            if close_enough(ebul,player,player.antiBulletRange) and (player.nextAntiBullet == 0 ) and (player.upgrades[12] > 0) then
                draw_color(4)
                love.graphics.line(player.x+4,player.y+4,ebul.x,ebul.y)
                reset_color()
                add_particle(ebul.x,ebul.y,love.math.random(),love.math.random(),8,"expl",love.math.random(1,3),15)
                add_text_bubble(ebul.x,ebul.y,love.math.random(),love.math.random(),"nope",4,2,10)
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