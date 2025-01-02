STATE = flycast.state
MEMORY = flycast.memory

MEMORY_ADDRESSES = {
    ['game_substate'] = 0x0C29B86F,
    ['round_timer'] = 0x0C29BCD8,
    ['round_counter'] = 0x029BCDE,
    ['can_throw'] = 0x0C1FF035,

    ['p1_character'] = 0x0C1FF044,
    ['p1_health'] = 0x0C1FF02A,
    ['p1_health_bar'] = 0x0C200FEC,
    ['p1_recovery_frames'] = 0x0C200BB2,
    ['p1_hit_type'] = 0x0C200A05, --
    ['p1_hit_count'] = 0x0C200BA4,                      
    ['p1_hit_blocking_opp_count'] = 0x0C200BA8,         
    ['p1_move_attempt_counter'] = 0x0C200BA0,
    ['p1_combo_count'] = 0x0C2033A9, --
    ['p1_combo_damage'] = 0x0C20122E, --
    ['p1_move_damage'] = 0x0C2035BC,

    ['p2_character'] = 0x0C2013ED,
    ['p2_health'] = 0x0C2013D2,
    ['p2_health_bar'] = 0x0C203394,
    ['p2_status'] = 0x0C2013C7,
    ['p2_recovery_frames'] = 0x0C202F5A,
    ['p2_hit_count'] = 0x0C202F4C,
    ['p2_hit_blocking_opp_count'] = 0x0C202F50,
    ['p2_move_attempt_counter'] = 0x0C20B6B8,
    ['p2_stagger_check'] = 0x0C202F59,
}

StoredData = {
    ['p1_recovery_frames'] = 0,
    ['p1_move_start_all_frames'] = 0,
    ['p1_move_startup_frames'] = 0,
    ['p1_move_total_frames'] = 0,
    ['p1_move_hit_frame'] = 0,
    ['p1_move_attempt_counter'] = 0,
    ['p1_move_show_startup'] = 0,
    ['p1_prev_frame_recovery_frames'] = 0,
    ['p1_adv_frames'] = 0,
    ['p1_hit_count'] = 0,
    ['p1_hit_blocking_opp_count'] = 0,
    ['p1_hit_type'] = 0,
    ['p1_combo_count'] = 0,
    ['p1_hit_check'] = false,

    ['p2_recovery_frames'] = 0,
    ['p2_prev_frame_recovery_frames'] = 0,
    ['p2_prev_frame_hp'] = 0,
    ['p2_adv_frames'] = 0,
    ['p2_move_attempt_counter'] = 0,
    ['p2_hit_count'] = 0,
    ['p2_hit_blocking_opp_count'] = 0,
    ['p2_move_total_frames'] = 0,
    ['p2_move_hit_frame'] = 0,
    ['p2_hit_type'] = 0,
    ['p2_combo_count'] = 0,
    ['p2_hit_check'] = false,
    ['p2_staggered'] = false,

    ['calculate_startup'] = true
}

HitType = {
    [0] = "High",
    [1] = "Mid",
    [2] = "Low",
    [3] = "Mid", -- Lau's and Pai's 7K ???
    [4] = "Ground",
    [5] = "Low", -- Taka's 2K 
    ["Throw"] = "Throw"
}

Characters = {
    [0] = "Akira",
    [1] = "Jacky",
    [2] = "Sarah",
    [3] = "Kage",
    [4] = "Lau",
    [5] = "Jeffry",
    [6] = "Pai",
    [7] = "Wolf",
    [8] = "Shun",
    [9] = "Dural",
    [10] = "Lion",
    [11] = "Aoi",
    [12] = "Taka",
}

CharactersWithLowThrows = {
    [5] = true,
    [7] = true,
    [11] = true,
    [12] = true,
}

HighThrowValues = {
    [0x8800] = true, -- front throw
    [0x0808] = true, -- side throw
    [0x0810] = true, -- side throw
    [0x2800] = true  -- back throw
}

