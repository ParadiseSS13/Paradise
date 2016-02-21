//Revenants: based off of wraiths from Goon
//"Ghosts" that are invisible and move like ghosts, cannot take damage while invsible
//Don't hear deadchat and are NOT normal ghosts
//Admin-spawn or random event
#define INVISIBILITY_REVENANT 50

/mob/living/simple_animal/revenant
	name = "revenant"
	desc = "A malevolent spirit."
	icon = 'icons/mob/mob.dmi'
	icon_state = "revenant_idle"
	var/icon_idle = "revenant_idle"
	var/icon_reveal = "revenant_revealed"
	var/icon_stun = "revenant_stun"
	var/icon_drain = "revenant_draining"
	incorporeal_move = 3
	invisibility = INVISIBILITY_REVENANT
	health =  INFINITY //Revenants don't use health, they use essence instead
	maxHealth =  INFINITY
	see_invisible = INVISIBILITY_REVENANT
	universal_understand = 1
	response_help   = "passes through"
	response_disarm = "swings at"
	response_harm   = "punches"
	unsuitable_atmos_damage = 0
	minbodytemp = 0
	maxbodytemp = INFINITY
	harm_intent_damage = 0
	friendly = "touches"
	status_flags = 0
	see_in_dark = 8
	wander = 0
	density = 0
	flying = 1
	anchored = 1

	var/essence = 75 //The resource of revenants. Max health is equal to three times this amount
	var/essence_regen_cap = 75 //The regeneration cap of essence (go figure); regenerates every Life() tick up to this amount.
	var/essence_regenerating = 1 //If the revenant regenerates essence or not; 1 for yes, 0 for no
	var/essence_regen_amount = 5 //How much essence regenerates
	var/essence_accumulated = 0 //How much essence the revenant has stolen
	var/revealed = 0 //If the revenant can take damage from normal sources.
	var/unreveal_time = 0 //How long the revenant is revealed for, is about 2 seconds times this var.
	var/unstun_time = 0 //How long the revenant is stunned for, is about 2 seconds times this var.
	var/inhibited = 0 //If the revenant's abilities are blocked by a chaplain's power.
	var/essence_drained = 0 //How much essence the revenant has drained.
	var/draining = 0 //If the revenant is draining someone.
	var/list/drained_mobs = list() //Cannot harvest the same mob twice
	var/perfectsouls = 0 //How many perfect, regen-cap increasing souls the revenant has.
	var/image/ghostimage = null //Visible to ghost with darkness off

/mob/living/simple_animal/revenant/Life()
	..()
	if(revealed && essence <= 0)
		death()
	if(essence_regenerating && !inhibited && essence < essence_regen_cap) //While inhibited, essence will not regenerate
		essence = min(essence_regen_cap, essence+essence_regen_amount)
	if(unreveal_time && world.time >= unreveal_time)
		unreveal_time = 0
		revealed = 0
		incorporeal_move = 3
		invisibility = INVISIBILITY_REVENANT
		src << "<span class='revenboldnotice'>You are once more concealed.</span>"
	if(unstun_time && world.time >= unstun_time)
		unstun_time = 0
		notransform = 0
		src << "<span class='revenboldnotice'>You can move again!</span>"
	update_spooky_icon()

/mob/living/simple_animal/revenant/ex_act(severity)
	return 1 //Immune to the effects of explosions.

/mob/living/simple_animal/revenant/blob_act()
	return 1 //blah blah blobs aren't in tune with the spirit world, or something.

/mob/living/simple_animal/revenant/singularity_act()
	return //don't walk into the singularity expecting to find corpses, okay?

/mob/living/simple_animal/revenant/narsie_act()
	return //most humans will now be either bones or harvesters, but we're still un-alive.

/mob/living/simple_animal/revenant/adjustBruteLoss(amount)
	if(!revealed)
		return
	essence = max(0, essence-amount)
	if(essence == 0)
		src << "<span class='revendanger'>You feel your essence fraying!</span>"

