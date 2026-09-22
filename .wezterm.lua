local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- config.color_scheme = 'Dracula (Official)'
config.color_scheme = 'Firewatch'
config.use_dead_keys = false

config.initial_rows = 32
config.initial_cols = 128

config.enable_kitty_graphics = true

config.font = wezterm.font 'Hack Nerd Font'

config.use_fancy_tab_bar = true

config.hide_mouse_cursor_when_typing = false
config.inactive_pane_hsb = {
  brightness = 0.4,
}
config.max_fps = 120
-- front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"

-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
function basename(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

-- ====================================================================
-- 2. РАЗНОЦВЕТНЫЕ ВКЛАДКИ (РАНДОМНЫЕ ПАСТЕЛЬНЫЕ ЦВЕТА)
-- ====================================================================

-- Функция генерации случайного мягкого цвета (чтобы текст оставался читаемым)
local function get_random_pastel_color()
  local r = string.format("%02x", math.random(100, 200))
  local g = string.format("%02x", math.random(100, 200))
  local b = string.format("%02x", math.random(100, 200))
  return "#" .. r .. g .. b
end

-- Сводная таблица для хранения цветов созданных вкладок
local tab_colors = {}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local id = tab.tab_id
  local pane = tab.active_pane
  local title = basename(pane.foreground_process_name)

  -- Если для этой вкладки еще нет цвета, генерируем его
  if not tab_colors[id] then
    tab_colors[id] = get_random_pastel_color()
  end
  
  local bg_color = tab_colors[id]
  local title = "  " .. (tab.tab_index + 1) .. ": " .. title .. "  "

  -- Визуальный стиль активной и неактивных вкладок
  if tab.is_active then
    return {
      { Background = { Color = bg_color } },
      { Foreground = { Color = "#1a1a1a" } }, -- Темный текст на ярком фоне
      { Text = title },
    }
  else
    return {
      { Background = { Color = "#2d2d2d" } }, -- Темный фон для неактивных
      { Foreground = { Color = bg_color } },   -- Цветной текст
      { Text = title },
    }
  end
end)

-- Apply pwsh only when running on Windows
if wezterm.target_triple:find("windows") then
  -- The optional '-NoLogo' argument hides the startup banner
  config.default_prog = { 'pwsh', '-NoLogo' } 
end

-- Отключает подтверждение при закрытии главного окна
config.window_close_confirmation = 'NeverPrompt'
-- Отключает подтверждение при закрытии табов со сплитами и процессами
wezterm.on('mux-is-process-stateful', function(proc)
  return false
end)
config.skip_close_confirmation_for_processes_named = { "*" }

-- НАСТРОЙКА ГОРЯЧИХ КЛАВИШ
config.keys = {
  -- Мгновенное закрытие текущей вкладки
  { key = 'w', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentTab{ confirm = false } },
  
  -- Мгновенное закрытие всего окна
  { key = 'x', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentPane{ confirm = false } },

  -- Закрытие текущего сплита (панели) без подтверждения
  { key = 'q', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentPane{ confirm = false } },

  -- Разделение (Split) экрана по вертикали
  { key = 'v', mods = 'CTRL|ALT', action = wezterm.action.SplitHorizontal{ domain = 'CurrentPaneDomain' } },
  
  -- Разделение (Split) экрана по горизонтали
  { key = 'h', mods = 'CTRL|ALT', action = wezterm.action.SplitVertical{ domain = 'CurrentPaneDomain' } },

}

return config
