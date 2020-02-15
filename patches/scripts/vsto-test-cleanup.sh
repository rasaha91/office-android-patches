--- "e:\\github\\fb-react-native-forpatch-base\\scripts\\vsto-test-cleanup.sh"	1969-12-31 16:00:00.000000000 -0800
+++ "e:\\github\\ms-react-native-forpatch\\scripts\\vsto-test-cleanup.sh"	2020-02-13 14:18:01.604281000 -0800
@@ -0,0 +1,37 @@
+#!/bin/bash
+set -ex
+
+# Script used by the VSTO build agent to cleanup the packager and web socket server
+# after the XCode test step has completed
+
+# kill whatever is occupying port 8081 (packager)
+lsof -i tcp:8081 | awk 'NR!=1 {print $2}' | xargs kill
+# kill whatever is occupying port 5555 (web socket server)
+lsof -i tcp:5555 | awk 'NR!=1 {print $2}' | xargs kill
+
+osascript <<'EOF'
+tell application "Terminal"
+  set winlist to windows where name contains "React Packager" or name contains "Metro Bundler" or name contains "Web Socket Test Server"
+  repeat with win in winlist
+    tell application "Terminal" to close win
+  end repeat
+end tell
+EOF
+
+# clear packager cache
+rm -fr $TMPDIR/react-*
+
+# clear watchman state
+rm -rf /usr/local/var/run/watchman/*
+watchman watch-del-all
+
+# dump the log files created by launchPackager.command and launchWebSocketServer.command
+THIS_DIR=$(dirname "$0")
+PACKAGER_LOG="${THIS_DIR}/launchPackager.log"
+WEBSOCKET_LOG="${THIS_DIR}/../IntegrationTests/launchWebSocketServer.log"
+if [ -f "$PACKAGER_LOG" ]; then
+  cat "$PACKAGER_LOG"
+fi
+if [ -f "$WEBSOCKET_LOG" ]; then
+  cat "$WEBSOCKET_LOG"
+fi
