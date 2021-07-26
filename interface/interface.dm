//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki()
	set name = "wiki"
	set desc = "Type what you want to know about.  This will open the wiki in your web browser."
	set hidden = 1
	if(GLOB.configuration.url.wiki_url)
		var/query = stripped_input(src, "Enter Search:", "Wiki Search", "Homepage")
		if(query == "Homepage")
			src << link(GLOB.configuration.url.wiki_url)
		else if(query)
			var/output = "[GLOB.configuration.url.wiki_url]/index.php?title=Special%3ASearch&profile=default&search=[query]"
			src << link(output)
	else
		to_chat(src, "<span class='danger'>The wiki URL is not set in the server configuration.</span>")
	return

/client/verb/forum()
	set name = "forum"
	set desc = "Visit the forum."
	set hidden = 1
	if(GLOB.configuration.url.forum_url)
		if(alert("Open the forum in your browser?", null, "Yes", "No") == "Yes")
			if(GLOB.configuration.url.forum_link_url && prefs && !prefs.fuid)
				link_forum_account()
			src << link(GLOB.configuration.url.forum_url)
	else
		to_chat(src, "<span class='danger'>The forum URL is not set in the server configuration.</span>")

/client/verb/rules()
	set name = "Rules"
	set desc = "View the server rules."
	set hidden = 1
	if(GLOB.configuration.url.rules_url)
		if(alert("This will open the rules in your browser. Are you sure?", null, "Yes", "No") == "No")
			return
		src << link(GLOB.configuration.url.rules_url)
	else
		to_chat(src, "<span class='danger'>The rules URL is not set in the server configuration.</span>")

/client/verb/github()
	set name = "GitHub"
	set desc = "Visit the GitHub page."
	set hidden = 1
	if(GLOB.configuration.url.github_url)
		if(alert("This will open our GitHub repository in your browser. Are you sure?", null, "Yes", "No") == "No")
			return
		src << link(GLOB.configuration.url.github_url)
	else
		to_chat(src, "<span class='danger'>The GitHub URL is not set in the server configuration.</span>")

/client/verb/discord()
	set name = "Discord"
	set desc = "Join our Discord server."
	set hidden = 1

	var/durl
	// Use normal URL
	if(GLOB.configuration.url.discord_url)
		durl = GLOB.configuration.url.discord_url

	// Use forums URL if set
	if(GLOB.configuration.url.forum_link_url && GLOB.configuration?.url.discord_forum_url && prefs?.fuid)
		durl = GLOB.configuration.url.discord_forum_url

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
	if(GLOB.configuration.url.donations_url)
		if(alert("This will open the donation page in your browser. Are you sure?", null, "Yes", "No") == "No")
			return
		src << link(GLOB.configuration.url.donations_url)
	else
		to_chat(src, "<span class='danger'>The rules URL is not set in the server configuration.</span>")
