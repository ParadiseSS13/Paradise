///////////////////Vanilla Morph////////////////////////////////////

/datum/dna/gene/basic/grant_spell/morph
	name = "Morphism"
	desc = "Enables the subject to reconfigure their appearance to that of any human."
	spelltype =/obj/effect/proc_holder/spell/targeted/morph
	activation_messages=list("Your body feels if can alter its appearance.")
	deactivation_messages = list("Your body doesn't feel capable of altering its appearance.")
	instability = GENE_INSTABILITY_MINOR
	mutation=MORPH

/datum/dna/gene/basic/grant_spell/morph/New()
	..()
	block = MORPHBLOCK

/obj/effect/proc_holder/spell/targeted/morph
	name = "Morph"
	desc = "Mimic the appearance of your choice!"
	panel = "Abilities"
	charge_max = 1800

	clothes_req = 0
	stat_allowed = 0
	invocation_type = "none"
	range = -1
	include_user = 1
	selection_type = "range"

	action_icon_state = "genetic_morph"

/obj/effect/proc_holder/spell/targeted/morph/cast(list/targets)
	if(!ishuman(usr))	return

	if(istype(usr.loc,/mob/))
		to_chat(usr, "<span class='warning'>You can't change your appearance right now!</span>")
		return
	var/mob/living/carbon/human/M=usr
	var/obj/item/organ/external/head/head_organ = M.get_organ("head")
	var/obj/item/organ/internal/eyes/eyes_organ = M.get_int_organ(/obj/item/organ/internal/eyes)

	var/new_gender = alert(usr, "Please select gender.", "Character Generation", "Male", "Female")
	if(new_gender)
		if(new_gender == "Male")
			M.change_gender(MALE)
		else
			M.change_gender(FEMALE)

	var/eyes_red = 0
	var/eyes_green = 0
	var/eyes_blue = 0
	if(eyes_organ)
		eyes_red = eyes_organ.eye_colour[1]
		eyes_green = eyes_organ.eye_colour[2]
		eyes_blue = eyes_organ.eye_colour[3]
	var/new_eyes = input("Please select eye color.", "Character Generation", rgb(eyes_red,eyes_green,eyes_blue)) as null|color
	if(new_eyes)
		eyes_red = hex2num(copytext(new_eyes, 2, 4))
		eyes_green = hex2num(copytext(new_eyes, 4, 6))
		eyes_blue = hex2num(copytext(new_eyes, 6, 8))
		M.change_eye_color(eyes_red, eyes_green, eyes_blue)

	// hair
	var/list/valid_hairstyles = M.generate_valid_hairstyles()
	var/new_style = input("Please select hair style", "Character Generation", head_organ.h_style) as null|anything in valid_hairstyles

	// if new style selected (not cancel)
	if(new_style)
		head_organ.h_style = new_style

	var/new_hair = input("Please select hair color.", "Character Generation", rgb(head_organ.r_hair, head_organ.g_hair, head_organ.b_hair)) as null|color
	if(new_hair)
		head_organ.r_hair = hex2num(copytext(new_hair, 2, 4))
		head_organ.g_hair = hex2num(copytext(new_hair, 4, 6))
		head_organ.b_hair = hex2num(copytext(new_hair, 6, 8))

	// facial hair
	var/list/valid_facial_hairstyles = M.generate_valid_facial_hairstyles()
	new_style = input("Please select facial style", "Character Generation", head_organ.f_style) as null|anything in valid_facial_hairstyles

	if(new_style)
		head_organ.f_style = new_style

	var/new_facial = input("Please select facial hair color.", "Character Generation", rgb(head_organ.r_facial, head_organ.g_facial, head_organ.b_facial)) as null|color
	if(new_facial)
		head_organ.r_facial = hex2num(copytext(new_facial, 2, 4))
		head_organ.g_facial = hex2num(copytext(new_facial, 4, 6))
		head_organ.b_facial = hex2num(copytext(new_facial, 6, 8))

	//Head accessory.
	if(head_organ.species.bodyflags & HAS_HEAD_ACCESSORY)
		var/list/valid_head_accessories = M.generate_valid_head_accessories()
		var/new_head_accessory = input("Please select head accessory style", "Character Generation", head_organ.ha_style) as null|anything in valid_head_accessories
		if(new_head_accessory)
			head_organ.ha_style = new_head_accessory

		var/new_head_accessory_colour = input("Please select head accessory colour.", "Character Generation", rgb(head_organ.r_headacc, head_organ.g_headacc, head_organ.b_headacc)) as null|color
		if(new_head_accessory_colour)
			head_organ.r_headacc = hex2num(copytext(new_head_accessory_colour, 2, 4))
			head_organ.g_headacc = hex2num(copytext(new_head_accessory_colour, 4, 6))
			head_organ.b_headacc = hex2num(copytext(new_head_accessory_colour, 6, 8))

	//Body markings.
	if(M.species.bodyflags & HAS_MARKINGS)
		var/list/valid_markings = M.generate_valid_markings()
		var/new_marking = input("Please select marking style", "Character Generation", M.m_style) as null|anything in valid_markings
		if(new_marking)
			M.m_style = new_marking

		var/new_marking_colour = input("Please select marking colour.", "Character Generation", rgb(M.r_markings, M.g_markings, M.b_markings)) as null|color
		if(new_marking_colour)
			M.r_markings = hex2num(copytext(new_marking_colour, 2, 4))
			M.g_markings = hex2num(copytext(new_marking_colour, 4, 6))
			M.b_markings = hex2num(copytext(new_marking_colour, 6, 8))

	//Body accessory.
	if(M.species.tail && M.species.bodyflags & HAS_TAIL)
		var/list/valid_body_accessories = M.generate_valid_body_accessories()
		if(valid_body_accessories.len > 1) //By default valid_body_accessories will always have at the very least a 'none' entry populating the list, even if the user's species is not present in any of the list items.
			var/new_body_accessory = input("Please select body accessory style", "Character Generation", M.body_accessory) as null|anything in valid_body_accessories
			if(new_body_accessory)
				M.body_accessory = body_accessory_by_name[new_body_accessory]

	//Skin tone.
	if(M.species.bodyflags & HAS_SKIN_TONE)
		var/new_tone = input("Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation", M.s_tone) as null|text
		if(!new_tone)
			new_tone = 35
		M.s_tone = 35 - max(min(round(text2num(new_tone)), 220), 1)

	if(M.species.bodyflags & HAS_ICON_SKIN_TONE)
		var/prompt = "Please select skin tone: 1-[M.species.icon_skin_tones.len] ("
		for(var/i = 1; i <= M.species.icon_skin_tones.len; i++)
			prompt += "[i] = [M.species.icon_skin_tones[i]]"
			if(i != M.species.icon_skin_tones.len)
				prompt += ", "
		prompt += ")"

		var/new_tone = input(prompt, "Character Generation", M.s_tone) as null|text
		if(!new_tone)
			new_tone = 0
		M.s_tone = max(min(round(text2num(new_tone)), M.species.icon_skin_tones.len), 1)

	//Skin colour.
	if(M.species.bodyflags & HAS_SKIN_COLOR)
		var/new_body_colour = input("Please select body colour.", "Character Generation", rgb(M.r_skin, M.g_skin, M.b_skin)) as null|color
		if(new_body_colour)
			M.r_skin = hex2num(copytext(new_body_colour, 2, 4))
			M.g_skin = hex2num(copytext(new_body_colour, 4, 6))
			M.b_skin = hex2num(copytext(new_body_colour, 6, 8))

	M.force_update_limbs()
	M.regenerate_icons()
	M.update_dna()

	M.visible_message("<span class='notice'>[src] morphs and changes [M.get_visible_gender() == MALE ? "his" : M.get_visible_gender() == FEMALE ? "her" : "their"] appearance!</span>", "<span class='notice'>You change your appearance!</span>", "<span class='warning'>Oh, god!  What the hell was that?  It sounded like flesh getting squished and bone ground into a different shape!</span>")

