/obj/item/storage/toolbox/green
	name = "artistic toolbox"
	desc = "A metal container designed to hold various tools. This variety holds art supplies."
	icon_state = "green"
	item_state = "toolbox_green"
	icon = 'icons/goonstation/objects/objects.dmi'
	lefthand_file = 'icons/goonstation/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/goonstation/mob/inhands/items_righthand.dmi'

/obj/item/storage/toolbox/green/memetic
	name = "artistic toolbox"
	desc = "His Grace."
	force = 5
	throwforce = 10
	origin_tech = "combat=4;engineering=4;syndicate=2"
	actions_types = list(/datum/action/item_action/toggle)
	var/list/servantlinks = list()
	var/hunger = 0
	var/hunger_message_level = 0
	var/mob/living/carbon/human/original_owner = null
	var/activated = FALSE

/obj/item/storage/toolbox/green/memetic/ui_action_click(mob/user)
	if(user.HasDisease(new /datum/disease/memetic_madness(0)))
		var/obj/item/storage/toolbox/green/memetic/M = user.get_active_hand()
		if(istype(M))
			to_chat(user, "<span class='warning'>His Grace [flags & NODROP ? "releases from" : "binds to"] your hand!</span>")
			flags ^= NODROP
	else
		to_chat(user, "<span class='warning'>You can't seem to understand what this does.</span>")


/obj/item/storage/toolbox/green/memetic/attack_hand(mob/living/carbon/user)
	if(loc == user)
		if(!activated)
			if(ishuman(user) && !user.HasDisease(new /datum/disease/memetic_madness(0)))
				activated = TRUE
				user.ForceContractDisease(new /datum/disease/memetic_madness(0))
				for(var/datum/disease/memetic_madness/DD in user.viruses)
					DD.progenitor = src
					servantlinks.Add(DD)
					break
				force += 4
				throwforce += 4
				SEND_SOUND(user, 'sound/goonstation/effects/screech.ogg')
				shake_camera(user, 20, 1)
				var/acount = 0
				var/amax = rand(10, 15)
				var/up_and_down
				var/asize = 1
				while(acount <= amax)
					up_and_down += "<font size=[asize]>a</font>"
					if(acount > (amax * 0.5))
						asize--
					else
						asize++
					acount++
				to_chat(user, "<span class='warning'>[up_and_down]</span>")
				to_chat(user, "<i><b><font face = Tempus Sans ITC>His Grace accepts thee, spread His will! All who look close to the Enlightened may share His gifts.</font></b></i>")
				original_owner = user
				return
	..()

/obj/item/storage/toolbox/green/memetic/attackby(obj/item/I, mob/user)
	if(activated)
		if(istype(I, /obj/item/grab))
			var/obj/item/grab/G = I
			var/mob/living/victim = G.affecting
			if(!user.HasDisease(new /datum/disease/memetic_madness(0)))
				to_chat(user, "<span class='warning'>You can't seem to find the latch to open this.</span>")
				return
			if(!victim)
				return
			if(!victim.stat && !victim.restrained() && !victim.IsWeakened())
				to_chat(user, "<span class='warning'>They're moving too much to feed to His Grace!</span>")
				return
			user.visible_message("<span class='userdanger'>[user] is trying to feed [victim] to [src]!</span>")
			if(!do_mob(user, victim, 30))
				return

			user.visible_message("<span class='userdanger'>[user] has fed [victim] to [src]!</span>")

			consume(victim)
			qdel(G)

			to_chat(user, "<i><b><font face = Tempus Sans ITC>You have done well...</font></b></i>")
			force += 5
			throwforce += 5
			return

	return ..()

/obj/item/storage/toolbox/green/memetic/proc/consume(mob/living/L)
	if(!L)
		return
	hunger = 0
	hunger_message_level = 0
	playsound(loc, 'sound/goonstation/misc/burp_alien.ogg', 50, 0)

	if(L != original_owner)
		var/list/equipped_items = L.get_equipped_items(TRUE)
		if(L.l_hand)
			equipped_items += L.l_hand
		if(L.r_hand)
			equipped_items += L.r_hand
		if(equipped_items.len)
			var/obj/item/storage/box/B = new(src)
			B.name = "Box-'[L.real_name]'"
			for(var/obj/item/SI in equipped_items)
				L.unEquip(SI, TRUE)
				SI.forceMove(B)
			equipped_items.Cut()

	L.forceMove(src)

	L.emote("scream")
	L.death()
	L.ghostize()
	if(L == original_owner)
		L.unEquip(src, TRUE)
		qdel(L)
		var/obj/item/storage/toolbox/green/fake_toolbox = new(get_turf(src))
		fake_toolbox.desc = "It looks a lot duller than it used to."
		qdel(src)
	else
		qdel(L)