/mob/living/simple_animal/revenant/ClickOn(var/atom/A, var/params) //Copypaste from ghost code - revenants can't interact with the world directly.
	if(client.buildmode)
		build_click(src, client.buildmode, params, A)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"])
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(world.time <= next_move)
		return
	A.attack_ghost(src)
	if(ishuman(A) && in_range(src, A))
		Harvest(A)

/mob/living/simple_animal/revenant/proc/Harvest(mob/living/carbon/human/target)
	if(!castcheck(0))
		return
	if(draining)
		src << "<span class='revenwarning'>You are already siphoning the essence of a soul!</span>"
		return
	if(target in drained_mobs)
		src << "<span class='revenwarning'>[target]'s soul is dead and empty.</span>"
		return
	if(!target.stat)
		src << "<span class='revennotice'>This being's soul is too strong to harvest.</span>"
		if(prob(10))
			target << "You feel as if you are being watched."
		return
	draining = 1
	essence_drained = rand(15, 20)
	src << "<span class='revennotice'>You search for the soul of [target].</span>"
	if(do_after(src, 10, 3, 0, target = target)) //did they get deleted in that second?
		if(target.ckey)
			src << "<span class='revennotice'>Their soul burns with intelligence.</span>"
			essence_drained += rand(20, 30)
		if(target.stat != DEAD)
			src << "<span class='revennotice'>Their soul blazes with life!</span>"
			essence_drained += rand(40, 50)
		else
			src << "<span class='revennotice'>Their soul is weak and faltering.</span>"
		if(do_after(src, 20, 6, 0, target = target)) //did they get deleted NOW?
			switch(essence_drained)
				if(1 to 30)
					src << "<span class='revennotice'>[target] will not yield much essence. Still, every bit counts.</span>"
				if(30 to 70)
					src << "<span class='revennotice'>[target] will yield an average amount of essence.</span>"
				if(70 to 90)
					src << "<span class='revenboldnotice'>Such a feast! [target] will yield much essence to you.</span>"
				if(90 to INFINITY)
					src << "<span class='revenbignotice'>Ah, the perfect soul. [target] will yield massive amounts of essence to you.</span>"
			if(do_after(src, 20, 6, 0, target = target)) //how about now
				if(!target.stat)
					src << "<span class='revenwarning'>They are now powerful enough to fight off your draining.</span>"
					target << "<span class='boldannounce'>You feel something tugging across your body before subsiding.</span>"
					draining = 0
					return //hey, wait a minute...
				src << "<span class='revenminor'>You begin siphoning essence from [target]'s soul.</span>"
				if(target.stat != DEAD)
					target << "<span class='warning'>You feel a horribly unpleasant draining sensation as your grip on life weakens...</span>"
				icon_state = "revenant_draining"
				reveal(27)
				stun(27)
				target.visible_message("<span class='warning'>[target] suddenly rises slightly into the air, their skin turning an ashy gray.</span>")
				target.Beam(src,icon_state="drain_life",icon='icons/effects/effects.dmi',time=26)
				if(do_after(src, 30, 9, 0, target)) //As one cannot prove the existance of ghosts, ghosts cannot prove the existance of the target they were draining.
					change_essence_amount(essence_drained, 0, target)
					if(essence_drained > 90)
						essence_regen_cap += 25
						perfectsouls += 1
						src << "<span class='revenboldnotice'>The perfection of [target]'s soul has increased your maximum essence level. Your new maximum essence is [essence_regen_cap].</span>"
					src << "<span class='revennotice'>[target]'s soul has been considerably weakened and will yield no more essence for the time being.</span>"
					target.visible_message("<span class='warning'>[target] slumps onto the ground.</span>", \
 										   "<span class='revenwarning'>Violets lights, dancing in your vision, getting clo--</span>")
					drained_mobs.Add(target)
					target.death(0)
				else
					src << "<span class='revenwarning'>[target ? "[target] has":"They have"] been drawn out of your grasp. The link has been broken.</span>"
					draining = 0
					essence_drained = 0
					if(target) //Wait, target is WHERE NOW?
						target.visible_message("<span class='warning'>[target] slumps onto the ground.</span>", \
											   "<span class='revenwarning'>Violets lights, dancing in your vision, receding--</span>")
					return
			else
				src << "<span class='revenwarning'>You are not close enough to siphon [target ? "[target]'s":"their"] soul. The link has been broken.</span>"
				draining = 0
				essence_drained = 0
				return
	draining = 0
	essence_drained = 0
	return

