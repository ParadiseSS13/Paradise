var/list/chatResources = list(
	"goon/browserassets/js/jquery.min.js",
	"goon/browserassets/js/jquery.mark.min.js",
	"goon/browserassets/js/json2.min.js",
	"goon/browserassets/js/twemoji.min.js",
	"goon/browserassets/js/browserOutput.js",
	"goon/browserassets/css/fonts/fontawesome-webfont.eot",
	"goon/browserassets/css/fonts/fontawesome-webfont.svg",
	"goon/browserassets/css/fonts/fontawesome-webfont.ttf",
	"goon/browserassets/css/fonts/fontawesome-webfont.woff",
	"goon/browserassets/css/fonts/PxPlus_IBM_MDA.ttf",
	"goon/browserassets/css/font-awesome.css",
	"goon/browserassets/css/browserOutput.css",
	"goon/browserassets/css/browserOutput-dark.css",
	"goon/browserassets/json/unicode_9_annotations.json",
	"goon/browserassets/html/saveInstructions.html"
)

//Should match the value set in the browser js
#define MAX_COOKIE_LENGTH 5

/var/savefile/iconCache = new /savefile("data/iconCache.sav")
/var/chatDebug = file("data/chatDebug.log")

/datum/chatOutput
	var/client/owner = null
	// How many times client data has been checked
	var/total_checks = 0
	// When to next clear the client data checks counter
	var/next_time_to_clear = 0
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
		spawn()
			alert(owner.mob, "Updated chat window does not exist. If you are using a custom skin file please allow the game to update.")
		broken = TRUE
		return 0

	if(!owner) // In case the client vanishes before winexists returns
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

	for(var/attempts in 1 to 5)
		for(var/asset in global.chatResources)
			owner << browse_rsc(file(asset))

		for(var/subattempts in 1 to 3)
			owner << browse(file2text("goon/browserassets/html/browserOutput.html"), "window=browseroutput")
			sleep(10 SECONDS)
			if(!owner || loaded)
				return

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
	if(owner.holder)
		loadAdmin()
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

/datum/chatOutput/proc/loadAdmin()
	var/data = json_encode(list("loadAdminCode" = replacetext(replacetext(file2text("goon/browserassets/html/adminOutput.html"), "\n", ""), "\t", "")))
	ehjax_send(data = url_encode(data))

/datum/chatOutput/proc/sendClientData()
	var/list/deets = list("clientData" = list())
	deets["clientData"]["ckey"] = owner.ckey
	deets["clientData"]["ip"] = owner.address
	deets["clientData"]["compid"] = owner.computer_id
	var/data = json_encode(deets)
	ehjax_send(data = data)

/datum/chatOutput/proc/analyzeClientData(cookie = "")
	//Spam check
	if(world.time  >  next_time_to_clear)
		next_time_to_clear = world.time + (3 SECONDS)
		total_checks = 0
	total_checks += 1
	if(total_checks > SPAM_TRIGGER_AUTOMUTE)
		message_admins("[key_name(owner)] kicked for goonchat topic spam")
		qdel(owner)
		return

	if(!cookie)
		return

	if(cookie != "none")
		var/list/connData = json_decode(cookie)
		if(connData && islist(connData) && connData.len > 0 && connData["connData"])
			connectionHistory = connData["connData"]
			var/list/found = new()
			if(connectionHistory.len > MAX_COOKIE_LENGTH)
				message_admins("[key_name(src.owner)] was kicked for an invalid ban cookie)")
				qdel(owner)
				return
			for(var/i = connectionHistory.len; i >= 1; i--)
				if(QDELETED(owner))
					//he got cleaned up before we were done
					return
				var/list/row = connectionHistory[i]
				if(!row || row.len < 3 || !(row["ckey"] && row["compid"] && row["ip"]))
					return
				if(world.IsBanned(key=row["ckey"], address=row["ip"], computer_id=row["compid"], type=null, check_ipintel=FALSE))
					found = row
					break
				CHECK_TICK
			//Add autoban using the DB_ban_record function
			//Uh oh this fucker has a history of playing on a banned account!!
			if (found.len > 0)
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

/proc/bicon(var/obj, var/use_class = 1)
	var/class = use_class ? "class='icon misc'" : null
	if (!obj)
		return

	if (isicon(obj))
		if (!bicon_cache["\ref[obj]"]) // Doesn't exist yet, make it.
			bicon_cache["\ref[obj]"] = icon2base64(obj)

		return "<img [class] src='data:image/png;base64,[bicon_cache["\ref[obj]"]]'>"

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
	if(use_class)
		class = "class='icon [A.icon_state]'"

	return "<img [class] src='data:image/png;base64,[bicon_cache[key]]'>"

/proc/is_valid_tochat_message(message)
	return istext(message)

/proc/is_valid_tochat_target(target)
	return !istype(target, /savefile) && (ismob(target) || islist(target) || isclient(target) || target == world)

var/to_chat_filename
var/to_chat_line
var/to_chat_src
// Call using macro: to_chat(target, message, flag)
/proc/to_chat_immediate(target, message, flag)
	if(!is_valid_tochat_message(message) || !is_valid_tochat_target(target))
		target << message

		// Info about the "message"
		if(isnull(message))
			message = "(null)"
		else if(istype(message, /datum))
			var/datum/D = message
			message = "([D.type]): '[D]'"
		else if(!is_valid_tochat_message(message))
			message = "(bad message) : '[message]'"

		// Info about the target
		var/targetstring = "'[target]'"
		if(istype(target, /datum))
			var/datum/D = target
			targetstring += ", [D.type]"

		// The final output
		log_runtime(new/exception("DEBUG: to_chat called with invalid message/target.", to_chat_filename, to_chat_line), to_chat_src, list("Message: '[message]'", "Target: [targetstring]"))
		return

	else if(is_valid_tochat_message(message))
		if(istext(target))
			log_runtime(EXCEPTION("Somehow, to_chat got a text as a target"))
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

		// url_encode it TWICE, this way any UTF-8 characters are able to be decoded by the javascript.
		var/output_message = "[url_encode(url_encode(message))]"
		if(flag)
			output_message += "&[url_encode(flag)]"

		target << output(output_message, "browseroutput:output")

/proc/__to_chat(target, message, flag)
	if(Master.current_runlevel == RUNLEVEL_INIT || !SSchat?.initialized)
		to_chat_immediate(target, message, flag)
		return
	SSchat.queue(target, message, flag)

#undef MAX_COOKIE_LENGTH
