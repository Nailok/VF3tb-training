STATE = flycast.state
MEMORY = flycast.memory

MEMORY_ADDRESSES = {
    ["game_substate"] = 0x0C29B86F,
    ["round_timer"] = 0x0C29BCD8,
    ["round_counter"] = 0x0C29BCDE,
    ["hitboxes"] = 0x0C29BCC0,

    [1] = {
        ["character"] = 0x0C1FF044,
        ["health"] = 0x0C1FF02A,
        ["health_bar"] = 0x0C200FEC,
        ["recovery_frames"] = 0x0C200BB2,
        ["hit_type"] = 0x0C200A05,
        ["hit_count"] = 0x0C200BA4,
        ["hit_blocking_opp_count"] = 0x0C200BA8,
        ["move_attempt_counter"] = 0x0C200BA0,
        ["combo_count"] = 0x0C2033A9,
        ["combo_damage"] = 0x0C20122E,
        ["move_damage"] = 0x0C2035BC,
        ["status"] = 0x0C1FF01F,
        ["can_throw"] = 0x0C1FF035,
    },

    [2] = {
        ["character"] = 0x0C2013ED,
        ["health"] = 0x0C2013D2,
        ["health_bar"] = 0x0C203394,
        ["recovery_frames"] = 0x0C202F5A,
        ["hit_type"] = 0x0C202DAD,
        ["hit_count"] = 0x0C202F4C,
        ["hit_blocking_opp_count"] = 0x0C202F50,
        ["move_attempt_counter"] = 0x0C20B6B8,
        ["combo_count"] = 0x0C201001,
        ["combo_damage"] = 0x0C2035D6,
        ["move_damage"] = 0x0C2035D6,
        ["status"] = 0x0C2013C7,
        ["can_throw"] = 0x0C2013DD,
    }
}

StoredData = {
    [1] = {
        ["recovery_frames"] = 0,
        ["prev_frame_recovery_frames"] = 0,
        ["move_startup_frames"] = 0,
        ["move_attempt_counter"] = 0,
        ["move_show_startup"] = 0,
        ["adv_frames"] = 0,
        ["hit_count"] = 0,
        ["hit_blocking_opp_count"] = 0,
        ["hit_type"] = 0,
        ["combo_count"] = 0,
        ["hit_check"] = false,
        ["throw_flag"] = false,
        ["calculate_startup"] = true
    },

    [2] = {
        ["recovery_frames"] = 0,
        ["prev_frame_recovery_frames"] = 0,
        ["move_startup_frames"] = 0,
        ["move_attempt_counter"] = 0,
        ["move_show_startup"] = 0,
        ["adv_frames"] = 0,
        ["hit_count"] = 0,
        ["hit_blocking_opp_count"] = 0,
        ["hit_type"] = 0,
        ["combo_count"] = 0,
        ["hit_check"] = false,
        ["throw_flag"] = false,
        ["calculate_startup"] = true
    },

    ["last_hit_player"] = 0,
}

