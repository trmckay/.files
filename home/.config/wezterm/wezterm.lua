local wezterm = require("wezterm")

local function get_font_size()
  if wezterm.target_triple:find(".*-darwin$") then
    return 12
  else
    return 8
  end
end

return {
  font_size = get_font_size(),
  color_scheme = "terafox",
  hide_tab_bar_if_only_one_tab = true,
  initial_cols = 100,
  initial_rows = 40,
  native_macos_fullscreen_mode = true,
  audible_bell = "Disabled",
  freetype_load_target = "Light",
}
