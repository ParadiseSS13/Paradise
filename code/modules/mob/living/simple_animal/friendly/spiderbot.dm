/mob/living/simple_animal/spiderbot
	name = "Spider-bot"
	desc = "A skittering robotic friend!" //More like ultimate shitter
	icon = 'icons/mob/robots.dmi'
	icon_state = "spiderbot-chassis"
	icon_living = "spiderbot-chassis"
	icon_dead = "spiderbot-smashed"
	wander = 0
	universal_speak = 1
	health = 40
	maxHealth = 40
	pass_flags = PASSTABLE

	melee_damage_lower = 2
	melee_damage_upper = 2
	melee_damage_type = BURN
	attacktext = "shocks"
	attack_sound = "sparks"

	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	speed = 0
	mob_size = MOB_SIZE_SMALL
	speak_emote = list("beeps","clicks","chirps")

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 500

	can_hide = 1
	ventcrawler = 2
	loot = list(/obj/effect/decal/cleanable/blood/gibs/robot)
	del_on_death = 1

	var/emagged = 0               //is it getting ready to explode?
	var/obj/item/mmi/mmi = null
	var/mob/emagged_master = null //for administrative purposes, to see who emagged the spiderbot; also for a holder for if someone emags an empty frame first then inserts an MMI.

/mob/living/simple_animal/spiderbot/Destroy()
	if(emagged)
		QDEL_NULL(mmi)
		explosion(get_turf(src), -1, -1, 3, 5)
	else
		eject_brain()
	return ..()

/mob/living/simple_animal/spiderbot/attackby(obj/item/O, mob/living/user, params)
	if(istype(O, /obj/item/mmi))
		var/obj/item/mmi/B = O
		if(mmi) //There's already a brain in it.
			to_chat(user, "<span class='warning'>There's already a brain in [src]!</span>")
			return
		if(!B.brainmob)
			to_chat(user, "<span class='warning'>Sticking an empty MMI into the frame would sort of defeat the purpose.</span>")
			return
		if(!B.brainmob.key)
			var/ghost_can_reenter = 0
			if(B.brainmob.mind)
				for(var/mob/dead/observer/G in GLOB.player_list)
					if(G.can_reenter_corpse && G.mind == B.brainmob.mind)
						ghost_can_reenter = 1
						break
				for(var/mob/living/simple_animal/S in GLOB.player_list)
					if(S in GLOB.respawnable_list)
						ghost_can_reenter = 1
						break
			if(!ghost_can_reenter)
				to_chat(user, "<span class='notice'>[B] is completely unresponsive; there's no point.</span>")
				return

		if(B.brainmob.stat == DEAD)
			to_chat(user, "<span class='warning'>[B] is dead. Sticking it into the frame would sort of defeat the purpose.</span>")
			return

		if(jobban_isbanned(B.brainmob, "Cyborg") || jobban_isbanned(B.brainmob, "nonhumandept"))
			to_chat(user, "<span class='warning'>[B] does not seem to fit.</span>")
			return

		to_chat(user, "<span class='notice'>You install [B] in [src]!</span>")

		user.drop_item()
		B.forceMove(src)
		mmi = B
		transfer_personality(B)

		update_icon()
		return 1

	else if(istype(O, /obj/item/card/id) || istype(O, /obj/item/pda))
		if(!mmi)
			to_chat(user, "<span class='warning'>There's no reason to swipe your ID - the spiderbot has no brain to remove.</span>")
			return 0

		if(emagged)
			to_chat(user, "<span class='warning'>[src] doesn't seem to respond.</span>")
			return 0

		var/obj/item/card/id/id_card

		if(istype(O, /obj/item/card/id))
			id_card = O
		else
			var/obj/item/pda/pda = O
			id_card = pda.id

		if(ACCESS_ROBOTICS in id_card.access)
			to_chat(user, "<span class='notice'>You swipe your access card and pop the brain out of [src].</span>")
			eject_brain()
			return 1
		else
			to_chat(user, "<span class='warning'>You swipe your card, with no effect.</span>")
			return 0

	else
		..()

/mob/living/simple_animal/spiderbot/welder_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	if(user == src) //No self-repair dummy
		return
	if(health >= maxHealth)
		to_chat(user, "<span class='warning'>[src] does not need repairing!</span>")
		return
		to_chat(user, "<span class='warning'>Unable to repair with the maintenance panel closed!</span>")
		return
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	adjustHealth(-5)
	add_fingerprint(user)
	user.visible_message("[user] repairs [src]!","<span class='notice'>You repair [src].</span>")

/mob/living/simple_animal/spiderbot/emag_act(mob/living/user)
	if(emagged)
		to_chat(user, "<span class='warning'>[src] doesn't seem to respond.</span>")
		return 0
	else
		emagged = 1
		to_chat(user, "<span class='notice'>You short out the security protocols and rewrite [src]'s internal memory.</span>")
		to_chat(src, "<span class='userdanger'>You have been emagged; you are now completely loyal to [user] and [user.p_their()] every order!</span>")
		emagged_master = user
		add_attack_logs(user, src, "Emagged")
		maxHealth = 60
		health = 60
		melee_damage_lower = 15
		melee_damage_upper = 15
		attack_sound = 'sound/machines/defib_zap.ogg'

/mob/living/simple_animal/spiderbot/proc/transfer_personality(obj/item/mmi/M)
	mind = M.brainmob.mind
	mind.key = M.brainmob.key
	ckey = M.brainmob.ckey
	name = "Spider-bot ([M.brainmob.name])"
	if(emagged)
		to_chat(src, "<span class='userdanger'>You have been emagged; you are now completely loyal to [emagged_master] and [emagged_master.p_their()] every order!</span>")

/mob/living/simple_animal/spiderbot/proc/update_icon()
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

/mob/living/simple_animal/spiderbot/proc/eject_brain()
	if(mmi)
		var/turf/T = get_turf(src)
		mmi.forceMove(T)
		if(mind)
			mind.transfer_to(mmi.brainmob)
		mmi = null
		name = "Spider-bot"
		update_icon()
