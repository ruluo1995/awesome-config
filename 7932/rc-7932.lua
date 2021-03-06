-----------------------------------------------------------------------------------------------------------------------
--                                                Colorless config                                                   --
-----------------------------------------------------------------------------------------------------------------------

-- Load modules
-----------------------------------------------------------------------------------------------------------------------

-- Standard awesome library
------------------------------------------------------------
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

require("awful.autofocus")

-- User modules
------------------------------------------------------------
local redflat = require("redflat")

redflat.startup:activate()

-- Error handling
-----------------------------------------------------------------------------------------------------------------------
require("7932.ercheck-config") -- load file with error handling


-- Setup theme and environment vars
-----------------------------------------------------------------------------------------------------------------------
local env = require("7932.env-config") -- load file with environment
env:init({ terminal = "alacritty", theme = "colored", fm = "ranger" })


-- Layouts setup
-----------------------------------------------------------------------------------------------------------------------
local layouts = require("7932.layout-config") -- load file with tile layouts setup
layouts:init()


-- Main menu configuration
-----------------------------------------------------------------------------------------------------------------------
local mymenu = require("7932.menu-config") -- load file with menu configuration
mymenu:init({ env = env })


-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- Separator
--------------------------------------------------------------------------------
local separator = redflat.gauge.separator.vertical()

-- Tasklist
--------------------------------------------------------------------------------
local tasklist = {}

tasklist.buttons = awful.util.table.join(
	awful.button({}, 1, redflat.widget.tasklist.action.select),
	awful.button({}, 2, redflat.widget.tasklist.action.close),
	awful.button({}, 3, redflat.widget.tasklist.action.menu),
	awful.button({}, 4, redflat.widget.tasklist.action.switch_next),
	awful.button({}, 5, redflat.widget.tasklist.action.switch_prev)
)

