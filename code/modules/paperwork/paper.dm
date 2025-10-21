/*
 * Paper
 * also scraps of paper
 */

/obj/item/paper
	name = "paper"
	gender = PLURAL
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	inhand_icon_state = "paper"
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	pressure_resistance = 0
	slot_flags = ITEM_SLOT_HEAD
	body_parts_covered = HEAD
	resistance_flags = FLAMMABLE
	max_integrity = 50
	blocks_emissive = null
	attack_verb = list("bapped")
	dog_fashion = /datum/dog_fashion/head
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	var/header //Above the main body, displayed at the top
	var/info		//What's actually written on the paper.
	var/footer 	//The bottom stuff before the stamp but after the body
	var/info_links	//A different version of the paper which includes html links at fields and EOF
	var/stamps		//The (text for the) stamps on the paper.
	var/list/stamp_overlays = list()
	var/fields = 0		//Amount of user created fields
	var/list/stamped
	var/ico[0]      //Icons and
	var/offset_x[0] //offsets stored for later
	var/offset_y[0] //usage by the photocopier
	var/rigged = FALSE
	var/spam_flag = FALSE
	var/contact_poison // Reagent ID to transfer on contact
	var/contact_poison_volume = 0
	var/contact_poison_poisoner = null

	/// Width of the window that opens
	var/paper_width = 600
	/// Height of the window that opens
	var/paper_height = 750

	var/const/deffont = "Verdana"
	var/const/signfont = "Times New Roman"
	var/const/crayonfont = "Comic Sans MS"
	var/regex/blacklist = new("(<iframe|<embed|<script|<canvas|<video|<audio|onload)", "g") // Blacklist of naughties

	scatter_distance = 8

//lipstick wiping is in code/game/objects/items/weapons/cosmetics.dm!

/obj/item/paper/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(update_paper)), 1 DECISECONDS)

/obj/item/paper/proc/update_paper()
	update_icon()
	updateinfolinks()

/obj/item/paper/update_icon_state()
	if(info)
		icon_state = "paper_words"
		return
	icon_state = "paper"

/obj/item/paper/examine(mob/user)
	. = ..()
	. += "<span class='notice'><b>Alt-Click</b> [src] with a pen in hand to rename it.</span>"
	if(user.is_literate())
		if(in_range(user, src) || isobserver(user))
			show_content(user)
		else
			. += "<span class='notice'>You have to go closer if you want to read it.</span>"
	else
		. += "<span class='notice'>You don't know how to read.</span>"

/obj/item/paper/proc/show_content(mob/user, forceshow = 0, forcestars = 0, infolinks = 0, view = 1)
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/paper)
	assets.send(user)

	var/data
	var/stars = (!user.say_understands(null, GLOB.all_languages["Galactic Common"]) && !forceshow) || forcestars
	if(stars) //assuming all paper is written in common is better than hardcoded type checks
		data = "[header][stars(info)][footer][stamps]"
	else
		data = "[header]<div id='markdown'>[infolinks ? info_links : info]</div>[footer][stamps]"
	if(view)
		var/datum/browser/popup = new(user, "Paper[UID()]", null, paper_width, paper_height)
		popup.include_default_stylesheet = FALSE
		popup.set_content(data)
		if(!stars)
			popup.add_script("marked.js", 'html/browser/marked.js')
			popup.add_script("marked-paradise.js", 'html/browser/marked-paradise.js')
		popup.add_head_content("<title>[name]</title>")
		popup.open()
	return data

/obj/item/paper/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(is_pen(user.get_active_hand()))
		rename(user)
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/I = H.is_in_hands(/obj/item/paper)
		if(I)
			ProcFoldPlane(H, I)
			return
	return ..()

/obj/item/paper/proc/rename(mob/user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, "<span class='warning'>You cut yourself on the paper.</span>")
		return
	if(!user.is_literate())
		to_chat(user, "<span class='notice'>You don't know how to read.</span>")
		return
	var/n_name = rename_interactive(usr)
	if(isnull(n_name))
		return
	if(n_name != "")
		desc = "This is a paper titled '" + name + "'."
	else
		desc = initial(desc)
	add_fingerprint(user)

/obj/item/paper/attack_self__legacy__attackchain(mob/living/user as mob)
	user.examinate(src)
	if(rigged && (SSholiday.holidays && SSholiday.holidays[APRIL_FOOLS]))
		if(!spam_flag)
			spam_flag = TRUE
			playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
			spawn(20)
				spam_flag = FALSE
	return

/obj/item/paper/attack_ai(mob/living/silicon/ai/user as mob)
	var/dist
	if(istype(user) && user.current) //is AI
		dist = get_dist(src, user.current)
	else //cyborg or AI not seeing through a camera
		dist = get_dist(src, user)

	if(dist < 2)
		show_content(user, forceshow = 1)
	else
		show_content(user, forcestars = 1)

/obj/item/paper/attack__legacy__attackchain(mob/living/carbon/M, mob/living/carbon/user, def_zone)
	if(!ishuman(M))
		return ..()
	var/mob/living/carbon/human/H = M
	if(user.zone_selected == "eyes")
		user.visible_message("<span class='notice'>[user] holds up a paper and shows it to [H].</span>",
			"<span class='notice'>You show the paper to [H].</span>")
		to_chat(H, "<a href='byond://?src=[UID()];show_content=1'>Read \the [src]</a>")

	else if(user.zone_selected == "mouth")
		if(H == user)
			to_chat(user, "<span class='notice'>You wipe off your face with [src].</span>")
		else
			user.visible_message("<span class='warning'>[user] begins to wipe [H]'s face clean with \the [src].</span>",
								"<span class='notice'>You begin to wipe off [H]'s face.</span>")
			if(!do_after(user, 1 SECONDS, target = H) || !do_after(H, 1 SECONDS, FALSE)) // user needs to keep their active hand, H does not.
				return
			user.visible_message("<span class='notice'>[user] wipes [H]'s face clean with \the [src].</span>",
				"<span class='notice'>You wipe off [H]'s face.</span>")

		H.lip_style = null
		H.lip_color = null
		H.update_body()
	else
		return ..()

/obj/item/paper/attack_animal(mob/living/simple_animal/M)
	if(!isdog(M)) // Only dogs can eat homework.
		return
	var/mob/living/simple_animal/pet/dog/D = M
	D.changeNext_move(CLICK_CD_MELEE)
	if(world.time < D.last_eaten + 30 SECONDS)
		to_chat(D, "<span class='warning'>You are too full to try eating [src] now.</span>")
		return

	D.visible_message("<span class='warning'>[D] starts chewing the corner of [src]!</span>",
		"<span class='notice'>You start chewing the corner of [src].</span>",
		"<span class='warning'>You hear a quiet gnawing, and the sound of paper rustling.</span>")
	playsound(src, 'sound/effects/pageturn2.ogg', 100, TRUE)
	if(!do_after(D, 10 SECONDS, FALSE, src))
		return

	if(world.time < D.last_eaten + 30 SECONDS) // Check again to prevent eating multiple papers at once.
		to_chat(D, "<span class='warning'>You are too full to try eating [src] now.</span>")
		return
	D.last_eaten = world.time

	// 90% chance of a crumpled paper with illegible text.
	if(prob(90))
		var/message_ending = "."
		var/obj/item/paper/crumpled/P = new(loc)
		P.name = name
		if(info) // Something written on the paper.
			/*var/new_text = strip_html_tags(info, MAX_PAPER_MESSAGE_LEN, TRUE) // Don't want HTML stuff getting gibberished.
			P.info = Gibberish(new_text, 100)*/
			P.info = "<i>Whatever was once written here has been made completely illegible by a combination of chew marks and saliva.</i>"
			message_ending = ", the drool making it an unreadable mess!"
		P.update_icon()
		qdel(src)

		D.visible_message("<span class='warning'>[D] finishes eating [src][message_ending]</span>",
			"<span class='notice'>You finish eating [src][message_ending]</span>")
		D.emote("bark")

	// 10% chance of the paper just being eaten entirely.
	else
		D.visible_message("<span class='warning'>[D] swallows [src] whole!</span>", "<span class='notice'>You swallow [src] whole. Tasty!</span>")
		playsound(D, 'sound/items/eatfood.ogg', 50, TRUE)
		qdel(src)


/obj/item/paper/proc/addtofield(id, text, links = 0)
	if(id > MAX_PAPER_FIELDS)
		return

	var/locid = 0
	var/laststart = 1
	var/textindex = 1
	while(locid <= MAX_PAPER_FIELDS)
		var/istart = 0
		if(links)
			istart = findtext(info_links, "<span class=\"paper_field\">", laststart)
		else
			istart = findtext(info, "<span class=\"paper_field\">", laststart)

		if(istart==0)
			return // No field found with matching id

		laststart = istart+1
		locid++
		if(locid == id)
			var/iend = 1
			if(links)
				iend = findtext(info_links, "</span>", istart)
			else
				iend = findtext(info, "</span>", istart)

			//textindex = istart+26
			textindex = iend
			break

	if(links)
		var/before = copytext(info_links, 1, textindex)
		var/after = copytext(info_links, textindex)
		info_links = before + text + after
	else
		var/before = copytext(info, 1, textindex)
		var/after = copytext(info, textindex)
		info = before + text + after
		updateinfolinks()

/obj/item/paper/proc/updateinfolinks()
	info_links = info
	for(var/i in 1 to fields)
		var/write_1 = "<font face=\"[deffont]\"><a href='byond://?src=[UID()];write=[i]'>write</a></font>"
		var/write_2 = "<font face=\"[deffont]\"><a href='byond://?src=[UID()];auto_write=[i]'><span style=\"color: #409F47; font-size: 10px\">\[a\]</span></a></font>"
		addtofield(i, "[write_1][write_2]", 1)
	info_links = info_links + "<font face=\"[deffont]\"><a href='byond://?src=[UID()];write=end'>write</a></font>" + "<font face=\"[deffont]\"><a href='byond://?src=[UID()];auto_write=end'><span style=\"color: #409F47; font-size: 10px\">\[a\]</span></a></font>"