LowThrowValues = {
    [0x4800] = true, -- front throw
    [0x0802] = true, -- side throw
    [0x0801] = true, -- side throw
    [0x0C00] = true  -- back throw
}

FrameDataWindow = {
    ["startup"] = "",
    ["advantage"] = 0,
    ["type"] = "",
    ["combo"] = "",
    ["can_throw"] = ""
}

-- utils
function read16(address_name)
    return MEMORY.read16(MEMORY_ADDRESSES[address_name])
end

function read8(address_name)
    return MEMORY.read8(MEMORY_ADDRESSES[address_name])
end

function clear_table(table)
    for key,value in pairs(table) do
        table[key] = ""
    end
end

-- Frame data functions
function update_p1_advantage()
    local curr_adv_frames = read16("p2_recovery_frames") - read16("p1_recovery_frames")
    local p2_status = read8('p2_status')

    if StoredData['p1_hit_check'] or StoredData['p2_hit_check'] or
      (curr_adv_frames ~= 0 and (curr_adv_frames == StoredData['p1_prev_frame_recovery_frames'])) then
            StoredData['p1_adv_frames'] = curr_adv_frames
    end
end

function set_hit_check_flag(player_num)
    if is_normal_hit(player_num) or hit_is_blocked(player_num) then
        StoredData['p'.. player_num .. '_hit_check'] = true
        StoredData['p' .. player_num .. '_hit_type'] = read8("p" .. player_num .. "_hit_type")
        return true
    end

    StoredData['p' .. player_num .. '_hit_check'] = false
    return false
end

function is_normal_hit(player_num)
    local addr_name = 'p' .. player_num .. '_hit_count'
    local current_hit_counter = read16(addr_name)
    local saved_counter = StoredData[addr_name] or 0

    if current_hit_counter ~= saved_counter then
        StoredData[addr_name] = current_hit_counter
        return true
    end

    return false
end

function hit_is_blocked(player_num)
    local addr_name = 'p' .. player_num .. '_hit_blocking_opp_count'
    local current_counter = read16(addr_name)

    if current_counter ~= StoredData[addr_name] then
        StoredData[addr_name] = current_counter
        return true
    end

    return false
end

function calculate_startup_for_p1()
    local move_attempt_counter = read8('p1_move_attempt_counter')

    if move_attempt_counter ~= StoredData['p1_move_attempt_counter'] then
        StoredData['p1_move_attempt_counter'] = move_attempt_counter
        StoredData['p1_move_startup_frames'] = 1
        StoredData['calculate_startup'] = true
        return
    end

    if move_attempt_counter == StoredData['p1_move_attempt_counter'] and StoredData['p1_move_startup_frames'] >= 300 then
        StoredData['calculate_startup'] = false
    end

    if StoredData['calculate_startup'] == false then
        return
    end

    if move_attempt_counter == StoredData['p1_move_attempt_counter'] then
        StoredData['p1_move_startup_frames'] = StoredData['p1_move_startup_frames'] + 1
    end

    if StoredData["p1_hit_check"] then
        StoredData['p1_move_show_startup'] = StoredData['p1_move_startup_frames']
        StoredData['calculate_startup'] = false
    end
end

function update_combo_values()
    local combo_counter = read8("p1_combo_count")
    local combo_value = read8("p1_combo_damage")

    if combo_counter == 0 and StoredData["p1_hit_check"] then
        StoredData['p1_combo_count'] = 0
        StoredData['p1_combo_damage'] = 0
    end

    if combo_counter == 1 then
        StoredData['p1_combo_count'] = combo_counter
        StoredData['p1_combo_damage'] = combo_value
    elseif combo_counter > StoredData['p1_combo_count'] then
        StoredData['p1_combo_count'] = combo_counter
        StoredData['p1_combo_damage'] = combo_value
    end

    if combo_value ~= StoredData['p1_combo_damage'] and StoredData['p2_prev_frame_hp'] ~= read8('p2_health') then
        StoredData['p1_combo_damage'] = combo_value
    end
end