/datum/dna/gene/basic/grant_spell/remotetalk
	name="Telepathy"
	activation_messages=list("You feel you can project your thoughts.")
	deactivation_messages=list("You no longer feel you can project your thoughts.")
	instability = GENE_INSTABILITY_MINOR
	mutation=REMOTE_TALK

	spelltype =/obj/effect/proc_holder/spell/targeted/remotetalk

/datum/dna/gene/basic/grant_spell/remotetalk/New()
	..()
	block=REMOTETALKBLOCK

/obj/effect/proc_holder/spell/targeted/remotetalk
	name = "Project Mind"
	desc = "Make people understand your thoughts at any range!"
	charge_max = 0

	clothes_req = 0
	stat_allowed = 0
	invocation_type = "none"
	range = -2
	selection_type = "range"

	action_icon_state = "genetic_project"

/obj/effect/proc_holder/spell/targeted/remotetalk/choose_targets(mob/user = usr)
	var/list/targets = new /list()
	var/list/validtargets = new /list()
	for(var/mob/M in view(user.client.view, user))
		if(M && M.mind)
			if(M == user)
				continue

			validtargets += M

	if(!validtargets.len)
		to_chat(usr, "<span class='warning'>There are no valid targets!</span>")
		start_recharge()
		return

	targets += input("Choose the target to talk to.", "Targeting") as null|mob in validtargets

	if(!targets.len || !targets[1]) //doesn't waste the spell
		revert_cast(user)
		return

	perform(targets)

