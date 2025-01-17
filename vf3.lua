STATE = flycast.state
MEMORY = flycast.memory

MEMORY_ADDRESSES = {
    ["game_substate"] = 0x0C29B86F,
    ["round_timer"] = 0x0C29BCD8,
    ["round_counter"] = 0x029BCDE,
    ["hitboxes"] = 0x0C29BCC0,

    ["p1_character"] = 0x0C1FF044,
    ["p1_health"] = 0x0C1FF02A,
    ["p1_health_bar"] = 0x0C200FEC,
    ["p1_recovery_frames"] = 0x0C200BB2,
    ["p1_hit_type"] = 0x0C200A05,
    ["p1_hit_count"] = 0x0C200BA4,
    ["p1_hit_blocking_opp_count"] = 0x0C200BA8,
    ["p1_move_attempt_counter"] = 0x0C200BA0,
    ["p1_combo_count"] = 0x0C2033A9,
    ["p1_combo_damage"] = 0x0C20122E,
    ["p1_move_damage"] = 0x0C2035BC,
    ["p1_status"] = 0x0C1FF01F,
    ["p1_can_throw"] = 0x0C1FF035,

    ["p2_character"] = 0x0C2013ED,
    ["p2_health"] = 0x0C2013D2,
    ["p2_health_bar"] = 0x0C203394,
    ["p2_recovery_frames"] = 0x0C202F5A,
    ["p2_hit_type"] = 0x0C202DAD,
    ["p2_hit_count"] = 0x0C202F4C,
    ["p2_hit_blocking_opp_count"] = 0x0C202F50,
    ["p2_move_attempt_counter"] = 0x0C20B6B8,
    ["p2_combo_count"] = 0x0C201001,
    ["p2_combo_damage"] = 0x0C2035D6,
    ["p2_move_damage"] = 0x0C2035D6,
    ["p2_status"] = 0x0C2013C7,
    ["p2_can_throw"] = 0x0C2013DD,
}

StoredData = {
    ["p1_recovery_frames"] = 0,
    ["p1_prev_frame_recovery_frames"] = 0,
    ["p1_move_startup_frames"] = 0,
    ["p1_move_attempt_counter"] = 0,
    ["p1_move_show_startup"] = 0,
    ["p1_adv_frames"] = 0,
    ["p1_hit_count"] = 0,
    ["p1_hit_blocking_opp_count"] = 0,
    ["p1_hit_type"] = 0,
    ["p1_combo_count"] = 0,
    ["p1_hit_check"] = false,
    ["p1_throw_flag"] = false,

    ["p2_recovery_frames"] = 0,
    ["p2_prev_frame_recovery_frames"] = 0,
    ["p2_move_startup_frames"] = 0,
    ["p2_move_attempt_counter"] = 0,
    ["p2_move_show_startup"] = 0,
    ["p2_adv_frames"] = 0,
    ["p2_hit_count"] = 0,
    ["p2_hit_blocking_opp_count"] = 0,
    ["p2_hit_type"] = 0,
    ["p2_combo_count"] = 0,
    ["p2_hit_check"] = false,
    ["p2_throw_flag"] = false,

    ["p1_calculate_startup"] = true,
    ["p2_calculate_startup"] = true,

    ["last_hit_player"] = 0,
}

TrainingData = {
    ["guard"] = false,
    ["kick"] = false,
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
    [12] = "Taka"
}

CharactersWithLowThrows = {
    [5] = true,
    [7] = true,
    [11] = true,
    [12] = true
}

HighThrowValues = {
    [0x8800] = true, -- front throw
    [0x0808] = true, -- side throw
    [0x0810] = true, -- side throw
    [0x2800] = true -- back throw
}

LowThrowValues = {
    [0x4800] = true, -- front throw
    [0x0802] = true, -- side throw
    [0x0801] = true, -- side throw
    [0x0C00] = true -- back throw
}

FrameDataWindowPlayer1 = {
    ["startup"] = "",
    ["advantage"] = 0,
    ["type"] = "",
    ["combo"] = "",
    ["can_throw"] = ""
}