/mob/living/simple_animal/revenant/say(message)
	return 0 //Revenants cannot speak out loud.

/mob/living/simple_animal/revenant/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Current essence: [essence]/[essence_regen_cap]E")
		stat(null, "Stolen essence: [essence_accumulated]E")
		stat(null, "Stolen perfect souls: [perfectsouls]")

/mob/living/simple_animal/revenant/New()
	..()

	ghostimage = image(src.icon,src,src.icon_state)
	ghost_darkness_images |= ghostimage
	updateallghostimages()

	spawn(5)
		if(src.mind)
			src.mind.wipe_memory()
			src << 'sound/effects/ghost.ogg'
			src << "<br>"
			src << "<span class='deadsay'><font size=3><b>You are a revenant.</b></font></span>"
			src << "<b>Your formerly mundane spirit has been infused with alien energies and empowered into a revenant.</b>"
			src << "<b>You are not dead, not alive, but somewhere in between. You are capable of limited interaction with both worlds.</b>"
			src << "<b>You are invincible and invisible to everyone but other ghosts. Most abilities will reveal you, rendering you vulnerable.</b>"
			src << "<b>To function, you are to drain the life essence from humans. This essence is a resource, as well as your health, and will power all of your abilities.</b>"
			src << "<b><i>You do not remember anything of your past lives, nor will you remember anything about this one after your death.</i></b>"
			src << "<b>Be sure to read the wiki page at http://nanotrasen.se/wiki/index.php/Revenant to learn more.</b>"
			var/datum/objective/revenant/objective = new
			objective.owner = src.mind
			src.mind.objectives += objective
			src << "<b>Objective #1</b>: [objective.explanation_text]"
			var/datum/objective/revenantFluff/objective2 = new
			objective2.owner = src.mind
			src.mind.objectives += objective2
			src << "<b>Objective #2</b>: [objective2.explanation_text]"
			ticker.mode.traitors |= src.mind //Necessary for announcing
		if(!src.giveSpells())
			message_admins("Revenant was created but has no mind. Trying again in five seconds.")
			spawn(50)
				if(!src.giveSpells())
					message_admins("Revenant still has no mind. Deleting...")
					qdel(src)

/mob/living/simple_animal/revenant/proc/giveSpells()
	if(src.mind)
		src.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/revenant_transmit(null))
		src.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/revenant/overload(null))
		src.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/revenant/defile(null))
		src.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/revenant/malfunction(null))
		return 1
	return 0

/mob/living/simple_animal/revenant/death()
	..()
	if(!revealed) //Revenants cannot die if they aren't revealed
		return
	ghost_darkness_images -= ghostimage
	updateallghostimages()

	src << "<span class='revendanger'>NO! No... it's too late, you can feel your essence breaking apart...</span>"
	notransform = 1
	revealed = 1
	invisibility = 0
	playsound(src, 'sound/effects/screech.ogg', 100, 1)
	visible_message("<span class='warning'>[src] lets out a waning screech as violet mist swirls around its dissolving body!</span>")
	icon_state = "revenant_draining"
	for(var/i = alpha, i > 0, i -= 10)
		sleep(0.1)
		alpha = i
	visible_message("<span class='danger'>[src]'s body breaks apart into a fine pile of blue dust.</span>")
	var/obj/item/weapon/ectoplasm/revenant/R = new (get_turf(src))
	R.client_to_revive = src.client //If the essence reforms, the old revenant is put back in the body
	ghostize()
	qdel(src)
	return


