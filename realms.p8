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
    default_anim_speed = 0.1
    sound_enabled = false

    sprites = {}
    anims = {}

    --////////////////////
    --composite sprites
    --////////////////////
    sprites['worm'] = new_composite_sprite(1,2,{38,54})
    sprites['knight_queen'] = new_composite_sprite(2,4,{64,65,80,81,96,97,112,113})


    --////////////////////
    --animations
    --////////////////////
    anims['player_down']  = new_anim({9})
    anims['player_right'] = new_anim({10})
    anims['player_left']  = new_anim({12})
    anims['player_up']  = new_anim({11})

    anims['player_attack_down'] = new_anim({new_composite_sprite(1,2,{9,25}),
                                           new_composite_sprite(1,2,{9,26}),
                                           new_composite_sprite(1,2,{9,27}),
                                           new_composite_sprite(1,2,{9,28})},
                                           {speed=0.4, loop=false, flip_x = false})

    anims['player_attack_right'] = new_anim({new_composite_sprite(2,1,{29,30}),
                                            new_composite_sprite(2,1,{32,33}),
                                            new_composite_sprite(2,1,{32,34})},
                                            {speed=0.4, loop=false, flip_x = false})

    anims['player_attack_left'] = new_anim({new_composite_sprite(2,1,{30,29},2,1,true),
                                            new_composite_sprite(2,1,{33,32},2,1,true),
                                            new_composite_sprite(2,1,{34,32},2,1,true)},
                                            {speed=0.4, loop=false, flip_x = false})

    anims['player_attack_up'] = new_anim({new_composite_sprite(1,2,{35,11},1,2),
                                         new_composite_sprite(1,2,{36,11},1,2),
                                         new_composite_sprite(1,2,{37,11},1,2)},
                                         {speed=0.4, loop=false, flip_x = false})

    anims['worm_down'] = new_anim({sprites['worm'],
                                   new_composite_sprite(1,2,{38,55})},
                                  {speed=0.05, loop=true, flip_x = false})

    anims['knight_queen_down'] = new_anim({sprites['knight_queen_down']})

    anims['shadow_down'] = new_anim({66})
    anims['shadow_attack_down'] = new_anim({new_composite_sprite(1,2,{66,82}),
                                            new_composite_sprite(1,2,{66,83}),
                                            new_composite_sprite(1,2,{66,84}),
                                            new_composite_sprite(1,2,{66,85})},
                                            {speed=0.4, loop=false, flip_x = false})

    init_objects()
    --music(0,0,4)
end

function _update()
    handle_inputs()
    player.update()
    enemy.update()

    if player.dead then
        init_objects()
    end
end

function _draw()
    cls()

    camera(player.x - 64, player.y - 64)
    map(0,0)

    if player.y >= enemy.y + enemy.height * tile_size / 2 then
        enemy.draw()
        player.draw()
    else
        player.draw()
        enemy.draw()
    end

    draw_hud(player, enemy)

    --log(round(enemy.y,0), 0)
end

function init_objects()
    player = new_player(19, 7)
    enemy = new_enemy('shadow', 25, 6)
end

function draw_hud(p, e)
    draw_health(p.x - 60, p.y - 60, 39, 40, 8, p)
    if not enemy.dead then
        draw_health(p.x - 57, p.y + 50, 41, 42, 1, e)
        print(enemy.type, p.x - 57, p.y + 45)
    end
end

function draw_health(x, y, spr_full, spr_empty, x_space, entity)
    for i = 0, entity.max_health - 1 do
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
        facing = 'down',

        max_health = health,
        health = health,

        dead = false,
        invin = false,
        anim_lock = false
    }

    function o.set_anim(self, anim, lock)
        if not self.anim_lock then
            self.anim_lock = lock or false
            self.anim = anim
            self.anim.reset()
        end
    end

    return o
end


--//////////////
--player
--//////////////
function new_player(x, y)
    local p = init_object(x, y, 5, 7, 1.3, 5)

    p.anim = anims['player_down']
    p.invin_start_time = time()
    p.invin_duration = 2

    p.moving = false
    p.visible = true
    p.attacking = false

    function p.update()
        if time() - p.invin_start_time > p.invin_duration then
            p.invin = false
        end
        p.move()
        p.collisions()
        p.anim.update()

        if p.anim.done then
            p.anim_lock = false
            if p.attacking then
                p.attacking = false
                enemy.invin = false
            end
            p:set_anim(anims['player_'..p.facing])
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
        p.facing = d
        p:set_anim(anims['player_'..p.facing])
    end

    function p.attack()
        p:set_anim(anims['player_attack_'..p.facing], true)
        p.attacking = true
    end

    function p.move()
        local orig_x = p.x
        local orig_y = p.y

        local new_x = p.x + p.dx * p.speed
        local new_y = p.y + p.dy * p.speed

        local solid_tile = tile_type_area(new_x, new_y, p.width, p.height, 0)

        --check if moving into wall
        if not solid_tile then
            p.x = new_x
            p.y = new_y
            p.start_moving()
        end

        --check if movement stopped
        if orig_x == p.x and
         orig_y == p.y then
            p.stop_moving()
        end

        --reset movement direction
        p.dx = 0
        p.dy = 0
    end

    function p.collisions()
        local damage_tile = tile_type_area(p.x, p.y, p.width, p.height, 1)
        if damage_tile and not p.invin and not enemy.dead then
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

    return p
