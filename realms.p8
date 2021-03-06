pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--realms
--author: bombadil

--code referenced:
    --animations / composite sprites:
        --fishing minigame remake by makke & gruber
    --collisions:
        --collisions demo by zep


function _init()
    tile_size = 8
    sound_enabled = false
    --music(0,0,4)
    freeze = false
    advance_frame = false

    sprites = {}
    anims = {}
    logs = {}

    --////////////////////
    --composite sprites
    --////////////////////
    sprites['worm'] = _sprite(1,2,{38,54})
    sprites['knight_queen'] = _sprite(2,4,{64,65,80,81,96,97,112,113})


    --////////////////////
    --animations
    --////////////////////
    anims['player_down']  = _anim(_frame(_sprite(1,1,{9})).set)
    anims['player_right'] = _anim(_frame(_sprite(1,1,{10})).set)
    anims['player_left']  = _anim(_frame(_sprite(1,1,{12})).set)
    anims['player_up']  = _anim(_frame(_sprite(1,1,{11})).set)

    anims['player_charging_down'] = _anim(
        _frame(_sprite(1,2,{9,26}), {dur=0.1})
        .next({9,0}).set
    )
    anims['player_charging_up'] = _anim(
        _frame(_sprite(1,2,{36,11},1,2), {dur=0.1})
        .next({0,11}).set
    )
    anims['player_charging_right'] = _anim(
        _frame(_sprite(2,1,{32,33}), {dur=0.1})
        .next({32,0}).set
    )
    anims['player_charging_left'] = _anim(
        _frame(_sprite(2,1,{33,32},2,1,true), {dur=0.1})
        .next({0,32}).set
    )

    anims['player_charging_done_down'] = _anim(
        _frame(_sprite(1,2,{13,26})).set
    )
    anims['player_charging_done_up'] = _anim(
        _frame(_sprite(1,2,{36,15},1,2)).set
    )
    anims['player_charging_done_left'] = _anim(
        _frame(_sprite(2,1,{33,76},2,1,true)).set
    )
    anims['player_charging_done_right'] = _anim(
        _frame(_sprite(2,1,{76,33})).set
    )

    anims['player_attack_down'] = _anim(
        _frame(_sprite(1,2,{9,25}))
        .next({9,26})
        .next({9,27})
        .next({9,28}).set
    )

    anims['player_attack_right'] = _anim(
        _frame(_sprite(2,1,{29,30}))
        .next({32,33})
        .next({32,34}).set
    )

    anims['player_attack_left'] = _anim(
        _frame(_sprite(2,1,{30,29},2,1,true))
        .next({33,32})
        .next({34,32}).set
    )

    anims['player_attack_up'] = _anim(
        _frame(_sprite(1,2,{35,11},1,2))
        .next({36,11})
        .next({37,11}).set
    )

    anims['worm_down'] = _anim(
        {sprites['worm'],
        _frame(_sprite(1,2,{38,55}))},
        {loop=true}
    )

    anims['knight_queen_down'] = _anim(_frame(sprites['knight_queen_down']))

    anims['shadow_down'] = _anim(_frame(_sprite(1,1,{66})).set)
    anims['shadow_up'] = _anim(_frame(_sprite(1,1,{68})).set)
    anims['shadow_right'] = _anim(_frame(_sprite(1,1,{67})).set)
    anims['shadow_left'] = _anim(_frame(_sprite(1,1,{70})).set)

    anims['shadow_attack_down'] = _anim(
        _frame(_sprite(1,1,{66}), {dur=0.4, ymod=-0.3})
        .next({66,82}, {dur=0.1, ymod=4, width=1, height=2})
        .next({66,83}, {dur=0, ymod=3})
        .next({66,84})
        .next({66,85})
        .next({66}, {dur=0.2, ymod=0, height=1}).set,
        {is_attack = true}
    )

    anims['shadow_attack_up'] = _anim(
        _frame(_sprite(1,1,{68}), {dur=0.4, ymod=0.3})
        .next({102,68}, {dur=0.1, ymod=-4, height=2})
        .next({102,68}, {dur=0, ymod=-3})
        .next({86,68})
        .next({68}, {dur=0.2, ymod=0, height=1}).set,
        {is_attack = true}
    )

    anims['shadow_attack_right'] = _anim(
        _frame(_sprite(1,1,{67}), {dur=0.5, xmod=-0.3})
        .next({98,99}, {dur=0.1, xmod=4, width=2})
        .next({100,103}, {dur=0, xmod=3})
        .next({100,101})
        .next({67}, {dur=0.2, xmod=0, width=1}).set,
        {is_attack = true}
    )

    anims['shadow_attack_left'] = _anim(
        _frame(_sprite(1,1,{70}), {dur=0.5, xmod=0.3})
        .next({99,98}, {dur=0.1, xmod=-4, width=2, x_origin=2, flip_x=true})
        .next({103,100}, {dur=0, xmod=-3})
        .next({101,100})
        .next({70}, {dur=0.2, xmod=0, width=1, x_origin=1, flip_x=false}).set,
        {is_attack = true, flip_x=true}
    )

    anims['shadow_teleport'] = _anim(
        _frame(_sprite(1,1,{71}), {dur=0.1})
        .next({72}, {dur=0.1})
        .next({73})
        .next({0}, {dur=1, movement='pos', xpos=20})
        .next({74}, {dur=0.1})
        .next({75})
        .next({74})
        .next({75})
        .next({99, 98}, {dur=0, width=2, x_origin=2, flip_x=true})
        .next({33, 100})
        .next({34, 100})
        .next({70}, {dur=0.2, width=1, x_origin=1, flip_x=false}).set,
        {is_attack = true}
    )

    init_objects()

    anims['shadow_attack_down'].set_obj(enemy)
    anims['shadow_attack_up'].set_obj(enemy)
    anims['shadow_attack_right'].set_obj(enemy)
    anims['shadow_attack_left'].set_obj(enemy)
    anims['shadow_teleport'].set_obj(enemy)
