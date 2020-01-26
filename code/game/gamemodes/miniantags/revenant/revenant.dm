//Revenants: based off of wraiths from Goon
//"Ghosts" that are invisible and move like ghosts, cannot take damage while invsible
//Don't hear deadchat and are NOT normal ghosts
//Admin-spawn or random event

#define INVISIBILITY_REVENANT 50
#define REVENANT_NAME_FILE "revenant_names.json"

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
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
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
	wander = 0
	density = 0
	flying = 1
	move_resist = INFINITY
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	speed = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

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


/mob/living/simple_animal/revenant/Life(seconds, times_fired)
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
		to_chat(src, "<span class='revenboldnotice'>You are once more concealed.</span>")
	if(unstun_time && world.time >= unstun_time)
		unstun_time = 0
		notransform = 0
		to_chat(src, "<span class='revenboldnotice'>You can move again!</span>")
	update_spooky_icon()

/mob/living/simple_animal/revenant/ex_act(severity)
	return 1 //Immune to the effects of explosions.

/mob/living/simple_animal/revenant/blob_act(obj/structure/blob/B)
	return //blah blah blobs aren't in tune with the spirit world, or something.

/mob/living/simple_animal/revenant/singularity_act()
	return //don't walk into the singularity expecting to find corpses, okay?

/mob/living/simple_animal/revenant/narsie_act()
	return //most humans will now be either bones or harvesters, but we're still un-alive.

/mob/living/simple_animal/revenant/adjustHealth(amount, updating_health = TRUE)
	if(!revealed)
		return
	essence = max(0, essence-amount)
	if(essence == 0)
		to_chat(src, "<span class='revendanger'>You feel your essence fraying!</span>")

/mob/living/simple_animal/revenant/say(message)
	if(!message)
		return
	log_say(message, src)
	var/rendered = "<span class='revennotice'><b>[src]</b> says, \"[message]\"</span>"
	for(var/mob/M in GLOB.mob_list)
		if(istype(M, /mob/living/simple_animal/revenant))
			to_chat(M, rendered)
		if(isobserver(M))
			to_chat(M, "<a href='?src=[M.UID()];follow=[UID()]'>(F)</a> [rendered]")
	return

/mob/living/simple_animal/revenant/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Current essence: [essence]/[essence_regen_cap]E")
		stat(null, "Stolen essence: [essence_accumulated]E")
		stat(null, "Stolen perfect souls: [perfectsouls]")

/mob/living/simple_animal/revenant/New()
	..()

	remove_from_all_data_huds()
	random_revenant_name()

	addtimer(CALLBACK(src, .proc/firstSetupAttempt), 15 SECONDS) // Give admin 15 seconds to put in a ghost (Or wait 15 seconds before giving it objectives)

/mob/living/simple_animal/revenant/proc/random_revenant_name()
	var/built_name = ""
	built_name += pick(strings(REVENANT_NAME_FILE, "spirit_type"))
	built_name += " of "
	built_name += pick(strings(REVENANT_NAME_FILE, "adjective"))
	built_name += pick(strings(REVENANT_NAME_FILE, "theme"))
	name = built_name

/mob/living/simple_animal/revenant/proc/firstSetupAttempt()
	if(mind)
		giveObjectivesandGoals()
		giveSpells()
	else
		message_admins("Revenant was created but has no mind. Put a ghost inside, or a poll will be made in one minute.")
		addtimer(CALLBACK(src, .proc/setupOrDelete), 1 MINUTES)

/mob/living/simple_animal/revenant/proc/setupOrDelete()
	if(mind)
		giveObjectivesandGoals()
		giveSpells()
	else
		var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as a revenant?", poll_time = 15 SECONDS)
		var/mob/dead/observer/theghost = null
		if(candidates.len)
			theghost = pick(candidates)
			message_admins("[key_name_admin(theghost)] has taken control of a revenant created without a mind")
			key = theghost.key
			giveObjectivesandGoals()
			giveSpells()
		else
			message_admins("No ghost was willing to take control of a mindless revenant. Deleting...")
			qdel(src)