/mob/living/simple_animal/revenant/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/weapon/nullrod))
		visible_message("<span class='warning'>[src] violently flinches!</span>", \
						"<span class='revendanger'>As the null rod passes through you, you feel your essence draining away!</span>")
		adjustBruteLoss(25) //hella effective
		inhibited = 1
		spawn(30)
			inhibited = 0

	..()

/mob/living/simple_animal/revenant/proc/castcheck(essence_cost)
	if(!src)
		return
	var/turf/T = get_turf(src)
	if(istype(T, /turf/simulated/wall))
		src << "<span class='revenwarning'>You cannot use abilities from inside of a wall.</span>"
		return 0
	if(src.inhibited)
		src << "<span class='revenwarning'>Your powers have been suppressed by nulling energy!</span>"
		return 0
	if(!src.change_essence_amount(essence_cost, 1))
		src << "<span class='revenwarning'>You lack the essence to use that ability.</span>"
		return 0
	return 1

/mob/living/simple_animal/revenant/proc/change_essence_amount(essence_amt, silent = 0, source = null)
	if(!src)
		return
	if(essence + essence_amt <= 0)
		return
	essence = max(0, essence+essence_amt)
	if(essence_amt > 0)
		essence_accumulated = max(0, essence_accumulated+essence_amt)
	if(!silent)
		if(essence_amt > 0)
			src << "<span class='revennotice'>Gained [essence_amt]E from [source].</span>"
		else
			src << "<span class='revenminor'>Lost [essence_amt]E from [source].</span>"
	return 1

/mob/living/simple_animal/revenant/proc/reveal(time)
	if(!src)
		return
	if(time <= 0)
		return
	revealed = 1
	invisibility = 0
	incorporeal_move = 0
	if(!unreveal_time)
		src << "<span class='revendanger'>You have been revealed!</span>"
		unreveal_time = world.time + time
	else
		src << "<span class='revenwarning'>You have been revealed!</span>"
		unreveal_time = unreveal_time + time
	update_spooky_icon()

/mob/living/simple_animal/revenant/proc/stun(time)
	if(!src)
		return
	if(time <= 0)
		return
	notransform = 1
	if(!unstun_time)
		src << "<span class='revendanger'>You cannot move!</span>"
		unstun_time = world.time + time
	else
		src << "<span class='revenwarning'>You cannot move!</span>"
		unstun_time = unstun_time + time
	update_spooky_icon()

/mob/living/simple_animal/revenant/proc/update_spooky_icon()
	if(revealed)
		if(notransform)
			if(draining)
				icon_state = icon_drain
			else
				icon_state = icon_stun
		else
			icon_state = icon_reveal
	else
		icon_state = icon_idle

/datum/objective/revenant
	var/targetAmount = 100

/datum/objective/revenant/New()
	targetAmount = rand(200,500)
	explanation_text = "Absorb [targetAmount] points of essence from humans."
	..()

/datum/objective/revenant/check_completion()
	if(!owner || !istype(owner.current, /mob/living/simple_animal/revenant))
		return 0
	var/mob/living/simple_animal/revenant/R = owner.current
	if(!R || R.stat == DEAD)
		return 0
	var/essence_stolen  = R.essence_accumulated
	if(essence_stolen  < targetAmount)
		return 0
	return 1

/datum/objective/revenantFluff

/datum/objective/revenantFluff/New()
	var/list/explanationTexts = list("Attempt to make your presence unknown to the crew.", \
									 "Collaborate with existing antagonists aboard the station to gain essence.", \
									 "Remain nonlethal and only absorb bodies that have already died.", \
									 "Use your environments to eliminate isolated people.", \
									 "If there is a chaplain aboard the station, ensure they are killed.", \
									 "Hinder the crew without killing them.")
	explanation_text = pick(explanationTexts)
	..()

