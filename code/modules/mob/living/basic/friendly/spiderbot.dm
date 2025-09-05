// No AI controller for these guys - they should be inert if they're not player controlled.
/mob/living/basic/spiderbot
	name = "Spider-bot"
	desc = "A skittering robotic friend!" // More like ultimate shitter
	icon = 'icons/mob/robots.dmi'
	icon_state = "spiderbot-chassis"
	icon_living = "spiderbot-chassis"
	icon_dead = "spiderbot-smashed"
	universal_speak = TRUE
	health = 40
	maxHealth = 40
	pass_flags = PASSTABLE

	melee_damage_lower = 2
	melee_damage_upper = 2
	melee_damage_type = BURN
	attack_verb_continuous = "shocks"
	attack_verb_simple = "shocks"
	attack_sound = "sparks"

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "stomps on"
	response_harm_simple = "stomps on"
	speed = 0
	mob_biotypes = MOB_ROBOTIC
	mob_size = MOB_SIZE_SMALL
	speak_emote = list("beeps", "clicks", "chirps")

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 500

	can_hide = TRUE
	ventcrawler = VENTCRAWLER_ALWAYS
	loot = list(/obj/effect/decal/cleanable/blood/gibs/robot)
	basic_mob_flags = DEL_ON_DEATH

	/// Is it getting ready to explode?
	var/emagged = FALSE
	/// MMI it contains
	var/obj/item/mmi/mmi = null
	/// Who emagged the spiderbot
	var/mob/emagged_master = null

/mob/living/basic/spiderbot/Destroy()
	if(emagged)
		QDEL_NULL(mmi)
		explosion(get_turf(src), -1, -1, 3, 5, cause = "Emagged spiderbot destruction")
	else
		eject_brain()
	return ..()

/mob/living/basic/spiderbot/item_interaction(mob/living/user, obj/item/O, list/modifiers)
	if(istype(O, /obj/item/mmi))
		var/obj/item/mmi/B = O
		if(mmi) // There's already a brain in it.
			to_chat(user, "<span class='warning'>There's already a brain in [src]!</span>")
			return ITEM_INTERACT_COMPLETE
		if(!B.brainmob)
			to_chat(user, "<span class='warning'>Sticking an empty MMI into the frame would sort of defeat the purpose.</span>")
			return ITEM_INTERACT_COMPLETE
		if(!B.brainmob.key)
			var/ghost_can_reenter = 0
			if(B.brainmob.mind)
				for(var/mob/dead/observer/ghost in GLOB.player_list)
					if(ghost.ghost_flags & GHOST_CAN_REENTER && ghost.mind == B.brainmob.mind)
						ghost_can_reenter = 1
						break
				for(var/mob/living/basic/S in GLOB.player_list)
					if(HAS_TRAIT(S, TRAIT_RESPAWNABLE))
						ghost_can_reenter = 1
						break
			if(!ghost_can_reenter)
				to_chat(user, "<span class='notice'>[B] is completely unresponsive; there's no point.</span>")
				return ITEM_INTERACT_COMPLETE

		if(B.brainmob.stat == DEAD)
			to_chat(user, "<span class='warning'>[B] is dead. Sticking it into the frame would sort of defeat the purpose.</span>")
			return ITEM_INTERACT_COMPLETE

		if(jobban_isbanned(B.brainmob, "Cyborg") || jobban_isbanned(B.brainmob, "nonhumandept"))
			to_chat(user, "<span class='warning'>[B] does not seem to fit.</span>")
			return ITEM_INTERACT_COMPLETE

		to_chat(user, "<span class='notice'>You install [B] in [src]!</span>")

		user.drop_item()
		B.forceMove(src)
		mmi = B
		transfer_personality(B)

		update_icon()
		return ITEM_INTERACT_COMPLETE

	else if(istype(O, /obj/item/card/id) || istype(O, /obj/item/pda))
		if(!mmi)
			to_chat(user, "<span class='warning'>There's no reason to swipe your ID - the spiderbot has no brain to remove.</span>")
			return ITEM_INTERACT_COMPLETE

		if(emagged)
			to_chat(user, "<span class='warning'>[src] doesn't seem to respond.</span>")
			return ITEM_INTERACT_COMPLETE

		var/obj/item/card/id/id_card

		if(istype(O, /obj/item/card/id))
			id_card = O
		else
			var/obj/item/pda/pda = O
			id_card = pda.id

		if(ACCESS_ROBOTICS in id_card.access)
			to_chat(user, "<span class='notice'>You swipe your access card and pop the brain out of [src].</span>")
			eject_brain()
			return ITEM_INTERACT_COMPLETE
		else
			to_chat(user, "<span class='warning'>You swipe your card, with no effect.</span>")
			return ITEM_INTERACT_COMPLETE

/mob/living/basic/spiderbot/welder_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	if(user == src) // No self-repair dummy
		return
	if(health >= maxHealth)
		to_chat(user, "<span class='warning'>[src] does not need repairing!</span>")
		return
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	adjustHealth(-5)
	add_fingerprint(user)
	user.visible_message("[user] repairs [src]!","<span class='notice'>You repair [src].</span>")

/mob/living/basic/spiderbot/emag_act(mob/living/user)
	if(emagged)
		to_chat(user, "<span class='warning'>[src] doesn't seem to respond.</span>")
		return 0
	else
		emagged = TRUE
		to_chat(user, "<span class='notice'>You short out the security protocols and rewrite [src]'s internal memory.</span>")
		to_chat(src, "<span class='userdanger'>You have been emagged; you are now completely loyal to [user] and [user.p_their()] every order!</span>")
		emagged_master = user
		add_attack_logs(user, src, "Emagged")
		maxHealth = 60
		health = 60
		melee_damage_lower = 15
		melee_damage_upper = 15
		attack_sound = 'sound/machines/defib_zap.ogg'
		return TRUE

/mob/living/basic/spiderbot/proc/transfer_personality(obj/item/mmi/M)
	mind = M.brainmob.mind
	mind.key = M.brainmob.key
	ckey = M.brainmob.ckey
	name = "Spider-bot ([M.brainmob.name])"
	if(emagged)
		to_chat(src, "<span class='userdanger'>You have been emagged; you are now completely loyal to [emagged_master] and [emagged_master.p_their()] every order!</span>")

/mob/living/basic/spiderbot/update_icon_state()
	if(mmi)
		if(istype(mmi, /obj/item/mmi))
			icon_state = "spiderbot-chassis-mmi"
			icon_living = "spiderbot-chassis-mmi"
		if(istype(mmi, /obj/item/mmi/robotic_brain))
			icon_state = "spiderbot-chassis-posi"
			icon_living = "spiderbot-chassis-posi"

	else
		icon_state = "spiderbot-chassis"
		icon_living = "spiderbot-chassis"

/mob/living/basic/spiderbot/proc/eject_brain()
	if(mmi)
		var/turf/T = get_turf(src)
		mmi.forceMove(T)
		if(mind)
			mind.transfer_to(mmi.brainmob)
		mmi = null
		name = "Spider-bot"
		update_icon()