/mob/living/simple_animal/revenant/proc/giveObjectivesandGoals()
			mind.wipe_memory()
			SEND_SOUND(src, 'sound/effects/ghost.ogg')
			to_chat(src, "<br>")
			to_chat(src, "<span class='deadsay'><font size=3><b>You are a revenant.</b></font></span>")
			to_chat(src, "<b>Your formerly mundane spirit has been infused with alien energies and empowered into a revenant.</b>")
			to_chat(src, "<b>You are not dead, not alive, but somewhere in between. You are capable of limited interaction with both worlds.</b>")
			to_chat(src, "<b>You are invincible and invisible to everyone but other ghosts. Most abilities will reveal you, rendering you vulnerable.</b>")
			to_chat(src, "<b>To function, you are to drain the life essence from humans. This essence is a resource, as well as your health, and will power all of your abilities.</b>")
			to_chat(src, "<b><i>You do not remember anything of your past lives, nor will you remember anything about this one after your death.</i></b>")
			to_chat(src, "<b>Be sure to read the wiki page at http://www.paradisestation.org/wiki/index.php/Revenant to learn more.</b>")
			var/datum/objective/revenant/objective = new
			objective.owner = mind
			mind.objectives += objective
			to_chat(src, "<b>Objective #1</b>: [objective.explanation_text]")
			var/datum/objective/revenantFluff/objective2 = new
			objective2.owner = mind
			mind.objectives += objective2
			to_chat(src, "<b>Objective #2</b>: [objective2.explanation_text]")
			SSticker.mode.traitors |= mind //Necessary for announcing