function throwable()
    character = read8('p1_character')
    can_throw = read16('can_throw')

    if HighThrowValues[can_throw] or
    (LowThrowValues[can_throw] and (character == 7 or character == 5)) or -- jeffry and wolf can low throw on any side
    (can_throw == 0x4800 and (character == 6 or character == 11)) or -- aoi and pai can low throw only on front
    ((can_throw == 0x4800 or can_throw == 0x0C00) and character == 12) then -- taka can low throw on front and back
        return "YES"
    else
        return "NO"
    end
end

-- flycast 
function Overlay()
    if flycast.state.gameId ~= "MK-51001" then
        return
    end

    update_frame_data()
    create_overlay()

    StoredData['p1_prev_frame_recovery_frames'] = read8('p2_recovery_frames') - read8('p1_recovery_frames')
    StoredData['p2_prev_frame_hp'] = read8('p2_health')
end

function update_frame_data()
    set_hit_check_flag(1)
    -- set_hit_check_flag(2)
    calculate_startup_for_p1()
    update_combo_values()
    update_p1_advantage()

    FrameDataWindow["startup"] = StoredData['p1_move_show_startup']
    FrameDataWindow["advantage"] = StoredData['p1_adv_frames']
    FrameDataWindow["type"] = HitType[StoredData["p1_hit_type"]]

    if FrameDataWindow["type"] == "Throw" then
        FrameDataWindow["combo"] = StoredData["p1_combo_damage"]
        FrameDataWindow["startup"] = ''
        FrameDataWindow["advantage"] = ''
    else
        FrameDataWindow["combo"] = StoredData["p1_combo_damage"] .. " (" .. StoredData["p1_combo_count"] .. " hits)"
    end

    if read8("p2_status") == 13 then -- if opponent is thrown
        clear_table(FrameDataWindow)

        FrameDataWindow["combo"] = StoredData["p1_combo_damage"]
        StoredData['p1_adv_frames'] = 0
        StoredData['p1_move_show_startup'] = 0
        StoredData["p1_combo_count"] = 0
        StoredData["p1_hit_type"] = "Throw"
    end

    if read8("p2_status") == 10 or read16("p2_status") == 11 then -- if opponent in juggle state or on the floor
        StoredData['p1_adv_frames'] = 0
        FrameDataWindow["advantage"] = ''
    end
    -- if MEMORY.read8(0xC2013C5) == 7 and MEMORY.read8(0x0C2013EE) == 2 and MEMORY.read8(0x0C2013EF) == 1 then
    --     FrameDataWindow["advantage"] = ''
    -- end

    FrameDataWindow["can_throw"] = throwable()
end

function create_overlay()
    substate_in_round = 9

    if read8("game_substate") ~= substate_in_round then
        return
    end

    local ui = flycast.ui
    local frame_data_width = 250
    local frame_data_height = 0
    local frame_data_y = math.floor((STATE.display.height / 2) + (STATE.display.height / 4))
    local frame_data_x = math.floor((STATE.display.width / 2) - (frame_data_width / 2))

    ui.beginWindow("Frame data", frame_data_x, frame_data_y, frame_data_width, frame_data_height)
        ui.text("Startup:")
        ui.rightText(FrameDataWindow["startup"])

        ui.text("Advantage:")
        if StoredData['p1_adv_frames'] <= -8 then
            ui.rightTextColor(FrameDataWindow["advantage"], 255, 0, 0, 255)
        else
            ui.rightText(FrameDataWindow["advantage"])
        end

        ui.text("Type:")
        ui.rightText(FrameDataWindow["type"])

        ui.text("Combo damage:")
        ui.rightText(FrameDataWindow["combo"])

        ui.text("Can throw: ")
        ui.rightText(FrameDataWindow["can_throw"])

    ui.endWindow()
end

flycast_callbacks = {
    overlay = Overlay
}

--[[
Player statuses:
1 - stand still
3 - walk towards
4 - backdash
5 - crouch walk toward
7 - jump
8 - block 
10 - was hit
11 - on the ground
13 - throwed
14 - stagger
]]--
