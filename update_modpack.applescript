set projectDir to "/Users/alex/Code/personal/minecraft"

tell application "Terminal"
	activate
	do script "cd " & quoted form of projectDir & " && /usr/local/bin/devbox run update-modpack; exit"
end tell
