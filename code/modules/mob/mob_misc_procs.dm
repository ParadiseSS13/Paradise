/proc/issmall(A)
	if(A && ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.dna.species && H.dna.species.is_small)
			return 1
	return 0

/proc/ispet(A)
	if(isanimal(A))
		var/mob/living/simple_animal/SA = A
		if(SA.can_collar)
			return 1
	return 0

/mob/proc/get_screen_colour()
	SHOULD_CALL_PARENT(TRUE)
	// OOC Colourblind setting takes priority over everything else.
	if(client?.prefs)
		switch(client.prefs.colourblind_mode)
			if(COLOURBLIND_MODE_NONE)
				. = null

			/*
				Also it goes without saying

				For the love of god, do NOT mess with the matricies below.
				The values may look arbitrary as hell, but they follow colour filtering rules
				to accent specific colours and block out others, which helps different
				forms of colourblindness. Its not perfect but it helps.

				If you ever want to modify these matricies, test them with someone who
				suffers that form of colourblindness, and ask if its an improvement or a hinderance.
				I cannot stress this enough

				-aa07
			*/
			if(COLOURBLIND_MODE_DEUTER)
				// Red-green (green weak, deuteranopia)
				// Below is a colour matrix to account for that
				. = list(
					1.8,  0, -0.14, 0,
					-1.05, 1,  0.1,  0,
					0.3,  0,  1,    0,
					0,    0,  0,    1
				) // Time spent creating this matrix: 1 hour 32 minutes

			if(COLOURBLIND_MODE_PROT)
				// Red-green (red weak, protanopia)
				// Below is a colour matrix to account for that
				. = list(
					1, 0.475, 0.594, 0,
					0, 0.482, -0.68, 0,
					0, 0.044, 1.087, 0,
					0, 0,     0,     1
				) // Time spent creating this matrix: 57 minutes

			if(COLOURBLIND_MODE_TRIT)
				// Blue-yellow (tritanopia)
				// Below is a colour matrix to account for that
				. = list(
					0.74,  0.07,  0, 0,
					-0.405, 0.593, 0, 0,
					0.665, 0.335, 1, 0,
					0,     0,     0, 1
				) // Time spent creating this matrix: 34 minutes

	return

/mob/proc/update_client_colour(time = 10) //Update the mob's client.color with an animation the specified time in length.
	if(!client) //No client_colour without client. If the player logs back in they'll be back through here anyway.
		return
	client.colour_transition(get_screen_colour(), time = time) //Get the colour matrix we're going to transition to depending on relevance (magic glasses first, eyes second).

/mob/living/carbon/human/get_screen_colour() //Fetch the colour matrix from wherever (e.g. eyes) so it can be compared to client.color.
	. = ..()
	if(.)
		return .

	var/obj/item/clothing/glasses/worn_glasses = glasses
	var/obj/item/organ/internal/eyes/eyes = get_int_organ(/obj/item/organ/internal/eyes)
	if(istype(worn_glasses) && worn_glasses.color_view) //Check to see if they got those magic glasses and they're augmenting the colour of what the wearer sees. If they're not, color_view should be null.
		return worn_glasses.color_view
	else if(eyes) //If they're not, check to see if their eyes got one of them there colour matrices. Will be null if eyes are robotic/the mob isn't colourblind and they have no default colour matrix.
		return eyes.get_colourmatrix()

/**
  * Flash up a color as an overlay on a player's screen, then fade back to normal.
  *
  * Arguments:
  * * flash_color - The color to overlay on the screen.
  * * flash_time - The time it takes for the color to fade back to normal.
  */
/mob/proc/flash_screen_color(flash_color, flash_time)
	if(!client)
		return
	if(client?.prefs.colourblind_mode != COLOURBLIND_MODE_NONE)
		return
	client.color = flash_color
	INVOKE_ASYNC(client, TYPE_PROC_REF(/client, colour_transition), get_screen_colour(), flash_time)

/proc/ismindshielded(A) //Checks to see if the person contains a mindshield implant, then checks that the implant is actually inside of them
	for(var/obj/item/implant/mindshield/L in A)
		if(L && L.implanted)
			return 1
	return 0