-- Taglist widget
--------------------------------------------------------------------------------
local taglist = {}
taglist.style = { widget = redflat.gauge.tag.orange.new, show_tip = true }
taglist.buttons = awful.util.table.join(
	awful.button({         }, 1, function(t) t:view_only() end),
	awful.button({ env.mod }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
	awful.button({         }, 2, awful.tag.viewtoggle),
	awful.button({         }, 3, function(t) redflat.widget.layoutbox:toggle_menu(t) end),
	awful.button({ env.mod }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
	awful.button({         }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({         }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

-- Textclock widget
--------------------------------------------------------------------------------
local textclock = {}
-- textclock.widget = redflat.widget.textclock({ timeformat = "%H:%M", dateformat = "%b  %d  %a" })
textclock.widget = redflat.widget.textclock({ timeformat = "%A %B %d %Y %H:%M:%S %Z", dateformat = "%b %d %Y %a", timeout = 1 })

-- Layoutbox configure
--------------------------------------------------------------------------------
local layoutbox = {}

layoutbox.buttons = awful.util.table.join(
	awful.button({ }, 1, function () awful.layout.inc( 1) end),
	awful.button({ }, 3, function () redflat.widget.layoutbox:toggle_menu(mouse.screen.selected_tag) end),
	awful.button({ }, 4, function () awful.layout.inc( 1) end),
	awful.button({ }, 5, function () awful.layout.inc(-1) end)
)

-- PA volume control
--------------------------------------------------------------------------------
local volume = {}
volume.widget = redflat.widget.pulse(nil, { widget = redflat.gauge.audio.blue.new })

-- activate player widget
redflat.float.player:init({ name = env.player })

volume.buttons = awful.util.table.join(
	awful.button({}, 4, function() volume.widget:change_volume()                end),
	awful.button({}, 5, function() volume.widget:change_volume({ down = true }) end),
	awful.button({}, 2, function() volume.widget:mute()                         end),
	awful.button({}, 3, function() redflat.float.player:show()                  end),
	awful.button({}, 1, function() redflat.float.player:action("PlayPause")     end),
	awful.button({}, 8, function() redflat.float.player:action("Previous")      end),
	awful.button({}, 9, function() redflat.float.player:action("Next")          end)
)


--[[
-- System resource monitoring widgets
--------------------------------------------------------------------------------
local sysmon = { widget = {}, buttons = {} }

-- battery
sysmon.widget.battery = redflat.widget.battery(
	{ func = redflat.system.pformatted.bat(25), arg = "BAT0" },
	{ timeout = 60, widget = redflat.gauge.monitor.dash }
)

-- network speed
sysmon.widget.network = redflat.widget.net(
	{
		interface = "wlp60s0",
		speed = { up = 6 * 1024^2, down = 6 * 1024^2 },
		autoscale = false
	},
	{ timeout = 2, widget = redflat.gauge.icon.double, monitor = { step = 0.1 } }
)

-- CPU usage
sysmon.widget.cpu = redflat.widget.sysmon(
	{ func = redflat.system.pformatted.cpu(80) },
	{ timeout = 2, widget = redflat.gauge.monitor.dash }
)

sysmon.buttons.cpu = awful.util.table.join(
	awful.button({ }, 1, function() redflat.float.top:show("cpu") end)
)

-- RAM usage
sysmon.widget.ram = redflat.widget.sysmon(
	{ func = redflat.system.pformatted.mem(70) },
	{ timeout = 10, widget = redflat.gauge.monitor.dash }
)

sysmon.buttons.ram = awful.util.table.join(
	awful.button({ }, 1, function() redflat.float.top:show("mem") end)
)
--]]

-- Tray widget
--------------------------------------------------------------------------------
local tray = {}
tray.widget = redflat.widget.minitray()

tray.buttons = awful.util.table.join(
	awful.button({}, 1, function() redflat.widget.minitray:toggle() end)
)


-- Screen setup
-----------------------------------------------------------------------------------------------------------------------
awful.screen.connect_for_each_screen(
	function(s)
		-- wallpaper
		env.wallpaper(s)

		-- tags
		awful.tag({ "Tag1", "Tag2", "Tag3", "Tag4", "Tag5" }, s, awful.layout.layouts[1])

		-- layoutbox widget
		layoutbox[s] = redflat.widget.layoutbox({ screen = s })

		-- taglist widget
		taglist[s] = redflat.widget.taglist({ screen = s, buttons = taglist.buttons, hint = env.tagtip }, taglist.style)

		-- tasklist widget
		tasklist[s] = redflat.widget.tasklist({ screen = s, buttons = tasklist.buttons })

		-- panel wibox
		s.panel = awful.wibar({ position = "top", screen = s, height = beautiful.panel_height or 36 })

		-- add widgets to the wibox
		s.panel:setup {
			layout = wibox.layout.align.horizontal,
			{ -- left widgets
				layout = wibox.layout.fixed.horizontal,

				env.wrapper(mymenu.widget, "mainmenu", mymenu.buttons),
				separator,
				env.wrapper(taglist[s], "taglist"),
				separator,
				s.mypromptbox,
			},
			{ -- middle widget
				layout = wibox.layout.align.horizontal,
				expand = "outside",

				nil,
				env.wrapper(tasklist[s], "tasklist"),
			},
			{ -- right widgets
				layout = wibox.layout.fixed.horizontal,

				separator,
				env.wrapper(layoutbox[s], "layoutbox", layoutbox.buttons),
				--[[
				separator,
				env.wrapper(sysmon.widget.network, "network"),
				separator,
				env.wrapper(volume.widget, "volume", volume.buttons),
				separator,
				env.wrapper(sysmon.widget.cpu, "cpu", sysmon.buttons.cpu),
				env.wrapper(sysmon.widget.ram, "ram", sysmon.buttons.ram),
				env.wrapper(sysmon.widget.battery, "battery"),
				--]]
				separator,
				env.wrapper(textclock.widget, "textclock"),
				separator,
				env.wrapper(tray.widget, "tray", tray.buttons),
			},
		}
	end
)


-- Key bindings
-----------------------------------------------------------------------------------------------------------------------

local appkeys = require("7932.appkeys-config") -- load file with application keys sheet

local hotkeys = require("7932.keys-config") -- load file with hotkeys configuration
hotkeys:init({ env = env, menu = mymenu.mainmenu, appkeys = appkeys, volume = volume.widget })

-- Rules
-----------------------------------------------------------------------------------------------------------------------
local rules = require("7932.rules-config") -- load file with rules configuration
rules:init({ hotkeys = hotkeys})


-- Titlebar setup
-----------------------------------------------------------------------------------------------------------------------
local titlebar = require("7932.titlebar-config") -- load file with titlebar configuration
titlebar:init()


-- Base signal set for awesome wm
-----------------------------------------------------------------------------------------------------------------------
local signals = require("7932.signals-config") -- load file with signals configuration
signals:init({ env = env })
