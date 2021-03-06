-- Standard awesome library
local awful = require('awful')
local gears = require("gears")
require("awful.autofocus")
-- Widget and layout library
local wibox = require('wibox')
-- Theme handling library
local beautiful = require('beautiful')
-- Notification library
local naughty = require('naughty')
local menubar = require('menubar')
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Misc library
local lain = require("lain")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
beautiful.init("/home/smoak/.config/awesome/theme.lua")

local home    = os.getenv("HOME")
local exec    = awful.util.spawn
local sexec   = awful.util.spawn_with_shell

terminal = "termite"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
volume_step = "6"

local function volume_up(device)
  os.execute(string.format("pactl set-sink-volume %d +%s%%", device, volume_step))
end

local function volume_down(device)
  os.execute(string.format("pactl set-sink-volume %d -%s%%", device, volume_step))
end

local function volume_mute(device)
  os.execute(string.format("pactl set-sink-mute %d toggle", device))
end

local function lock_screen()
  exec("xscreensaver-command -lock")
end

local function interactive_screenshot()
  exec("flameshot gui")
end

modkey = "Mod4"

awful.layout.layouts = {
  awful.layout.suit.tile,         -- 1
  awful.layout.suit.tile.bottom,  -- 2
  awful.layout.suit.tile,         -- 3
  awful.layout.suit.max,          -- 4
  awful.layout.suit.magnifier,    -- 5
  awful.layout.suit.tile,         -- 6
  awful.layout.suit.tile,         -- 7
  awful.layout.suit.tile,         -- 8
  awful.layout.suit.tile,         -- 9
}

local markup = lain.util.markup
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end

  -- {{{ Spotify
function send_to_spotify(command)
  return function ()
    awful.util.spawn_with_shell("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player." .. command)
  end
end
  -- }}}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
local my_menu = require("menu")
local myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}

menu = {
  { "awesome", myawesomemenu, beautiful.awesome_icon },
}

for k,v in pairs(my_menu) do
  table.insert(menu, v)
end

mymainmenu = awful.menu({ items = menu })
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Lain Widgets

local neticon = wibox.widget.imagebox(beautiful.net_icon)
local net = lain.widget.net({
  settings = function()
    if net_now.carrier == "1" then
      net_state = "(Connected)"
    else
      net_state = "(Disconnected)"
    end
    widget:set_markup(markup.fontfg(beautiful.font, beautiful.gray, net_state))
  end
})

local volicon = wibox.widget.imagebox(beautiful.vol_icon)
local volume = lain.widget.pulse({
  settings = function()
      vlevel = volume_now.left .. "-" .. volume_now.right .. "%"
      if volume_now.muted == "yes" then
          vlevel = vlevel .. " M"
      end
      widget:set_markup(lain.util.markup(beautiful.gray, vlevel))
  end
})
volume.widget:buttons(awful.util.table.join(
  awful.button({}, 1, function() -- left click
    awful.spawn("pavucontrol")
  end),
  awful.button({}, 2, function() -- middle click
      os.execute(string.format("pactl set-sink-vol %d 100%%", volume.device))
      volume.update()
  end),
  awful.button({}, 3, function() -- right click
      volume_mute(volume.device)
      volume.update()
  end),
  awful.button({}, 4, function() -- scroll up
      volume_up(volume.device)
      volume.update()
  end),
  awful.button({}, 5, function() -- scroll down
      volume_down(volume.device)
      volume.update()
  end)
))

local cpuicon = wibox.widget.imagebox(beautiful.cpu_icon)
local cpu = lain.widget.cpu({
  settings = function()
    color = beautiful.good_color
    cpu_percent = cpu_now.usage
    if cpu_percent >= 50 and cpu_percent < 75 then
      color = beautiful.warn_color
    elseif cpu_percent >= 75 then
      color = beautiful.severe_color
    end
    widget:set_markup(markup.fontfg(beautiful.font, color, cpu_percent .. "% "))
  end
})

local memicon = wibox.widget.imagebox(beautiful.mem_icon)
local mem = lain.widget.mem({
  settings = function()
    color = beautiful.good_color
    mem_used = mem_now.used
    mem_perc = mem_now.perc
    if mem_perc >= 50 and mem_perc < 75 then
      color = beautiful.warn_color
    elseif mem_perc >= 75 then
      color = beautiful.severe_color
    end
    widget:set_markup(markup.fontfg(beautiful.font, color, mem_used .. "M "))
  end
})

