var/list/chatResources = list(
	"goon/browserassets/js/jquery.min.js",
	"goon/browserassets/js/json2.min.js",
	"goon/browserassets/js/browserOutput.js",
	"goon/browserassets/css/fonts/fontawesome-webfont.eot",
	"goon/browserassets/css/fonts/fontawesome-webfont.svg",
	"goon/browserassets/css/fonts/fontawesome-webfont.ttf",
	"goon/browserassets/css/fonts/fontawesome-webfont.woff",
	"goon/browserassets/css/font-awesome.css",
	"goon/browserassets/css/browserOutput.css"
)

/var/savefile/iconCache = new /savefile("data/iconCache.sav")
/var/chatDebug = file("data/chatDebug.log")

/datum/chatOutput
	var/client/owner = null
	var/loaded = 0
	var/list/messageQueue = list()
	var/cookieSent = 0
	var/list/connectionHistory = list()
	var/broken = FALSE

/datum/chatOutput/New(client/C)
	. = ..()

	owner = C

/datum/chatOutput/proc/start()
	if(!owner)
		return 0

	if(!winexists(owner, "browseroutput"))
		alert(owner.mob, "Updated chat window does not exist. If you are using a custom skin file please allow the game to update.")
		broken = TRUE
		return 0

	if(winget(owner, "browseroutput", "is-disabled") == "false")
		doneLoading()

	else
		load()

	return 1

/datum/chatOutput/proc/load()
	set waitfor = FALSE
	if(!owner)
		return

	for(var/attempts = 1 to 5)
		for(var/asset in global.chatResources)
			owner << browse_rsc(file(asset))

		owner << browse(file("goon/browserassets/html/browserOutput.html"), "window=browseroutput")
		sleep(20 SECONDS)
		if(!owner || loaded)
			break

/datum/chatOutput/Topic(var/href, var/list/href_list)
	if(usr.client != owner)
		return 1

	var/list/params = list()
	for(var/key in href_list)
		if(length(key) > 7 && findtext(key, "param"))
			var/param_name = copytext(key, 7, -1)
			var/item = href_list[key]
			params[param_name] = item

	var/data
	switch(href_list["proc"])
		if("doneLoading")
			data = doneLoading(arglist(params))

		if("debug")
			data = debug(arglist(params))

		if("ping")
			data = ping(arglist(params))

		if("analyzeClientData")
			data = analyzeClientData(arglist(params))

	if(data)
		ehjax_send(data = data)

/datum/chatOutput/proc/doneLoading()
	if(loaded)
		return

	loaded = TRUE
	winset(owner, "browseroutput", "is-disabled=false")
	for(var/message in messageQueue)
		to_chat(owner, message)

	messageQueue = null
	src.sendClientData()

	pingLoop()

/datum/chatOutput/proc/pingLoop()
	set waitfor = FALSE

	while (owner)
		ehjax_send(data = owner.is_afk(29 SECONDS) ? "softPang" : "pang") // SoftPang isn't handled anywhere but it'll always reset the opts.lastPang.
		sleep(30 SECONDS)

/datum/chatOutput/proc/ehjax_send(var/client/C = owner, var/window = "browseroutput", var/data)
	if(islist(data))
		data = json_encode(data)
	C << output("[data]", "[window]:ehjaxCallback")


/datum/chatOutput/proc/sendClientData()
	var/list/deets = list("clientData" = list())
	deets["clientData"]["ckey"] = owner.ckey
	deets["clientData"]["ip"] = owner.address
	deets["clientData"]["compid"] = owner.computer_id
	var/data = json_encode(deets)
	ehjax_send(data = data)

