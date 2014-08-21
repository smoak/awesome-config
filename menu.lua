local internetmenu = {
  { "chromium", "chromium --incognito" },
  { "firefox", "/usr/bin/firefox" },
}

local gamesmenu = {
  { "steam", "/usr/bin/steam" },
  { "Diablo III", "setarch i386 -3 /usr/bin/primusrun /usr/bin/wine \"/home/smoak/.wine/drive_c/Program Files (x86)/Diablo III/Diablo III Launcher.exe\"" },
  { "Guild Wars 2", "/usr/bin/primusrun /usr/bin/wine \"/home/smoak/.wine/drive_c/Program Files (x86)/Guild Wars 2/Gw2.exe\" -dx9single" },
  { "steam (wine)", "/usr/bin/primusrun /usr/bin/wine \"/home/smoak/.wine/drive_c/Program Files (x86)/Steam/Steam.exe\" -no-dwrite" },
  { "minecraft", "/usr/bin/primusrun /usr/bin/java -jar /home/smoak/games/Minecraft.jar" },
}

local misc_menu = {
  { "keepass", "keepassx" },
  { "gimp", "gimp" },
}

local system_menu = {
  { "reboot", "systemctl reboot" },
  { "shutdown", "systemctl poweroff" },
}

menu = {
  { "internet", internetmenu },
  { "games", gamesmenu },
  { "misc", misc_menu },
  { "system", system_menu },
}

return menu