/proc/isLivingSSD(mob/M)
	return istype(M) && M.player_logged && M.stat != DEAD

/proc/isAntag(A)
	if(isliving(A))
		var/mob/living/L = A
		if(L.mind?.special_role)
			return TRUE
	return FALSE

/proc/isNonCrewAntag(A)
	if(!isAntag(A))
		return 0

	var/mob/living/carbon/C = A
	var/special_role = C.mind.special_role
	var/list/crew_roles = list(
		SPECIAL_ROLE_BLOB,
		SPECIAL_ROLE_CULTIST,
		SPECIAL_ROLE_CHANGELING,
		SPECIAL_ROLE_ERT,
		SPECIAL_ROLE_HEAD_REV,
		SPECIAL_ROLE_REV,
		SPECIAL_ROLE_TRAITOR,
		SPECIAL_ROLE_VAMPIRE,
		SPECIAL_ROLE_VAMPIRE_THRALL,
		SPECIAL_ROLE_DEATHSQUAD
	)
	if(special_role in crew_roles)
		return 0

	return 1

/proc/cannotPossess(A)
	var/mob/dead/observer/G = A
	if(G.has_enabled_antagHUD && GLOB.configuration.general.restrict_antag_hud_rejoin)
		return 1
	return 0


/proc/iscuffed(A)
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(C.handcuffed)
			return 1
	return 0