end


function _update()

    if btnp(5) then
        freeze = not freeze
    end

    if btnp(4) and freeze then
        advance_frame = true
    end

    log('p:'..round(player.x,0)..', '..round(player.y,0))
    log('e:'..round(enemy.x,0)..', '..round(enemy.y,0))
    log(player.attack_power)
    if not freeze or (freeze and advance_frame) then
        handle_inputs()
        player.update()
        enemy.update()

        if freeze then advance_frame = false end
    end

    if player.dead then
        init_objects()
    end
end


function _draw()
    cls()

    camera(player.x - 64, player.y - 64)
    map(0,0)

    if player.y >= enemy.y + enemy.height / 2 then
        enemy.draw()
        player.draw()
    else
        player.draw()
        enemy.draw()
    end

    draw_hud()
    print_logs()
end


function init_objects()
    player = _player(19, 7)
    enemy = _enemy('shadow', 25, 8)
end


function draw_hud()
    local px = player.x
    local py = player.y

    draw_health(px - 60, py - 60, 39, 40, 8, player)
    if not enemy.dead then
        draw_health(px - 57, py + 50, 41, 42, 1, enemy)
        print(enemy.type, px - 57, py + 45)
    end
end


function draw_health(x, y, spr_full, spr_empty, x_space, entity)
    for i = 0, entity.__health - 1 do
        if i >= entity.health then
            hb_spr = spr_empty
        else
            hb_spr = spr_full
        end

        spr(hb_spr, x + x_space * i, y)
    end
end


