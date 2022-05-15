//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki()
	set name = "wiki"
	set desc = "Type what you want to know about.  This will open the wiki in your web browser."
	set hidden = 1
	if(config.wikiurl)
		var/query = stripped_input(src, "Enter Search:", "Wiki Search", "Homepage")
		if(query == "Homepage")
			src << link(config.wikiurl)
		else if(query)
			var/output = config.wikiurl + "/index.php?title=Special%3ASearch&profile=default&search=" + query
			src << link(output)
	else
		to_chat(src, "<span class='danger'>The wiki URL is not set in the server configuration.</span>")
	return

/client/verb/forum()
	set name = "forum"
	set desc = "Visit the forum."
	set hidden = 1
	if(config.forumurl)
		if(alert("Open the forum in your browser?", null, "Yes", "No") == "Yes")
			if(config.forum_link_url && prefs && !prefs.fuid)
				link_forum_account()
			src << link(config.forumurl)
	else
		to_chat(src, "<span class='danger'>The forum URL is not set in the server configuration.</span>")

/client/verb/rules()
	set name = "Rules"
	set desc = "View the server rules."
	set hidden = 1
	if(config.rulesurl)
		if(alert("This will open the rules in your browser. Are you sure?", null, "Yes", "No") == "No")
			return
		src << link(config.rulesurl)
	else
		to_chat(src, "<span class='danger'>The rules URL is not set in the server configuration.</span>")

/client/verb/github()
	set name = "GitHub"
	set desc = "Visit the GitHub page."
	set hidden = 1
	if(config.githuburl)
		if(alert("This will open our GitHub repository in your browser. Are you sure?", null, "Yes", "No") == "No")
			return
		src << link(config.githuburl)
	else
		to_chat(src, "<span class='danger'>The GitHub URL is not set in the server configuration.</span>")

/client/verb/discord()
	set name = "Discord"
	set desc = "Join our Discord server."
	set hidden = 1

	var/durl = config.discordurl
	if(config.forum_link_url && prefs && prefs.fuid && config.discordforumurl)
		durl = config.discordforumurl
	if(!durl)
		to_chat(src, "<span class='danger'>The Discord URL is not set in the server configuration.</span>")
		return
	if(alert("This will invite you to our Discord server. Are you sure?", null, "Yes", "No") == "No")
		return
	src << link(durl)

/client/verb/donate()
	set name = "Donate"
	set desc = "Donate to help with hosting costs."
	set hidden = 1
	if(config.donationsurl)
		if(alert("This will open the donation page in your browser. Are you sure?", null, "Yes", "No") == "No")
			return
		src << link(config.donationsurl)
	else
		to_chat(src, "<span class='danger'>The rules URL is not set in the server configuration.</span>")