/proc/hassensorlevel(A, level)
	var/mob/living/carbon/human/H = A
	if(istype(H) && istype(H.w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = H.w_uniform
		return U.sensor_mode >= level
	return 0

/proc/getsensorlevel(A)
	var/mob/living/carbon/human/H = A
	if(istype(H) && istype(H.w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = H.w_uniform
		return U.sensor_mode
	return SUIT_SENSOR_OFF

/proc/offer_control(mob/M)
	to_chat(M, "Control of your mob has been offered to dead players.")
	log_admin("[key_name(usr)] has offered control of ([key_name(M)]) to ghosts.")
	var/minhours = input(usr, "Minimum hours required to play [M]?", "Set Min Hrs", 10) as num
	message_admins("[key_name_admin(usr)] has offered control of ([key_name_admin(M)]) to ghosts with [minhours] hrs playtime")
	var/question = "Do you want to play as [M.real_name ? M.real_name : M.name][M.job ? " ([M.job])" : ""]"
	if(alert("Do you want to show the antag status?","Show antag status","Yes","No") == "Yes")
		question += ", [M.mind?.special_role ? M.mind?.special_role : "No special role"]"
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("[question]?", poll_time = 10 SECONDS, min_hours = minhours, source = M)
	var/mob/dead/observer/theghost = null

	if(length(candidates))
		if(QDELETED(M))
			return
		theghost = pick(candidates)
		to_chat(M, "Your mob has been taken over by a ghost!")
		message_admins("[key_name_admin(theghost)] has taken control of ([key_name_admin(M)])")
		M.ghostize()
		M.key = theghost.key
		dust_if_respawnable(theghost)
	else
		to_chat(M, "There were no ghosts willing to take control.")
		message_admins("No ghosts were willing to take control of [key_name_admin(M)])")

/proc/check_zone(zone)
	if(!zone)	return "chest"
	switch(zone)
		if("eyes")
			zone = "head"
		if("mouth")
			zone = "head"
	return zone

// Returns zone with a certain probability.
// If the probability misses, returns "chest" instead.
// If "chest" was passed in as zone, then on a "miss" will return "head", "l_arm", or "r_arm"
// Do not use this if someone is intentionally trying to hit a specific body part.
// Use get_zone_with_miss_chance() for that.
/proc/ran_zone(zone, probability = 80)

	zone = check_zone(zone)

	if(prob(probability))
		return zone

	var/t = rand(1, 18) // randomly pick a different zone, or maybe the same one
	switch(t)
		if(1)		 return "head"
		if(2)		 return "chest"
		if(3 to 4)	 return "l_arm"
		if(5 to 6)   return "l_hand"
		if(7 to 8)	 return "r_arm"
		if(9 to 10)  return "r_hand"
		if(11 to 12) return "l_leg"
		if(13 to 14) return "l_foot"
		if(15 to 16) return "r_leg"
		if(17 to 18) return "r_foot"

	return zone

/proc/above_neck(zone)
	var/list/zones = list("head", "mouth", "eyes")
	if(zones.Find(zone))
		return 1
	else
		return 0

/proc/stars(n, pr)
	if(pr == null)
		pr = 25
	if(pr <= 0)
		return null
	else
		if(pr >= 100)
			return n
	var/te = n
	var/t = ""
	n = length_char(n)	// SS220 EDIT - ORIGINAL: length
	var/p = null
	p = 1
	while(p <= n)
		if((copytext_char(te, p, p + 1) == " " || prob(pr)))	// SS220 EDIT - ORIGINAL: copytext
			t = text("[][]", t, copytext_char(te, p, p + 1))	// SS220 EDIT - ORIGINAL: copytext
		else
			t = text("[]*", t)
		p++
	return t

/proc/stars_all(list/message_pieces, pr)
	for(var/datum/multilingual_say_piece/S in message_pieces)
		S.message = stars(S.message, pr)

/proc/slur(phrase, list/slurletters = ("'"))//use a different list as an input if you want to make robots slur with $#@%! characters
	phrase = html_decode(phrase)
	var/leng=length_char(phrase)		// SS220 EDIT - ORIGINAL: length
	var/counter=length_char(phrase)		// SS220 EDIT - ORIGINAL: length
	var/newphrase=""
	var/newletter=""
	while(counter>=1)
		newletter=copytext_char(phrase,(leng-counter)+1,(leng-counter)+2)	// SS220 EDIT - ORIGINAL: copytext
		if(rand(1,3)==3)
			if(lowertext(newletter)=="o")	newletter="u";	if(lowertext(newletter)=="о")	newletter="у";	if(lowertext(newletter)=="э")	newletter="и"
			if(lowertext(newletter)=="s")	newletter="ch";	if(lowertext(newletter)=="с")	newletter="сш";	if(lowertext(newletter)=="г")	newletter="х"
			if(lowertext(newletter)=="a")	newletter="ah";	if(lowertext(newletter)=="а")	newletter="ах"
			if(lowertext(newletter)=="c")	newletter="k";	if(lowertext(newletter)=="ц")	newletter="сц"
		switch(rand(1,15))
			if(1,3,5,8)	newletter="[lowertext(newletter)]"
			if(2,4,6,15)	newletter="[uppertext(newletter)]"
			if(7)	newletter+=pick(slurletters)
			else
				pass()
		newphrase+="[newletter]"
		counter-=1
	return newphrase

/proc/stutter(n)
	var/te = html_decode(n)
	var/t = "" //placed before the message. Not really sure what it's for.
	n = length_char(n) //length of the entire word	// SS220 EDIT - ORIGINAL: length
	var/p = null
	p = 1 //1 is the start of any word
	while(p <= n) //while P, which starts at 1 is less or equal to N which is the length.
		var/n_letter = copytext_char(te, p, p + 1) //copies text from a certain distance. In this case, only one letter at a time.			// SS220 EDIT - ORIGINAL: copytext
		if(prob(80) && (lowertext(n_letter) in list("b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z","б","в","г","д","ж","з","к","л","м","н","п","р","с","т","ф","х","ц","ч","ш","щ")))	// SS220 EDIT - ORIGINAL: (ckey(n_letter) + ADDED RU LETTERS
			if(prob(10))
				n_letter = text("[n_letter]-[n_letter]-[n_letter]-[n_letter]") //replaces the current letter with this instead.
			else
				if(prob(5))
					n_letter = null
				else
					n_letter = text("[n_letter]-[n_letter]")
		t = text("[t][n_letter]") //since the above is ran through for each letter, the text just adds up back to the original word.
		p++ //for each letter p is increased to find where the next letter will be.
	return sanitize(copytext_char(t,1,MAX_MESSAGE_LEN))	// SS220 EDIT - ORIGINAL: copytext

/proc/robostutter(n) //for robutts
	var/te = html_decode(n)
	var/t = ""//placed before the message. Not really sure what it's for.
	n = length_char(n)//length of the entire word	// SS220 EDIT - ORIGINAL: length
	var/p = null
	p = 1//1 is the start of any word
	while(p <= n)//while P, which starts at 1 is less or equal to N which is the length.
		var/robotletter = pick("@", "!", "#", "$", "%", "&", "?") //for beep boop
		var/n_letter = copytext_char(te, p, p + 1)//copies text from a certain distance. In this case, only one letter at a time.			// SS220 EDIT - ORIGINAL: copytext
		if(prob(80) && (lowertext(n_letter) in list("b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z")))	// SS220 EDIT - ORIGINAL: (ckey(n_letter)
			if(prob(10))
				n_letter = text("[n_letter]-[robotletter]-[n_letter]-[n_letter]")//replaces the current letter with this instead.
			else
				if(prob(20))
					n_letter = text("[n_letter]-[robotletter]-[n_letter]")
				else
					if(prob(5))
						n_letter = robotletter
					else
						n_letter = text("[n_letter]-[n_letter]")
		t = text("[t][n_letter]")//since the above is ran through for each letter, the text just adds up back to the original word.
		p++//for each letter p is increased to find where the next letter will be.
	return sanitize(copytext_char(t,1,MAX_MESSAGE_LEN))							// SS220 EDIT - ORIGINAL: copytext


/proc/Gibberish(t, p, replace_rate = 50)//t is the inputted message, and any value higher than 70 for p will cause letters to be replaced instead of added. replace_rate is the chance a letter is corrupted.
	/* Turn text into complete gibberish! */
	var/returntext = ""
	for(var/i = 1, i <= length_char(t), i++)									// SS220 EDIT - ORIGINAL: length

		var/letter = copytext_char(t, i, i+1)									// SS220 EDIT - ORIGINAL: copytext
		if(prob(replace_rate))
			if(p >= 70)
				letter = ""

			for(var/j = 1, j <= rand(0, 2), j++)
				letter += pick("#","@","*","&","%","$","/", ";","*","*","*","*","*","*","*")

		returntext += letter

	return returntext

/proc/Gibberish_all(list/message_pieces, p, replace_rate)
	for(var/datum/multilingual_say_piece/S in message_pieces)
		S.message = Gibberish(S.message, p, replace_rate)


/proc/muffledspeech(phrase)
	phrase = html_decode(phrase)
	var/leng=length_char(phrase)												// SS220 EDIT - ORIGINAL: length
	var/counter=length_char(phrase)												// SS220 EDIT - ORIGINAL: length
	var/newphrase=""
	var/newletter=""
	while(counter>=1)
		newletter=copytext_char(phrase,(leng-counter)+1,(leng-counter)+2)		// SS220 EDIT - ORIGINAL: copytext
		if(newletter in list(" ", "!", "?", ".", ","))
			// Skip these
			counter -= 1
			continue

		else if(lowertext(newletter) in list("a", "e", "i", "o", "u", "y"))
			newletter = "ph"

		else
			newletter = "m"

		newphrase += "[newletter]"
		counter -= 1
	return newphrase

/proc/muffledspeech_all(list/message_pieces)
	for(var/datum/multilingual_say_piece/S in message_pieces)
		S.message = muffledspeech(S.message)


///Shake the camera of the person viewing the mob SO REAL!
/proc/shake_camera(mob/M, duration, strength = 1)
	if(!M || !M.client || duration < 1)
		return
	var/client/C = M.client
	var/oldx = C.pixel_x
	var/oldy = C.pixel_y
	var/max = strength * world.icon_size
	var/min = -(strength * world.icon_size)

	for(var/i in 0 to duration - 1)
		if(i == 0)
			animate(C, pixel_x = rand(min, max), pixel_y = rand(min, max), time = 1)
		else
			animate(pixel_x = rand(min, max), pixel_y = rand(min, max), time = 1)
	animate(pixel_x = oldx, pixel_y = oldy, time = 1)


/proc/findname(msg)
	for(var/mob/M in GLOB.mob_list)
		if(M.real_name == text("[msg]"))
			return 1
	return 0


/mob/proc/abiotic(full_body = 0)
	if(full_body && ((l_hand && !(l_hand.flags & ABSTRACT)) || (r_hand && !(r_hand.flags & ABSTRACT)) || (back || wear_mask)))
		return 1

	if((l_hand && !(l_hand.flags & ABSTRACT)) || (r_hand && !(r_hand.flags & ABSTRACT)))
		return 1

	return 0

//converts intent-strings into numbers and back
GLOBAL_LIST_INIT(intents, list(INTENT_HELP,INTENT_DISARM,INTENT_GRAB,INTENT_HARM))
/proc/intent_numeric(argument)
	if(istext(argument))
		switch(argument)
			if(INTENT_HELP)		return 0
			if(INTENT_DISARM)	return 1
			if(INTENT_GRAB)		return 2
			else			return 3
	else
		switch(argument)
			if(0)			return INTENT_HELP
			if(1)			return INTENT_DISARM
			if(2)			return INTENT_GRAB
			else			return INTENT_HARM

//change a mob's act-intent. Input the intent as a string such as "help" or use "right"/"left
/mob/verb/a_intent_change(input as text)
	set name = "a-intent"
	set hidden = 1

	if(can_change_intents)
		if(ishuman(src) || isalienadult(src) || isbrain(src))
			switch(input)
				if(INTENT_HELP,INTENT_DISARM,INTENT_GRAB,INTENT_HARM)
					a_intent = input
				if("right")
					a_intent = intent_numeric((intent_numeric(a_intent)+1) % 4)
				if("left")
					a_intent = intent_numeric((intent_numeric(a_intent)+3) % 4)
			if(hud_used && hud_used.action_intent)
				hud_used.action_intent.icon_state = "[a_intent]"

		else if(isrobot(src) || islarva(src) || isanimal(src) || isAI(src))
			switch(input)
				if(INTENT_HELP)
					a_intent = INTENT_HELP
				if(INTENT_HARM)
					a_intent = INTENT_HARM
				if("right","left")
					a_intent = intent_numeric(intent_numeric(a_intent) - 3)
			if(hud_used && hud_used.action_intent)
				if(a_intent == INTENT_HARM)
					hud_used.action_intent.icon_state = "harm"
				else
					hud_used.action_intent.icon_state = "help"


/mob/living/verb/mob_sleep()
	set name = "Sleep"
	set category = "IC"

	if(IsSleeping())
		to_chat(src, "<span class='notice'>You are already sleeping.</span>")
		return
	if(alert(src, "You sure you want to sleep for a while?", "Sleep", "Yes", "No") == "Yes")
		SetSleeping(40 SECONDS, voluntary = TRUE) //Short nap

/mob/living/verb/rest()
	set name = "Rest"
	set category = "IC"


	resting = !resting // this happens before the do_mob so that you can stay resting if you are stunned.

	if(resting)
		to_chat(src, "<span class='notice'>You are now trying to rest.</span>")
	else
		to_chat(src, "<span class='notice'>You are now trying to get up.</span>")

	if(!do_mob(src, src, 1 SECONDS, extra_checks = list(CALLBACK(src, TYPE_PROC_REF(/mob/living, cannot_stand))), only_use_extra_checks = TRUE))
		return

	if(resting)
		lay_down()
	else
		stand_up()

/proc/get_multitool(mob/user as mob)
	// Get tool
	var/obj/item/multitool/P
	if(isrobot(user) || ishuman(user))
		P = user.get_active_hand()
	else if(isAI(user))
		var/mob/living/silicon/ai/AI=user
		P = AI.aiMulti

	if(!istype(P))
		return null
	return P

/proc/get_both_hands(mob/living/carbon/M)
	return list(M.l_hand, M.r_hand)


//Direct dead say used both by emote and say
//It is somewhat messy. I don't know what to do.
//I know you can't see the change, but I rewrote the name code. It is significantly less messy now
/proc/say_dead_direct(message, mob/subject = null)
	var/name
	var/keyname
	if(subject && subject.client)
		var/client/C = subject.client
		keyname = (C.holder && C.holder.fakekey) ? C.holder.fakekey : C.key
		if(C.mob) //Most of the time this is the dead/observer mob; we can totally use him if there is no better name
			var/mindname
			var/realname = C.mob.real_name
			if(C.mob.mind)
				mindname = C.mob.mind.name
				if(C.mob.mind.original_mob_name)
					realname = C.mob.mind.original_mob_name
			if(mindname && mindname != realname)
				name = "[realname] died as [mindname]"
			else
				name = realname

	for(var/obj/item/radio/deadsay_radio_system as anything in GLOB.deadsay_radio_systems)
		deadsay_radio_system.attempt_send_deadsay_message(subject, message)

	for(var/mob/M in GLOB.player_list)
		if(M.client && ((!isnewplayer(M) && M.stat == DEAD) || check_rights(R_ADMIN|R_MOD,0,M)) && M.get_preference(PREFTOGGLE_CHAT_DEAD))
			var/follow
			var/lname
			if(subject)
				if(subject != M)
					follow = "([ghost_follow_link(subject, ghost=M)]) "
				if(M.stat != DEAD && check_rights(R_ADMIN|R_MOD,0,M))
					follow = "([admin_jump_link(subject)]) "
				var/mob/dead/observer/DM
				if(isobserver(subject))
					DM = subject
				if(check_rights(R_ADMIN|R_MOD, FALSE, M)) 							// What admins see
					lname = "[keyname][(DM?.client.prefs.toggles2 & PREFTOGGLE_2_ANON) ? (@"[ANON]") : (DM ? "" : "^")] ([name])"
					//lname = "[keyname][(DM?.client.prefs.toggles2 & PREFTOGGLE_2_ANON) ? TRUE : (DM ? "" : "^")] ([name])"
				else
					if(DM?.client.prefs.toggles2 & PREFTOGGLE_2_ANON)	// If the person is actually observer they have the option to be anonymous
						lname = "<i>Anon</i> ([name])"
					else if(DM)									// Non-anons
						lname = "[keyname] ([name])"
					else										// Everyone else (dead people who didn't ghost yet, etc.)
						lname = name
				lname = "<span class='name'>[lname]</span> "
			to_chat(M, "<span class='deadsay'>[lname][follow][message]</span>")

/proc/notify_ghosts(message, ghost_sound = null, enter_link = null, title = null, atom/source = null, image/alert_overlay = null, flashwindow = TRUE, action = NOTIFY_JUMP, role = null) //Easy notification of ghosts.
	for(var/mob/O in GLOB.player_list)
		if(O.client && HAS_TRAIT(O, TRAIT_RESPAWNABLE) && (!role || (role in O.client.prefs.be_special)))
			to_chat(O, "<span class='ghostalert'>[message][(enter_link) ? " [enter_link]" : ""]</span>")
			if(ghost_sound)
				SEND_SOUND(O, sound(ghost_sound))
			if(flashwindow)
				window_flash(O.client)
			if(source)
				var/obj/screen/alert/notify_action/A = O.throw_alert("\ref[source]_notify_action", /obj/screen/alert/notify_action)
				if(A)
					if(O.client.prefs && O.client.prefs.UI_style)
						A.icon = ui_style2icon(O.client.prefs.UI_style)
					if(title)
						A.name = title
					A.desc = message
					A.action = action
					A.target = source
					if(!alert_overlay)
						// if the icon is greater than 32x, use its base icon instead of its full actual appearance
						// otherwise, if we don't do this, it totally messes with the viewport
						var/icon/atom_icon = icon(source.icon, source.icon_state)
						var/width = atom_icon.Width()
						var/height = atom_icon.Height()
						if(width > 32 || height > 32)
							atom_icon.Scale(32, 32)
							atom_icon.Crop(0, 0, 32, 32)
							A.overlays += atom_icon
						else
							var/image/appearance = image(source)
							appearance.layer = FLOAT_LAYER
							appearance.plane = FLOAT_PLANE
							A.overlays += appearance
					else
						alert_overlay.layer = FLOAT_LAYER
						alert_overlay.plane = FLOAT_PLANE
						A.overlays += alert_overlay

/**
  * Checks if a mob's ghost can reenter their body or not. Used to check for DNR or AntagHUD.
  *
  * Returns FALSE if there is a ghost, and it can't reenter the body. Returns TRUE otherwise.
  */
/mob/proc/ghost_can_reenter()
	var/mob/dead/observer/ghost = get_ghost(TRUE)
	if(ghost && !ghost.can_reenter_corpse)
		return FALSE
	return TRUE

/mob/proc/switch_to_camera(obj/machinery/camera/C)
	if(!C.can_use() || incapacitated() || (get_dist(C, src) > 1 || machine != src || !has_vision()))
		return FALSE
	check_eye(src)
	return TRUE

/mob/proc/rename_character(oldname, newname)
	if(!newname)
		return 0
	real_name = newname
	name = newname
	if(mind)
		mind.name = newname
	if(dna)
		dna.real_name = real_name

	if(oldname)
		//update the datacore records! This is goig to be a bit costly.
		for(var/list/L in list(GLOB.data_core.general, GLOB.data_core.medical, GLOB.data_core.security, GLOB.data_core.locked))
			for(var/datum/data/record/R in L)
				if(R.fields["name"] == oldname)
					R.fields["name"] = newname
					break

		//update our pda and id if we have them on our person
		var/list/searching = GetAllContents(searchDepth = 3)
		var/search_id = 1
		var/search_pda = 1

		for(var/A in searching)
			if( search_id && istype(A,/obj/item/card/id) )
				var/obj/item/card/id/ID = A
				if(ID.registered_name == oldname)
					ID.registered_name = newname
					ID.name = "[newname]'s ID Card ([ID.assignment])"
					ID.RebuildHTML()
					if(!search_pda)	break
					search_id = 0

			else if( search_pda && istype(A,/obj/item/pda) )
				var/obj/item/pda/PDA = A
				if(PDA.owner == oldname)
					PDA.owner = newname
					PDA.name = "PDA-[newname] ([PDA.ownjob])"
					if(!search_id)	break
					search_pda = 0

		//Fixes renames not being reflected in objective text
		var/length
		var/pos
		for(var/datum/objective/objective in GLOB.all_objectives)
			if(!mind || objective.target != mind)
				continue
			length = length_char(oldname)									// SS220 EDIT - ORIGINAL: length
			pos = findtextEx_char(objective.explanation_text, oldname)		// SS220 EDIT - ORIGINAL: findtextEx
			objective.explanation_text = copytext_char(objective.explanation_text, 1, pos)+newname+copytext_char(objective.explanation_text, pos+length)	// SS220 EDIT - ORIGINAL: copytext
	return 1

/mob/proc/rename_self(role, allow_numbers = FALSE, force = FALSE)
	spawn(0)
		var/oldname = real_name

		var/time_passed = world.time
		var/newname

		for(var/i=1,i<=3,i++)	//we get 3 attempts to pick a suitable name.
			if(force)
				newname = clean_input("Pick a new name.", "Name Change", oldname, src)
			else
				newname = clean_input("You are a [role]. Would you like to change your name to something else? (You have 3 minutes to select a new name.)", "Name Change", oldname, src)
			if(((world.time - time_passed) > 1800) && !force)
				alert(src, "Unfortunately, more than 3 minutes have passed for selecting your name. If you are a robot, use the Namepick verb; otherwise, adminhelp.", "Name Change")
				return	//took too long
			newname = reject_bad_name(newname,allow_numbers)	//returns null if the name doesn't meet some basic requirements. Tidies up a few other things like bad-characters.

			for(var/mob/living/M in GLOB.player_list)
				if(M == src)
					continue
				if(!newname || M.real_name == newname)
					newname = null
					break
			if(newname)
				break	//That's a suitable name!
			to_chat(src, "Sorry, that [role]-name wasn't appropriate, please try another. It's possibly too long/short, has bad characters or is already taken.")

		if(!newname)	//we'll stick with the oldname then
			return

		rename_character(oldname, newname)

/proc/cultslur(n) // Inflicted on victims of a stun talisman
	var/phrase = html_decode(n)
	var/leng = length_char(phrase)												// SS220 EDIT - ORIGINAL: length
	var/counter=length_char(phrase)												// SS220 EDIT - ORIGINAL: length
	var/newphrase=""
	var/newletter=""
	while(counter>=1)
		newletter=copytext_char(phrase,(leng-counter)+1,(leng-counter)+2)		// SS220 EDIT - ORIGINAL: copytext
		if(rand(1,2)==2)
			if(lowertext(newletter)=="o")
				newletter="u"
			if(lowertext(newletter)=="t")
				newletter="ch"
			if(lowertext(newletter)=="a")
				newletter="ah"
			if(lowertext(newletter)=="u")
				newletter="oo"
			if(lowertext(newletter)=="c")
				newletter=" NAR "
			if(lowertext(newletter)=="s")
				newletter=" SIE "
		if(rand(1,4)==4)
			if(newletter==" ")
				newletter=" no hope... "
			if(newletter=="H")
				newletter=" IT COMES... "

		switch(rand(1,15))
			if(1)
				newletter="'"
			if(2)
				newletter+="agn"
			if(3)
				newletter="fth"
			if(4)
				newletter="nglu"
			if(5)
				newletter="glor"
			else
				pass()

		newphrase+="[newletter]";counter-=1
	return newphrase

// Why does this exist?
/mob/proc/get_preference(toggleflag)
	if(!client)
		return FALSE
	if(!client.prefs)
		. = FALSE
		CRASH("Mob '[src]', ckey '[ckey]' is missing a prefs datum on the client!")
	// Cast to 1/0
	return !!(client.prefs.toggles & toggleflag)

/**
 * Helper proc to determine if a mob can use emotes that make sound or not.
 */
/mob/proc/can_use_audio_emote(intentional)
	var/emote_status = intentional ? audio_emote_cd_status : audio_emote_unintentional_cd_status
	switch(emote_status)
		if(EMOTE_INFINITE)  // Spam those emotes
			return TRUE
		if(EMOTE_ADMIN_BLOCKED)  // Cooldown emotes were disabled by an admin, prevent use
			return FALSE
		if(EMOTE_ON_COOLDOWN)	// Already on CD, prevent use
			return FALSE
		if(EMOTE_READY)
			return TRUE

	CRASH("Invalid emote type")

/**
 * Start the cooldown for an emote that plays audio.
 *
 * Arguments:
 * * intentional - Whether or not the user deliberately triggered this emote.
 * * cooldown - The amount of time that should be waited before any other audio emote can fire.
 */
/mob/proc/start_audio_emote_cooldown(intentional, cooldown = AUDIO_EMOTE_COOLDOWN)
	if(!can_use_audio_emote(intentional))
		return FALSE

	var/cooldown_source = intentional ? audio_emote_cd_status : audio_emote_unintentional_cd_status

	if(cooldown_source == EMOTE_READY)
		// we do have to juggle between cooldowns a little bit, but this lets us keep them on separate cooldowns so
		// a user screaming every five seconds doesn't prevent them from sneezing.
		if(intentional)
			audio_emote_cd_status = EMOTE_ON_COOLDOWN	// Starting cooldown
		else
			audio_emote_unintentional_cd_status = EMOTE_ON_COOLDOWN
		addtimer(CALLBACK(src, PROC_REF(on_audio_emote_cooldown_end), intentional), cooldown)
	return TRUE  // proceed with emote


/mob/proc/on_audio_emote_cooldown_end(intentional)
	if(intentional)
		if(audio_emote_cd_status == EMOTE_ON_COOLDOWN)
			// only reset to ready if we're in a cooldown state
			audio_emote_cd_status = EMOTE_READY
	else
		if(audio_emote_unintentional_cd_status == EMOTE_ON_COOLDOWN)
			audio_emote_unintentional_cd_status = EMOTE_READY

/proc/stat_to_text(stat)
	switch(stat)
		if(CONSCIOUS)
			return "conscious"
		if(UNCONSCIOUS)
			return "unconscious"
		if(DEAD)
			return "dead"

/mob/proc/attempt_listen_to_deadsay()

