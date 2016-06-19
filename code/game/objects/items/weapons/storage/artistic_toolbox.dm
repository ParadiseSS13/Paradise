/obj/item/weapon/storage/toolbox/green
	name = "artistic toolbox"
	desc = "A metal container designed to hold various tools. This variety holds art supplies."
	icon_state = "green"
	item_state = "toolbox_green"
	icon = 'icons/goonstation/objects/objects.dmi'
	lefthand_file = 'icons/goonstation/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/goonstation/mob/inhands/items_righthand.dmi'

/obj/item/weapon/storage/toolbox/green/memetic
	name = "artistic toolbox"
	desc = "His Grace."
	force = 5
	throwforce = 10
	var/list/servantlinks = list()
	var/hunger = 0
	var/hunger_message_level = 0
	var/original_owner = null
	var/activated = 0
	var/mindless_override = 0

/obj/item/weapon/storage/toolbox/green/memetic/attack_hand(mob/living/carbon/user)
	if(!activated)
		if(ishuman(user) && !user.HasDisease(new /datum/disease/memetic_madness(0)))
			activated = 1
			user.ForceContractDisease(new /datum/disease/memetic_madness(0))
			for(var/datum/disease/memetic_madness/DD in user.viruses)
				DD.progenitor = src
				servantlinks.Add(DD)
				break
			force += 4
			throwforce += 4
			user << 'sound/goonstation/effects/screech.ogg'
			shake_camera(user, 20, 1)
			to_chat(user, "<i><b><font face = Tempus Sans ITC>His Grace accepts thee, spread His will! All who look close to the Enlightened may share His gifts.</font></b></i>")
			original_owner = user
			return
	..()

/obj/item/weapon/storage/toolbox/green/memetic/attackby(obj/item/I, mob/user)
	if(activated)
		if(istype(I, /obj/item/weapon/grab/))
			var/obj/item/weapon/grab/G = I
			if(!G.affecting)
				return
			if(!user.HasDisease(new /datum/disease/memetic_madness(0)))
				to_chat(user, "<span class='warning'>You can't seem to find the latch to open this.</span>")
				return
			if(!ishuman(G.affecting) || issmall(G.affecting))
				to_chat(user, "<span class='warning'>His Grace will not accept such a meager offering!</span>")
				return
			if(!mindless_override)
				if(G.affecting.mind == null && G.affecting.ckey == null)
					to_chat(user, "<span class='warning'>His Grace will not accept a soulless shell for an offering!</span>")
					return
			if(!G.affecting.stat && !G.affecting.restrained() && !G.affecting.weakened)
				to_chat(user, "<span class='warning'>They're moving too much to feed to His Grace!</span>")
				return
			user.visible_message("<span class='userdanger'>[user] is trying to feed [G.affecting] to [src]!</span>")
			if(!do_mob(user, G.affecting, 30))
				return
			G.affecting.forceMove(src)
			user.visible_message("<span class='userdanger'>[user] has fed [G.affecting] to [src]!</span>")

			consume(G.affecting)
			qdel(G)

			to_chat(user, "<i><b><font face = Tempus Sans ITC>You have done well...</font></b></i>")
			force += 5
			throwforce += 5
			return

	..()

/obj/item/weapon/storage/toolbox/green/memetic/proc/consume(mob/M)
	if (!M)
		return
	hunger = 0
	hunger_message_level = 0
	playsound(src.loc, 'sound/goonstation/misc/burp_alien.ogg', 50, 0)
	M.emote("scream")
	M.death()
	M.ghostize()
	if(M == original_owner)
		qdel(M)
		var/obj/item/weapon/storage/toolbox/green/fake_toolbox = new(get_turf(src))
		fake_toolbox.desc = "It looks a lot duller than it used to."
		qdel(src)

/obj/item/weapon/storage/toolbox/green/memetic/Destroy()
	for(var/mob/living/carbon/human/H in src)
		H.forceMove(get_turf(src))
		visible_message("<span class='warning'>[H] bursts out of [src]!</span>")

	for(var/A in servantlinks)
		var/datum/disease/memetic_madness/D = A
		if(D)
			D.cure()
			break

	if(servantlinks)
		servantlinks.Cut()
	servantlinks = null
	original_owner = null
	visible_message("<span class='userdanger'>[src] screams!</span>")
	playsound(src.loc, 'sound/goonstation/effects/screech.ogg', 100, 1)
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
	disease_flags = CURABLE
	spread_flags = NON_CONTAGIOUS
	var/obj/item/weapon/storage/toolbox/green/memetic/progenitor = null

/datum/disease/memetic_madness/Destroy()
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
		affected_mob.dizziness = max(0, affected_mob.dizziness-10)
		affected_mob.drowsyness = max(0, affected_mob.drowsyness-10)
		affected_mob.SetSleeping(0)
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