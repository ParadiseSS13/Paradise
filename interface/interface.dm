//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki(query as text)
	set name = "wiki"
	set desc = "Type what you want to know about.  This will open the wiki in your web browser."
	set hidden = 1
	if(config.wikiurl)
		if(query)
			var/output = config.wikiurl + "/index.php?title=Special%3ASearch&profile=default&search=" + query
			src << link(output)
		else
			src << link(config.wikiurl)
	else
		to_chat(src, "<span class='danger'>The wiki URL is not set in the server configuration.</span>")
	return

/client/verb/changes()
	set name = "Changelog"
	set desc = "View the changelog."
	set hidden = 1

	getFiles(
		'html/88x31.png',
		'html/bug-minus.png',
		'html/cross-circle.png',
		'html/hard-hat-exclamation.png',
		'html/image-minus.png',
		'html/image-plus.png',
		'html/music-minus.png',
		'html/music-plus.png',
		'html/tick-circle.png',
		'html/wrench-screwdriver.png',
		'html/spell-check.png',
		'html/burn-exclamation.png',
		'html/chevron.png',
		'html/chevron-expand.png',
		'html/changelog.css',
		'html/changelog.js',
		'html/changelog.html'
		)
	src << browse('html/changelog.html', "window=changes;size=675x650")
	update_changelog_button()
	if(prefs.lastchangelog != GLOB.changelog_hash) //if it's already opened, no need to tell them they have unread changes
		prefs.SetChangelog(src, GLOB.changelog_hash)

/client/verb/forum()
	set name = "forum"
	set desc = "Visit the forum."
	set hidden = 1
	if(config.forumurl)
		if(alert("Open the forum in your browser?",,"Yes","No")=="Yes")
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
		if(alert("This will open the rules in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(config.rulesurl)
	else
		to_chat(src, "<span class='danger'>The rules URL is not set in the server configuration.</span>")

/client/verb/github()
	set name = "GitHub"
	set desc = "Visit the GitHub page."
	set hidden = 1
	if(config.githuburl)
		if(alert("This will open our GitHub repository in your browser. Are you sure?",,"Yes","No")=="No")
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
	if(alert("This will invite you to our Discord server. Are you sure?",,"Yes","No")=="No")
		return
	src << link(durl)

/client/verb/donate()
	set name = "Donate"
	set desc = "Donate to help with hosting costs."
	set hidden = 1
	if(config.donationsurl)
		if(alert("This will open the donation page in your browser. Are you sure?",,"Yes","No")=="No")
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
\tM = me
\tT = say
\tO = OOC
\tB = resist
\tH = Holster/unholster gun if you have a holster
\tX = swap-hand
\tZ = activate held object (or y)
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
\tCtrl+B = resist
\tCtrl+H = stop pulling
\tCtrl+O = OOC
\tCtrl+X = swap-hand
\tCtrl+Z = activate held object (or Ctrl+y)
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
\tM = Me
\tT = Say
\tO = OOC
\tX = Cycle Active Modules
\tB = Resist
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
\tCtrl+X = Cycle Active Modules
\tCtrl+B = Resist
\tCtrl+O = OOC
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
\tF3 = Say
\tF4 = Me
</font>"}

	to_chat(src, hotkey_mode)
	to_chat(src, other)
