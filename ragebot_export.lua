local clipboard = require 'gamesense/clipboard'

local weapon_type_ref = ui.reference("Rage", "Weapon type", "Weapon type")

local adaptive_settings = {
    "Enabled",
    "Target selection",
    "Target hitbox",
    "Multi-point",
    "Multi-point scale",
    "Minimum hit chance",
    "Minimum damage",
    "Minimum damage override",
    "Prefer safe point",
    "Force safe point",
    "Avoid unsafe hitboxes",
    "Prefer body aim",
    "Force body aim",
    "Force body aim on peek",
    "Quick stop",
    "Double tap",
    "Double tap hit chance",
    "Double tap fake lag limit",
    "Double tap quick stop",
    "Automatic scope",
}

local adaptive_tabs = {
    "Global",
    "G3SG1 / SCAR-20",
    "SSG 08",
    "AWP",
    "R8 Revolver",
    "Desert Eagle",
    "Pistol",
    "Zeus",
    "Rifle",
    "Shotgun",
    "SMG",
    "Machine gun",
}

local other_settings = {
    "Accuracy boost",
    "Anti-aim correction",
    "Automatic fire",
    "Automatic penetration",
    "Silent aim",
    "Remove recoil",
    "Delay shot",
    "Quick peek assist",
    "Quick peek assist mode",
    "Quick peek assist distance",
    "Duck peek assist",
    "Reduce aim step",
    "Maximum FOV",
    "Log misses due to spread",
}

references = {}
references["Aimbot"] = {}
references["Other"] = {}

for _, setting in ipairs(adaptive_settings) do
    local ref = { ui.reference("Rage", "Aimbot", setting) }
    table.insert(references["Aimbot"], {setting, ref})
end

for _, setting in ipairs(other_settings) do
    local ref = ui.reference("Rage", "Other", setting)
    table.insert(references["Other"], {setting, ref})
end

local function export() 
    local prev_weapon_type = ui.get(weapon_type_ref)

    local settings = {}

    settings["Aimbot"] = {}
    settings["Other"] = {}

    for _, tab in ipairs(adaptive_tabs) do
        settings["Aimbot"][tab] = {}

        ui.set(weapon_type_ref, tab)

        for _, setting in ipairs(references["Aimbot"]) do
            local setting_name = setting[1]
            local ref = setting[2]

            if #ref > 1 then
                settings["Aimbot"][tab][setting_name] = {}
                for i = 1, #ref do
                    settings["Aimbot"][tab][setting_name][i] = ui.get(ref[i])
                end
            else
                settings["Aimbot"][tab][setting_name] = ui.get(ref[1])
            end
        end
    end

    for _, tab in ipairs(references["Other"]) do
        local setting_name = tab[1]
        local ref = tab[2]

        settings["Other"][setting_name] = ui.get(ref)
    end

    local str = json.stringify(settings)

    clipboard.set(str)

    ui.set(weapon_type_ref, prev_weapon_type)

    print("Exported settings")
end

local function import()
    local clipboard = clipboard.get()

    if clipboard == nil then
        print("Clipboard is empty")
        return
    end

    local settings = json.parse(clipboard)

    if settings == nil then
        print("Invalid clipboard")
        return
    end

    local prev_weapon_type = ui.get(weapon_type_ref)

    for _, tab in ipairs(adaptive_tabs) do
        ui.set(weapon_type_ref, tab)

        for _, setting in ipairs(references["Aimbot"]) do
            local setting_name = setting[1]
            local ref = setting[2]

            local result = pcall(function() 
                if #ref > 1 then
                    for i = 1, #ref do
                        ui.set(ref[i], settings["Aimbot"][tab][setting_name][i])
                    end
                else
                    ui.set(ref[1], settings["Aimbot"][tab][setting_name])
                end
            end)

            if not result then
                print("Failed to import " .. setting_name .. " for " .. tab)
            end
        end
    end

    for _, tab in ipairs(references["Other"]) do
        local setting_name = tab[1]
        local ref = tab[2]

        local result = pcall(function() 
            ui.set(ref, settings["Other"][setting_name])
        end)

        if not result then
            print("Failed to import " .. setting_name)
        end
    end

    ui.set(weapon_type_ref, prev_weapon_type)

    print("Imported settings")

end

local export_button = ui.new_button("Rage", "other", "Export Rage Tab", export)
local import_button = ui.new_button("Rage", "other", "Import Rage Tab", import)