function init_object(x, y, width, height, speed, health)
    local o = {
        x = x * tile_size,
        y = y * tile_size,
        dx = 0,
        dy = 0,
        width = width,
        height = height,

        speed = speed,
        __speed = speed,

        attack_power = 3,
        __attack_power = 3,

        health = health,
        __health = health,

        facing = 'down',
        dead = false,
        invin = false,
        anim_lock = false,
        attacking = false
    }

    function o.set_anim(self, anim, lock)
        if not self.anim_lock then
            self.anim_lock = lock or false
            self.anim = anim
            self.anim.reset()
        end
    end

    function o.collisions(self, attacker)
        local ax = attacker.x
        local ay = attacker.y

        local sx = self.x
        local sy = self.y
        local sw = self.width
        local sh = self.height

        local range = 0.75

        local attacker_spr = attacker.anim.get_cur_frame().spr
        local aw = attacker_spr.width * tile_size
        local ah = attacker_spr.height * tile_size

        if attacker.attacking then
            if attacker.facing == 'left' then
                if ax >= sx and
                   ax <= sx + aw * range and
                   ay <= sy + sh and
                   ay >= sy - sh then
                    return true
                end
            elseif attacker.facing == 'right' then
                if ax <= sx and
                   ax >= sx - aw * range and
                   ay <= sy + sh and
                   ay >= sy - sh then
                    return true
                end
            elseif attacker.facing == 'up' then
                if ax <= sx + sw and
                   ax >= sx - sw and
                   ay >= sy and
                   ay <= sy + ah * range then
                    return true
                end
            elseif attacker.facing == 'down' then
                if ax <= sx + sw and
                   ax >= sx - sw and
                   ay <= sy and
                   ay >= sy - ah * range then
                    return true
                end
            end
        end

        return false
    end

    return o
end


--//////////////
--player
--//////////////
function _player(x, y)
    local p = init_object(x, y, 5, 7, 1.3, 5)

    p.anim = anims['player_down']
    p.invin_start_time = time()

    p.moving = false
    p.visible = true

    p.attack_held = false
    p.charge_start_time = 0
    p.charge_modifier = 7

    local charge_threshold = 0.5
    local invin_duration = 3
    local max_attack_power = 30

    function p.update()
        if time() - p.invin_start_time > invin_duration then
            p.invin = false
        end
        p.adjust_speed()
        p.move()
        p.check_collisions()
        p.anim.update()

        if p.attack_power == max_attack_power and p.is_charging() then
            p.anim_lock = false
            p:set_anim(anims['player_charging_done_'..p.facing])
            p.anim_lock = true
        end

        if p.anim.done then
            p.anim_lock = false
            if p.attacking then
                p.attacking = false
                enemy.invin = false
            end
            p:set_anim(anims['player_'..p.facing])
        end
    end

    function p.adjust_speed()
        if p.attack_held and p.speed > 0.8 then
            p.speed = p.speed - 0.1
        elseif not p.attack_held then
            p.speed = p.__speed
        end
    end

    function p.draw()
        if p.invin then
            cur_milli = round(time() - flr(time()), 2)
            if cur_milli % 0.2 == 0 then
                p.visible = not p.visible
            end
        else
            p.visible = true
        end

        if p.visible then
            p.anim.draw_frame(p.x,p.y)
        end
    end

    --movement
    function p.set_direction(d)
        if d == 'left' then
            p.dx = -1
        elseif d == 'right' then
            p.dx = 1
        elseif d == 'up' then
            p.dy = -1
        else
            p.dy = 1
        end
        if not p.attacking then
            p.facing = d
            if not p.is_charging() then
                p:set_anim(anims['player_'..p.facing])
            end
        end
    end

    function p.attack()
        p:set_anim(anims['player_attack_'..p.facing], true)
        p.attacking = true
    end
    
    function p.is_charging()
        local charge_duration = time() - p.charge_start_time
        return p.attack_held and charge_duration > charge_threshold
    end

    function p.move()
        local orig_x = p.x
        local orig_y = p.y

        local modifier
        if p.attacking and p.attack_power ~= p.__attack_power then
            p.set_direction(p.facing)
            modifier = p.attack_power / p.charge_modifier
        else
            modifier = p.speed
        end

        local new_x = p.x + p.dx * modifier
        local new_y = p.y + p.dy * modifier

        local solid_tile = tile_type_area(new_x, new_y, p.width, p.height, 0)

        local can_move = not solid_tile

        if can_move then
            p.x = new_x
            p.y = new_y
            p.start_moving()
        end

        --check if movement stopped
        if orig_x == p.x and orig_y == p.y then
            p.stop_moving()
        end

        --reset movement direction
        p.dx = 0
        p.dy = 0
    end

    function p.check_collisions()
        local damage_tile = tile_type_area(p.x, p.y, p.width, p.height, 1)
        if damage_tile and not p.invin and not enemy.dead then
            p.take_damage()
        end

        local damage = p:collisions(enemy)

        if damage and not p.invin then
            p.take_damage()
        end
    end

    function p.start_moving()
        if not p.moving then
            play_sound(0)
        end
        p.moving = true
    end

    function p.stop_moving()
        p.moving = false
        sfx(-1,0)
    end

    function p.take_damage()
        p.health -= 1
        if p.health < 1 then
            p.dead = true
        end
        p.invin = true
        p.invin_start_time = time()
    end

    function p.set_attack_held(value)
        p.attack_held = value
        if value then
            p.charge_start_time = time()
        end
    end

    function p.set_attack_power(value)
        if value <= max_attack_power then
            p.attack_power = value
        end
    end

    return p