end


--//////////////////
--enemy
--//////////////////
function new_enemy(enem_type, x, y)
    if enem_type == 'worm' then
        return init_enemy(x,y,1,2,0,enem_type)
    elseif enem_type == 'knight_queen' then
        return init_enemy(x,y,2,4,0.2,enem_type)
    elseif enem_type == 'shadow' then
        return init_enemy(x,y,1,1,0.4,enem_type)
    end
end

function init_enemy(x, y, width, height, speed, type)
    local e = init_object(x, y, width, height, speed, 115)

    e.type = type
    e.anim = anims[e.type..'_'..e.facing]
    e.anim_lock = false
    e.hurt_on_touch = true

    function e.update()
        if not e.dead then
            e.move()
            e.collisions()
            e.attack()
            e.anim.update()

            if e.anim.done then
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

    function e.collisions()
        local damage = false
        local p = player

        if p.attacking then
            local start_x = e.x + e.width * tile_size
            local end_y = e.y + e.height * tile_size
            if p.facing == 'left' then
                if p.x >= start_x - p.width and
                   p.x <= start_x + tile_size - p.width / 1.5 and
                   p.y >= e.y and
                   p.y <= end_y + tile_size - p.height then
                    damage = true
                end
            elseif p.facing == 'right' then
                if p.x <= e.x + p.width / 1.5 and
                   p.x >= e.x - tile_size - p.width / 1.5 and
                   p.y >= e.y and
                   p.y <= end_y + tile_size - p.height then
                    damage = true
                end
            elseif p.facing == 'up' then
                if p.x <= e.x + p.width and
                   p.x >= e.x - tile_size - p.width and
                   p.y >= e.y and
                   p.y <= end_y + tile_size - p.height / 2 then
                    damage = true
                end
            end
        end

        if damage and not e.invin then
            e.take_damage()
            e.invin = true
        end
    end

    function e.move()
        local px = round(player.x, 0)
        local py = round(player.y, 0)

        local ex = round(e.x, 0)
        local ey = round(e.y, 0)

        if px > ex then
            e.dx = 1
        elseif px < ex then
            e.dx = -1
        end

        if py > ey + e.height * tile_size / 2 then
            e.dy = 1
        elseif py < ey + e.height * tile_size / 2 then
            e.dy = -1
        end

        e.x += e.dx * e.speed
        e.y += e.dy * e.speed

        e.dx = 0
        e.dy = 0
    end

    function e.take_damage()
        e.health -= 10
        if e.health < 1 then
            e.dead = true
        end
    end

    function e.attack()
        local p = player
        if e.type == 'shadow' then
            if round(e.x, 0) == round(p.x, 0) and e.y < p.y and e.y > p.y - 10 then
                e:set_anim(anims[e.type..'_attack_'..e.facing], true)
            end
        end
    end

    return e
end


--////////////////////
--sprites + animation
--////////////////////
function new_composite_sprite(width, height, sprites, x_origin, y_origin, flip_x)
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

function new_frame_set(frames)
    local fs = {}
    fs.frames = frames
    return fs
end

function new_anim(frame_set, args)
    local args = args or {speed = default_anim_speed,
                          loop = true,
                          flip_x = false}

    local a = {}
    a.frame_set = new_frame_set(frame_set)
    a.frame_index = 1
    a.speed = args.speed
    a.done = false
    a.timer = 0
    a.flip_x = args.flip_x
    a.loop = args.loop

    function a.reset()
        a.timer = 0
        a.frame_index=1
        a.done=false
    end

    function a.get_cur_frame()
        return a.frame_set.frames[a.frame_index]
    end

    function a.update()
        if (a.done) return

        a.timer += a.speed

        while a.timer >= 1 do
            a.frame_index += 1
            a.timer -= 1
        end

        if a.frame_index > #a.frame_set.frames then
            if a.loop then
                a.reset()
            else
                a.done = true
            end
        end
    end

    function a.draw_frame(x,y)
        if type(a.get_cur_frame()) == "number" then
            spr(a.get_cur_frame(), x, y, 1, 1, a.flip_x)
        else
            --draw composite sprites
            a.get_cur_frame().draw(x, y)
        end
    end

    return a
end