FrameDataWindowPlayer2 = {
    ["startup"] = "",
    ["advantage"] = 0,
    ["type"] = "",
    ["combo"] = "",
    ["can_throw"] = ""
}

OppositePlayerNum = {
    [1] = 2,
    [2] = 1
}

-- utils
function read16(address_name)
    return MEMORY.read16(MEMORY_ADDRESSES[address_name])
end

function read8(address_name)
    return MEMORY.read8(MEMORY_ADDRESSES[address_name])
end

function clear_table(table)
    for key, value in pairs(table) do
        table[key] = ""
    end
end

-- Frame data functions
function update_advantage(player)
    local curr_adv_frames = read16("p"..OppositePlayerNum[player].."_recovery_frames") - read16("p"..player.."_recovery_frames")

    if
        StoredData["p"..player.."_hit_check"] or StoredData["p"..OppositePlayerNum[player].."_hit_check"] or
            (curr_adv_frames ~= 0 and (curr_adv_frames == StoredData["p"..player.."_prev_frame_recovery_frames"]))
     then
        StoredData["p"..player.."_adv_frames"] = curr_adv_frames
    end
end

function update_hit_check_flag(player_num)
    if is_normal_hit(player_num) or hit_is_blocked(player_num) then
        StoredData["p" .. player_num .. "_hit_check"] = true
        StoredData["p" .. player_num .. "_hit_type"] = read8("p" .. player_num .. "_hit_type")
        StoredData["last_hit_player"] = player_num
        return
    end

    StoredData["p" .. player_num .. "_hit_check"] = false
    return
end

function is_normal_hit(player_num)
    local addr_name = "p" .. player_num .. "_hit_count"
    local current_hit_counter = read16(addr_name)
    local saved_counter = StoredData[addr_name] or 0

    if current_hit_counter ~= saved_counter then
        StoredData[addr_name] = current_hit_counter
        return true
    end

    return false
end

function hit_is_blocked(player_num)
    local addr_name = "p" .. player_num .. "_hit_blocking_opp_count"
    local current_counter = read16(addr_name)

    if current_counter ~= StoredData[addr_name] then
        StoredData[addr_name] = current_counter
        return true
    end

    return false
end

function calculate_startup(player)
    local move_attempt_counter = read8("p"..player.."_move_attempt_counter")

    if move_attempt_counter ~= StoredData["p"..player.."_move_attempt_counter"] then
        StoredData["p"..player.."_move_attempt_counter"] = move_attempt_counter
        StoredData["p"..player.."_move_startup_frames"] = 1
        StoredData["p"..player.."_calculate_startup"] = true
        return
    end

    if move_attempt_counter == StoredData["p"..player.."_move_attempt_counter"] and StoredData["p"..player.."_move_startup_frames"] >= 300 then
        StoredData["p"..player.."_calculate_startup"] = false
    end

    if StoredData["p"..player.."_calculate_startup"] == false then
        return
    end

    if move_attempt_counter == StoredData["p"..player.."_move_attempt_counter"] then
        StoredData["p"..player.."_move_startup_frames"] = StoredData["p"..player.."_move_startup_frames"] + 1
    end

    if StoredData["p"..player.."_hit_check"] then
        StoredData["p"..player.."_move_show_startup"] = StoredData["p"..player.."_move_startup_frames"]
        StoredData["p"..player.."_calculate_startup"] = false
    end
end

function update_combo_values(player)
    local combo_counter = read8("p"..player.."_combo_count")
    local combo_value = read8("p"..player.."_combo_damage")

    if (combo_counter == 0 and StoredData["p"..player.."_hit_check"]) or combo_value == 0 then
        StoredData["p"..player.."_combo_count"] = 0
        StoredData["p"..player.."_combo_damage"] = 0
        return
    end

    if (combo_counter == 1) or combo_counter > StoredData["p"..player.."_combo_count"] then
        StoredData["p"..player.."_combo_count"] = combo_counter
        StoredData["p"..player.."_combo_damage"] = combo_value
    end

    if (combo_value ~= StoredData["p"..player.."_combo_damage"] and combo_counter ~= 0) or StoredData["p"..player.."_throw_flag"] then
        StoredData["p1_combo_damage"] = combo_value
    end
