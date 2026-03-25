set projectDir to "~/Minecraft"

tell application "Terminal"
	activate
	do script "cd " & quoted form of projectDir & " && /usr/local/bin/devbox run update-modpack; exit"
end tell