HitType = {
    [0] = "High",
    [1] = "Mid",
    [2] = "Low",
    [3] = "Mid", -- Lau's and Pai's 7K
    [4] = "Ground",
    [5] = "Low", -- Taka's 2K, Kage's 66K
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

FrameDataWindowPlayer = {
    [1] = { 
        ["startup"] = "",
        ["advantage"] = 0,
        ["type"] = "",
        ["combo"] = "",
        ["can_throw"] = ""
    },

    [2] = {
        ["startup"] = "",
        ["advantage"] = 0,
        ["type"] = "",
        ["combo"] = "",
        ["can_throw"] = ""
    }
}

OppositePlayerNum = {
    [1] = 2,
    [2] = 1
}

BooleanToString = {
    [true] = "On",
    [false] = "Off"
}

TrainingData = {
    ["position"] = {
        ["crouch"] = false
    },

    ["reaction"] = {
        ["guard"] = false,
        ["guard_then_mid"] = false,
        ["guard_then_throw"] = false,
        ["guard_then_recorded_move"] = false,
        ["counter_hit"] = false
    },

    ["wakeup"] = {
        ["forward_roll"] = false,
        ["backward_roll"] = false,
        ["side_roll_right"] = false,
        ["side_roll_left"] = false,
        ["handstand"] = false,
        ["mid_kick"] = false,
        ["low_kick"] = false,
    }
}

Cheats = {
    ["infinite_health"] = {
        [1] = true,
        [2] = true
    },

    ["freeze_round_timer"] = true,
    ["freeze_round_counter"] = true
}


-- utils
function read16(address_name)
    return MEMORY.read16(MEMORY_ADDRESSES[address_name])
end

function clear_table(table)
    for key, value in pairs(table) do
        table[key] = ""
    end
end

function read8_for(player, address_name)
    return MEMORY.read8(MEMORY_ADDRESSES[player][address_name])
end

function read8(address_name)
    return MEMORY.read8(MEMORY_ADDRESSES[address_name])
end

function read16_for(player, address_name)
    return MEMORY.read16(MEMORY_ADDRESSES[player][address_name])
end

function read16(address_name)
    return MEMORY.read16(MEMORY_ADDRESSES[address_name])
end

-- Frame data functions
function update_advantage(player)
    local curr_adv_frames = read8_for(OppositePlayerNum[player], "recovery_frames") - read8_for(player, "recovery_frames")

    if
        StoredData[player]["hit_check"] or StoredData[OppositePlayerNum[player]]["hit_check"] or
            (curr_adv_frames ~= 0 and (curr_adv_frames == StoredData[player]["prev_frame_recovery_frames"]))
     then
        StoredData[player]["adv_frames"] = curr_adv_frames
    end
end

function update_hit_check_flag(player)
    if is_normal_hit(player) or hit_is_blocked(player) then
        StoredData[player]["hit_check"] = true
        StoredData[player]["hit_type"] = read8_for(player, "hit_type")
        StoredData["last_hit_player"] = player
        return
    end

    StoredData[player]["hit_check"] = false
    return
end

function is_normal_hit(player)
    local current_hit_counter = read8_for(player, "hit_count")
    local saved_counter = StoredData[player]["hit_count"]

    if current_hit_counter ~= saved_counter then
        StoredData[player]["hit_count"] = current_hit_counter
        return true
    end

    return false
end

function hit_is_blocked(player)
    local current_counter = read8_for(player, "hit_blocking_opp_count")

    if current_counter ~= StoredData[player]["hit_blocking_opp_count"] then
        StoredData[player]["hit_blocking_opp_count"] = current_counter
        return true
    end

    return false
end

function calculate_startup(player)
    local move_attempt_counter = read8_for(player, "move_attempt_counter")

    if move_attempt_counter ~= StoredData[player]["move_attempt_counter"] then
        StoredData[player]["move_attempt_counter"] = move_attempt_counter
        StoredData[player]["move_startup_frames"] = 1
        StoredData[player]["calculate_startup"] = true
        return
    end

    if move_attempt_counter == StoredData[player]["move_attempt_counter"] and StoredData[player]["move_startup_frames"] >= 300 then
        StoredData[player]["calculate_startup"] = false
    end

    if StoredData[player]["calculate_startup"] == false then
        return
    end

    if move_attempt_counter == StoredData[player]["move_attempt_counter"] then
        StoredData[player]["move_startup_frames"] = StoredData[player]["move_startup_frames"] + 1
    end

    if StoredData[player]["hit_check"] then
        StoredData[player]["move_show_startup"] = StoredData[player]["move_startup_frames"]
        StoredData[player]["calculate_startup"] = false
    end
end

function update_combo_values(player)
    local combo_counter = read8_for(player, "combo_count")
    local combo_value = read8_for(player, "combo_damage")

    if (combo_counter == 0 and StoredData[player]["hit_check"]) or combo_value == 0 then
        StoredData[player]["combo_count"] = 0
        StoredData[player]["combo_damage"] = 0
        return
    end

    if (combo_counter == 1) or combo_counter > StoredData[player]["combo_count"] then
        StoredData[player]["combo_count"] = combo_counter
        StoredData[player]["combo_damage"] = combo_value
    end

    if (combo_value ~= StoredData[player]["combo_damage"] and combo_counter ~= 0) or StoredData[player]["throw_flag"] then
        StoredData[player]["combo_damage"] = combo_value
    end
end

function throwable(player)
    character = read8_for(player, "character")
    can_throw = read16_for(player, "can_throw")

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
    if read8_for(player, "status") == 12 or read8_for(OppositePlayerNum[player], "status") == 13 then
        StoredData[player]["throw_flag"] = true
        StoredData["last_hit_player"] = player
    else
        StoredData[player]["throw_flag"] = false
    end
end

function update_framedata(player)
    local framedata_table = FrameDataWindowPlayer[player]
    update_hit_check_flag(player)
    update_throw_flag(player)
    calculate_startup(player)
    update_combo_values(player)
    update_advantage(player)

    framedata_table["startup"] = StoredData[player]["move_show_startup"]
    framedata_table["advantage"] = StoredData[player]["adv_frames"]
    framedata_table["type"] = HitType[StoredData[player]["hit_type"]]

    if framedata_table["type"] == "Throw" then
        framedata_table["combo"] = StoredData[player]["combo_damage"]
        framedata_table["startup"] = ""
        framedata_table["advantage"] = ""
    elseif StoredData["last_hit_player"] == OppositePlayerNum[player] then
        framedata_table["combo"] = ""
        framedata_table["startup"] = ""
        framedata_table["type"] = ""
    elseif StoredData[player]["combo_count"] == 1 then
        framedata_table["combo"] = StoredData[player]["combo_damage"] .. " (" .. StoredData[player]["combo_count"] .. " hit)"
    else
        framedata_table["combo"] = StoredData[player]["combo_damage"] .. " (" .. StoredData[player]["combo_count"] .. " hits)"
    end

    if StoredData[player]["throw_flag"]  then -- clear table if opponent is thrown 
        clear_table(framedata_table)

        framedata_table["combo"] = StoredData[player]["combo_damage"]
        StoredData[player]["adv_frames"] = 0
        StoredData[player]["move_show_startup"] = 0
        StoredData[player]["combo_count"] = 0
        StoredData[player]["hit_type"] = "Throw"
    end


    if read8_for(OppositePlayerNum[player], "status") == 10 or read16_for(OppositePlayerNum[player], "status") == 11 or -- if opponent in juggle state or on the floor
            read8_for(player, "status") == 10 or read8_for(player, "status") == 11 then
        StoredData[player]["adv_frames"] = 0
        framedata_table["advantage"] = ""
    end

    framedata_table["can_throw"] = throwable(player)
end

-- cheats

    function infinite_health(player)
        if Cheats["infinite_health"][player] then
            MEMORY.write8(MEMORY_ADDRESSES[player]["health"], 201)
        end
    end

    function freeze_round_counter()
        if Cheats["freeze_round_counter"] then
            MEMORY.write8(MEMORY_ADDRESSES["round_counter"], 0)
        end
    end

    function freeze_round_timer()
        if Cheats["freeze_round_timer"] then
            MEMORY.write16(MEMORY_ADDRESSES["round_timer"], 1921) -- 30 sec timer
        end
    end

    function process_cheats()
        infinite_health(1)
        infinite_health(2)
        freeze_round_timer()
        freeze_round_counter()
    end

-- training

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
    local framedata_table = FrameDataWindowPlayer[player]

    ui.beginWindow("Player "..player, framedata_x, framedata_y, framedata_width, framedata_height)
    ui.text("Startup:")
    ui.rightText(framedata_table["startup"])

    ui.text("Advantage:")
    if StoredData[player]["adv_frames"] <= -8 then
        ui.rightTextColor(framedata_table["advantage"], 255, 0, 0, 255)
    elseif StoredData[player]["adv_frames"] >= 8 then
        ui.rightTextColor(framedata_table["advantage"], 0, 255, 0, 255)
    else
        ui.rightText(framedata_table["advantage"])
    end

    ui.text("Type:")
    ui.rightText(framedata_table["type"])

    ui.text("Combo damage:")
    ui.rightText(framedata_table["combo"])

    ui.text("Can throw: ")
    ui.rightText(framedata_table["can_throw"])

    ui.endWindow()
end

function create_health_overlay()
    local ui = flycast.ui
    local framedata_width = 100
    local framedata_height = 0
    local framedata_y = math.floor(STATE.display.height / 9)
    local framedata_x = math.floor(STATE.display.width / 4)

    ui.beginWindow("p1 health", framedata_x, framedata_y, framedata_width, framedata_height)
    ui.text(read8_for(1, "health"))
    ui.endWindow()

    local framedata_width = 100
    local framedata_height = 0
    local framedata_y = math.floor(STATE.display.height / 9)
    local framedata_x = STATE.display.width - math.floor(STATE.display.width / 4) - 100

    ui.beginWindow("p2 health", framedata_x, framedata_y, framedata_width, framedata_height)
    ui.rightText(read8_for(2, "health"))
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

function create_cheats_overlay()
    local ui = flycast.ui
    local framedata_width = 250
    local framedata_height = 0
    local framedata_y = math.floor(STATE.display.height / 4) + 500
    local framedata_x = math.floor(STATE.display.width / 6)

    ui.beginWindow("Cheats", framedata_x, framedata_y, framedata_width, framedata_height)
    ui.button(
        "Infinite P1 HP: "..BooleanToString[Cheats["infinite_health"][1]],
        function()
            Cheats["infinite_health"][1] = not Cheats["infinite_health"][1]
        end
    )

    ui.button(
        "Infinite P2 HP: "..BooleanToString[Cheats["infinite_health"][2]],
        function()
            Cheats["infinite_health"][2] = not Cheats["infinite_health"][2]
        end
    )

    ui.button(
        "Freeze round counter: "..BooleanToString[Cheats["freeze_round_counter"]],
        function()
            Cheats["freeze_round_counter"] = not Cheats["freeze_round_counter"]
        end
    )

    ui.button(
        "Freeze round timer: "..BooleanToString[Cheats["freeze_round_timer"]],
        function()
            Cheats["freeze_round_timer"] = not Cheats["freeze_round_timer"]
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
    create_cheats_overlay()

    process_cheats()

    StoredData[1]["prev_frame_recovery_frames"] = read8_for(2, "recovery_frames") - read8_for(1, "recovery_frames")
    StoredData[2]["prev_frame_recovery_frames"] = read8_for(1, "recovery_frames") - read8_for(2, "recovery_frames")
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