end

function throwable(player)
    character = read8("p"..player.."_character")
    can_throw = read16("p"..player.."_can_throw")

    if HighThrowValues[can_throw] or (LowThrowValues[can_throw] and
            (character == 7 or character == 5)) or -- jeffry and wolf can low throw on any side
            (can_throw == 0x4800 and (character == 6 or character == 11)) or -- aoi and pai can low throw only on front
            ((can_throw == 0x4800 or can_throw == 0x0C00) and character == 12) -- taka can low throw on front and back
     then 
        return "YES"
    else
        return "NO"
    end
end

function update_throw_flag(player)
    if read8("p"..player.."_status") == 12 or read8("p"..OppositePlayerNum[player].."_status") == 13 then
        StoredData["p"..player.."_throw_flag"] = true
        StoredData["last_hit_player"] = player
    else
        StoredData["p"..player.."_throw_flag"] = false
    end
end

function update_framedata(player)
    local framedata_table = _ENV["FrameDataWindowPlayer"..player]
    update_hit_check_flag(player)
    update_throw_flag(player)
    calculate_startup(player)
    update_combo_values(player)
    update_advantage(player)

    framedata_table["startup"] = StoredData["p"..player.."_move_show_startup"]
    framedata_table["advantage"] = StoredData["p"..player.."_adv_frames"]
    framedata_table["type"] = HitType[StoredData["p"..player.."_hit_type"]]

    if framedata_table["type"] == "Throw" then
        framedata_table["combo"] = StoredData["p"..player.."_combo_damage"]
        framedata_table["startup"] = ""
        framedata_table["advantage"] = ""
    elseif StoredData["last_hit_player"] == OppositePlayerNum[player] then
        framedata_table["combo"] = ""
        framedata_table["startup"] = ""
        framedata_table["type"] = ""
    elseif StoredData["p"..player.."_combo_count"] == 1 then
        framedata_table["combo"] = StoredData["p"..player.."_combo_damage"] .. " (" .. StoredData["p"..player.."_combo_count"] .. " hit)"
    else
        framedata_table["combo"] = StoredData["p"..player.."_combo_damage"] .. " (" .. StoredData["p"..player.."_combo_count"] .. " hits)"
    end

    if StoredData["p"..player.."_throw_flag"]  then -- clear table if opponent is thrown 
        clear_table(framedata_table)

        framedata_table["combo"] = StoredData["p"..player.."_combo_damage"]
        StoredData["p"..player.."_adv_frames"] = 0
        StoredData["p"..player.."_move_show_startup"] = 0
        StoredData["p"..player.."_combo_count"] = 0
        StoredData["p"..player.."_hit_type"] = "Throw"
    end


    if read8("p"..OppositePlayerNum[player].."_status") == 10 or read16("p"..OppositePlayerNum[player].."_status") == 11 or -- if opponent in juggle state or on the floor
            read8("p"..player.."_status") == 10 or read16("p"..player.."_status") == 11 then
        StoredData["p"..player.."_adv_frames"] = 0
        framedata_table["advantage"] = ""
    end

    framedata_table["p"..player.."_can_throw"] = throwable(player)
end

function toggle_hitboxes()
    if read8("hitboxes") == 0x10 then
        MEMORY.write8(MEMORY_ADDRESSES.hitboxes, 0x0)
    else
        MEMORY.write8(MEMORY_ADDRESSES.hitboxes, 0x10)
    end
end

function release_all_buttons(player)
    local DPAD_UP = 1 << 4
    local DPAD_DOWN = 1 << 5
    local DPAD_LEFT = 1 << 6
    local DPAD_RIGHT = 1 << 7

    local BTN_B = 1 << 1
    local BTN_A = 1 << 2
    local BTN_Y = 1 << 9
    local BTN_X = 1 << 10

    flycast.input.releaseButtons(player, DPAD_UP | DPAD_DOWN | DPAD_LEFT | DPAD_RIGHT)
    flycast.input.releaseButtons(player, BTN_X | BTN_A | BTN_Y | BTN_B)
end

