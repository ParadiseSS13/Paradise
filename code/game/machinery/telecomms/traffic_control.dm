/obj/machinery/computer/telecomms/traffic
	name = "telecommunications traffic control"

	light_color = LIGHT_COLOR_DARKGREEN

	req_access = list(ACCESS_TCOMSAT)
	circuit = /obj/item/circuitboard/comm_traffic

	// NTTC
	var/window_id // mostly used to let the configuration datum update the user's UI
	var/unlocked = FALSE

/obj/machinery/computer/telecomms/traffic/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	unlocked = !unlocked
	to_chat(user, "<span class='notice'>This computer is now [unlocked ? "<span class='good'>Unlocked</span>" : "<span class='bad'>Locked</span>"]. Reopen the UI to see the difference.</span>")

/obj/machinery/computer/telecomms/traffic/attack_hand(mob/user)
	interact(user)

/obj/machinery/computer/telecomms/traffic/interact(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return 0

	if(GLOB.nttc_config.valid_languages.len == 1)
		GLOB.nttc_config.update_languages() // this is silly but it has to be done because NTTC inits before languages do

	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/nttc)
	assets.send(user)

	var/dat = file2text("html/nttc/dist/index.html")
	if(unlocked)
		dat += "\n<script type='text/javascript'>window.secretsunlocked = true;</script>"
	var/datum/browser/nttc/nt_browser = new(user, name, "NTTC", 720, 480, src, GLOB.nttc_config.nttc_serialize())
	nt_browser.set_content(dat)
	nt_browser.open()
	window_id = nt_browser.window_id

/obj/machinery/computer/telecomms/traffic/Topic(href, href_list)
	if(..())
		return 1

	var/mob/user = usr
	if(!istype(user) || !user.client)
		return 0

	GLOB.nttc_config.Topic(user, href_list, window_id, src)