/client/verb/hotkeys_help()
	set name = "Hotkey Help"
	set category = "OOC"

	var/adminhotkeys = {"<font color='purple'>
Admin:
\tF5 = Asay
\tF6 = Admin Ghost
\tF7 = Player Panel
\tF8 = Admin PM
\tF9 = Invisimin

Admin ghost:
\tCtrl+Click = Player Panel
\tCtrl+Shift+Click = View Variables
\tShift+Middle Click = Mob Info
</font>"}

	mob.hotkey_help()

	if(check_rights(R_MOD|R_ADMIN,0))
		to_chat(src, adminhotkeys)

/mob/proc/hotkey_help()
	var/hotkey_mode = {"<font color='purple'>
Hotkey-Mode: (hotkey-mode must be on)
\tTAB = toggle hotkey-mode
\tA = left
\tS = down
\tD = right
\tW = up
\tQ = drop
\tE = equip
\tR = throw
\tC = stop pulling
\tM = me
\tT = say (+SHIFT - whisper)
\tO = OOC
\tL = LOOC
\tB = resist (+SHIFT - rest)
\tH = Holster/unholster gun if you have a holster
\tX = swap-hand
\tZ = activate held object (or Y)
\tF = cycle-intents-left
\tG = cycle-intents-right
\t1 = help-intent
\t2 = disarm-intent
\t3 = grab-intent
\t4 = harm-intent
\tNumpad = Body target selection (Press 8 repeatedly for Head->Eyes->Mouth)
\tAlt(HOLD) = Alter movement intent
</font>"}

	var/other = {"<font color='purple'>
Any-Mode: (hotkey doesn't need to be on)
\tCtrl+A = left
\tCtrl+S = down
\tCtrl+D = right
\tCtrl+W = up
\tCtrl+Q = drop
\tCtrl+E = equip
\tCtrl+R = throw
\tCtrl+C = stop pulling
\tCtrl+M = me
\tCtrl+T = say (+SHIFT - whisper)
\tCtrl+O = OOC
\tCtrl+L = LOOC
\tCtrl+B = resist (+SHIFT - rest)
\tCtrl+X = swap-hand
\tCtrl+Z = activate held object (or Ctrl+Y)
\tCtrl+F = cycle-intents-left
\tCtrl+G = cycle-intents-right
\tCtrl+1 = help-intent
\tCtrl+2 = disarm-intent
\tCtrl+3 = grab-intent
\tCtrl+4 = harm-intent
\tDEL = stop pulling
\tINS = cycle-intents-right
\tHOME = drop
\tPGUP = swap-hand
\tPGDN = activate held object
\tEND = throw
\tCtrl+Numpad = Body target selection (Press 8 repeatedly for Head->Eyes->Mouth)
\tF2 = OOC
\tF3 = Say (+SHIFT - whisper)
\tF4 = Me
\tF11 = Fulscreen
\tCtrl+F11 = Fit Viewport
</font>"}

	to_chat(src, hotkey_mode)
	to_chat(src, other)

/mob/living/silicon/robot/hotkey_help()
	var/hotkey_mode = {"<font color='purple'>
Hotkey-Mode: (hotkey-mode must be on)
\tTAB = Toggle Hotkey Mode
\tA = Move Left
\tS = Move Down
\tD = Move Right
\tW = Move Up
\tQ = Unequip Active Module
\tC = Stop pulling
\tM = Me
\tT = Say (+SHIFT - whisper)
\tO = OOC
\tL = LOOC
\tX = Cycle Active Modules
\tB = Resist (+SHIFT - rest)
\tZ or Y = Activate Held Object
\tF = Cycle Intents Left
\tG = Cycle Intents Right
\t1 = Activate Module 1
\t2 = Activate Module 2
\t3 = Activate Module 3
\t4 = Toggle Intents
</font>"}

	var/other = {"<font color='purple'>
Any-Mode: (hotkey doesn't need to be on)
\tCtrl+A = Move Left
\tCtrl+S = Move Down
\tCtrl+D = Move Right
\tCtrl+W = Move Up
\tCtrl+Q = Unequip Active Module
\tCtrl+C = Stop pulling
\tCtrl+M = Me
\tCtrl+T = Say (+SHIFT - whisper)
\tCtrl+O = OOC
\tCtrl+L = LOOC
\tCtrl+X = Cycle Active Modules
\tCtrl+B = Resist (+SHIFT - rest)
\tCtrl+Z or Ctrl+Y = Activate Held Object
\tCtrl+F = Cycle Intents Left
\tCtrl+G = Cycle Intents Right
\tCtrl+1 = Activate Module 1
\tCtrl+2 = Activate Module 2
\tCtrl+3 = Activate Module 3
\tCtrl+4 = Toggle Intents
\tDEL = Pull
\tINS = Toggle Intents
\tPGUP = Cycle Active Modules
\tPGDN = Activate Held Object
\tF2 = OOC
\tF3 = Say (+SHIFT - whisper)
\tF4 = Me
\tF11 = Fulscreen
\tCtrl+F11 = Fit Viewport
</font>"}

	to_chat(src, hotkey_mode)
	to_chat(src, other)
