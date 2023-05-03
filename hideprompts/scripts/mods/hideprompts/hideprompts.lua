local mod = get_mod("hideprompts")

mod:hook_safe("HudElementPlayerAbility", "set_input_text", function(self, text)
    local widgets_by_name = self._widgets_by_name
    local widget = widgets_by_name.ability
    widget.content.input_text = nil
    widget.dirty = true
end)

mod:hook_safe("HudElementPlayerWeapon", "set_input_text", function(self, text, visible)
    local widgets_by_name = self._widgets_by_name
    local widget = widgets_by_name.input_text
    widget.content.text = nil
    widget.dirty = true
end)

mod.on_setting_changed = function(setting_id)
    if setting_id == "ability_slot" then
        if mod:get("ability_slot") then
            mod:hook_disable("HudElementPlayerAbility", "set_input_text")
        else
            mod:hook_enable("HudElementPlayerAbility", "set_input_text")
        end
    elseif setting_id == "weapon_slots" then
        if mod:get("weapon_slots") then
            mod:hook_disable("HudElementPlayerWeapon", "set_input_text")
        else
            mod:hook_enable("HudElementPlayerWeapon", "set_input_text")
        end
    end
end