--////////////////
--misc
--////////////////
--inputs
function handle_inputs()
    --set direction player wants to move in
    if btn(⬅️)        then player.set_direction('left')
       elseif btn(➡️) then player.set_direction('right')
       elseif btn(⬆️) then player.set_direction('up')
       elseif btn(⬇️) then player.set_direction('down')
    end

    if btnp(❎) then
        player.attack()
    end
end

--collision detection
function get_tile_type(x,y,tile_type)
    if tile_type == 1 and enemy.hurt_on_touch then
        local e = enemy
        if x >= e.x and x <= e.x + (e.width * tile_size) and
           y >= e.y and y <= e.y + (e.height * tile_size * 0.6) then
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

function log(log_text, offset)
    print(log_text, player.x + 30, player.y - 55 + (10 * offset))
end


__gfx__
000000001dd11dd1111111dddddddddd111111dddddddddd11111111dd111111dddddddd02222000022220000222200002222000000000001111000000000000
00000000dd1111dd111111dddddddddd111111dddddddddd11111111dd111111dddddddd22222200222222002222220022222200000000001111100000000000
00000000d111111d1111111111111111111111dd111111dd11111111dd111111dd11111122222200222222002222220022222200000000001111111111000000
00000000111111111111111111111111111111dd111111dd11111111dd111111dd11111121ff1200222f1f0022222200f1f222000000000001111111d1d11000
00000000111111111111111111111111111111dd111111dd11111101dd111111dd1111112ffff20022ffff0022222200ffff2200000000000000111111d1d110
00000000d111111d1111111111111111111111dd111111dd11011101dd111111dd111111888888008888880088888800888888000000000000000000011111d1
00000000dd1111dd1111111111111111111111dd111111dd10001100dd111111dd1111119889990099988900999999009999990000000000000000000001d111
000000001dd11dd11111111111111111111111dd111111dd00001000dd111111dd11111198899900999889009999990099999900000000000000000000011111
222222222222222255555555111111dddd111111dddddddd11111111dd111111dd11111077727700000077000000070000000700022220007000000000011111
222222222222222255555555111111dddd111111dddddddd11111111dd111111dd10000100020000000222000000222000002220222222077000000000001111
535555555555553355555555111111dddd1110111011111111111111dd101111dd00111100000000077700000000700000000700222222070000000000000011
533555555555553555555555011111ddd00100111101111110111111dd010111dd11001100000000770000000007700000000700222f1f270000000000000000
533355555555333555555555000111d0000000101101111110011101dd111000dd1110110000000000000000000700000000070022ffff720000000000000000
33533355555335335555555500011100000000001100111100010100dd000011dd11110000000000000000000077000000000700888888702000000000000000
35553335555355555555555500001000000000001101011100000000dd011111dd11111000000000000000000070000000000700999889000000000000000000
55555535555355555555555500000000000000001011101100000000dd111111dd11111100000000000000000000000000000000999889000000000000000000
022220000000000000000000000000000000000000000000dddddddd00880000008800000000000000000000222222225555555555555555555555551dd11111
222222000077000000000000000000000000000000000000dddddddd0899800008008000600000006000000022222222556565655655556555555555dd111111
222222000770000000000000000000000000000007000000111111118999980080000800300000000000000053555555565666656665666556555655d1111115
222f1f00770000000000000000000000000000000700000055666655899998008000080030000000000000005335555555555655555655655666666511115515
22ffff02700000000000000000000000000077000700000056666665089980000800800030000000000000005333555555556555555665555555556511115555
888888727000000077777000000000000007700007000000566666650088000000880000600000006000000033533555555655555555555555555555d1155555
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
00000000000090000555500005555000000000005555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000090005555550055555500000000005555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000090005555550055555500000000005556655500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000090005877850055578700000000005565665500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000090005777750055777700000000005566565500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000090006666660066666600000000005556655500000000000000000000000000000000000000000000000000000000000000000000000000000000
09000900090090005665550055566500000000005555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
09909990990090005665550055566500000000005555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
09999999990090007775770000007700000007000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000
07727272770090000005000000055500000055500000555000000000000000000000000000000000000000000000000000000000000000000000000000000000
00727272700090000000000007770000000070000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000
00727272700090200000000077000000000770000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777777700090200000000000000000000700000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777000090200000000000000000007700000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007270000090200000000000000000007000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777277777022200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07707270007790000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07007270000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077277000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777777700090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00772727700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07722722770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07727772770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07227772270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0100010101010101010000000000000000000100010101010100000000000000000000000000010000000000000000010000000000010202010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000018010101010101010101010101040000000000000000010101010000000000000000000606060101435656005801010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000007010101010101010101010101040000000000000000010101010000000000000000000000000101010142435801010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000014161606060101061606160606130000000000000000010101010000000000000000000000000101010101546601010101010606160616010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

