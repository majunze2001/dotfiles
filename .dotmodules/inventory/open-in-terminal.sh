#!/usr/bin/env bash

pluginkit -mAD -p com.apple.FinderSync -vvv
pluginkit -e "use" -u "F2547F13-4E43-4E88-9D8F-56DF05C020D8"

wang.jianing.app.OpenInTerminal-Lite LiteDefaultTerminal

defaults write /Users/jeffjma/Library/Group\ Containers/group.wang.jianing.app.OpenInTerminal/Library/Preferences/group.wang.jianing.app.OpenInTerminal.plist NeovimCommand "open -na ghostty --args -e /Users/jeffjma/.local/bin/nvim 'PATH'"
