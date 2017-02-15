local internetmenu = {
  { "chromium", "chromium --incognito" },
  { "firefox", "/usr/bin/firefox" },
}

local gamesmenu = {
  { "steam", "/usr/bin/steam" },
  { "Battle.net", "setarch i386 -L -B -R -3 /usr/bin/wine \"/home/smoak/.wine/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe\"" },
  { "Guild Wars", "/usr/bin/wine \"/home/smoak/.wine/drive_c/Program Files (x86)/Guild Wars/Gw.exe\" -dx8 -dsound" },
  { "Guild Wars 2", "/usr/bin/wine \"/home/smoak/.wine/drive_c/Program Files (x86)/Guild Wars 2/Gw2.exe\" -dx9single" },
  { "steam (wine)", "/usr/bin/wine \"/home/smoak/.wine/drive_c/Program Files (x86)/Steam/Steam.exe\" -no-dwrite" },
  { "minecraft", "/usr/bin/java -jar /home/smoak/games/Minecraft.jar" },
  { "factorio", "factorio" }
}

local misc_menu = {
  { "keepass", "keepassx" },
  { "gimp", "gimp" },
  { "IntelliJ", "idea.sh" },
  { "Android Studio", "android-studio" }
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
