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
	var/obj/item/device/mmi/mmi = null
	var/emagged_master = null //for administrative purposes, to see who emagged the spiderbot; also for a holder for if someone emags an empty frame first then inserts an MMI.

/mob/living/simple_animal/spiderbot/Destroy()
	if(emagged)
		QDEL_NULL(mmi)
		explosion(get_turf(src), -1, -1, 3, 5)
	else
		eject_brain()
	return ..()

/mob/living/simple_animal/spiderbot/attackby(obj/item/O, mob/living/user, params)
	if(istype(O, /obj/item/device/mmi))
		var/obj/item/device/mmi/B = O
		if(mmi) //There's already a brain in it.
			to_chat(user, "<span class='warning'>There's already a brain in [src]!</span>")
			return
		if(!B.brainmob)
			to_chat(user, "<span class='warning'>Sticking an empty MMI into the frame would sort of defeat the purpose.</span>")
			return
		if(!B.brainmob.key)
			var/ghost_can_reenter = 0
			if(B.brainmob.mind)
				for(var/mob/dead/observer/G in player_list)
					if(G.can_reenter_corpse && G.mind == B.brainmob.mind)
						ghost_can_reenter = 1
						break
				for(var/mob/living/simple_animal/S in player_list)
					if(S in respawnable_list)
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

	else if(iswelder(O) && user.a_intent == INTENT_HELP)
		var/obj/item/weapon/weldingtool/WT = O
		user.changeNext_move(CLICK_CD_MELEE)
		if(WT.remove_fuel(0))
			if(health < maxHealth)
				adjustHealth(-5)
				playsound(loc, WT.usesound, 50, 1)
				add_fingerprint(user)
				visible_message("<span class='warning'>[user] has spot-welded some of the damage to [src]!</span>")
			else
				to_chat(user, "<span class='notice'>[src] is undamaged!</span>")
		else
			to_chat(user, "Need more welding fuel!")
	else if(istype(O, /obj/item/weapon/card/id) || istype(O, /obj/item/device/pda))
		if(!mmi)
			to_chat(user, "<span class='warning'>There's no reason to swipe your ID - the spiderbot has no brain to remove.</span>")
			return 0

		if(emagged)
			to_chat(user, "<span class='warning'>[src] doesn't seem to respond.</span>")
			return 0

		var/obj/item/weapon/card/id/id_card

		if(istype(O, /obj/item/weapon/card/id))
			id_card = O
		else
			var/obj/item/device/pda/pda = O
			id_card = pda.id

		if(access_robotics in id_card.access)
			to_chat(user, "<span class='notice'>You swipe your access card and pop the brain out of [src].</span>")
			eject_brain()
			return 1
		else
			to_chat(user, "<span class='warning'>You swipe your card, with no effect.</span>")
			return 0

	else
		..()

/mob/living/simple_animal/spiderbot/emag_act(mob/living/user)
	if(emagged)
		to_chat(user, "<span class='warning'>[src] doesn't seem to respond.</span>")
		return 0
	else
		emagged = 1
		to_chat(user, "<span class='notice'>You short out the security protocols and rewrite [src]'s internal memory.</span>")
		to_chat(src, "<span class='userdanger'>You have been emagged; you are now completely loyal to [user] and their every order!</span>")
		emagged_master = user.name
		add_logs(user, src, "emagged")
		maxHealth = 60
		health = 60
		melee_damage_lower = 15
		melee_damage_upper = 15
		attack_sound = 'sound/machines/defib_zap.ogg'

/mob/living/simple_animal/spiderbot/proc/transfer_personality(obj/item/device/mmi/M)
	mind = M.brainmob.mind
	mind.key = M.brainmob.key
	ckey = M.brainmob.ckey
	name = "Spider-bot ([M.brainmob.name])"
	if(emagged)
		to_chat(src, "<span class='userdanger'>You have been emagged; you are now completely loyal to [emagged_master] and their every order!</span>")

/mob/living/simple_animal/spiderbot/proc/update_icon()
	if(mmi)
		if(istype(mmi, /obj/item/device/mmi))
			icon_state = "spiderbot-chassis-mmi"
			icon_living = "spiderbot-chassis-mmi"
		if(istype(mmi, /obj/item/device/mmi/posibrain))
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
