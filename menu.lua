local internetmenu = {
  { "chromium", "chromium" },
  { "chromium (incognito)", "chromium --incognito" },
  { "firefox", "/usr/bin/firefox" },
}

local misc_menu = {
  { "keepass", "keepassx" },
  { "IntelliJ", "idea.sh" },
  { "VSCode", "code" },
}

local system_menu = {
  { "reboot", "systemctl reboot" },
  { "shutdown", "systemctl poweroff" },
}

menu = {
  { "internet", internetmenu },
  { "misc", misc_menu },
  { "system", system_menu },
}

return menu
