/proc/issmall(A)
	if(A && istype(A, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = A
		if(H.dna.species && H.dna.species.is_small)
			return 1
 	return 0

/proc/ispet(A)
	if(istype(A, /mob/living/simple_animal))
		var/mob/living/simple_animal/SA = A
		if(SA.can_collar)
			return 1
	return 0

/mob/proc/isSynthetic()
	return 0

/mob/living/carbon/human/isSynthetic()
	if(ismachine(src))
		return TRUE
	return FALSE

/mob/proc/get_screen_colour()

/mob/proc/update_client_colour(var/time = 10) //Update the mob's client.color with an animation the specified time in length.
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

/proc/ismindshielded(A) //Checks to see if the person contains a mindshield implant, then checks that the implant is actually inside of them
	for(var/obj/item/implant/mindshield/L in A)
		if(L && L.implanted)
			return 1
	return 0

/proc/ismindslave(A) //Checks to see if the person contains a mindslave implant, then checks that the implant is actually inside of them
	for(var/obj/item/implant/traitor/T in A)
		if(T && T.implanted)
			return 1
	return 0

/proc/isLivingSSD(mob/M)
	return istype(M) && M.player_logged && M.stat != DEAD

/proc/isAntag(A)
	if(istype(A, /mob/living/carbon))
		var/mob/living/carbon/C = A
		if(C.mind && C.mind.special_role)
			return 1
	return 0

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
		SPECIAL_ROLE_SHADOWLING,
		SPECIAL_ROLE_SHADOWLING_THRALL,
		SPECIAL_ROLE_TRAITOR,
		SPECIAL_ROLE_VAMPIRE,
		SPECIAL_ROLE_VAMPIRE_THRALL
	)
	if(special_role in crew_roles)
		return 0

	return 1

/proc/cannotPossess(A)
	var/mob/dead/observer/G = A
	if(G.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
		return 1
	return 0


/proc/iscuffed(A)
	if(istype(A, /mob/living/carbon))
		var/mob/living/carbon/C = A
		if(C.handcuffed)
			return 1
	return 0

/proc/hassensorlevel(A, var/level)
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
	var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as [M.real_name ? M.real_name : M.name]?", poll_time = 100, min_hours = minhours)
	var/mob/dead/observer/theghost = null

	if(LAZYLEN(candidates))
		theghost = pick(candidates)
		to_chat(M, "Your mob has been taken over by a ghost!")
		message_admins("[key_name_admin(theghost)] has taken control of ([key_name_admin(M)])")
		M.ghostize()
		M.key = theghost.key
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
	n = length(n)
	var/p = null
	p = 1
	while(p <= n)
		if((copytext(te, p, p + 1) == " " || prob(pr)))
			t = text("[][]", t, copytext(te, p, p + 1))
		else
			t = text("[]*", t)
		p++
	return t

/proc/stars_all(list/message_pieces, pr)
	for(var/datum/multilingual_say_piece/S in message_pieces)
		S.message = stars(S.message, pr)

/proc/slur(phrase, var/list/slurletters = ("'"))//use a different list as an input if you want to make robots slur with $#@%! characters
	phrase = html_decode(phrase)
	var/leng=length(phrase)
	var/counter=length(phrase)
	var/newphrase=""
	var/newletter=""
	while(counter>=1)
		newletter=copytext(phrase,(leng-counter)+1,(leng-counter)+2)
		if(rand(1,3)==3)
			if(lowertext(newletter)=="o")	newletter="u"
			if(lowertext(newletter)=="s")	newletter="ch"
			if(lowertext(newletter)=="a")	newletter="ah"
			if(lowertext(newletter)=="c")	newletter="k"
		switch(rand(1,15))
			if(1,3,5,8)	newletter="[lowertext(newletter)]"
			if(2,4,6,15)	newletter="[uppertext(newletter)]"
			if(7)	newletter+=pick(slurletters)
			//if(9,10)	newletter="<b>[newletter]</b>"
			//if(11,12)	newletter="<big>[newletter]</big>"
			//if(13)	newletter="<small>[newletter]</small>"
		newphrase+="[newletter]"
		counter-=1
	return newphrase

/proc/stutter(n)
	var/te = html_decode(n)
	var/t = ""//placed before the message. Not really sure what it's for.
	n = length(n)//length of the entire word
	var/p = null
	p = 1//1 is the start of any word
	while(p <= n)//while P, which starts at 1 is less or equal to N which is the length.
		var/n_letter = copytext(te, p, p + 1)//copies text from a certain distance. In this case, only one letter at a time.
		if(prob(80) && (ckey(n_letter) in list("b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z")))
			if(prob(10))
				n_letter = text("[n_letter]-[n_letter]-[n_letter]-[n_letter]")//replaces the current letter with this instead.
			else
				if(prob(20))
					n_letter = text("[n_letter]-[n_letter]-[n_letter]")
				else
					if(prob(5))
						n_letter = null
					else
						n_letter = text("[n_letter]-[n_letter]")
		t = text("[t][n_letter]")//since the above is ran through for each letter, the text just adds up back to the original word.
		p++//for each letter p is increased to find where the next letter will be.
	return sanitize(copytext(t,1,MAX_MESSAGE_LEN))

/proc/robostutter(n) //for robutts
	var/te = html_decode(n)
	var/t = ""//placed before the message. Not really sure what it's for.
	n = length(n)//length of the entire word
	var/p = null
	p = 1//1 is the start of any word
	while(p <= n)//while P, which starts at 1 is less or equal to N which is the length.
		var/robotletter = pick("@", "!", "#", "$", "%", "&", "?") //for beep boop
		var/n_letter = copytext(te, p, p + 1)//copies text from a certain distance. In this case, only one letter at a time.
		if(prob(80) && (ckey(n_letter) in list("b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z")))
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
	return sanitize(copytext(t,1,MAX_MESSAGE_LEN))


/proc/Gibberish(t, p)//t is the inputted message, and any value higher than 70 for p will cause letters to be replaced instead of added
	/* Turn text into complete gibberish! */
	var/returntext = ""
	for(var/i = 1, i <= length(t), i++)

		var/letter = copytext(t, i, i+1)
		if(prob(50))
			if(p >= 70)
				letter = ""

			for(var/j = 1, j <= rand(0, 2), j++)
				letter += pick("#","@","*","&","%","$","/", "<", ">", ";","*","*","*","*","*","*","*")

		returntext += letter

	return returntext

/proc/Gibberish_all(list/message_pieces, p)
	for(var/datum/multilingual_say_piece/S in message_pieces)
		S.message = Gibberish(S.message, p)


proc/muffledspeech(phrase)
	phrase = html_decode(phrase)
	var/leng=length(phrase)
	var/counter=length(phrase)
	var/newphrase=""
	var/newletter=""
	while(counter>=1)
		newletter=copytext(phrase,(leng-counter)+1,(leng-counter)+2)
		if(newletter in list(" ", "!", "?", ".", ","))
			//do nothing
		else if(lowertext(newletter) in list("a", "e", "i", "o", "u", "y"))
			newletter = "ph"
		else
			newletter = "m"
		newphrase+="[newletter]"
		counter-=1
	return newphrase

/proc/muffledspeech_all(list/message_pieces)
	for(var/datum/multilingual_say_piece/S in message_pieces)
		S.message = muffledspeech(S.message)


/proc/shake_camera(mob/M, duration, strength=1)
	if(!M || !M.client || M.shakecamera)
		return
	M.shakecamera = 1
	spawn(1)

		var/atom/oldeye=M.client.eye
		var/aiEyeFlag = 0
		if(istype(oldeye, /mob/camera/aiEye))
			aiEyeFlag = 1

		var/x
		for(x=0; x<duration, x++)
			if(aiEyeFlag)
				M.client.eye = locate(dd_range(1,oldeye.loc.x+rand(-strength,strength),world.maxx),dd_range(1,oldeye.loc.y+rand(-strength,strength),world.maxy),oldeye.loc.z)
			else
				M.client.eye = locate(dd_range(1,M.loc.x+rand(-strength,strength),world.maxx),dd_range(1,M.loc.y+rand(-strength,strength),world.maxy),M.loc.z)
			sleep(1)
		M.client.eye=oldeye
		M.shakecamera = 0


/proc/findname(msg)
	for(var/mob/M in GLOB.mob_list)
		if(M.real_name == text("[msg]"))
			return 1
	return 0


/mob/proc/abiotic(var/full_body = 0)
	if(full_body && ((l_hand && !(l_hand.flags & ABSTRACT)) || (r_hand && !(r_hand.flags & ABSTRACT)) || (back || wear_mask)))
		return 1

	if((l_hand && !(l_hand.flags & ABSTRACT)) || (r_hand && !(r_hand.flags & ABSTRACT)))
		return 1

	return 0

//converts intent-strings into numbers and back
var/list/intents = list(INTENT_HELP,INTENT_DISARM,INTENT_GRAB,INTENT_HARM)
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

	if(sleeping)
		to_chat(src, "<span class='notice'>You are already sleeping.</span>")
		return
	else
		if(alert(src, "You sure you want to sleep for a while?", "Sleep", "Yes", "No") == "Yes")
			SetSleeping(20) //Short nap

/mob/living/verb/lay_down()
	set name = "Rest"
	set category = "IC"

	if(!resting)
		client.move_delay = world.time + 20
		to_chat(src, "<span class='notice'>You are now resting.</span>")
		StartResting()
	else if(resting)
		to_chat(src, "<span class='notice'>You are now getting up.</span>")
		StopResting()

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
/proc/say_dead_direct(var/message, var/mob/subject = null)
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
				if(C.mob.mind.original && C.mob.mind.original.real_name)
					realname = C.mob.mind.original.real_name
			if(mindname && mindname != realname)
				name = "[realname] died as [mindname]"
			else
				name = realname

	for(var/mob/M in GLOB.player_list)
		if(M.client && ((!istype(M, /mob/new_player) && M.stat == DEAD) || check_rights(R_ADMIN|R_MOD,0,M)) && M.get_preference(CHAT_DEAD))
			var/follow
			var/lname
			if(subject)
				if(subject != M)
					follow = "([ghost_follow_link(subject, ghost=M)]) "
				if(M.stat != DEAD && check_rights(R_ADMIN|R_MOD,0,M))
					follow = "([admin_jump_link(subject)]) "
				var/mob/dead/observer/DM
				if(istype(subject, /mob/dead/observer))
					DM = subject
				if(check_rights(R_ADMIN|R_MOD,0,M)) 							// What admins see
					lname = "[keyname][(DM && DM.client && DM.client.prefs.ghost_anonsay) ? "*" : (DM ? "" : "^")] ([name])"
				else
					if(DM && DM.client && DM.client.prefs.ghost_anonsay)	// If the person is actually observer they have the option to be anonymous
						lname = "Ghost of [name]"
					else if(DM)									// Non-anons
						lname = "[keyname] ([name])"
					else										// Everyone else (dead people who didn't ghost yet, etc.)
						lname = name
				lname = "<span class='name'>[lname]</span> "
			to_chat(M, "<span class='deadsay'>[lname][follow][message]</span>")

/proc/notify_ghosts(message, ghost_sound = null, enter_link = null, title = null, atom/source = null, image/alert_overlay = null, flashwindow = TRUE, var/action = NOTIFY_JUMP) //Easy notification of ghosts.
	for(var/mob/dead/observer/O in GLOB.player_list)
		if(O.client)
			to_chat(O, "<span class='ghostalert'>[message][(enter_link) ? " [enter_link]" : ""]</span>")
			if(ghost_sound)
				O << sound(ghost_sound)
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
						var/old_layer = source.layer
						var/old_plane = source.plane
						source.layer = FLOAT_LAYER
						source.plane = FLOAT_PLANE
						A.overlays += source
						source.layer = old_layer
						source.plane = old_plane
					else
						alert_overlay.layer = FLOAT_LAYER
						alert_overlay.plane = FLOAT_PLANE
						A.overlays += alert_overlay

/mob/proc/switch_to_camera(var/obj/machinery/camera/C)
	if(!C.can_use() || stat || (get_dist(C, src) > 1 || machine != src || !has_vision() || !canmove))
		return 0
	check_eye(src)
	return 1

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
		for(var/list/L in list(data_core.general,data_core.medical,data_core.security,data_core.locked))
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
			length = length(oldname)
			pos = findtextEx(objective.explanation_text, oldname)
			objective.explanation_text = copytext(objective.explanation_text, 1, pos)+newname+copytext(objective.explanation_text, pos+length)
	return 1

/mob/proc/rename_self(var/role, var/allow_numbers = FALSE, var/force = FALSE)
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
	var/leng = length(phrase)
	var/counter=length(phrase)
	var/newphrase=""
	var/newletter=""
	while(counter>=1)
		newletter=copytext(phrase,(leng-counter)+1,(leng-counter)+2)
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
		newphrase+="[newletter]";counter-=1
	return newphrase

/mob/proc/get_preference(toggleflag)
	if(!client)
		return FALSE
	if(!client.prefs)
		log_runtime(EXCEPTION("Mob '[src]', ckey '[ckey]' is missing a prefs datum on the client!"))
		return FALSE
	// Cast to 1/0
	return !!(client.prefs.toggles & toggleflag)

// Used to make sure that a player has a valid job preference setup, used to knock players out of eligibility for anything if their prefs don't make sense.
// A "valid job preference setup" in this situation means at least having one job set to low, or not having "return to lobby" enabled
// Prevents "antag rolling" by setting antag prefs on, all jobs to never, and "return to lobby if preferences not availible"
// Doing so would previously allow you to roll for antag, then send you back to lobby if you didn't get an antag role
// This also does some admin notification and logging as well
/mob/proc/has_valid_preferences()
	if(!client)
		return FALSE //Not sure how this would get run without the mob having a client, but let's just be safe.
	if(client.prefs.alternate_option != RETURN_TO_LOBBY)
		return TRUE
	// If they have antags enabled, they're potentially doing this on purpose instead of by accident. Notify admins if so.
	var/has_antags = FALSE
	if(client.prefs.be_special.len > 0)
		has_antags = TRUE
	if(!client.prefs.check_any_job())
		to_chat(src, "<span class='danger'>You have no jobs enabled, along with return to lobby if job is unavailable. This makes you ineligible for any round start role, please update your job preferences.</span>")
		if(has_antags)
			log_admin("[src.ckey] just got booted back to lobby with no jobs, but antags enabled.")
			message_admins("[src.ckey] just got booted back to lobby with no jobs enabled, but antag rolling enabled. Likely antag rolling abuse.")
		return FALSE //This is the only case someone should actually be completely blocked from antag rolling as well
	return TRUE

#define isterrorspider(A) (istype((A), /mob/living/simple_animal/hostile/poison/terror_spider))