function crouch(player)
    local DPAD_DOWN = 1 << 5
    local DPAD_UP = 1 << 4
    flycast.input.releaseButtons(player, DPAD_UP)
    flycast.input.pressButtons(player, DPAD_DOWN)
end

function guard(player)
    local DPAD_GUARD = 1 << 2
    flycast.input.pressButtons(player, DPAD_GUARD)
end

function create_framedata_overlay(player)
    local ui = flycast.ui
    local framedata_width = 250
    local framedata_height = 0
    local framedata_y = math.floor((STATE.display.height / 2) + (STATE.display.height / 4))
    local framedata_x = math.floor((STATE.display.width / 2) - (framedata_width / 2)) + ((player - 1) * 350) - 175
    local framedata_table = _ENV["FrameDataWindowPlayer"..player]

    ui.beginWindow("Player "..player, framedata_x, framedata_y, framedata_width, framedata_height)
    ui.text("Startup:")
    ui.rightText(framedata_table["startup"])

    ui.text("Advantage:")
    if StoredData["p"..player.."_adv_frames"] <= -8 then
        ui.rightTextColor(framedata_table["advantage"], 255, 0, 0, 255)
    elseif StoredData["p"..player.."_adv_frames"] >= 8 then
        ui.rightTextColor(framedata_table["advantage"], 0, 255, 0, 255)
    else
        ui.rightText(framedata_table["advantage"])
    end

    ui.text("Type:")
    ui.rightText(framedata_table["type"])

    ui.text("Combo damage:")
    ui.rightText(framedata_table["combo"])

    ui.text("Can throw: ")
    ui.rightText(framedata_table["p"..player.."_can_throw"])

    ui.endWindow()
end

function create_health_overlay()
    local ui = flycast.ui
    local framedata_width = 100
    local framedata_height = 0
    local framedata_y = math.floor(STATE.display.height / 9)
    local framedata_x = math.floor(STATE.display.width / 4)

    ui.beginWindow("p1 health", framedata_x, framedata_y, framedata_width, framedata_height)
    ui.text(read8("p1_health"))
    ui.endWindow()

    local framedata_width = 100
    local framedata_height = 0
    local framedata_y = math.floor(STATE.display.height / 9)
    local framedata_x = STATE.display.width - math.floor(STATE.display.width / 4) - 100

    ui.beginWindow("p2 health", framedata_x, framedata_y, framedata_width, framedata_height)
    ui.rightText(read8("p2_health"))
    ui.endWindow()
end

function create_training_overlay()
    local ui = flycast.ui
    local framedata_width = 250
    local framedata_height = 0
    local framedata_y = math.floor(STATE.display.height / 4)
    local framedata_x = math.floor(STATE.display.width / 6)

    ui.beginWindow("Training", framedata_x, framedata_y, framedata_width, framedata_height)
    ui.button(
        "Guard",
        function()
            guard(2)
        end
    )

    ui.button(
        "Crouch",
        function()
            crouch(2)
        end
    )

    ui.button(
        "Release all",
        function()
            release_all_buttons(2)
        end
    )

    ui.button(
        "Toggle hitboxes",
        function()
            toggle_hitboxes()
        end
    )

    ui.endWindow()
end

-- flycast
function Overlay()
    if flycast.state.gameId ~= "MK-51001" then
        return
    end

    substate_in_round = 9 -- round starts

    if read8("game_substate") ~= substate_in_round then
        return
    end

    update_framedata(1)
    update_framedata(2)

    create_framedata_overlay(1)
    create_framedata_overlay(2)

    create_health_overlay()
    create_training_overlay()

    MEMORY.write16(MEMORY_ADDRESSES["round_timer"], 1921) -- 30 sec timer
    MEMORY.write16(MEMORY_ADDRESSES["round_counter"], 0)

    StoredData["p1_prev_frame_recovery_frames"] = read8("p2_recovery_frames") - read8("p1_recovery_frames")
    StoredData["p2_prev_frame_recovery_frames"] = read8("p1_recovery_frames") - read8("p2_recovery_frames")
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
]]
 --


 --[[
 buttons
 0x4 - guard
 0x20 - down
 0x200 - kick
 ]]--