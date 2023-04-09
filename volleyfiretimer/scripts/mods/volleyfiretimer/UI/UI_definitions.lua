local mod = get_mod("volleyfiretimer")

local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")

local scenegraph_definition = {
  screen = UIWorkspaceSettings.screen,
  volley_fire_duration = {
    parent = "screen",
    vertical_alignment = "center",
    horizontal_alignment = "center",
    size = {
      50,
      20
    },
    position = { 0, 180, 55 }
  },
}

local widget_definitions = {
  volley_fire_duration = UIWidget.create_definition({
    {
      pass_type = "rect",
      style_id = "timer_bar",
      style = {
        size = {
          mod:get("bar_width"),
          mod:get("bar_height")
        },
        max_height = 50,
        vertical_alignment = "center",
        horizontal_alignment = "center",
        color = {
          255 * mod:get("bar_opacity"),
          mod:get("bar_color_r"),
          mod:get("bar_color_g"),
          mod:get("bar_color_b")
        },
        offset = { 0, 0, 1 }
      },
      visibility_function = function(content, style)
        local bar_enabled = mod:get("bar_enabled")
        return bar_enabled
      end
    },
    {
      pass_type = "rect",
      style_id = "timer_bar_border",
      style = {
        size = {
          mod:get("bar_width"),
          mod:get("bar_height")
        },
        max_height = 54,
        vertical_alignment = "center",
        horizontal_alignment = "center",
        color = {
          255 * mod:get("bar_opacity"),
          0,
          0,
          0
        },
        offset = { 2, 2, 0 }
      },
      visibility_function = function(content, style)
        local bar_enabled = mod:get("bar_border_enabled")
        return bar_enabled
      end
    },
    {
      pass_type = "text",
      value = "0.0",
      value_id = "timer_text",
      style_id = "timer_text",
      style = {
        font_size = mod:get("text_font_size"),
        font_type = "machine_medium",
        text_vertical_alignment = "center",
        text_horizontal_alignment = "center",
        text_color = {
          255 * mod:get("text_opacity"),
          mod:get("text_color_r"),
          mod:get("text_color_g"),
          mod:get("text_color_b")
        },
        offset = {
          mod:get("text_horizontal_offset"),
          -mod:get("text_vertical_offset"),
          2
        }
      },
      visibility_function = function(content, style)
        local bar_enabled = mod:get("text_enabled")
        return bar_enabled
      end
    },
    {
      pass_type = "text",
      value = "00x",
      value_id = "stack_text",
      style_id = "stack_text",
      style = {
        font_size = mod:get("stack_font_size"),
        font_type = "machine_medium",
        size = {
          2 * mod:get("stack_font_size"),
          1 * mod:get("stack_font_size")
        },
        text_vertical_alignment = "center",
        text_horizontal_alignment = "right",
        text_color = {
          255 * mod:get("stack_opacity"),
          mod:get("stack_color_r"),
          mod:get("stack_color_g"),
          mod:get("stack_color_b")
        },
        offset = {
          mod:get("stack_horizontal_offset"),
          -mod:get("stack_vertical_offset"),
          3
        }
      },
      visibility_function = function(content, style)
        local bar_enabled = mod:get("stack_enabled")
        return bar_enabled
      end
    }
  }, "volley_fire_duration")
}

return {
  scenegraph_definition = scenegraph_definition,
  widget_definitions = widget_definitions
}
