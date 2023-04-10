local mod = get_mod("volleyfiretimer")

local orientation_options = table.enum("horizontal", "vertical")
mod.orientation_options = orientation_options

return {
  name = mod:localize("mod_name"),
  description = mod:localize("mod_description"),
  is_togglable = false,
  options = {
    widgets =
    {
      {
        setting_id = "timer_bar_options",
        type = "group",
        sub_widgets = {
          {
            setting_id = "bar_enabled",
            type = "checkbox",
            default_value = true
          },
          {
            setting_id = "bar_border_enabled",
            type = "checkbox",
            default_value = true
          },
          {
            setting_id = "bar_orientation",
            type = "dropdown",
            default_value = orientation_options.horizontal,
            options = {
              { text = "bar_horizontal_option", value = orientation_options.horizontal },
              { text = "bar_vertical_option",   value = orientation_options.vertical },
            }
          },
          {
            setting_id = "bar_width",
            type = "numeric",
            range = { 1, 500 },
            default_value = 200,
            decimals_number = 0,
            step_size_value = 1
          },
          {
            setting_id = "bar_height",
            type = "numeric",
            range = { 1, 500 },
            default_value = 8,
            decimals_number = 0,
            step_size_value = 1
          }
        }
      },
      {
        setting_id = "text_options",
        type = "group",
        sub_widgets = {
          {
            setting_id = "text_enabled",
            type = "checkbox",
            default_value = true
          },
          {
            setting_id = "text_font_size",
            type = "numeric",
            range = { 12, 48 },
            default_value = 28,
            decimals_number = 0,
            step_size_value = 1
          },
          {
            setting_id = "text_horizontal_offset",
            type = "numeric",
            range = { -250, 250 },
            default_value = 130,
            decimals_number = 0,
            step_size_value = 1
          },
          {
            setting_id = "text_vertical_offset",
            type = "numeric",
            range = { -250, 250 },
            default_value = 0,
            decimals_number = 0,
            step_size_value = 1
          }
        }
      },
      {
        setting_id = "stack_options",
        type = "group",
        sub_widgets = {
          {
            setting_id = "stack_enabled",
            type = "checkbox",
            default_value = true
          },
          {
            setting_id = "stack_alert",
            type = "checkbox",
            default_value = true
          },
          {
            setting_id = "stack_font_size",
            type = "numeric",
            range = { 12, 48 },
            default_value = 22,
            decimals_number = 0,
            step_size_value = 1
          },
          {
            setting_id = "stack_horizontal_offset",
            type = "numeric",
            range = { -100, 100 },
            default_value = 0,
            decimals_number = 0,
            step_size_value = 1
          },
          {
            setting_id = "stack_vertical_offset",
            type = "numeric",
            range = { -100, 100 },
            default_value = 16,
            decimals_number = 0,
            step_size_value = 1
          }
        }
      },
      {
        setting_id = "bar_color",
        type = "group",
        sub_widgets = {
          {
            setting_id = "bar_color_r",
            type = "numeric",
            range = { 0, 255 },
            default_value = 216,
            decimals_number = 0,
            step_size_value = 1
          },
          {
            setting_id = "bar_color_g",
            type = "numeric",
            range = { 0, 255 },
            default_value = 229,
            decimals_number = 0,
            step_size_value = 1
          },
          {
            setting_id = "bar_color_b",
            type = "numeric",
            range = { 0, 255 },
            default_value = 207,
            decimals_number = 0,
            step_size_value = 1
          },
          {
            setting_id = "bar_opacity",
            type = "numeric",
            range = { 0, 1 },
            default_value = 1,
            decimals_number = 2,
            step_size_value = 0.01
          }
        }
      },
      {
        setting_id = "text_color",
        type = "group",
        sub_widgets = {
          {
            setting_id = "text_color_r",
            type = "numeric",
            range = { 0, 255 },
            default_value = 251,
            decimals_number = 0,
            step_size_value = 1
          },
          {
            setting_id = "text_color_g",
            type = "numeric",
            range = { 0, 255 },
            default_value = 193,
            decimals_number = 0,
            step_size_value = 1
          },
          {
            setting_id = "text_color_b",
            type = "numeric",
            range = { 0, 255 },
            default_value = 87,
            decimals_number = 0,
            step_size_value = 1
          },
          {
            setting_id = "text_opacity",
            type = "numeric",
            range = { 0, 1 },
            default_value = 1,
            decimals_number = 2,
            step_size_value = 0.01
          }
        }
      },
      {
        setting_id = "stack_color",
        type = "group",
        sub_widgets = {
          {
            setting_id = "stack_color_r",
            type = "numeric",
            range = { 0, 255 },
            default_value = 108,
            decimals_number = 0,
            step_size_value = 1
          },
          {
            setting_id = "stack_color_g",
            type = "numeric",
            range = { 0, 255 },
            default_value = 187,
            decimals_number = 0,
            step_size_value = 1
          },
          {
            setting_id = "stack_color_b",
            type = "numeric",
            range = { 0, 255 },
            default_value = 196,
            decimals_number = 0,
            step_size_value = 1
          },
          {
            setting_id = "stack_opacity",
            type = "numeric",
            range = { 0, 1 },
            default_value = 1,
            decimals_number = 2,
            step_size_value = 0.01
          }
        }
      },
      {
        setting_id = "mod_options",
        type = "group",
        sub_widgets = {
          {
            setting_id = "always_visible",
            type = "checkbox",
            default_value = false
          }
        }
      }
    }
  }
}