/obj/item/storage/toolbox/green/memetic/Destroy()
	for(var/datum/disease/memetic_madness/D in servantlinks)
		D.cure()

	servantlinks.Cut()
	servantlinks = null
	original_owner = null
	visible_message("<span class='userdanger'>[src] screams!</span>")
	playsound(loc, 'sound/goonstation/effects/screech.ogg', 100, 1)
	return ..()

/datum/disease/memetic_madness
	name = "Memetic Kill Agent"
	max_stages = 4
	stage_prob = 8
	spread_text = "Non-Contagious"
	spread_flags = SPECIAL
	cure_text = "Unknown"
	viable_mobtypes = list(/mob/living/carbon/human)
	severity = BIOHAZARD
	disease_flags = CAN_CARRY
	spread_flags = NON_CONTAGIOUS
	virus_heal_resistant = TRUE
	var/obj/item/storage/toolbox/green/memetic/progenitor = null

/datum/disease/memetic_madness/Destroy()
	if(progenitor)
		progenitor.servantlinks.Remove(src)
	progenitor = null
	if(affected_mob)
		affected_mob.status_flags |= CANSTUN | CANWEAKEN | CANPARALYSE
	return ..()

/datum/disease/memetic_madness/stage_act()
	..()
	if(!progenitor) //if someone admin spawns this, cure it right away; this should only ever be given directly from the toolbox itself.
		cure()
		return
	if(progenitor in affected_mob.contents)
		affected_mob.adjustOxyLoss(-5)
		affected_mob.adjustBruteLoss(-12)
		affected_mob.adjustFireLoss(-12)
		affected_mob.adjustToxLoss(-5)
		affected_mob.setStaminaLoss(0)
		var/status = CANSTUN | CANWEAKEN | CANPARALYSE
		affected_mob.status_flags &= ~status
		affected_mob.AdjustDizzy(-10)
		affected_mob.AdjustDrowsy(-10)
		affected_mob.SetSleeping(0)
		affected_mob.SetSlowed(0)
		affected_mob.SetConfused(0)
		stage = 1
		switch(progenitor.hunger)
			if(10 to 60)
				if(progenitor.hunger_message_level < 1)
					progenitor.hunger_message_level = 1
					to_chat(affected_mob, "<i><b><font face = Tempus Sans ITC>Feed Me the unclean ones...They will be purified...</font></b></i>")
			if(61 to 120)
				if(progenitor.hunger_message_level < 2)
					progenitor.hunger_message_level = 2
					to_chat(affected_mob, "<i><b><font face = Tempus Sans ITC>I hunger for the flesh of the impure...</font></b></i>")
			if(121 to 210)
				if(prob(10) && progenitor.hunger_message_level < 3)
					progenitor.hunger_message_level = 3
					to_chat(affected_mob, "<i><b><font face = Tempus Sans ITC>The hunger of your Master grows with every passing moment.  Feed Me at once.</font></b></i>")
			if(211 to 399)
				if(progenitor.hunger_message_level < 4)
					progenitor.hunger_message_level = 4
					to_chat(affected_mob, "<i><b><font face = Tempus Sans ITC>His Grace starves in your hands.  Feed Me the unclean or suffer.</font></b></i>")
			if(400 to INFINITY)
				affected_mob.visible_message("<span class='userdanger'>[progenitor] consumes [affected_mob] whole!</span>")
				progenitor.consume(affected_mob)
				return

		progenitor.hunger += min(max((progenitor.force / 10), 1), 10)

	else
		affected_mob.status_flags |= CANSTUN | CANWEAKEN | CANPARALYSE

	if(stage == 4)
		if(get_dist(get_turf(progenitor), get_turf(affected_mob)) <= 7)
			stage = 1
			return
		if(prob(4))
			to_chat(affected_mob, "<span class='danger'>You are too far from His Grace...</span>")
			affected_mob.adjustToxLoss(5)
		else if(prob(6))
			to_chat(affected_mob, "<span class='danger'>You feel weak.</span>")
			affected_mob.adjustBruteLoss(5)

		if(ismob(progenitor.loc))
			progenitor.hunger++