/datum/objective/revenantFluff/check_completion()
	return 1


/obj/item/weapon/ectoplasm/revenant
	name = "glimmering residue"
	desc = "A pile of fine blue dust. Small tendrils of violet mist swirl around it."
	icon = 'icons/effects/effects.dmi'
	icon_state = "revenantEctoplasm"
	w_class = 2
	var/reforming = 1
	var/inert = 0
	var/client/client_to_revive

/obj/item/weapon/ectoplasm/revenant/New()
	..()
	reforming = 0
	spawn(600) //1 minutes
		if(src && reforming)
			return reform()
		else
			inert = 1
			visible_message("<span class='warning'>[src] settles down and seems lifeless.</span>")
			return

/obj/item/weapon/ectoplasm/revenant/attack_self(mob/user)
	if(!reforming || inert)
		return ..()
	user.visible_message("<span class='notice'>[user] scatters [src] in all directions.</span>", \
						 "<span class='notice'>You scatter [src] across the area. The particles slowly fade away.</span>")
	user.drop_item()
	qdel(src)

/obj/item/weapon/ectoplasm/revenant/throw_impact(atom/hit_atom)
	..()
	if(inert)
		return
	visible_message("<span class='notice'>[src] breaks into particles upon impact, which fade away to nothingness.</span>")
	qdel(src)

/obj/item/weapon/ectoplasm/revenant/examine(mob/user)
	..(user)
	if(inert)
		user << "<span class='revennotice'>It seems inert.</span>"
	else if(reforming)
		user << "<span class='revenwarning'>It is shifting and distorted. It would be wise to destroy this.</span>"

/obj/item/weapon/ectoplasm/revenant/proc/reform()
	if(inert || !src)
		return
	var/key_of_revenant
	message_admins("Revenant ectoplasm was left undestroyed for 1 minute and is reforming into a new revenant.")
	loc = get_turf(src) //In case it's in a backpack or someone's hand
	var/mob/living/simple_animal/revenant/R = new(get_turf(src))
	if(client_to_revive)
		for(var/mob/M in dead_mob_list)
			if(M.client == client_to_revive) //Only recreates the mob if the mob the client is in is dead
				R.client = client_to_revive
				key_of_revenant = client_to_revive.key

	if(!key_of_revenant)
		message_admins("The new revenant's old client either could not be found or is in a new, living mob - grabbing a random candidate instead...")
		var/list/candidates = get_candidates(ROLE_REVENANT)
		if(!candidates.len)
			qdel(R)
			message_admins("No candidates were found for the new revenant. Oh well!")
			inert = 1
			visible_message("<span class='revenwarning'>[src] settles down and seems lifeless.</span>")
			return 0
		var/client/C = pick(candidates)
		key_of_revenant = C.key
		if(!key_of_revenant)
			qdel(R)
			message_admins("No ckey was found for the new revenant. Oh well!")
			inert = 1
			visible_message("<span class='revenwarning'>[src] settles down and seems lifeless.</span>")
			return 0
	var/datum/mind/player_mind = new /datum/mind(key_of_revenant)
	player_mind.active = 1
	player_mind.transfer_to(R)
	player_mind.assigned_role = "revenant"
	player_mind.special_role = "Revenant"
	ticker.mode.traitors |= player_mind
	message_admins("[key_of_revenant] has been [client_to_revive ? "re":""]made into a revenant by reforming ectoplasm.")
	log_game("[key_of_revenant] was [client_to_revive ? "re":""]made as a revenant by reforming ectoplasm.")
	visible_message("<span class='revenboldnotice'>[src] suddenly rises into the air before fading away.</span>")
	qdel(src)
	if(src) //Should never happen, but just in case
		inert = 1
	return 1