end


--//////////////////
--enemy
--//////////////////
function _enemy(enem_type, x, y)
    if enem_type == 'worm' then
        return init_enemy(x,y,1,2,0,enem_type)
    elseif enem_type == 'knight_queen' then
        return init_enemy(x,y,2,4,0.2,enem_type)
    elseif enem_type == 'shadow' then
        return init_shadow(x,y,1,1,0.4)
    end
end


function init_shadow(x, y, width, height, speed)
    local shad = init_enemy(x, y, width, height, speed, 'shadow')

    function shad.attack()
        if not shad.can_attack then
            return
        end

        local p = player
        local coeff = p.height / 2
        local x_diff_abs = point_diff(p.x, shad.x, coeff, true)
        local y_diff_abs = point_diff(p.y, shad.y, coeff, true)
        local new_anim = ''

        if x_diff_abs and point_diff(p.y, shad.y, 30, false) then
            new_anim = 'shadow_attack_down'
        elseif x_diff_abs and point_diff(shad.y, p.y, 30, false) then
            new_anim = 'shadow_attack_up'
        elseif y_diff_abs and point_diff(shad.x, p.x, 30, false) then
            new_anim = 'shadow_attack_left'
        elseif y_diff_abs and point_diff(p.x, shad.x, 30, false) then
            new_anim = 'shadow_teleport'
        else
            return
        end

        shad:set_anim(anims[new_anim])
    end

    return shad
end


function point_diff(a, b, coefficient, absolute)
    local diff = round(a, 0) - round(b, 0)
    if absolute then
        return abs(diff) <= coefficient
    else
        return diff <= coefficient and diff >= 0
    end
end


function init_enemy(x, y, width, height, speed, type)
    local e = init_object(
        x,
        y,
        width * tile_size,
        height * tile_size,
        speed,
        115
    )

    e.type = type
    e.anim = anims[e.type..'_'..e.facing]
    e.anim_lock = false
    e.hurt_on_touch = false
    e.attacking = false
    e.can_attack = true
    e.can_move = true
    e.start_rest_time = 0
    e.rest_duration = 0

    function e.update()
        if not e.dead then
            if not e.attacking then
                e.move()
                e.attack()
            end
            e.check_collisions()
            e.anim.update()

            if time() - e.start_rest_time > e.rest_duration then
                e.can_move = true
                e.can_attack = true
                e.rest_duration = 0
            end

            if e.anim.done then
                if e.anim.is_attack then
                    if e.type == 'shadow' then
                        e.rest(1)
                    end
                end
                e.anim_lock = false
                e:set_anim(anims[e.type..'_'..e.facing])
            end
        end
    end

    function e.draw()
        if not e.dead then
            e.anim.draw_frame(e.x,e.y)
        end
    end

    function e.rest(duration)
        e.start_rest_time = time()
        e.rest_duration = duration
        e.can_move = false
        e.can_attack = false
    end

    function e.check_collisions()
        local damage = e:collisions(player)

        if damage and not e.invin then
            e.take_damage()
            e.invin = true
        end
    end

    function e.move()
        if not e.can_move then
            return
        end

        local px = round(player.x, 0)
        local py = round(player.y, 0)

        local ex = round(e.x, 0)
        local ey = round(e.y, 0)

        if py > ey then
            e.dy = 1
            e.facing = 'down'
        elseif py < ey then
            e.dy = -1
            e.facing = 'up'
        end

        if px > ex then
            e.dx = 1
            e.facing = 'right'
        elseif px < ex then
            e.dx = -1
            e.facing = 'left'
        end

        e.x += e.dx * e.speed
        e.y += e.dy * e.speed

        e:set_anim(anims[e.type..'_'..e.facing])

        e.dx = 0
        e.dy = 0
    end

    function e.take_damage()
        e.health -= player.attack_power
        if e.health < 1 then
            e.dead = true
        end
    end

    return e