/mob/living/simple_animal/revenant/proc/giveSpells()
	mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/night_vision/revenant(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/revenant_transmit(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/revenant/overload(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/revenant/defile(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/revenant/malfunction(null))
	return TRUE


/mob/living/simple_animal/revenant/dust()
	. = death()

/mob/living/simple_animal/revenant/gib()
	. = death()

/mob/living/simple_animal/revenant/death()
	if(!revealed)
		return FALSE
	// Only execute the below if we successfully died
	. = ..()
	if(!.)
		return FALSE

	to_chat(src, "<span class='revendanger'>NO! No... it's too late, you can feel your essence breaking apart...</span>")
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
	var/obj/item/ectoplasm/revenant/R = new (get_turf(src))
	var/reforming_essence = essence_regen_cap //retain the gained essence capacity
	R.essence = max(reforming_essence - 15 * perfectsouls, 75) //minus any perfect souls
	R.client_to_revive = src.client //If the essence reforms, the old revenant is put back in the body
	ghostize()
	qdel(src)

/mob/living/simple_animal/revenant/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/nullrod))
		visible_message("<span class='warning'>[src] violently flinches!</span>", \
						"<span class='revendanger'>As \the [W] passes through you, you feel your essence draining away!</span>")
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
		to_chat(src, "<span class='revenwarning'>You cannot use abilities from inside of a wall.</span>")
		return 0
	if(src.inhibited)
		to_chat(src, "<span class='revenwarning'>Your powers have been suppressed by nulling energy!</span>")
		return 0
	if(!src.change_essence_amount(essence_cost, 1))
		to_chat(src, "<span class='revenwarning'>You lack the essence to use that ability.</span>")
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
			to_chat(src, "<span class='revennotice'>Gained [essence_amt]E from [source].</span>")
		else
			to_chat(src, "<span class='revenminor'>Lost [essence_amt]E from [source].</span>")
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
		to_chat(src, "<span class='revendanger'>You have been revealed!</span>")
		unreveal_time = world.time + time
	else
		to_chat(src, "<span class='revenwarning'>You have been revealed!</span>")
		unreveal_time = unreveal_time + time
	update_spooky_icon()

/mob/living/simple_animal/revenant/proc/stun(time)
	if(!src)
		return
	if(time <= 0)
		return
	notransform = 1
	if(!unstun_time)
		to_chat(src, "<span class='revendanger'>You cannot move!</span>")
		unstun_time = world.time + time
	else
		to_chat(src, "<span class='revenwarning'>You cannot move!</span>")
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
	targetAmount = rand(350,600)
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
	var/list/explanationTexts = list("Assist and exacerbate existing threats at critical moments.", \
									 "Avoid killing in plain sight.", \
									 "Cause as much chaos and anger as you can without being killed.", \
									 "Damage and render as much of the station rusted and unusable as possible.", \
									 "Disable and cause malfunctions in as many machines as possible.", \
									 "Ensure that any holy weapons are rendered unusable.", \
									 "Hinder the crew while attempting to avoid being noticed.", \
									 "Make the crew as miserable as possible.", \
									 "Make the clown as miserable as possible.", \
									 "Make the captain as miserable as possible.", \
									 "Prevent the use of energy weapons where possible.")
	explanation_text = pick(explanationTexts)
	..()

/datum/objective/revenantFluff/check_completion()
	return 1


/obj/item/ectoplasm/revenant
	name = "glimmering residue"
	desc = "A pile of fine blue dust. Small tendrils of violet mist swirl around it."
	icon = 'icons/effects/effects.dmi'
	icon_state = "revenantEctoplasm"
	w_class = WEIGHT_CLASS_SMALL
	var/reforming = 1
	var/essence = 75 //the maximum essence of the reforming revenant
	var/inert = 0
	var/client/client_to_revive

/obj/item/ectoplasm/revenant/New()
	..()
	reforming = 0
	spawn(600) //1 minutes
		if(src && reforming)
			reform()
		else
			inert = 1
			visible_message("<span class='warning'>[src] settles down and seems lifeless.</span>")

/obj/item/ectoplasm/revenant/attack_self(mob/user)
	if(!reforming || inert)
		return ..()
	user.visible_message("<span class='notice'>[user] scatters [src] in all directions.</span>", \
						 "<span class='notice'>You scatter [src] across the area. The particles slowly fade away.</span>")
	user.drop_item()
	qdel(src)

/obj/item/ectoplasm/revenant/throw_impact(atom/hit_atom)
	..()
	if(inert)
		return
	visible_message("<span class='notice'>[src] breaks into particles upon impact, which fade away to nothingness.</span>")
	qdel(src)

/obj/item/ectoplasm/revenant/examine(mob/user)
	. = ..()
	if(inert)
		. += "<span class='revennotice'>It seems inert.</span>"
	else if(reforming)
		. += "<span class='revenwarning'>It is shifting and distorted. It would be wise to destroy this.</span>"

/obj/item/ectoplasm/revenant/proc/reform()
	if(inert || !src)
		return
	var/key_of_revenant
	message_admins("Revenant ectoplasm was left undestroyed for 1 minute and is reforming into a new revenant.")
	loc = get_turf(src) //In case it's in a backpack or someone's hand
	var/mob/living/simple_animal/revenant/R = new(get_turf(src))
	if(client_to_revive)
		for(var/mob/M in GLOB.dead_mob_list)
			if(M.client == client_to_revive) //Only recreates the mob if the mob the client is in is dead
				R.client = client_to_revive
				key_of_revenant = client_to_revive.key

	spawn()
		if(!key_of_revenant)
			message_admins("The new revenant's old client either could not be found or is in a new, living mob - grabbing a random candidate instead...")
			var/list/candidates = pollCandidates("Do you want to play as a revenant?", ROLE_REVENANT, 1)
			if(!candidates.len)
				qdel(R)
				message_admins("No candidates were found for the new revenant. Oh well!")
				inert = 1
				visible_message("<span class='revenwarning'>[src] settles down and seems lifeless.</span>")
				return
			var/mob/C = pick(candidates)
			key_of_revenant = C.key
			if(!key_of_revenant)
				qdel(R)
				message_admins("No ckey was found for the new revenant. Oh well!")
				inert = 1
				visible_message("<span class='revenwarning'>[src] settles down and seems lifeless.</span>")
				return
		var/datum/mind/player_mind = new /datum/mind(key_of_revenant)
		player_mind.active = 1
		player_mind.transfer_to(R)
		player_mind.assigned_role = SPECIAL_ROLE_REVENANT
		player_mind.special_role = SPECIAL_ROLE_REVENANT
		SSticker.mode.traitors |= player_mind
		message_admins("[key_of_revenant] has been [client_to_revive ? "re":""]made into a revenant by reforming ectoplasm.")
		log_game("[key_of_revenant] was [client_to_revive ? "re":""]made as a revenant by reforming ectoplasm.")
		visible_message("<span class='revenboldnotice'>[src] suddenly rises into the air before fading away.</span>")
		qdel(src)
		if(src) //Should never happen, but just in case
			inert = 1
