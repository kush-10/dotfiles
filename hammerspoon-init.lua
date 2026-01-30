-- Hyper = Ctrl+Alt+Cmd+Shift (what Karabiner emits)
local hyper = {"ctrl", "alt", "cmd", "shift"}

-- Map keys -> apps
local app = {
  t = "Ghostty",
  s = "Safari",
  f = "Finder",
  m = "Spotify",
}

-- Launch or focus app
local function focus(appName)
  hs.application.launchOrFocus(appName)
end

for key, name in pairs(app) do
  hs.hotkey.bind(hyper, key, function() focus(name) end)
end