/datum/chatOutput/proc/analyzeClientData(cookie = "")
	if(!cookie)
		return

	if(cookie != "none")
		var/list/connData = json_decode(cookie)
		if(connData && islist(connData) && connData.len > 0 && connData["connData"])
			connectionHistory = connData["connData"]
			var/list/found = new()
			for(var/i = connectionHistory.len; i >= 1; i--)
				var/list/row = connectionHistory[i]
				if(!row || row.len < 3 || (!row["ckey"] && !row["compid"] && !row["ip"]))
					return
				if(world.IsBanned(row["ckey"], row["compid"], row["ip"]))
					found = row
					break

			//Uh oh this fucker has a history of playing on a banned account!!
			if (found.len > 0)
				//TODO: add a new evasion ban for the CURRENT client details, using the matched row details
				message_admins("[key_name(src.owner)] has a cookie from a banned account! (Matched: [found["ckey"]], [found["ip"]], [found["compid"]])")
				log_admin("[key_name(src.owner)] has a cookie from a banned account! (Matched: [found["ckey"]], [found["ip"]], [found["compid"]])")

	cookieSent = 1

/datum/chatOutput/proc/ping()
	return "pong"

/datum/chatOutput/proc/debug(error)
	error = "\[[time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")]\] Client : [owner.key ? owner.key : owner] triggered JS error: [error]"
	chatDebug << error

/client/verb/debug_chat()
	set hidden = 1
	chatOutput.ehjax_send(data = list("firebug" = 1))


/var/list/bicon_cache = list()

//Converts an icon to base64. Operates by putting the icon in the iconCache savefile,
// exporting it as text, and then parsing the base64 from that.
// (This relies on byond automatically storing icons in savefiles as base64)
/proc/icon2base64(var/icon/icon, var/iconKey = "misc")
	if (!isicon(icon)) return 0

	iconCache[iconKey] << icon
	var/iconData = iconCache.ExportText(iconKey)
	var/list/partial = splittext(iconData, "{")
	return replacetext(copytext(partial[2], 3, -5), "\n", "")

/proc/bicon(var/obj)
	if (!obj)
		return

	if (isicon(obj))
		if (!bicon_cache["\ref[obj]"]) // Doesn't exist yet, make it.
			bicon_cache["\ref[obj]"] = icon2base64(obj)

		return "<img class='icon misc' src='data:image/png;base64,[bicon_cache["\ref[obj]"]]'>"

	// Either an atom or somebody fucked up and is gonna get a runtime, which I'm fine with.
	var/atom/A = obj
	var/key = "[istype(A.icon, /icon) ? "\ref[A.icon]" : A.icon]:[A.icon_state]"
	if (!bicon_cache[key]) // Doesn't exist, make it.
		var/icon/I = icon(A.icon, A.icon_state, SOUTH, 1)
		if (ishuman(obj)) // Shitty workaround for a BYOND issue.
			var/icon/temp = I
			I = icon()
			I.Insert(temp, dir = SOUTH)
		bicon_cache[key] = icon2base64(I, key)

	return "<img class='icon [A.icon_state]' src='data:image/png;base64,[bicon_cache[key]]'>"

//Aliases for bicon
/proc/bi(obj)
	bicon(obj)

/proc/to_chat(target, message)
	if(istype(message, /image) || istype(message, /sound) || istype(target, /savefile) || !(ismob(target) || islist(target) || isclient(target) || target == world))
		target << message
		if (!isatom(target)) // Really easy to mix these up, and not having to make sure things are mobs makes the code cleaner.
			CRASH("DEBUG: to_chat called with invalid message")
		return

	else if(istext(message))
		if(istext(target))
			return

		message = replacetext(message, "\n", "<br>")

		message = macro2html(message)
		if(findtext(message, "\improper"))
			message = replacetext(message, "\improper", "")
		if(findtext(message, "\proper"))
			message = replacetext(message, "\proper", "")

		var/client/C
		if(istype(target, /client))
			C = target
		if(ismob(target))
			C = target:client

		if(C && C.chatOutput)
			if(C.chatOutput.broken)
				C << message
				return

			if(!C.chatOutput.loaded && C.chatOutput.messageQueue && islist(C.chatOutput.messageQueue))
				C.chatOutput.messageQueue.Add(message)
				return


		target << output(url_encode(message), "browseroutput:output")