local weathericon = wibox.widget.imagebox(beautiful.weather_icon)
local weather = lain.widget.weather({
  city_id = 5799841, -- Kirkland. from: http://openweathermap.org/city/5799841
  notification_preset = { cont = "xos4 Terminus 10", fg = beautiful.fg_normal },
  weather_na_markup = markup.fontfg(beautiful.font, beautiful.fg_normal, "N/A "),
  settings = function()
    descr = weather_now["weather"][1]["description"]:lower()
    temp = math.floor(weather_now["main"]["temp"])
    widget:set_markup(markup.fontfg(beautiful.font, beautiful.fg_normal, descr .. " @ " .. temp .. "°C "))
  end
})
-- }}}

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()
mytextclock.font = beautiful.font

local cal = lain.widget.cal({
  attach_to = { mytextclock },
  followtag = true,
  notification_preset = {
    font = "Monospace 10",
    fg = beautiful.fg_normal,
    bg = beautiful.bg_normal
  }
})
-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

local tags = {
  names = { "term", "web", "im", "music", "misc", "web2", "games", "8", "code" }
}


-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag(tags.names, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            cpuicon,
            cpu.widget,
            memicon,
            mem.widget,
            --baticon,
            --bat.widget,
            neticon,
            net.widget,
            volicon,
            volume.widget,
            weathericon,
            weather.widget,
            mytextclock,
            wibox.widget.systray(),
            mykeyboardlayout,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),

    -- Volume manipulation
    awful.key({ }, "XF86AudioLowerVolume",
              function()
                volume_down(volume.device)
                volume.update()
              end,
              {description = "lower volume", group = "sound"}),
    awful.key({ }, "XF86AudioRaiseVolume",
              function()
                volume_up(volume.device)
                volume.update()
              end,
              {description = "raise volume", group = "sound"}),
    awful.key({ }, "XF86AudioMute",
              function()
                volume_mute(volume.device)
                volume.update()
              end,
              {description = "mute volume", group = "sound"}),
    awful.key({ modkey }, "Up",
              function()
                volume_up(volume.device)
                volume.update()
              end,
              {description = "raise volume", group = "sound"}),
    awful.key({ modkey }, "Down",
              function()
                volume_down(volume.device)
                volume.update()
              end,
              {description = "lower volume", group = "sound"}),
    awful.key({ modkey, "Control" }, "m",
              function()
                volume_mute(volume.device)
                volume.update()
              end,
              {description = "mute volume", group = "sound"}),

    -- Custom
    awful.key({ modkey, "Shift"   }, "l",     function () lock_screen()  end,
              {description = "lock the screen", group = "custom"}),
    awful.key({ }, "F7", function() exec("xrandr --auto") end,
              {description = "auto select screen resolution", group = "custom"}),
    awful.key({ "Control", "Shift" }, "4", function() interactive_screenshot() end,
              {description = "capture screenshot interactively", group = "custom"}),
    awful.key({ "Control" }, "F7", function() exec("/home/smoak/.screenlayout/monitors.sh") end,
              {description = "", group = "custom"}),
    awful.key({ "Control", modkey, }, "e", function () exec("emoji-keyboard -k") end,
              {description = "Toggle emoji keyboard", group = "custom"}),

    -- Spotify
    awful.key({ }, "XF86AudioPlay", function() send_to_spotify("PlayPause") end,
              {description = "play/pause spotify", group = "spotify" }),
    awful.key({ }, "XF86AudioNext", function() send_to_spotify("Next") end,
              {description = "play next song", group = "spotify"}),
    awful.key({ }, "XF86AudioPrev", function() send_to_spotify("Previous") end,
              {description = "play previous song", group = "spotify"})

)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "pinentry",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
          "galculator"
        },
        role = {
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    { rule = { class = "firefox" },
      properties = { tag = tags.names[2], floating = false } },
    -- Steam
    { rule = { class = "Steam" },
       properties = { border_width = 0, floating = true, screen = 1, tag = tags.names[8] } },
    -- Teams
    { rule = { class = "Microsoft Teams - Insiders" },
      properties = { tag = tags.names[8], floating = true } },

    -- Discord
    { rule = { class = "discord" },
      properties = { tag = tags.names[3], floating = false } },

    -- VSCode
    { rule = { class = "Code" },
      properties = { tag = tags.names[9], floating = false } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ auto start
sexec(home .. "/.config/awesome/autorun.sh")
sexec(home .. "/.screenlayout/wfh.sh")
--- }}}
