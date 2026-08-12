local mainMod = "SUPER"

-- flags
--[[
    locked (l) -> locked, will also work when an input inhibitor (e.g. a
    lockscreen) is active.

    release (r) -> release, will trigger on release of a key.

    repeating (e) -> repeat, will repeat when held.

    non_consuming (n) -> non-consuming, key/mouse events will be passed to the active window in addition to triggering the dispatcher.

    mouse (m) -> mouse, see below

    transparent (t) -> transparent, cannot be shadowed by other binds.

    ignore_mods (i) -> ignore modifiers.
--]]

-- mouse binds
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

for key, cmd in pairs({
	-- volume
	["XF86AudioMute"] = "pamixer -t",
	["XF86AudioRaiseVolume"] = "pamixer -i 5 --allow-boost --set-limit 200",
	["XF86AudioLowerVolume"] = "pamixer -d 5 --allow-boost --set-limit 200",
	-- smal increments
	["SHIFT + XF86AudioRaiseVolume"] = "pamixer -i 1 --allow-boost --set-limit 200",
	["SHIFT + XF86AudioLowerVolume"] = "pamixer -d 1 --allow-boost --set-limit 200",
	--  brightness
	["XF86MonBrightnessUp"] = "brightnessctl --exponent=1.9 set 5%+",
	["XF86MonBrightnessDown"] = "brightnessctl --exponent=1.9 set 5%-",
}) do
	hl.bind(key, hl.dsp.exec_cmd(cmd), { locked = true, repeating = true })
end

-- NOTE: you can use wev to see the keysym for a button
--  (nix-shell -p wev)

-- media controls
for key, cmd in pairs({
	-- volume
	["XF86AudioPrev"] = "previous",
	["XF86AudioNext"] = "next",

	-- this binds both play and pause to play-pause since my headphones 
	-- alternates which one it sends if this is a problem (e.g you actually 
	-- have and use two specific play/pause buttons) then you might want to 
	-- change this
	["XF86AudioPlay"] = "play-pause",
	["XF86AudioPause"] = "play-pause",
}) do
	-- Only try the currently focused one
	-- Otherwise it's gonna try everyone (in order) until it
	-- finds an available one, which can be one that isn't focused.
	local base = [[playerctl --player="$(playerctl -l | head -n 1)" ]]

	hl.bind(key, hl.dsp.exec_cmd(base .. cmd), { locked = true, ignore_mods = true })
end

-- If we dont export that grimblast tries to create a new headless
-- display to take the image on for some reason.
-- That breaks ags and messes upp the display.
-- Disabling it seams to have no effect on the image
local function mkScreenshotBind(core)
	return (
		[[mkdir images; GRIMBLAST_HIDE_CURSOR=1 grimblast ]] --
		.. core --
		.. [[images/$(date "+%Y-%m-%-d_%H:%M:%S").png]]
	)
end

for key, cmd in pairs({
	-- manual select
	["Print"] = mkScreenshotBind("--freeze copysave area"),
	-- current screen
	["SHIFT + Print"] = mkScreenshotBind("copysave output"),
	-- all screens
	["CTRL + Print"] = mkScreenshotBind("copysave screen"),

	-- copy text using ocr
	[mainMod .. " + O"] = mkScreenshotBind("--freeze save area") .. [[ | tesseract - - | wl-copy]],
}) do
	hl.bind(key, hl.dsp.exec_cmd(cmd))
end

-- kbd binds
-- they work in vms / cant be overridden by programs
for key, disp in pairs({
	["S"] = hl.dsp.exec_cmd("$TERMINAL"),
	["Return"] = hl.dsp.exec_cmd("$TERMINAL"),

	["D"] = hl.dsp.exec_cmd("rofi -show drun"),
	["F"] = hl.dsp.exec_cmd("$BROWSER"),

	["P"] = hl.dsp.exec_cmd("color-pick"),

	["Escape"] = hl.dsp.exec_cmd("hyprlock --immediate --immediate-render"),
	["C"] = hl.dsp.window.close(),
	["M"] = hl.dsp.exit(),

	["U"] = hl.dsp.window.float({ action = "toggle" }),
	["I"] = hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }),
}) do
	hl.bind(mainMod .. " + " .. key, disp, { bypass = true })
end

-- hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("firefox"), { bypass = true })
-- hl.bind("Print", hl.dsp.exec_cmd("grimblast copy area"), { bypass = true })

local dispatchers = {
	[""] = hl.dsp.focus,
	["CTRL"] = hl.dsp.window.move,
	["SHIFT"] = hl.dsp.window.swap,
}

for mods, dis in pairs(dispatchers) do
	local prefix = mainMod
	if mods ~= "" then
		prefix = prefix .. " + " .. mods
	end

	local dirs = {
		l = { "left", "H" },
		r = { "right", "L" },
		u = { "up", "K" },
		d = { "down", "J" },
	}

	for dir, keys in pairs(dirs) do
		for _, key in ipairs(keys) do
			hl.bind( --
				prefix .. " + " .. key,
				dis({ direction = dir }),
				{ bypass = true }
			)
		end
	end
end

for x = 0, 9 do
	local nb = tostring((x + 1) % 10)
	local wn = tostring(x + 1)

	-- move active to workspace n, (preserve window focus)
	hl.bind( --
		mainMod .. " + CTRL + " .. nb,
		hl.dsp.window.move({ workspace = wn, follow = true }),
		{ bypass = true }
	)

	-- throw active to workspace n, (preserve workspace focus)
	hl.bind( --
		mainMod .. " + ALT + " .. nb,
		hl.dsp.window.move({ workspace = wn, follow = false }),
		{ bypass = true }
	)

	-- switch current workspace with workspace n
	hl.bind( --
		mainMod .. " + " .. nb,
		hl.dsp.focus({ workspace = wn, on_current_monitor = true }),
		{ bypass = true }
	)
end