/obj/effect/proc_holder/spell/targeted/remotetalk/cast(list/targets)
	if(!ishuman(usr))	return
	var/say = input("What do you wish to say") as text|null
	if(!say)
		return
	say = strip_html(say)

	for(var/mob/living/target in targets)
		log_say("Project Mind: [key_name(usr)]->[key_name(target)]: [say]")
		if(REMOTE_TALK in target.mutations)
			target.show_message("<span class='notice'>You hear [usr.real_name]'s voice: [say]</span>")
		else
			target.show_message("<span class='notice'>You hear a voice that seems to echo around the room: [say]</span>")
		usr.show_message("<span class='notice'>You project your mind into [target.real_name]: [say]</span>")
		for(var/mob/dead/observer/G in player_list)
			G.show_message("<i>Telepathic message from <b>[usr]</b> ([ghost_follow_link(usr, ghost=G)]) to <b>[target]</b> ([ghost_follow_link(target, ghost=G)]): [say]</i>")

/datum/dna/gene/basic/grant_spell/remoteview
	name="Remote Viewing"
	activation_messages=list("Your mind can see things from afar.")
	deactivation_messages=list("Your mind can no longer can see things from afar.")
	instability = GENE_INSTABILITY_MINOR
	mutation=REMOTE_VIEW

	spelltype =/obj/effect/proc_holder/spell/targeted/remoteview

/datum/dna/gene/basic/grant_spell/remoteview/New()
	block=REMOTEVIEWBLOCK


/obj/effect/proc_holder/spell/targeted/remoteview
	name = "Remote View"
	desc = "Spy on people from any range!"
	charge_max = 600

	clothes_req = 0
	stat_allowed = 0
	invocation_type = "none"
	range = -2
	selection_type = "range"

	action_icon_state = "genetic_view"

/obj/effect/proc_holder/spell/targeted/remoteview/choose_targets(mob/user = usr)
	var/list/targets = list()
	var/list/remoteviewers = new /list()
	for(var/mob/M in living_mob_list)
		if(PSY_RESIST in M.mutations)
			continue
		if(REMOTE_VIEW in M.mutations)
			remoteviewers += M
	if(!remoteviewers.len || remoteviewers.len == 1)
		to_chat(usr, "<span class='warning'>No valid targets with remote view were found!</span>")
		start_recharge()
		return
	targets += input("Choose the target to spy on.", "Targeting") as mob in remoteviewers

	perform(targets)

/obj/effect/proc_holder/spell/targeted/remoteview/cast(list/targets)
	var/mob/living/carbon/human/user
	if(ishuman(usr))
		user = usr
	else
		return

	var/mob/target

	if(istype(user.l_hand, /obj/item/tk_grab) || istype(user.r_hand, /obj/item/tk_grab/))
		to_chat(user, "<span class='warning'>Your mind is too busy with that telekinetic grab.</span>")
		user.remoteview_target = null
		user.reset_view(0)
		return

	if(user.client.eye != user.client.mob)
		user.remoteview_target = null
		user.reset_view(0)
		return

	for(var/mob/living/L in targets)
		target = L

	if(target)
		user.remoteview_target = target
		user.reset_view(target)
	else
		user.remoteview_target = null
		user.reset_view(0)
