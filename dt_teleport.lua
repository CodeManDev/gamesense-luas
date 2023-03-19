local master_switch = ui.new_checkbox("AA", "Other", "Double tap teleport with onshot AA")

local double_tap_ref = { ui.reference("RAGE", "Aimbot", "Double tap") }
local onshot_aa_ref = { ui.reference("AA", "Other", "On shot anti-aim") }

toggled_onshot_aa = false
next_time = 0

local function on_paint_ui()
    local double_tap = ui.get(double_tap_ref[1]) and ui.get(double_tap_ref[2])
    local onshot_aa = ui.get(onshot_aa_ref[1]) and ui.get(onshot_aa_ref[2])

    if double_tap then
        ui.set(onshot_aa_ref[1], false)
        toggled_onshot_aa = true
        next_time = globals.curtime() + 0.1
    elseif toggled_onshot_aa and next_time < globals.curtime() then
        ui.set(onshot_aa_ref[1], true)
        toggled_onshot_aa = false
    end
end

ui.set_callback(master_switch, function()
    func = ui.get(master_switch) and client.set_event_callback or client.unset_event_callback

    func("paint_ui", on_paint_ui)
end)