end


--////////////////////
--sprites + animation
--////////////////////
function _sprite(width, height, sprites, x_origin, y_origin, flip_x)
    local s = {}
    s.width = width
    s.height = height
    s.sprites = sprites
    s.flip_x = flip_x or false
    s.x_origin = x_origin or 1
    s.y_origin = y_origin or 1

    function s.draw(x,y)
        for index_y = 1, s.height do
            for index_x = 1, s.width do
                local frame_index = index_y * s.width + index_x - s.width
                local sprite_index = s.sprites[frame_index]

                local offset_x = (index_x - s.x_origin) * tile_size
                local offset_y = (index_y - s.y_origin) * tile_size

                spr(sprite_index, x+offset_x, y+offset_y, 1, 1, s.flip_x)
            end
        end
    end

    return s
end


function _frame(sprite, args)
    local args = args or {}

    local f = {
        spr = sprite,
        dur = args.dur or 0,
        movement = args.movement or 'mod',
        xmod = args.xmod or 0,
        ymod = args.ymod or 0,
        xpos = args.xpos or 0,
        ypos = args.ypos or 0,
        set = {}
    }

    f.set = {f}

    function f.next(sprites, args)
        local spr = f.spr
        local set = f.set

        local args = args or {}

        local s = sprites or spr.sprights

        local w = args.width or spr.width
        local h = args.height or spr.height
        local xo = args.x_origin or spr.x_origin
        local yo = args.y_origin or spr.y_origin

        local fx
        if type(args.flip_x) == 'boolean' then
            fx = args.flip_x
        else
            fx = spr.flip_x
        end

        local frame_args = {
            dur = args.dur or spr.dur,
            xmod = args.xmod or spr.xmod,
            ymod = args.ymod or spr.ymod,
            xpos = args.xpos or spr.xpos,
            ypos = args.ypos or spr.ypos,
            movement=args.movement or spr.movement
        }

        local next_frame = _frame(
            _sprite(w, h, s, xo, yo, fx), frame_args)

        set[#set+1] = next_frame
        next_frame.set = set

        return next_frame
    end

    return f
end


function _anim(frame_set, args)
    local args = args or {
        loop = false,
        flip_x = false,
        object = nil,
        is_attack = false
    }

    local a = {}
    a.frame_set = frame_set
    a.frame_index = 1
    a.done = false
    a.flip_x = args.flip_x
    a.loop = args.loop
    a.start_time = time()
    a.running_duration = nil
    a.object = args.object
    a.is_attack = args.is_attack

    function a.reset()
        a.frame_index=1
        a.done=false
        a.start_time = time()
        a.running_duration = nil
        if a.is_attack then
            a.object.attacking = true
        end
    end

    function a.set_obj(obj)
        a.object = obj
    end

    function a.get_cur_frame()
        return a.frame_set[a.frame_index]
    end

    function a.update()
        if (a.done) return

        local curr_frame = a.get_cur_frame()
        local duration = 0

        duration = curr_frame.dur

        if not a.running_duration then
            a.running_duration = duration
        end

        if time() > a.start_time + a.running_duration then
            a.frame_index += 1
            if a.frame_index > #a.frame_set then
                if a.loop then
                    a.reset()
                else
                    a.done = true
                    if a.is_attack then
                        a.object.attacking = false
                    end
                end
                return
            end
            a.running_duration += a.get_cur_frame().dur
        end

        if a.object then
            if curr_frame.movement == 'mod' then
                a.object.x += curr_frame.xmod
                a.object.y += curr_frame.ymod
            elseif curr_frame.movement == 'pos' then
                a.object.x = player.x + curr_frame.xpos
                a.object.y = player.y + curr_frame.ypos
            end
        end
    end

    function a.draw_frame(x,y)
        c_frame = a.get_cur_frame()
        c_frame.spr.draw(x,y)
    end

    return a
end


--////////////////
--misc
--////////////////
--inputs
function handle_inputs()
    local p = player
    --set direction player wants to move in
    if not p.attacking or p.attack_power == p.__attack_power then
        if btn(0)        then p.set_direction('left')
           elseif btn(1) then p.set_direction('right')
           elseif btn(2) then p.set_direction('up')
           elseif btn(3) then p.set_direction('down')
        end
    end

    if not freeze then
        if btn(4) and not p.attack_held then
            p.set_attack_held(true)
            p.set_attack_power(p.__attack_power)
        elseif btn(4) and p.attack_held then
            if p.is_charging() then
                p:set_anim(anims['player_charging_'..p.facing])
                p.set_attack_power(p.attack_power + 1)
                p.anim_lock = true
            end
        elseif p.attack_held then
            p.anim_lock = false
            p.attack()
            p.set_attack_held(false)
        end
    end
end


--collision detection
function get_tile_type(x,y,tile_type)
    if tile_type == 1 and enemy.hurt_on_touch then
        local e = enemy
        if x >= e.x and x <= e.x + e.width and
           y >= e.y and y <= e.y + e.height then
            return true
        end
    else
        tile = mget(x/tile_size, y/tile_size)
        return fget(tile, tile_type)
    end
end


function tile_type_area(x,y,w,h,tile_type)
    return
    get_tile_type(x,y,tile_type) or
    get_tile_type(x+w,y,tile_type) or
    get_tile_type(x,y+h,tile_type) or
    get_tile_type(x+w,y+h,tile_type)
end


--audio
function play_sound(track)
    if sound_enabled then
        sfx(track)
    end
end


function round(number, digits)
    local shift = 10 ^ digits
    return flr(number * shift + 0.5 ) / shift
end


function log(log_text)
    logs[#logs+1] = log_text
end


function print_logs()
    for i = 1, #logs do
        print(logs[i], player.x + 10, player.y - 70 + (10 * i))
    end
    logs = {}
end


__gfx__
000000001dd11dd1111111dddddddddd111111ddddddddd011111111dd1111110ddddddd022220000222200002222000022220000cccc0000cccc0000cccc000
00000000dd1111dd111111dddddddddd111111dddddddddd11111111dd111111dddddddd22222200222222002222220022222200cccccc00cccccc00cccccc00
00000000d111111d1111111111111111111111dd11111ddd11111111dd111111ddd1111122222200222222002222220022222200cccccc00cccccc00cccccc00
00000000111111111111111111111111111111dd111111dd11111111dd111111dd11111121ff1200222f1f0022222200f1f22200c1ff1c00cccf1f00cccccc00
00000000111111111111111111111111111111dd111111dd11111101dd111111dd1111112ffff20022ffff0022222200ffff2200cffffc00ccffff00cccccc00
00000000d111111d1111111111111111111111dd111111dd11011101dd111111dd11111188888800888888008888880088888800888888008888880088888800
00000000dd1111dd1111111111111111111111dd111111dd10001100dd111111dd11111198899900999889009999990099999900988999009998890099999900
000000001dd11dd11111111111111111111111dd111111dd00001000dd111111dd11111198899900999889009999990099999900988999009998890099999900
222222222222222255555555111111dddd111111dddddddd11111111dd111111dd1111107772770000007700000007000000070002222000700000000000aa00
222222222222222255555555111111dddd111111dddddddd11111111dd111111dd10000100020000000222000000222000002220222222077000000000022200
535555555555553355555555111111dddd1110111011111111111111dd101111dd0011110000000007770000000070000000070022222207000000000aaa0000
533555555555553555555555011111ddd00100111101111110111111dd010111dd11001100000000770000000007700000000700222f1f2700000000aa000000
533355555555333555555555000111d0000000101101111110011101dd111000dd1110110000000000000000000700000000070022ffff720000000000000000
33533355555335335555555500011100000000001100111100010100dd000011dd11110000000000000000000077000000000700888888702000000000000000
35553335555355555555555500001000000000001101011100000000dd011111dd11111000000000000000000070000000000700999889000000000000000000
55555535555355555555555500000000000000001011101100000000dd111111dd11111100000000000000000000000000000000999889000000000000000000
022220000000000000000000000000000000000000000000dddddddd00220000002200000000000000000000222222225555555555555555555555551dd11111
222222000077000000000000000000000000000000000000dddddddd0299200002002000600000006000000022222222556565655655556555555555dd111111
222222000770000000000000000000000000000007000000111111112999920020000200300000000000000053555555565666656665666556555655d1111115
222f1f00770000000000000000000000000000000700000055666655299992002000020030000000000000005335555555555655555655655666666511115515
22ffff02700000000000000000000000000077000700000056666665029920000200200030000000000000005333555555556555555665555555556511115555
888888727000000077777000000000000007700007000000566666650022000000220000600000006000000033533555555655555555555555555555d1155555
999889020000000000000000000000000077000007000000116666110000000000000000000000000000000035553555555555555555555555555555dd155555
9998890000000000000000000777770007700000070000001666666100000000000000000000000000000000555533555555555555555555555555551dd55555
00000000000000000000000000000000777777775555552206666660066666602222222255555522225555555555535522555555222222222222222200000000
0000a000000000000000000000000000777777775555552200666600008668002222222255555522225555555555533522555555222222222222222200000000
0000aa0000000000000000000000a000777777775555552206666660060660605555555555555555555555555555553522555555225555555555552200000000
000a9a000000000000000000000aa000777777775555552206666660006666005555555555555555555555555555333322555555225555555555552200000005
000060000000600000000000000a9a00777777775555552200866800000000005555555555555555555555555553355322555555225555555555552200000055
00066000000660000006600000006600777777775555552206066060000000005555555555555555555555555553555322555555225555555555552200050055
00066000000660000006660000066600777777775555552206000060000000005555555555555555555555555553555322555555225555555555552200055555
00666000006660000066666000666660777777775555552200600600000000005555555555555555555555555553555322555555225555555555552200055555
0000000000009000055550000555500005555000555555550555500002200000000000000000000000000000000000000cccc000000000000000000000000000
000000000000900055555500555555005555550055555555555555000200222200000200000000000000000000000000cccccc00000000000000000000000000
000000000000900055555500555555005555550055566555555555000228820202288200002082000000a000000a0a00cccccc00000000000000000000000000
00000000000090005877850055578700555555005565665578755500028228000082280000822000000aaa000000a000cccf1f00000000000600000000000000
000000000000900057777500557777005555550055665655777755000082282000822800000228000000a000000a0a00ccffff02000000000000000000000000
00000000000090006666660066666600666666005556655566666600202882200028822000280200000000000000000088888872000000000000000000000000
09000900090090005665550055566500555555005555555555555500222200200020000000000000000000000000000099988902000000000600000000000000
09909990990090005665550055566500555555005555555555555500000002200000000000000000000000000000000099988900000000000000000000000000
099999999900900089a5aa000000aa0000000a0000000a00000000000000000000000000000000000000000000000000000000000cccc0000000000000000000
07727272770090008995000000055500000055500000555008000000000000000000000000000000000000000000000000000000cccccc060000000000000000
0072727270009000800000000889a90000009a9000009a9088800000000000000000080000000000000000000000000000000000cccccc000000000000000000
00727272700090200000000088888000000999900008999888800000000000000000088000000000000000000000000000000000c1ff1c000000000000000000
00777777700090200000000088800000000888800000898088800000000000000000088000000000000000000000000000000000cffffc000000000000000000
00077777000090200000000000000000008888000000888089880000000000000000888800000000000000000000000000008000888888000000000000000000
00007270000090200000000000000000088880000000888099980000000000000000888800000000000000000000000000008800988999000000000000000000
0077727777702220000000000000000008880000000008009a900000000000000008888800000000000000000000000000088800988999000000000000000000
07707270007790000555500880000000055550000000000000000000000888000008888800000000000000000555500000888800000000000000000000000000
07007270000090005555558880000000555555000000000000000000008888000088888800000000000000005555550000888800000000000000000000000000
00077277000090005555558900000000555555000000000000000000088880000088888000000000000000005555550008998000000000000000000000000000
00777777700090005557875900000000555787000880000000008880888800000888988000000000000000005557870089988000000000000000000000000000
0077272770000000557777a500000000557777059988888000088880988000000889988000000000000000005577770599980000000000000000000000000000
0772272277000000666666a050000000666666a5a99888880088880098000000888998800000000000000000666666a588800000000000000000000000000000
07727772770000005556650000000000555665059988888008998800000000008899980000000000000000005556650500000000000000000000000000000000
07227772270000005556650000000000555665000880000089998000000000008999980000000000000000005556650000000000000000000000000000000000
77277777277000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
43434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343
43434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000055000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000055550055000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000055550055000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0100010101010101010000000000000000000100010101010100000000000000000000000000010000000000000000010000000000010202010101010101010100000000000000000000000000000000000002020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005800000000000000003300000031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010101010101010101015959595900000000003d103838382b3e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010101010101454545015959595900000000003c121212123b350000000000000000000000000000000000000000000000000101010101010101010101010101010101010100000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010101010145450145455959595900000000003c122c2d2e12350000000000000000000000000000000000000000000000000101010101010101010101010101010101010101000000000000000000000000
00000000000000000000000000000000080303030303030303030315030500000000000000000101010106060606060606060645010101455959595900000000003c2c2e2c2d2e350000000000000000000000000000000000000000000000000101010101010101010101010101010101010101000000000000000000000000
00000000000000000000000000000000070101010101010101010101010400000000000000000101010100000000000000000045010101455959595900000000313c1212121212353200000000000000000000000000000000000000000000000101010101010101010101010101010101010101000000000000000000000000
0000000000000000000000000000000007010101010101010101010101040000000000000000010101010000000000000000004501010145595959590000003f113a1212121212392b3e000000000000000000000000000000000000000000000101010101010101010101010101010101010101000000000000000000000000
000000000000000000000000000000001701010101010101010101010104000000000000000001010101000000000000000000010101010159595959002f381212121212121212123b39383e01010100000000000000000000000000000001010101010101010101010101010101010101010101000000000000000000000000
0000000000000000000000000000000007010101010101010101010101040000000000000000010101010000000000000000000101010101595959590001010101010101010101010101010101010100000000000000000000000000010101000001010101010101010101010101010101010101010000000000000000000000
0000000000000000000000000000000007010101010101010101010101040000000000000000010101010000000000000000000101010101595959595601010101010101010101010101010101010100000000000000000001010101010000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000018010101010101010101010101040000000000000000010101010000000000000000000606060101005656005801010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000007010101010101010101010101040000000000000000010101010000000000000000000000000101010100005801010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000014161606060101061606160606130000000000000000010101010000000000000000000000000101010101006601010101010606160616010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000101000000000000000000000000000000010101010000000000000000000000000606010101010101010101160000000000060101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000101000000000000000000000000000000010101010000000000000000000000000000060601010101010106000000000000001601010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000101010101010101010101010101010101010101010000000000000000000000000000000006060101010100000000000000000001010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000101010101010101010101010101010101010101010000000000000000000000000000000000000101010101000000000000000101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000606060606060606060606060606060606060606060000000000000000000000000000000000000101010101010000000000010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000057005757000000000000000000000000000000000000005757575757575757575757575757575757570000000000000101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575701010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757010101010606060606060606060606060606060606060601010101010000000000000000000000000001010101010101010101010101010101010101000000000000000000000000
0000000000575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575700010100000000000000000000000000000000000000000000000101010100000000000000000000000001010101010101010101010101010101010101000000000000000000000000
0000000000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000010101010100000000000000000001010101010101010101010101010101010101000000000000000000000000
0000000000010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010001010001010101010101010101010101010101010101000000000000000000000000
0000000000010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101000000000000000000000000
0000000000010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101010101010101010101010101010101010101010101010101000000000000000000000000
0000000000010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101000000000000000000000000
0000000000010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101010101010101010101010101010101000000000000000000000000
0000000000010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000a00040a6100160022000026400b6000c600016000c6000a6001570030b002fb002fb002eb002ef0029700277002db00257002db002db0022700257001b7001c7001a700187001870017700186001560013600
001c001011510145201653010540135201654014540115400d5300b5100d5500d5501950016500145001c5001d500215001750017500175001750017500185002050021500000000000000000000000000000000
001c0004055500855005550055001c5001c5000f5000f5000f5000f50006500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
02 01024344

