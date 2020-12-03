local internet_menu = {
  { "chromium", "chromium" },
  { "chromium (incognito)", "chromium --incognito" },
  { "firefox", "firefox" },
  { "edge", "microsoft-edge-stable" },
  { "telegram", "telegram-desktop" },
}

local misc_menu = {
  { "keepass", "keepassxc" },
  { "IntelliJ", "idea.sh" },
  { "VSCode", "code" },
}

local system_menu = {
  { "reboot", "systemctl reboot" },
  { "shutdown", "systemctl poweroff" },
}

local multimedia_menu = {
  { "spotify", "spotify" },
}

menu = {
  { "internet", internet_menu },
  { "multimedia", multimedia_menu },
  { "misc", misc_menu },
  { "system", system_menu },
}

return menu