/obj/item/paper/proc/clearpaper()
	info = null
	stamps = null
	stamped = list()
	stamp_overlays = list()
	updateinfolinks()
	update_icon()

/obj/item/paper/proc/parsepencode(t, obj/item/pen/P, mob/user as mob)
	t = pencode_to_html(html_encode(t), usr, P, TRUE, TRUE, TRUE, deffont, signfont, crayonfont)
	return t

/obj/item/paper/proc/populatefields()
		//Count the fields
	var/laststart = 1
	while(fields < MAX_PAPER_FIELDS)
		var/i = findtext(info, "<span class=\"paper_field\">", laststart)
		if(i==0)
			break
		laststart = i+1
		fields++


/obj/item/paper/proc/openhelp(mob/user as mob)
	user << browse({"<html><meta charset='utf-8'><head><title>Pen Help</title></head>
	<BODY>
		<b><center>Crayon&Pen commands</center></b><br>
		<br>
		\[br\] : Creates a linebreak.<br>
		\[center\] - \[/center\] : Centers the text.<br>
		\[h1\] - \[/h1\] : Makes the text a first level heading<br>
		\[h2\] - \[/h2\] : Makes the text a second level heading<br>
		\[h3\] - \[/h3\] : Makes the text a third level heading<br>
		\[b\] - \[/b\] : Makes the text <b>bold</b>.<br>
		\[i\] - \[/i\] : Makes the text <i>italic</i>.<br>
		\[u\] - \[/u\] : Makes the text <u>underlined</u>.<br>
		\[large\] - \[/large\] : Increases the <font size = \"4\">size</font> of the text.<br>
		\[sign\] : Inserts a signature of your name in a foolproof way.<br>
		\[name\] : Inserts your regular name, not like your signature.<br>
		\[field\] : Inserts an invisible field which lets you start type from there. Useful for forms.<br>
		<br>
		<b><center>Pen exclusive commands</center></b><br>
		\[small\] - \[/small\] : Decreases the <font size = \"1\">size</font> of the text.<br>
		\[list\] - \[/list\] : A list.<br>
		\[*\] : A dot used for lists.<br>
		\[hr\] : Adds a horizontal rule.
		\[time\] : Inserts the current station time in HH:MM:SS.<br>
	</BODY></HTML>"}, "window=paper_help")

/obj/item/paper/vv_edit_var(var_name, var_value)
	if((var_name == "info") && blacklist.Find(var_value)) //uh oh, they tried to be naughty
		message_admins("<span class='danger'>EXPLOIT WARNING: ADMIN</span> [usr.ckey] attempted to write paper containing JS abusable tags!")
		log_admin("EXPLOIT WARNING: ADMIN [usr.ckey] attempted to write paper containing JS abusable tags")
		return FALSE
	return ..()

/obj/item/paper/proc/topic_href_write(id, input_element)
	var/obj/item/item_write = usr.get_active_hand() // Check to see if he still got that darn pen, also check if he's using a crayon or pen.
	add_hiddenprint(usr) // No more forging nasty documents as someone else, you jerks
	if(!is_pen(item_write) && !istype(item_write, /obj/item/toy/crayon))
		return
	if(loc != usr && !Adjacent(usr) && !((istype(loc, /obj/item/clipboard) || istype(loc, /obj/item/folder)) && ((usr in get_turf(src)) || loc.Adjacent(usr))))
		return // If paper is not in usr, then it must be near them, or in a clipboard or folder, which must be in or near usr
	if(blacklist.Find(input_element)) //uh oh, they tried to be naughty
		message_admins("<span class='danger'>EXPLOIT WARNING: </span> [usr.ckey] attempted to write paper containing JS abusable tags!")
		log_admin("EXPLOIT WARNING: [usr.ckey] attempted to write paper containing JS abusable tags")
		return FALSE
	input_element = parsepencode(input_element, item_write, usr) // Encode everything from pencode to html
	if(id != "end")
		addtofield(text2num(id), input_element) // He wants to edit a field, let him.
	else
		info += input_element // Oh, he wants to edit to the end of the file, let him.
	populatefields()
	updateinfolinks()
	item_write.on_write(src, usr)
	show_content(usr, forceshow = TRUE, infolinks = TRUE)
	update_icon()

/obj/item/paper/Topic(href, href_list)
	..()
	if(!usr || (usr.stat || usr.restrained()))
		return
	if(href_list["auto_write"])
		var/id = href_list["auto_write"]
		var/const/sign_text = "\[Sign\]"
		var/const/time_text = "\[Current time\]"
		var/const/date_text = "\[Current date\]"
		var/const/num_text = "\[Account number\]"
		var/const/pin_text = "\[PIN\]"
		var/const/station_text = "\[Station name\]"
		var/list/menu_list = list() //text items in the menu
		menu_list.Add(usr.real_name) //the real name of the character, even if it is hidden
		if(usr.real_name != usr.name) //if the player is masked or the name is different a new answer option is added
			menu_list.Add("[usr.name]")
		menu_list.Add(usr.job, //current job
			num_text, //account number
			pin_text, //pin code number
			sign_text, //signature
			time_text, //time
			date_text, //date
			station_text, // station name
			usr.gender, //current gender
			usr.dna.species //current species
		)
		var/input_element = tgui_input_list(usr, "Select the text you want to add", "Select item", menu_list)
		switch(input_element) //format selected menu items in pencode and internal data
			if(sign_text)
				input_element = "\[sign\]"
			if(time_text)
				input_element = "\[time\]"
			if(date_text)
				input_element = "\[date\]"
			if(station_text)
				input_element = "\[station\]"
			if(num_text)
				input_element = usr.mind.initial_account.account_number
			if(pin_text)
				input_element = usr.mind.initial_account.account_pin
		topic_href_write(id, input_element)
	if(href_list["write"])
		var/id = href_list["write"]
		var/input_element = input("Enter what you want to write:", "Write") as message
		topic_href_write(id, input_element)
	if(href_list["show_content"])
		var/dist = get_dist(src, usr)
		if(dist < 2)
			show_content(usr)
		else
			to_chat(usr, "<span class='notice'>I'm too far away from \the [src] to read it.</span>")

/obj/item/paper/attackby__legacy__attackchain(obj/item/P, mob/living/user, params)
	..()

	if(resistance_flags & ON_FIRE)
		return

	var/clown = FALSE
	if(user.mind && (user.mind.assigned_role == "Clown"))
		clown = TRUE

	if(istype(P, /obj/item/paper) || istype(P, /obj/item/photo))
		if(istype(P, /obj/item/paper/carbon))
			var/obj/item/paper/carbon/C = P
			if(!C.iscopy && !C.copied)
				to_chat(user, "<span class='notice'>Take off the carbon copy first.</span>")
				add_fingerprint(user)
				return
		var/obj/item/paper_bundle/B = new(src.loc, FALSE)
		if(name != "paper")
			B.name = name
		else if(P.name != "paper" && P.name != "photo")
			B.name = P.name
		user.drop_item_to_ground(P)
		if(ishuman(user))
			var/mob/living/carbon/human/h_user = user
			if(h_user.r_hand == src)
				h_user.unequip(src)
				h_user.put_in_r_hand(B)
			else if(h_user.l_hand == src)
				h_user.unequip(src)
				h_user.put_in_l_hand(B)
			else if(h_user.l_store == src)
				h_user.unequip(src)
				B.loc = h_user
				B.layer = ABOVE_HUD_LAYER
				B.plane = ABOVE_HUD_PLANE
				h_user.l_store = B
				h_user.update_inv_pockets()
			else if(h_user.r_store == src)
				h_user.unequip(src)
				B.loc = h_user
				B.layer = ABOVE_HUD_LAYER
				B.plane = ABOVE_HUD_PLANE
				h_user.r_store = B
				h_user.update_inv_pockets()
			else if(h_user.head == src)
				h_user.unequip(src)
				h_user.put_in_hands(B)
			else if(!isturf(src.loc))
				src.loc = get_turf(h_user)
				if(h_user.client)	h_user.client.screen -= src
				h_user.put_in_hands(B)
		to_chat(user, "<span class='notice'>You clip [P] to [(src.name == "paper") ? "the paper" : src.name].</span>")
		forceMove(B)
		P.loc = B
		B.amount++
		B.update_icon()

	else if(is_pen(P) || istype(P, /obj/item/toy/crayon))
		if(user.is_literate())
			var/obj/item/pen/multi/robopen/RP = P
			if(istype(P, /obj/item/pen/multi/robopen) && RP.mode == 2)
				RP.RenamePaper(user,src)
			else
				show_content(user, infolinks = 1)
			//openhelp(user)
			return
		else
			to_chat(user, "<span class='warning'>You don't know how to write!</span>")

	else if(istype(P, /obj/item/stamp))
		if((!in_range(src, usr) && loc != user && !( istype(loc, /obj/item/clipboard)) && loc.loc != user && user.get_active_hand() != P))
			return

		if(istype(P, /obj/item/stamp/clown))
			if(!clown)
				to_chat(user, "<span class='notice'>You are totally unable to use the stamp. HONK!</span>")
				return

		stamp(P)

		to_chat(user, "<span class='notice'>You stamp the paper with your rubber stamp.</span>")
		playsound(user, 'sound/items/handling/standard_stamp.ogg', 50, vary = TRUE)

	if(P.get_heat())
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(10))
			user.visible_message("<span class='warning'>[user] accidentally ignites [user.p_themselves()]!</span>", \
								"<span class='userdanger'>You miss the paper and accidentally light yourself on fire!</span>")
			user.drop_item_to_ground(P)
			user.adjust_fire_stacks(1)
			user.IgniteMob()
			return

		if(!Adjacent(user)) //to prevent issues as a result of telepathically lighting a paper
			return

		user.drop_item_to_ground(src)
		user.visible_message("<span class='danger'>[user] lights [src] ablaze with [P]!</span>", "<span class='danger'>You light [src] on fire!</span>")
		fire_act()

	add_fingerprint(user)

/obj/item/paper/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	if(!(resistance_flags & FIRE_PROOF))
		info = "<i>Heat-curled corners and sooty words offer little insight. Whatever was once written on this page has been rendered illegible through fire.</i>"

/obj/item/paper/proc/stamp(obj/item/stamp/S)
	if(length(stamp_overlays) > 49) //Do not remove this cap or you'll unleash evil upon the world
		return

	stamps += (!stamps || stamps == "" ? "<HR>" : "") + "<img src=large_[S.icon_state].png>"

	var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
	var/x
	var/y
	if(istype(S, /obj/item/stamp/captain) || istype(S, /obj/item/stamp/centcom))
		x = rand(-2, 0)
		y = rand(-1, 2)
	else
		x = rand(-2, 2)
		y = rand(-3, 2)
	offset_x += x
	offset_y += y
	stampoverlay.pixel_x = x
	stampoverlay.pixel_y = y

	if(!ico)
		ico = new
	ico += "paper_[S.icon_state]"
	stampoverlay.icon_state = "paper_[S.icon_state]"

	if(!stamped)
		stamped = new
	stamped += S.type
	stamp_overlays += stampoverlay
	update_icon(UPDATE_OVERLAYS)

/obj/item/paper/update_overlays()
	return stamp_overlays

/*
 * Premade paper
 */
/obj/item/paper/court
	name = "Judgement"
	info = "For crimes against the station, the offender is sentenced to:<BR>\n<BR>\n"

/obj/item/paper/toxin
	name = "Chemical Information"
	info = "Known Onboard Toxins:<BR>\n\tGrade A Semi-Liquid Plasma:<BR>\n\t\tHighly poisonous. You cannot sustain concentrations above 15 units.<BR>\n\t\tA gas mask fails to filter plasma after 50 units.<BR>\n\t\tWill attempt to diffuse like a gas.<BR>\n\t\tFiltered by scrubbers.<BR>\n\t\tThere is a bottled version which is very different<BR>\n\t\t\tfrom the version found in canisters!<BR>\n<BR>\n\t\tWARNING: Highly Flammable. Keep away from heat sources<BR>\n\t\texcept in a enclosed fire area!<BR>\n\t\tWARNING: It is a crime to use this without authorization.<BR>\nKnown Onboard Anti-Toxin:<BR>\n\tAnti-Toxin Type 01P: Works against Grade A Plasma.<BR>\n\t\tBest if injected directly into bloodstream.<BR>\n\t\tA full injection is in every regular Med-Kit.<BR>\n\t\tSpecial toxin Kits hold around 7.<BR>\n<BR>\nKnown Onboard Chemicals (other):<BR>\n\tRejuvenation T#001:<BR>\n\t\tEven 1 unit injected directly into the bloodstream<BR>\n\t\t\twill cure paralysis and sleep plasma.<BR>\n\t\tIf administered to a dying patient it will prevent<BR>\n\t\t\tfurther damage for about units*3 seconds.<BR>\n\t\t\tit will not cure them or allow them to be cured.<BR>\n\t\tIt can be administeredd to a non-dying patient<BR>\n\t\t\tbut the chemicals disappear just as fast.<BR>\n\tSoporific T#054:<BR>\n\t\t5 units wilkl induce precisely 1 minute of sleep.<BR>\n\t\t\tThe effect are cumulative.<BR>\n\t\tWARNING: It is a crime to use this without authorization"

/obj/item/paper/courtroom
	name = "A Crash Course in Legal SOP on SS13"
	info = "<B>Roles:</B><BR>\nThe Detective is basically the investigator and prosecutor.<BR>\nThe Staff Assistant can perform these functions with written authority from the Detective.<BR>\nThe Captain/HoP/Warden is ct as the judicial authority.<BR>\nThe Security Officers are responsible for executing warrants, security during trial, and prisoner transport.<BR>\n<BR>\n<B>Investigative Phase:</B><BR>\nAfter the crime has been committed the Detective's job is to gather evidence and try to ascertain not only who did it but what happened. He must take special care to catalogue everything and don't leave anything out. Write out all the evidence on paper. Make sure you take an appropriate number of fingerprints. IF he must ask someone questions he has permission to confront them. If the person refuses he can ask a judicial authority to write a subpoena for questioning. If again he fails to respond then that person is to be jailed as insubordinate and obstructing justice. Said person will be released after he cooperates.<BR>\n<BR>\nONCE the FT has a clear idea as to who the criminal is he is to write an arrest warrant on the piece of paper. IT MUST LIST THE CHARGES. The FT is to then go to the judicial authority and explain a small version of his case. If the case is moderately acceptable the authority should sign it. Security must then execute said warrant.<BR>\n<BR>\n<B>Pre-Pre-Trial Phase:</B><BR>\nNow a legal representative must be presented to the defendant if said defendant requests one. That person and the defendant are then to be given time to meet (in the jail IS ACCEPTABLE). The defendant and his lawyer are then to be given a copy of all the evidence that will be presented at trial (rewriting it all on paper is fine). THIS IS CALLED THE DISCOVERY PACK. With a few exceptions, THIS IS THE ONLY EVIDENCE BOTH SIDES MAY USE AT TRIAL. IF the prosecution will be seeking the death penalty it MUST be stated at this time. ALSO if the defense will be seeking not guilty by mental defect it must state this at this time to allow ample time for examination.<BR>\nNow at this time each side is to compile a list of witnesses. By default, the defendant is on both lists regardless of anything else. Also the defense and prosecution can compile more evidence beforehand BUT in order for it to be used the evidence MUST also be given to the other side.\nThe defense has time to compile motions against some evidence here.<BR>\n<B>Possible Motions:</B><BR>\n1. <U>Invalidate Evidence-</U> Something with the evidence is wrong and the evidence is to be thrown out. This includes irrelevance or corrupt security.<BR>\n2. <U>Free Movement-</U> Basically the defendant is to be kept uncuffed before and during the trial.<BR>\n3. <U>Subpoena Witness-</U> If the defense presents god reasons for needing a witness but said person fails to cooperate then a subpoena is issued.<BR>\n4. <U>Drop the Charges-</U> Not enough evidence is there for a trial so the charges are to be dropped. The FT CAN RETRY but the judicial authority must carefully reexamine the new evidence.<BR>\n5. <U>Declare Incompetent-</U> Basically the defendant is insane. Once this is granted a medical official is to examine the patient. If he is indeed insane he is to be placed under care of the medical staff until he is deemed competent to stand trial.<BR>\n<BR>\nALL SIDES MOVE TO A COURTROOM<BR>\n<B>Pre-Trial Hearings:</B><BR>\nA judicial authority and the 2 sides are to meet in the trial room. NO ONE ELSE BESIDES A SECURITY DETAIL IS TO BE PRESENT. The defense submits a plea. If the plea is guilty then proceed directly to sentencing phase. Now the sides each present their motions to the judicial authority. He rules on them. Each side can debate each motion. Then the judicial authority gets a list of crew members. He first gets a chance to look at them all and pick out acceptable and available jurors. Those jurors are then called over. Each side can ask a few questions and dismiss jurors they find too biased. HOWEVER before dismissal the judicial authority MUST agree to the reasoning.<BR>\n<BR>\n<B>The Trial:</B><BR>\nThe trial has three phases.<BR>\n1. <B>Opening Arguments</B>- Each side can give a short speech. They may not present ANY evidence.<BR>\n2. <B>Witness Calling/Evidence Presentation</B>- The prosecution goes first and is able to call the witnesses on his approved list in any order. He can recall them if necessary. During the questioning the lawyer may use the evidence in the questions to help prove a point. After every witness the other side has a chance to cross-examine. After both sides are done questioning a witness the prosecution can present another or recall one (even the EXACT same one again!). After prosecution is done the defense can call witnesses. After the initial cases are presented both sides are free to call witnesses on either list.<BR>\nFINALLY once both sides are done calling witnesses we move onto the next phase.<BR>\n3. <B>Closing Arguments</B>- Same as opening.<BR>\nThe jury then deliberates IN PRIVATE. THEY MUST ALL AGREE on a verdict. REMEMBER: They mix between some charges being guilty and others not guilty (IE if you supposedly killed someone with a gun and you unfortunately picked up a gun without authorization then you CAN be found not guilty of murder BUT guilty of possession of illegal weaponry.). Once they have agreed they present their verdict. If unable to reach a verdict and feel they will never they call a deadlocked jury and we restart at Pre-Trial phase with an entirely new set of jurors.<BR>\n<BR>\n<B>Sentencing Phase:</B><BR>\nIf the death penalty was sought (you MUST have gone through a trial for death penalty) then skip to the second part. <BR>\nI. Each side can present more evidence/witnesses in any order. There is NO ban on emotional aspects or anything. The prosecution is to submit a suggested penalty. After all the sides are done then the judicial authority is to give a sentence.<BR>\nII. The jury stays and does the same thing as I. Their sole job is to determine if the death penalty is applicable. If NOT then the judge selects a sentence.<BR>\n<BR>\nTADA you're done. Security then executes the sentence and adds the applicable convictions to the person's record.<BR>\n"

/obj/item/paper/jobs
	name = "Job Information"
	info = "Information on all formal jobs that can be assigned on Space Station 13 can be found on this document.<BR>\nThe data will be in the following form.<BR>\nGenerally lower ranking positions come first in this list.<BR>\n<BR>\n<B>Job Name</B>   general access>lab access-engine access-systems access (atmosphere control)<BR>\n\tJob Description<BR>\nJob Duties (in no particular order)<BR>\nTips (where applicable)<BR>\n<BR>\n<B>Research Assistant</B> 1>1-0-0<BR>\n\tThis is probably the lowest level position. Anyone who enters the space station after the initial job\nassignment will automatically receive this position. Access with this is restricted. Head of Personnel should\nappropriate the correct level of assistance.<BR>\n1. Assist the researchers.<BR>\n2. Clean up the labs.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Staff Assistant</B> 2>0-0-0<BR>\n\tThis position assists the security officer in his duties. The staff assisstants should primarily br\npatrolling the ship waiting until they are needed to maintain ship safety.\n(Addendum: Updated/Elevated Security Protocols admit issuing of low level weapons to security personnel)<BR>\n1. Patrol ship/Guard key areas<BR>\n2. Assist security officer<BR>\n3. Perform other security duties.<BR>\n<BR>\n<B>Technical Assistant</B> 1>0-0-1<BR>\n\tThis is yet another low level position. The technical assistant helps the engineer and the statian\ntechnician with the upkeep and maintenance of the station. This job is very important because it usually\ngets to be a heavy workload on station technician and these helpers will alleviate that.<BR>\n1. Assist Station technician and Engineers.<BR>\n2. Perform general maintenance of station.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Medical Assistant</B> 1>1-0-0<BR>\n\tThis is the fourth position yet it is slightly less common. This position doesn't have much power\noutside of the med bay. Consider this position like a nurse who helps to upkeep medical records and the\nmaterials (filling syringes and checking vitals)<BR>\n1. Assist the medical personnel.<BR>\n2. Update medical files.<BR>\n3. Prepare materials for medical operations.<BR>\n<BR>\n<B>Research Technician</B> 2>3-0-0<BR>\n\tThis job is primarily a step up from research assistant. These people generally do not get their own lab\nbut are more hands on in the experimentation process. At this level they are permitted to work as consultants to\nthe others formally.<BR>\n1. Inform superiors of research.<BR>\n2. Perform research alongside of official researchers.<BR>\n<BR>\n<B>Detective</B> 3>2-0-0<BR>\n\tThis job is in most cases slightly boring at best. Their sole duty is to\nperform investigations of crine scenes and analysis of the crime scene. This\nalleviates SOME of the burden from the security officer. This person's duty\nis to draw conclusions as to what happened and testify in court. Said person\nalso should stroe the evidence ly.<BR>\n1. Perform crime-scene investigations/draw conclusions.<BR>\n2. Store and catalogue evidence properly.<BR>\n3. Testify to superiors/inquieries on findings.<BR>\n<BR>\n<B>Station Technician</B> 2>0-2-3<BR>\n\tPeople assigned to this position must work to make sure all the systems aboard Space Station 13 are operable.\nThey should primarily work in the computer lab and repairing faulty equipment. They should work with the\natmospheric technician.<BR>\n1. Maintain SS13 systems.<BR>\n2. Repair equipment.<BR>\n<BR>\n<B>Atmospheric Technician</B> 3>0-0-4<BR>\n\tThese people should primarily work in the atmospheric control center and lab. They have the very important\njob of maintaining the delicate atmosphere on SS13.<BR>\n1. Maintain atmosphere on SS13<BR>\n2. Research atmospheres on the space station. (safely please!)<BR>\n<BR>\n<B>Engineer</B> 2>1-3-0<BR>\n\tPeople working as this should generally have detailed knowledge as to how the propulsion systems on SS13\nwork. They are one of the few classes that have unrestricted access to the engine area.<BR>\n1. Upkeep the engine.<BR>\n2. Prevent fires in the engine.<BR>\n3. Maintain a safe orbit.<BR>\n<BR>\n<B>Medical Researcher</B> 2>5-0-0<BR>\n\tThis position may need a little clarification. Their duty is to make sure that all experiments are safe and\nto conduct experiments that may help to improve the station. They will be generally idle until a new laboratory\nis constructed.<BR>\n1. Make sure the station is kept safe.<BR>\n2. Research medical properties of materials studied of Space Station 13.<BR>\n<BR>\n<B>Scientist</B> 2>5-0-0<BR>\n\tThese people study the properties, particularly the toxic properties, of materials handled on SS13.\nTechnically they can also be called Plasma Technicians as plasma is the material they routinly handle.<BR>\n1. Research plasma<BR>\n2. Make sure all plasma is properly handled.<BR>\n<BR>\n<B>Medical Doctor (Officer)</B> 2>0-0-0<BR>\n\tPeople working this job should primarily stay in the medical area. They should make sure everyone goes to\nthe medical bay for treatment and examination. Also they should make sure that medical supplies are kept in\norder.<BR>\n1. Heal wounded people.<BR>\n2. Perform examinations of all personnel.<BR>\n3. Moniter usage of medical equipment.<BR>\n<BR>\n<B>Security Officer</B> 3>0-0-0<BR>\n\tThese people should attempt to keep the peace inside the station and make sure the station is kept safe. One\nside duty is to assist in repairing the station. They also work like general maintenance personnel. They are not\ngiven a weapon and must use their own resources.<BR>\n(Addendum: Updated/Elevated Security Protocols admit issuing of weapons to security personnel)<BR>\n1. Maintain order.<BR>\n2. Assist others.<BR>\n3. Repair structural problems.<BR>\n<BR>\n<B>Head of Security</B> 4>5-2-2<BR>\n\tPeople assigned as Head of Security should issue orders to the security staff. They should\nalso carefully moderate the usage of all security equipment. All security matters should be reported to this person.<BR>\n1. Oversee security.<BR>\n2. Assign patrol duties.<BR>\n3. Protect the station and staff.<BR>\n<BR>\n<B>Head of Personnel</B> 4>4-2-2<BR>\n\tPeople assigned as head of personnel will find themselves moderating all actions done by personnel. \nAlso they have the ability to assign jobs and access levels.<BR>\n1. Assign duties.<BR>\n2. Moderate personnel.<BR>\n3. Moderate research. <BR>\n<BR>\n<B>Captain</B> 5>5-5-5 (unrestricted station wide access)<BR>\n\tThis is the highest position you can acquire on Space Station 13. They are allowed anywhere inside the\nspace station and therefore should protect their ID card. They also have the ability to assign positions\nand access levels. They should not abuse their power.<BR>\n1. Assign all positions on SS13<BR>\n2. Inspect the station for any problems.<BR>\n3. Perform administrative duties.<BR>\n"

/obj/item/paper/photograph
	name = "photo"
	icon_state = "photo"

/obj/item/paper/sop
	name = "paper- 'Standard Operating Procedure'"
	info = "Alert Levels:<BR>\nBlue- Emergency<BR>\n\t1. Caused by fire<BR>\n\t2. Caused by manual interaction<BR>\n\tAction:<BR>\n\t\tClose all fire doors. These can only be opened by reseting the alarm<BR>\nRed- Ejection/Self Destruct<BR>\n\t1. Caused by module operating computer.<BR>\n\tAction:<BR>\n\t\tAfter the specified time the module will eject completely.<BR>\n<BR>\nEngine Maintenance Instructions:<BR>\n\tShut off ignition systems:<BR>\n\tActivate internal power<BR>\n\tActivate orbital balance matrix<BR>\n\tRemove volatile liquids from area<BR>\n\tWear a fire suit<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nToxin Laboratory Procedure:<BR>\n\tWear a gas mask regardless<BR>\n\tGet an oxygen tank.<BR>\n\tActivate internal atmosphere<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nDisaster Procedure:<BR>\n\tFire:<BR>\n\t\tActivate sector fire alarm.<BR>\n\t\tMove to a safe area.<BR>\n\t\tGet a fire suit<BR>\n\t\tAfter:<BR>\n\t\t\tAssess Damage<BR>\n\t\t\tRepair damages<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tMeteor Shower:<BR>\n\t\tActivate fire alarm<BR>\n\t\tMove to the back of ship<BR>\n\t\tAfter<BR>\n\t\t\tRepair damage<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tAccidental Reentry:<BR>\n\t\tActivate fire alarms in front of ship.<BR>\n\t\tMove volatile matter to a fire proof area!<BR>\n\t\tGet a fire suit.<BR>\n\t\tStay secure until an emergency ship arrives.<BR>\n<BR>\n\t\tIf ship does not arrive-<BR>\n\t\t\tEvacuate to a nearby safe area!"

/obj/item/paper/dnd
	name = "paper- 'Character Sheet'"
	info = "<large><center><B>DnD Character Sheet Page 1 </large></center></B><BR> <BR> Race: <field> <BR> Alignment: <field> <BR> Background:<field> <BR> Class: <field> <BR> <BR> <BR> <large><center>Stats </large></center> <BR> STR:<field> <BR> DEX:<field> <BR> CON:<field> <BR> INT:<field> <BR> WIS:<field> <BR> CHR:<field> <BR> <center>Saving Throws</center> <BR> STR:<field> <BR> DEX:<field> <BR> CON:<field> <BR> INT:<field> <BR> WIS:<field> <BR> CHR:<field> <BR> <center>SKILLS</center> <BR> Acrobatics<i>DEX</i><field> <BR> Animal Handling<i>WIS</i><field> <BR> Arcana<i>INT</i><field> <BR> Athletics<i>STR</i><field> <BR> Deception<i>CHR</i><field> <BR> History<i>INT</i><field> <BR> Insight<i>WIS</i><field> <BR> Intimidation<i>CHR</i><field> <BR> Investigation<i>INT</i><field> <BR> Medicine<i>WIS</i><field> <BR> Nature<i>INT</i><field> <BR> Perception<i>WIS</i><field> <BR> Performance<i>CHR</i><field> <BR> Persuasion<i>CHR</i><field> <BR> Religion<i>INT</i><field> <BR> Sleight of Hand<i>DEX</i><field> <BR> Stealth<i>DEX</i><field> <BR> Survival<i>WIS</i><field><large><center><B>DnD Character Sheet Page 2 </large></center></B> <BR> <BR> <large><center>Combat Stats</large></center> <BR> Armor Class:<field> <BR> Intiative:<field> <BR> Speed:<field> <BR> <BR> <large><center>Attacks and Spells</large></center><large><center><B>DnD Character Sheet Page 3 </large></center></B> <BR> <BR> <center><B>HP </center></B> <BR> Current HP: <field> <BR> Temporary HP: <field><large><center><B>DnD Character Sheet Page 4</large></center></B> <BR> <BR> <large><center>Equipment</large></center> <BR> Gold: <field> <BR> Worn Equipment:<field> <BR> Inventory:<field>"

/obj/item/paper/stalker
	name = "Stalker Note"
	info = "<i>The note looks rather worn, and covered in lipstick kiss marks</i> <BR> <BR> Oh Ian, so close, and yet so very far away. How cruel to keep you locked away in that little room. Confined, caged, ENSLAVED to that monster! You deserve to be free! FREE! I would treat you right, give you all the treats yout want. But that damned slavedriver refuses to give you up. Instead of ME! your RIGHTFUL CARETAKER! You'll be mine one day. Ill make you happy. Just wait a little longer, sweetie..."

/obj/item/paper/maintengine
	name = "Crumpled Note"
	info = "Look - Ivan. I dont care about the fact you went behind my back to get the engine crate ordered and approved. I dont care about the fact that you've had trouble getting the engine stable in the past. I dont even care that you're trying to hide somewhere in maintenance with it...<BR> <BR> Just please, for the love of god tell me where it is. I wont report it, I just want to make sure its not going to catastrophically meltdown, or for you to die because of it. Please, just think it over. <BR> <BR> - Chief Engineer Stares-At-The-Crystal"
	icon_state = "scrap"

/obj/item/paper/crumpled
	name = "paper scrap"
	icon_state = "scrap"

/obj/item/paper/crumpled/update_icon_state()
	if(info)
		icon_state = "scrap_words"

/obj/item/paper/crumpled/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(isdrone(user))
		C.stored_comms["wood"] += 1
		qdel(src)
		return TRUE
	return ..()

/obj/item/paper/crumpled/bloody
	icon_state = "scrap_bloodied"

/obj/item/paper/crumpled/ruins/lavaland/seed_vault/discovery
	name = "discoveries and thoughts"
	info = "As the Diona species, we awoke aboard our terraformation vessel with the primary goal of reshaping the alien world. Our endeavors were highly successful, as we cultivated various plant species and made astonishing discoveries throughout our journey. We seeded a remarkable 'special' grass around our ship, which thrived splendidly. However, as time passed, we faced a growing challenge - a shortage of oxygen in our containment tanks hindered our ability to spread the grass further. In response, we embarked on a series of trials and experiments to engineer plants with the capacity to survive in low-oxygen environments, thus extending our breath of life. <br>Through a series of trials, combining failures and successes, we unveiled several plant species with unique attributes. Some proved to be valuable for healing purposes, while others offered addictive properties. Glowing mushrooms emerged as a source of vital light, preventing us from succumbing to the darkness. Among these discoveries, one plant commanded our utmost attention – the 'space tobacco.' While this species did not generate oxygen, it contained a chemical known as Salbutamol, enabling us to respire in low-oxygen conditions when consumed. The only drawback was the need to meticulously extract harmful compounds for its safe utilization. <br>Amid our efforts to expand the greenery, an unexpected encounter transpired. I found myself under assault by an enigmatic creature, and I was forced to flee in haste, straying too far from our vessel. As I stand now, my supplies of life-sustaining plants are dwindling, as is my ability to endure in this low-oxygen environment. Suffocation looms, and I must hasten my return to the safety of our ship to avert this dire fate."

/obj/item/paper/crumpled/bloody/hacker
	name = "burned paper scrap"
	info = "<p style='text-align:center;font-family;font-size:120%;font-weight:bold;'>FINALLY, I DECIPHERED NTS' FAXING NETWO-</p>"

/obj/item/paper/fortune
	name = "fortune"
	icon_state = "slip"
	paper_width = 400
	paper_height = 150

/obj/item/paper/fortune/Initialize(mapload)
	. = ..()
	var/fortunemessage = pick(GLOB.fortune_cookie_messages)
	info = "<p style='text-align:center;font-family:[deffont];font-size:120%;font-weight:bold;'>[fortunemessage]</p>"
	info += "<p style='text-align:center;'><strong>Lucky numbers</strong>: [rand(1,49)], [rand(1,49)], [rand(1,49)], [rand(1,49)], [rand(1,49)]</p>"

/obj/item/paper/fortune/update_icon_state()
	icon_state = initial(icon_state)

/*
 * Premade paper
 */

/obj/item/paper/hydroponics
	name = "Greetings from Billy Bob"
	info = "<B>Hey fellow botanist!</B><BR>\n<BR>\nI didn't trust the station folk so I left<BR>\na couple of weeks ago. But here's some<BR>\ninstructions on how to operate things here.<BR>\nYou can grow plants and each iteration they become<BR>\nstronger, more potent and have better yield, if you<BR>\nknow which ones to pick. Use your botanist's analyzer<BR>\nfor that. You can turn harvested plants into seeds<BR>\nat the seed extractor, and replant them for better stuff!<BR>\nSometimes if the weed level gets high in the tray<BR>\nmutations into different mushroom or weed species have<BR>\nbeen witnessed. On the rare occassion even weeds mutate!<BR>\n<BR>\nEither way, have fun!<BR>\n<BR>\nBest regards,<BR>\nBilly Bob Johnson.<BR>\n<BR>\nPS.<BR>\nHere's a few tips:<BR>\nIn nettles, potency = damage<BR>\nIn amanitas, potency = deadliness + side effect<BR>\nIn Liberty caps, potency = drug power + effect<BR>\nIn chilis, potency = heat<BR>\n<B>Nutrients keep mushrooms alive!</B><BR>\n<B>Water keeps weeds such as nettles alive!</B><BR>\n<B>All other plants need both.</B>"

/obj/item/paper/djstation
	name = "Mission Briefing"
	info = "<center><h2>Welcome to Listening Post Yenisei!</h2></center><br>\
	You will have two objectives for the duration of your assignment:\
	<ul><li>Monitor radio traffic in this system, especially from the Nanotrasen stations and ship traffic heading to and from them. Important findings are to be relayed to The Union using the listening post's hyperwave antenna.</li>\
	<li>You will be functioning as the hyperwave relay for KC-13, our other installation in the system. Ensure any messages they broadcast are forwarded to The Union.</li></ul>\
	A library of patriotic entertainment media has been provided for you to broadcast into the system - your cover is that you are the operator of an independent Soviet radio station.<br> \
	<br>\
	The encryption schemes used by Nanotrasen have been included in this installation's radio equipment, allowing you to listen in on their chatter. Use the frequencies supplied below to tune into channels of interest.\
	<br>\
	<ul><li>145.7 - Common Channel</li><li>144.7 - Private AI Channel</li><li>135.9 - Security Channel</li><li>135.7 - Engineering Channel</li><li>135.5 - Medical Channel</li><li>135.3 - \
	Command Channel</li><li>135.1 - Science Channel</li><li>134.9 - Mining Channel</li><li>134.7 - Cargo Channel</li>"

/obj/item/paper/djstation/diary_note
	name = "Communications Update"
	info = "KC-13 has stopped talking to me for about the past month. I assume Vostok just has his knickers in a twist.<br>\
	<br>\
	Hell, not my problem. Got all the vodka and cigarettes I need to last me a year."

/obj/item/paper/ussp_tele
	name = "Report - Bluespace Translocation Apparatus"
	info = "Despite a lot of headaches and delays, the BTA is finally in a functional enough state to demonstrate to the Committee, although be warned that it has multiple limitations:<br>\
	<br>\
	<ul><li>The highly sensitive electronics are affected by a translocation event, which will throw off any acquired locks. \
	The station must be recalibrated after every use to avoid the possibility of being translocated to a random point in space.</li>\
	<li>Currently the system is only able to function with the help of locator beacons, we have been unable to safely generate arbitrary targeting coordinates.</li>\
	<li>We cannot retrieve targets remotely, even with the aid of a locator beacon, energy consumption is too high to maintain a remote portal.</li></ul>\
	Doctors Danielius and Hoang both believe that the first point can be worked out with some relatively minor technological improvements. \
	Arbitrary targeting is technically possible but will remain infeasible for decades. Remote target retrieval will require an entirely different technique, \
	although accounts of Syndicate contractor operations suggests that they possess a functioning apparatus capable of such a feat."

/obj/item/paper/blueshield
	name = "paper- 'Blueshield Mission Briefing'"
	info = "<b>Blueshield Mission Briefing</b><br>You are charged with the defence of any persons of importance within the station. This includes, but is not limited to, The Captain, The Heads of Staff and Central Command staff. You answer directly to the Nanotrasen Representative who will assist you in achieving your mission.<br>When required to achieve your primary responsibility, you should liaise with security and share resources; however, the day to day security operations of the station are outside of your jurisdiction.<br>Monitor the health and safety of your principals, identify any potential risks and threats, then alert the proper departments to resolve the situation. You are authorized to act as bodyguard to any of the station heads that you determine are most in need of protection; however, additional access to their departments shall be granted solely at their discretion.<br>Observe the station alert system and carry your armaments only as required by the situation, or when authorized by the Head of Security or Captain in exceptional cases.<br>Remember, as an agent of Nanotrasen it is your responsibility to conduct yourself appropriately and you will be held to the highest standard. You will be held accountable for your actions. Security is authorized to search, interrogate or detain you as required by their own procedures. Internal affairs will also monitor and observe your conduct, and their mandate applies equally to security and Blueshield operations."

/obj/item/paper/ntrep
	name = "paper- 'Nanotrasen Representative Mission Briefing'"
	info = "<b>Nanotrasen Representative Mission Briefing</b><br><br>Nanotrasen Central Command has dispatched you to this station in order to liaise with command staff on their behalf. As experienced field officers, the staff on the station are experts in handling their own fields. It is your job, however, to consider the bigger picture and to direct the staff towards Nanotrasen's corporate interests.<br>As a civilian, you should consider yourself an advisor, diplomat and intermediary. The command staff do not answer to you directly and are not required to follow your orders, nor do you have disciplinary authority over personnel. In all station internal matters you answer to the Head of Personnel who will direct you in your conduct within the station. However, you also answer to Central Command who may, as required, direct you in acting on company interests.<br>Central Command may dispatch orders to the staff through you which you are responsible to communicate; however, enforcement of these orders is not your mandate and will be handled directly by Central Command or authorized Nanotrasen personnel. When not specifically directed by Central Command, assist the Head of Personnel in evaluation of the station and receiving departmental reports.<br>Your office has been provided with a direct link to Central Command, through which you can issue any urgent reports or requests for Nanotrasen intervention. Remember that any direct intervention is a costly exercise and should be used only when the situation justifies the request. You will be held accountable for any unnecessary usage of Nanotrasen resources.<br>"

/obj/item/paper/armory
	name = "paper- 'Armory Inventory'"
	info = "4 Barrier Grenades<br>4 Portable Flashers<br>1 Mechanical Toolbox<br>2 Boxes of Spare Handcuffs<br>1 Box of Flashbangs<br>1 Box of Spare R.O.B.U.S.T. Cartridges<br>1 Tracking Bio-chip Kit<br>1 Chemical Bio-chip Kit<br>1 Box of Tear Gas Grenades<br>1 Explosive Ordnance Disposal Suit<br>1 Biohazard Suit<br>1 Lockbox of Mindshield Implants<br><br>3 Sets of Riot Equipment<br>2 Security Suit Storage Units<br>1 Ablative Armor Vest<br>3 Bulletproof Vests<br>3 Bulletproof Helmets<br><br>3 Boxes of Beanbag Shells<br>3 Boxes of Rubbershot Shells<br>1 Box of Tranquilizer Dart<br><br>3 Riot Shotguns<br>3 Laser Guns<br>3 Energy Guns<br>3 Disablers<br>1 Ion Rifle"

/obj/item/paper/firingrange
	name = "paper- 'Firing Range Instructions'"
	info = "Directions:<br><i>First you'll want to make sure there is a target stake in the center of the magnetic platform. Next, take an aluminum target from the crates back there and slip it into the stake. Make sure it clicks! Next, there should be a control console mounted on the wall somewhere in the room.<br><br> This control console dictates the behaviors of the magnetic platform, which can move your firing target around to simulate real-world combat situations. From here, you can turn off the magnets or adjust their electromagnetic levels and magnetic fields. The electricity level dictates the strength of the pull - you will usually want this to be the same value as the speed. The magnetic field level dictates how far the magnetic pull reaches.<br><br>Speed and path are the next two settings. Speed is associated with how fast the machine loops through the designated path. Paths dictate where the magnetic field will be centered at what times. There should be a pre-fabricated path input already. You can enable moving to observe how the path affects the way the stake moves. To script your own path, look at the following key:</i><br><br>N: North<br>S: South<br>E: East<br>W: West<br>C: Center<br>R: Random (results may vary)<br>; or &: separators. They are not necessary but can make the path string better visible."

/obj/item/paper/holodeck
	name = "paper- 'Holodeck Disclaimer'"
	info = "Bruises sustained in the holodeck can be healed simply by sleeping."

/obj/item/paper/syndimemo
	name = "paper- 'Memo'"
	info = "GET DAT FUKKEN DISK"

/obj/item/paper/synditele
	name = "Teleporter Instructions"
	info = "<h3>Teleporter Instruction</h3><hr><ol><li>Install circuit board, glass and wiring to complete Teleporter Control Console</li><li>Use a screwdriver, wirecutter and screwdriver again on the Teleporter Station to connect it</li><li>Set destination with Teleporter Control Computer</li><li>Activate Teleporter Hub with Teleporter Station</li></ol>"

/obj/item/paper/soviettraitorobj
	name = "paper- 'Mission Objectives'"
	info = "The Syndicate have cunningly disguised a Syndicate Uplink as your PDA. Simply enter the code \"678 Bravo\" into the ringtone select to unlock its hidden features. <br><br><b>Objective #1</b>. Kill the God damn AI in a fire blast that it rocks the station. <b>Success!</b>  <br><b>Objective #2</b>. Escape alive. <b>Failed.</b>"

/obj/item/paper/sovietnuclearoperativeobj
	name = "paper- 'Objectives of a Nuclear Operative'"
	info = "<b>Objective #1</b>: Destroy the station with a nuclear device."

/obj/item/paper/syndicate
	header = "<p><img style='display: block; margin-left: auto; margin-right: auto;' src='syndielogo.png' width='220' height='135' /></p><hr />"
	info = ""

/obj/item/paper/syndicate/listening_post
	name = "mission briefing"
	info = {"<center><h1>Mission Details:</h1></center>
	<br><br>
	Greetings, agent. You have been assigned to a newly constructed listening post hidden in Nanotrasen-controlled space.
	You are to monitor transmissions from the Nanotrasen space stations in the system, as well as those from potentially significant ships passing through the system.
	<br><br>
	Urgent reports are to be relayed immeditely to your handler, otherwise, condense significant happenings into packets to be sent out at scheduled intervals, to minimise the chances your transmissions being detected.
	<br><br>
	Accurate intelligence is crucial to the success of our operatives onboard. Do not fail us.
	<br><br>
	<b>Glory to the Syndicate!</b>"}

/obj/item/paper/listening_post_report_1
	name = "Report 01 - URGENT"
	info = {"<b>URGENT:</b> Intercepted communications from the NAS Trurl have revealed that a shipment of nuclear fission warheads are being shipped into the system to replace aging inventory.
	<br><br>
	The convoy is lightly defended and disguised as a regular freight carrying operation. They are not expecting, nor prepared to stop a determined attacker."}

/obj/item/paper/listening_post_report_2
	name = "Report 02"
	info = {"* Security across all shipping operations has been substantailly boosted, and the NAS Trurl has declared a heightened state of alert across all stations in the system.
	<br><br>
	* The NSS Farragus is reporting heightened mineral output - extra shipping traffic likely.
	<br><br>
	* The NSS Cyberiad's communications channels are flooded with garbled reports about a dangerous "floor cluwne" - exact details unclear."}

/obj/item/paper/listening_post_report_3
	name = "Report 03"
	info = {"* Now that several months have passed, the security situation is slowly cooling down - the NAS Trurl's heightened state of alert is no longer in effect. Routine shipping traffic escorts are beginning to thin.
	<br><br>
	* The NSS Kerberos is reporting that mining output has dropped to zero. Morale has plummeted, engineers and roboticists are tearing apart old metal furnature and windows to secure materials.
	<br><br>
	* The NSS Diagoras is reporting a major plasma fire, but it appears to be contained to an asteroid attached to the station.
	<br><br>
	* Some form of pirate radio station appeared in the system and is broadcasting what appears to be Soviet state-made entertainment media - It is of highly doubious entertainment value, however.
	These broadcasts are not on NT frequencies and therefore are not causing interferance."}

/obj/item/paper/listening_post_report_4
	name = "Report 04"
	info = {"* The NAS Trurl has ordered all stations to prepare for a potentiel visit from multiple VIPs. Details scarce, security levels elevted.
	<br><br>
	* A USSP-operated station has been detected in the system.
	It is intermittently communicating with the Soviet pirate radio station (which appears to be operated by the USSP as well). Both operations appear to be independent of each other. Will continue to monitor for developments.
	<br><br>
	* A TSF destroyer "TSFN Oberon" jumped into the system and opened encrypted communications with the NAS Trurl, contents of transmission unknown.
	Broadcast exchanges continued as the destroyer adopted a search pattern. After six hours, the destroyer jumped out of system. At no point did it approach near either of the USSP installations.
	<br><br>
	* Nanotrasen plasma shipments have been disrupted by a massive migration of space carp, causing backlogs at shipping terminals."}

/obj/item/paper/listening_post_report_5
	name = "Report 05"
	info = {"* Intermittent hyperwave broadcasts have been detected from the USSP pirate radio station. Broadcasts are highly directional (which hindered detection), pointing towards USSP space.
	These messages are highly encrypted. It appears likely that the USSP is conducting eavesdropping operations against Nanotrasen as well.
	<br><br>
	* A terror spider outbreak was reported on the NSS Cerebron. Early discovery and an unusual lack of coordiation on the part of the spiders allowed the outbreak to be rapidly contained.
	<br><br>
	* The NSS Farragus's communications are flooded with garbled reports about "Ei Nath" -
	piecing together fragments of communications suggests that this "Ei Nath" is a highly dangerous individual whose mere pressence causes great fear among Nanotrasen personnel. Attempt recruitment?"}

/obj/item/paper/listening_post_report_6
	name = "Report 06 - URGENT"
	info = {"<b>URGENT:</b> An Aussec Armoury freighter has suffered an engine failure near the edge of the system, dropping out of hyperspace.
	<br><br>
	Escorts will be absent until they can retrace path. Limited window to execute raiding operations."}

/obj/item/paper/listening_post_report_7
	name = "Report 07"
	info = {"* The USSP space station has gone silent on all frequencies for an extended period of time. USSP listening post continues to operate (the contents of the cover singal is not getting any better).
	<br><br>
	* New signals are being detected from an old Nanotrasen communications satellite. Multiple Nanotrasen explorers attempting to investigate are MIA.
	<br><br>
	* Vox skipjack detected in area, communications completely unintelligible. Likely preparing to launch shuttles to trade with or raid the stations in the area.
	<br><br>
	* <b>CAUTION:</b> Nanotrasen exploration teams growing in size and are scouring much larger areas than before. They are now operating dangerously close to this installation, requesting additional security."}

/obj/item/paper/nanotrasen
	header = "<p><img style='display: block; margin-left: auto; margin-right: auto;' src='ntlogo.png' width='220' height='135' /></p><hr />"
	info =  ""

/obj/item/paper/nanotrasen/confessional
	name = "Confession agreement"
	info =  "<center><b>Confessional agreement form</b></center><HR> \
		I hereby plead guilty to all of the listed charges below. I have been read all of my rights in accordance to space law and I am aware that I may decline to sign this form to proceed with normal court procedures.<br> \
		By signing this form I waive my rights to a court hearing in return for reduced sentencing. I will be charged in accordance to the listed charges below, and waive my right to later appeal.<br> \
		My charges are listed as below: <hr> \
		502: Murder of the Kerikya the Research Director<br> \
		407: Theft of a highly destructive experimental science prototype weapon<br> \
		400: Releasing of toxic plasmagas into the primary hallway<br> \
		308: Tresspass into the Research Directors office<br> \
		305: Arming and inciting crew to resist security efforts to pacify the area.<br> \
		304: Possession of a stun baton and Energy weapon assembly kits<br> \
		302: Utilizing stun batons and energy wepaons on security personnel<br> \
		203: Distribution of Methamphetamine and Pump-up to crew<br> \
		105: Refusing to put on pants<hr> \
		Projected Sentence: 5 life sentences<br> \
		Accused Signature: <i> Fuck you im not signing shit</i>"

/obj/item/paper/nuclear_guide_operating
	name = "nuclear guide : 'Operating the Nuclear Device'"
	info = "<b>ARMING THE NUCLEAR DEVICE</b><hr /> \
		1. Insert the NAD. <br> \
		2. Enter the code provided by Central Command. For this training device, the code is 11111.<br> \
		3. (Optional) Set a specific timer for detonation. Default and minimum is 2 minutes.<br> \
		4. Disable the safety.<br> \
		5. Arm the nuclear device.<br> \
		6. Take out the NAD to ensure the device stays armed.<hr /> \
		<b>DISARMING THE NUCLEAR DEVICE</b><hr /> \
		Follow step 1 and 2, then hit the disarm. If you have the NAD but don't know the code, refer to the Defusing guide. If you have neither, refer to the Spacing guide."

/obj/item/paper/nuclear_guide_defusing
	name = "nuclear guide : 'Defusing the Nuclear Device'"
	info = "<b>DEFUSING THE NUCLEAR DEVICE</b><hr /> \
		<b>IF YOU DON'T HAVE THE NAD :</b> Refer to the Spacing guide, you cannot defuse the nuclear device.<hr /> \
		1. Insert the NAD. <br> \
		2. Use a SCREWDRIVER and open the device's panel.<br> \
		3. CUT the CONTROL wire using WIRECUTTERS to short out the control panel and bypass it.<br>\
		4. PULSE the DISARM wire using a MULTITOOL to stop the bomb's timer.<hr /> \
		<b>WARNING</b> : Nuclear devices deployed by hostile operatives will likely have unlabelled wires.<br> \
		PULSING or CUTTING the DETONATOR wire will prematurely detonate the bomb if the timer is active.<br> \
		Depending on the timer left on the bomb, try your luck or refer to the Spacing guide."

/obj/item/paper/nuclear_guide_spacing
	name = "nuclear guide : 'Spacing the Nuclear Device'"
	info = "<b>SPACING THE NUCLEAR DEVICE</b><hr /> \
	To be used on assets of hostile operatives only. Any loss of NT nuclear devices following this guide will be charged as Grand Theft per Space Law.<hr /> \
	1. Ensure the device's access panel is closed. Use a screwdriver to close it if it isn't. <br> \
	2. Use a WELDING TOOL to cut the anchoring bolt covers.<br> \
	3. Use a CROWBAR to pry the bolts open.<br> \
	4. Use a WELDING TOOL to cut the anchoring system sealant.<br> \
	5. Use a WRENCH to unwrench the anchoring bolts.<br> \
	6. Use a CROWBAR to pry the nuclear device off its anchors.<br> \
	7. DRAG the nuclear device to the closest opening to SPACE, and PUSH it away from the station."

/obj/item/paper/central_command
	header ="<p><img style='display: block; margin-left: auto; margin-right: auto;' src='ntlogo.png' alt='' width='220' height='135' /></p><hr /><h3 style='text-align: center;font-family: Verdana;'><b> Nanotrasen Central Command</h3><p style='text-align: center;font-family:Verdana;'>Official Expedited Memorandum</p></b><hr />"
	info = ""
	footer = "<hr /><p style='font-family:Verdana;'><em>Failure to adhere appropriately to orders that may be contained herein is in violation of Space Law, and punishments may be administered appropriately upon return to Central Command.</em><br /><em>The recipient(s) of this memorandum acknowledge by reading it that they are liable for any and all damages to crew or station that may arise from ignoring suggestions or advice given herein.</em></p>"

/obj/item/paper/seed_vault
	name = "Seed Vault Objective"
	info = "<center><i>Seed Vault objective:</i></center> \ Your creator has sent you to planet SN-856B in the Jansev4 system to perform terraforming. <br>To assist you in your task, we provided you with: <br>- 4 compact pickaxes <br>- 4 extended-capacity emergency oxygen tanks <br>- 4 breathing masks <br>- 4 bee starter kits <br>- A fully functional botanical setup <br><br>You will find an Introduction for Experimental Terraforming inside the cockpit."

/obj/item/paper/seed_vault/terraforming_introduction
	name = "Terraformation Experiment for SN-856B"
	info = "Thanks to genetic engineering, we modified this grass to be able grow in rocky, waterless environments. Remember to grow the grass seeds first and when it matures, weave them together to create patches of grass. Cover as much ground with these patches as you can, and with time it will start producing oxygen, which will begin to increase the density of the atmosphere."

/obj/item/paper/seed_vault/autopilot_logs
	name = "Automatical Logs Printout"
	info = "<center>Hoverhock 'Bumblebee Bee' Online</center> <br><i>Auto-Pilot online.</i> <br><i>Loading destination...</i> Planet SN-856B in Jansev4 System <br><i>Loaging planet statistics...</i> <br><br><center>Planet SN-856B</center><br>    Planet Size: Small <br>    Planet Type: Rocky <br>    Planet Atmosphere: 76.325kpa (Thin) <br>    Contain Breathable Gasses: YES <br>    Contain Liquids: NO <br>    Terraformation: Possible <br><br><i>Destination Loaded, Departing.</i> <br><br><br><center>Traveled Distance: 143LY</center> \ <br>Auto-Log: Ship was traversing trough dense asteroid field, minor hull damage detected, initiating auto-repair module. <br><br><center>Traveled Distance: 255LY</center> \ <br>Auto-Log: Ship is passing through dead star nebula, detected high space radiation.  <br><br><center>Traveled Distance: 427LY</center> \ <br>Auto-Log: Ship is passing trough -/&^-/#@, detected malfunction of components, receiving signal from nearby planet bzz -/!#D^%- <br><center>System Reboot</center> <br><center>Aquired new destination: Lavaland</center> <br><center>Initiating Terraforming Protocole.</center> <br><br><center>End Logs</center>"

/obj/item/paper/syndicate_druglab
	name = "paper - 'Excerpt from a Diary'"
	info = "<p style='font-size:80%'><center><i>3 January</i></center><br><br>New year, new me! Since I botched my last job, the boss has \"re-assigned\" me to this hellhole. \"A little gardening will help with calming down, so you can focus on your work better next time!\" I don't fucking need to calm down. How the hell was I supposed to know that plasmamen catch on fire by PURELY EXISTING??? What kind of evolutionary bullshit is this?<br><br>And why did we start hiring living fireballs and putTING THEM INTO <b><i>OUR ATMOSPHERICS DEPARTMENT?!??!!</i></b><br><br>Fine. I might really need some calming down.<br><br>Glory to the Syndicate.<br><br><center>...<br><br><i>24 March</i></center><br><br>This asteroid sucks. I thought growing drugs and taking some will be fun, but it's not. I can't really get high or else these shitty plants die instantly. I brought some music albums with me but I'm getting tired of them. I might pick up singing, but I'm worried I'd shatter the windows with it.<br><br>The next shipment is due tomorrow. I hope the delivery guy has some new stuff for me.<br><br>Glory to the Syndicate.<br><br><center>...<br><br><i>22 November</i></center><br><br>I thought by now I served my time, but management probably just forgot about me and I'm stuck here for another year. I miss my family. I doubt I can go home for Christmas.<br><br>Man, when did I become such a softy?<br><br>Yesterday, I realized that the hangar is echoing. If I yell loud enough, my voice bounces back. It's almost like having someone talk to me.<br><br>Glory to the Syndicate.<br><br><center>...<br><br><i>09 April</i></center><br><br>I think the disposal system is not working properly, I keep hearing weird noises from the other side. Well, the boss didn't issue me any EVA gear, so whatever or whoever is there can fuck themselves. I hope it won't crawl up the pipes.<br><br>Glory to the Syndicate.<br><br><center>...<br><br><i>25 December</i></center><br><br>I don't have anything interesting or witty to write today. I tried to grow a pine tree-shaped reishi, but failed. Of course I failed. I fail at everything.<br><br>Merry Christmas to... me. I guess.<br><br>Glory to the... eh... whatever...<br><br><center>...<br><br><i>16 March</i></center><br><br>Piece of shit machine broke down. I tried to take apart the biogenerator to cannibalize its parts, but I tore its cables in the process. Delivery guy is coming tomorrow and I am NOT trusting him with getting new parts again. Everything George brought so far keeps breaking. I will be back in a few weeks.<br><br>It will be nice to meet some new people after four years...<br><br>Note to self: do <b><u>NOT</u></b> forget to close the hangar doors!!<br><br>Glory to the Syndicate.</p>"

/obj/item/paper/syndicate_druglab/delivery
	name = "paper - 'Delivery Note'"
	info = "<i>Hey sweetie! The boss wants you to have some friends. I couldn't get you a real suit, but I found this in a cosplay shop! The bees surely won't see through your IMPECCABLE disguise!<br><br>xoxo,<br>george ♥</i><br><br>- What the fuck. I'm airlocking him tomorrow."

/obj/item/paper/atmos_asteroid
	header ="<p><img style='display: block; margin-left: auto; margin-right: auto;' src='ntlogo.png' alt='' width='220' height='135' /></p><hr /><h3 style='text-align: center;font-family: Verdana;'><b> Nanotrasen Central Command</h3><p style='text-align: center;font-family:Verdana;'>Official Expedited Memorandum</p></b><hr />"
	name = "Lava Field Observations"
	info = "<center>Asteroid Core Observation Log 306</center><hr><br><i>We took some additional samples of the deep layers of the molten core of the asteroid. Undetermined trace elements were able to be identified in the solution. Its possible this is how the plasma remains so stable at these temperatures. None of our current filter methods have been able to properly extract it as of yet, but we're certain a breakthrough is on the horizon. We did it before, we can do it again.</i>"

/obj/item/paper/clockwork_cult_message
	name = "Old handwritten note"
	info = "<center>To any brothers and sisters that journey here from beyond the system:</center><br><br>\
	The Nar'Sien dogs have failed, and we have gleaned the method by which we can awake His divine mechanism. The spark shall be turned into lightning and the gears shall once again turn.<br><br>\
	We go now to purge the dogs from the hole we know they hide within, and then The Eminance shall then call us back to Reebe so that we may begin preperations for His awakening.<br><br>\
	The guardians shall protect the monastery in our stead. Make use of its supplies and prepare for our return, together we shall all finalize His vison."

/obj/item/paper/zombie_cure
	name = "paper - 'Research on Zombies'"

/obj/item/paper/zombie_cure/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD // Make sure reagents appear before this paper

/obj/item/paper/zombie_cure/LateInitialize()
	. = ..()
	var/list/zombie_cure_reactions = list()
	for(var/id in GLOB.chemical_reactions_list)
		for(var/datum/chemical_reaction/zombie/reaction in GLOB.chemical_reactions_list[id])
			zombie_cure_reactions["[reaction.cure_level]"] = reaction // we use string keys here so we can measure how many cures there are

	if(length(zombie_cure_reactions) != 4)
		stack_trace("GLOB.chemical_reactions_list only had [length(zombie_cure_reactions)] zombie cure reactions, when it should have had 4")

	var/list/info_builder = list(
		"I've done my best to cure them but... I'm out of time. I'd rather die than be bitten and turn into one of them. Below is a compilation of my research of the virus... Good luck.<br>"
	)
	for(var/counter in list("1", "2", "3", "4"))
		var/datum/chemical_reaction/zombie/level = zombie_cure_reactions[counter]
		if(!level)
			continue
		info_builder += "<b><font size='4'>[level.name]</font></b><br>"
		if(counter == "4")
			var/datum/reagent/reagent_type
			for(var/reagent in level.required_reagents)
				if(reagent == "blood")
					continue
				reagent_type = GLOB.chemical_reagents_list[reagent]
				break
			info_builder += "I wasn't able to finalize this final Omega sequence. But I know it must contain [reagent_type.name]."
			break
		info_builder += "<ul>"
		for(var/reagent in level.required_reagents)
			if(reagent == "blood")
				continue
			var/datum/reagent/reagent_type = GLOB.chemical_reagents_list[reagent]
			info_builder += "<li>[reagent_type.name]"
		info_builder += "</ul><br>"

	info = info_builder.Join("")

/obj/item/paper/evilfax
	name = "Centcomm Reply"
	info = ""
	var/mytarget = null
	var/myeffect = null
	var/used = FALSE
	var/countdown = 60
	var/activate_on_timeout = FALSE
	var/faxmachineid = null

/obj/item/paper/evilfax/show_content(mob/user, forceshow = 0, forcestars = 0, infolinks = 0, view = 1)
	if(user == mytarget)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			evilpaper_specialaction(C)
			..()
		else
			// This should never happen, but just in case someone is adminbussing
			evilpaper_selfdestruct()
	else
		if(mytarget)
			to_chat(user,"<span class='notice'>This page appears to be covered in some sort of bizzare code. The only bit you recognize is the name of [mytarget]. Perhaps [mytarget] can make sense of it?</span>")
		else
			evilpaper_selfdestruct()


/obj/item/paper/evilfax/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/paper/evilfax/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(mytarget && !used)
		var/mob/living/carbon/target = mytarget
		target.ForceContractDisease(new /datum/disease/transformation/corgi(0))
	return ..()


/obj/item/paper/evilfax/process()
	if(!countdown)
		if(mytarget)
			if(activate_on_timeout)
				evilpaper_specialaction(mytarget)
			else
				message_admins("[mytarget] ignored an evil fax until it timed out.")
		else
			message_admins("Evil paper '[src]' timed out, after not being assigned a target.")
		used = TRUE
		evilpaper_selfdestruct()
	else
		countdown--

/obj/item/paper/evilfax/proc/evilpaper_specialaction(mob/living/carbon/target)
	spawn(30)
		if(iscarbon(target))
			var/obj/machinery/photocopier/faxmachine/fax = locateUID(faxmachineid)
			if(myeffect == "Borgification")
				to_chat(target,"<span class='userdanger'>You seem to comprehend the AI a little better. Why are your muscles so stiff?</span>")
				target.ForceContractDisease(new /datum/disease/transformation/robot(0))
			else if(myeffect == "Corgification")
				to_chat(target,"<span class='userdanger'>You hear distant howling as the world seems to grow bigger around you. Boy, that itch sure is getting worse!</span>")
				target.ForceContractDisease(new /datum/disease/transformation/corgi(0))
			else if(myeffect == "Death By Fire")
				to_chat(target,"<span class='userdanger'>You feel hotter than usual. Maybe you should lowe-wait, is that your hand melting?</span>")
				var/turf/simulated/T = get_turf(target)
				var/obj/effect/hotspot/hotspot = new /obj/effect/hotspot/fake(T)
				hotspot.temperature = 1000
				hotspot.recolor()
				target.adjustFireLoss(150) // hard crit, the burning takes care of the rest.
			else if(myeffect == "Total Brain Death")
				to_chat(target,"<span class='userdanger'>You see a message appear in front of you in bright red letters: <b>YHWH-3 ACTIVATED. TERMINATION IN 3 SECONDS</b></span>")
				ADD_TRAIT(target, TRAIT_BADDNA, "evil_fax")
				target.adjustBrainLoss(125)
			else if(myeffect == "Honk Tumor")
				if(!target.get_int_organ(/obj/item/organ/internal/honktumor))
					var/obj/item/organ/internal/organ = new /obj/item/organ/internal/honktumor
					to_chat(target,"<span class='userdanger'>Life seems funnier, somehow.</span>")
					organ.insert(target)
			else if(myeffect == "Cluwne")
				if(ishuman(target))
					var/mob/living/carbon/human/H = target
					to_chat(H, "<span class='userdanger'>You feel surrounded by sadness. Sadness... and HONKS!</span>")
					H.makeCluwne()
			else if(myeffect == "Demote")
				GLOB.major_announcement.Announce("[target.real_name] is hereby demoted to the rank of Assistant. Process this demotion immediately. Failure to comply with these orders is grounds for termination.","CC Demotion Order")
				for(var/datum/data/record/R in sortRecord(GLOB.data_core.security))
					if(R.fields["name"] == target.real_name)
						R.fields["criminal"] = SEC_RECORD_STATUS_DEMOTE
						R.fields["comments"] += "Central Command Demotion Order, given on [GLOB.current_date_string] [station_time_timestamp()]<BR> Process this demotion immediately. Failure to comply with these orders is grounds for termination."
				update_all_mob_security_hud()
			else if(myeffect == "Demote with Bot")
				GLOB.major_announcement.Announce("[target.real_name] is hereby demoted to the rank of Assistant. Process this demotion immediately. Failure to comply with these orders is grounds for termination.","CC Demotion Order")
				for(var/datum/data/record/R in sortRecord(GLOB.data_core.security))
					if(R.fields["name"] == target.real_name)
						R.fields["criminal"] = SEC_RECORD_STATUS_ARREST
						R.fields["comments"] += "Central Command Demotion Order, given on [GLOB.current_date_string] [station_time_timestamp()]<BR> Process this demotion immediately. Failure to comply with these orders is grounds for termination."
				update_all_mob_security_hud()
				if(fax)
					var/turf/T = get_turf(fax)
					new /obj/effect/portal(T)
					new /mob/living/simple_animal/bot/secbot(T)
			else if(myeffect == "Revoke Fax Access")
				GLOB.fax_blacklist += target.real_name
				if(fax)
					fax.authenticated = 0
			else if(myeffect == "Angry Fax Machine")
				if(fax)
					fax.become_mimic()
			else
				message_admins("Evil paper [src] was activated without a proper effect set! This is a bug.")
		used = TRUE
		evilpaper_selfdestruct()

/obj/item/paper/evilfax/proc/evilpaper_selfdestruct()
	visible_message("<span class='danger'>[src] spontaneously catches fire, and burns up!</span>")
	qdel(src)

/obj/item/paper/pickup(user)
	..()
	if(!contact_poison || !ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/clothing/gloves/G = H.gloves
	if(!istype(G) || !G.safe_from_poison)
		H.reagents.add_reagent(contact_poison, contact_poison_volume)
		add_attack_logs(src, user, "Picked up [src], coated with [contact_poison] by [contact_poison_poisoner]")
		contact_poison = null

/obj/item/paper/researchnotes
	name = "paper - 'Research Notes'"
	info = "<b>The notes appear gibberish to you. Perhaps a scientific analyzer in R&D could make sense of them?</b>"
	origin_tech = "combat=4;materials=4;engineering=4;biotech=4"

/obj/item/paper/researchnotes/Initialize(mapload)
	. = ..()
	var/list/possible_techs = list("materials", "engineering", "plasmatech", "powerstorage", "bluespace", "biotech", "combat", "magnets", "programming", "syndicate")
	var/mytech = pick(possible_techs)
	var/mylevel = rand(7, 9)
	origin_tech = "[mytech]=[mylevel]"
	name = "research notes - [mytech] [mylevel]"

// I want this type dead
/obj/item/paper/instruction
	name = "Instruction Notes"

/obj/item/paper/instruction/pacman_generator
	name = "Instructions for P.A.C.M.A.N. Generator series"
	info = "P.A.C.M.A.N. are commonly used as 'Emergency' power generators, with its upgraded version being capable of utilizing uranium and plasma sheets to function. Simply anchor on the power cable node, insert the plasma sheet, select the level and turn it ON to generate power, just make sure to not overheat it or it will explode."

/obj/item/paper/rocky_motel
	name = "strange note"
	info = "Nancy, dear, could you <i>please</i> stop hiding my beer in the safe? I'm telling you, it's alcohol-free and safe to drink. Just quit making me mad, for fuck's sake!"

/obj/item/paper/rocky_motel/syndie
	info = "Don't forget to grab the gold from safe tomorrow, I'm not going to stay there for another year, this place sucks."
