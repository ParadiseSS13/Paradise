///////////////////Vanilla Morph////////////////////////////////////

/datum/dna/gene/basic/grant_spell/morph
	name = "Morphism"
	desc = "Enables the subject to reconfigure their appearance to that of any human."

	spelltype =/obj/effect/proc_holder/spell/targeted/morph
	activation_messages=list("Your body feels if can alter its appearance.")
	deactivation_messages = list("Your body doesn't feel capable of altering its appearance.")


	mutation=MORPH

	New()
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

	if (istype(usr.loc,/mob/))
		to_chat(usr, "\red You can't change your appearance right now!")
		return
	var/mob/living/carbon/human/M=usr

	var/new_facial = input("Please select facial hair color.", "Character Generation",rgb(M.r_facial,M.g_facial,M.b_facial)) as null|color
	if(new_facial)
		M.r_facial = hex2num(copytext(new_facial, 2, 4))
		M.g_facial = hex2num(copytext(new_facial, 4, 6))
		M.b_facial = hex2num(copytext(new_facial, 6, 8))

	var/new_hair = input("Please select hair color.", "Character Generation",rgb(M.r_hair,M.g_hair,M.b_hair)) as null|color
	if(new_facial)
		M.r_hair = hex2num(copytext(new_hair, 2, 4))
		M.g_hair = hex2num(copytext(new_hair, 4, 6))
		M.b_hair = hex2num(copytext(new_hair, 6, 8))

	var/new_eyes = input("Please select eye color.", "Character Generation",rgb(M.r_eyes,M.g_eyes,M.b_eyes)) as null|color
	if(new_eyes)
		M.r_eyes = hex2num(copytext(new_eyes, 2, 4))
		M.g_eyes = hex2num(copytext(new_eyes, 4, 6))
		M.b_eyes = hex2num(copytext(new_eyes, 6, 8))

	var/new_tone = input("Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation", "[35-M.s_tone]") as null|text

	if (!new_tone)
		new_tone = 35
	M.s_tone = max(min(round(text2num(new_tone)), 220), 1)
	M.s_tone =  -M.s_tone + 35

	// hair
	var/list/all_hairs = subtypesof(/datum/sprite_accessory/hair)
	var/list/hairs = list()

	// loop through potential hairs
	for(var/x in all_hairs)
		var/datum/sprite_accessory/hair/H = new x // create new hair datum based on type x
		hairs.Add(H.name) // add hair name to hairs
		qdel(H) // delete the hair after it's all done

	var/new_style = input("Please select hair style", "Character Generation",M.h_style)  as null|anything in hairs

	// if new style selected (not cancel)
	if (new_style)
		M.h_style = new_style

	// facial hair
	var/list/all_fhairs = subtypesof(/datum/sprite_accessory/facial_hair)
	var/list/fhairs = list()

	for(var/x in all_fhairs)
		var/datum/sprite_accessory/facial_hair/H = new x
		fhairs.Add(H.name)
		qdel(H)

	new_style = input("Please select facial style", "Character Generation",M.f_style)  as null|anything in fhairs

	if(new_style)
		M.f_style = new_style

	var/new_gender = alert(usr, "Please select gender.", "Character Generation", "Male", "Female")
	if (new_gender)
		if(new_gender == "Male")
			M.change_gender(MALE)
		else
			M.change_gender(FEMALE)
	M.regenerate_icons()
	M.check_dna()

	M.visible_message("\blue \The [src] morphs and changes [M.get_visible_gender() == MALE ? "his" : M.get_visible_gender() == FEMALE ? "her" : "their"] appearance!", "\blue You change your appearance!", "\red Oh, god!  What the hell was that?  It sounded like flesh getting squished and bone ground into a different shape!")

/datum/dna/gene/basic/grant_spell/remotetalk
	name="Telepathy"
	activation_messages=list("You feel you can project your thoughts.")
	deactivation_messages=list("You no longer feel you can project your thoughts.")
	mutation=REMOTE_TALK

	spelltype =/obj/effect/proc_holder/spell/targeted/remotetalk

	New()
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
			target.show_message("\blue You hear [usr.real_name]'s voice: [say]")
		else
			target.show_message("\blue You hear a voice that seems to echo around the room: [say]")
		usr.show_message("\blue You project your mind into [target.real_name]: [say]")
		for(var/mob/dead/observer/G in player_list)
			G.show_message("<i>Telepathic message from <b>[usr]</b> ([ghost_follow_link(usr, ghost=G)]) to <b>[target]</b> ([ghost_follow_link(target, ghost=G)]): [say]</i>")

/datum/dna/gene/basic/grant_spell/remoteview
	name="Remote Viewing"
	activation_messages=list("Your mind can see things from afar.")
	deactivation_messages=list("Your mind can no longer can see things from afar.")
	mutation=REMOTE_VIEW

	spelltype =/obj/effect/proc_holder/spell/targeted/remoteview

	New()
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
	var/list/targets = living_mob_list
	var/list/remoteviewers = new /list()
	for(var/mob/M in targets)
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
		to_chat(user, "\red Your mind is too busy with that telekinetic grab.")
		user.remoteview_target = null
		user.reset_view(0)
		return

	if(user.client.eye != user.client.mob)
		user.remoteview_target = null
		user.reset_view(0)
		return

	for(var/mob/living/L in targets)
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(PSY_RESIST in H.mutations)
				continue
		target = L

	if (target)
		user.remoteview_target = target
		user.reset_view(target)
	else
		user.remoteview_target = null
		user.reset_view(0)


