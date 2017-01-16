/*
  Tiny babby plant critter plus procs.
*/

//Mob defines.
/mob/living/simple_animal/diona
	name = "diona nymph"
	icon = 'icons/mob/monkey.dmi'
	icon_state = "nymph"
	icon_living = "nymph"
	icon_dead = "nymph_dead"
	icon_resting = "nymph_sleep"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	ventcrawler = 2

	maxHealth = 50
	health = 50

	voice_name = "diona nymph"
	speak_emote = list("chirrups")
	emote_hear = list("chirrups")
	emote_see = list("chirrups")

	response_help  = "pets"
	response_disarm = "pushes"
	response_harm   = "kicks"

	melee_damage_lower = 5
	melee_damage_upper = 8
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	speed = 0
	stop_automated_movement = 0
	turns_per_move = 4

	var/list/donors = list()
	var/ready_evolve = 0
	holder_type = /obj/item/weapon/holder/diona
	can_collar = 1

/mob/living/simple_animal/diona/New()
	..()
	if(name == initial(name)) //To stop Pun-Pun becoming generic.
		name = "[name] ([rand(1, 1000)])"
		real_name = name

	add_language("Rootspeak")
	src.verbs += /mob/living/simple_animal/diona/proc/merge

/mob/living/simple_animal/diona/attack_hand(mob/living/carbon/human/M as mob)
	//Let people pick the little buggers up.
	if(M.a_intent == I_HELP)
		if(M.species && M.species.name == "Diona")
			to_chat(M, "You feel your being twine with that of [src] as it merges with your biomass.")
			to_chat(src, "You feel your being twine with that of [M] as you merge with its biomass.")
			src.verbs += /mob/living/simple_animal/diona/proc/split
			src.verbs -= /mob/living/simple_animal/diona/proc/merge
			src.forceMove(M)
		else
			get_scooped(M)

	..()

/mob/living/simple_animal/diona/proc/merge()
	set category = "Diona"
	set name = "Merge with gestalt"
	set desc = "Merge with another diona."

	if(istype(src.loc,/mob/living/carbon))
		src.verbs -= /mob/living/simple_animal/diona/proc/merge
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))

		if(!(src.Adjacent(C)) || !(C.client)) continue

		if(istype(C,/mob/living/carbon/human))
			var/mob/living/carbon/human/D = C
			if(D.species && D.species.name == "Diona")
				choices += C

	var/mob/living/M = input(src,"Who do you wish to merge with?") in null|choices

	if(!M || !src || !(src.Adjacent(M))) return

	if(istype(M,/mob/living/carbon/human))
		to_chat(M, "You feel your being twine with that of [src] as it merges with your biomass.")
		M.status_flags |= PASSEMOTES

		to_chat(src, "You feel your being twine with that of [M] as you merge with its biomass.")
		src.loc = M
		src.verbs += /mob/living/simple_animal/diona/proc/split
		src.verbs -= /mob/living/simple_animal/diona/proc/merge
	else
		return

/mob/living/simple_animal/diona/proc/split()
	set category = "Diona"
	set name = "Split from gestalt"
	set desc = "Split away from your gestalt as a lone nymph."

	if(!(istype(src.loc,/mob/living/carbon)))
		src.verbs -= /mob/living/simple_animal/diona/proc/split
		return

	to_chat(src.loc, "You feel a pang of loss as [src] splits away from your biomass.")
	to_chat(src, "You wiggle out of the depths of [src.loc]'s biomass and plop to the ground.")

	var/mob/living/M = src.loc

	src.loc = get_turf(src)
	src.verbs -= /mob/living/simple_animal/diona/proc/split
	src.verbs += /mob/living/simple_animal/diona/proc/merge

	if(istype(M))
		for(var/atom/A in M.contents)
			if(istype(A,/mob/living/simple_animal/borer) || istype(A,/obj/item/weapon/holder))
				return
	M.status_flags &= ~PASSEMOTES

/mob/living/simple_animal/diona/verb/fertilize_plant()
	set category = "Diona"
	set name = "Fertilize plant"
	set desc = "Turn your food into nutrients for plants."

	var/list/trays = list()
	for(var/obj/machinery/portable_atmospherics/hydroponics/tray in range(1))
		if(tray.nutrilevel < 10)
			trays += tray

	var/obj/machinery/portable_atmospherics/hydroponics/target = input("Select a tray:") as null|anything in trays

	if(!src || !target || target.nutrilevel == 10) return //Sanity check.

	src.nutrition -= ((10-target.nutrilevel)*5)
	target.nutrilevel = 10
	src.visible_message("<span class='danger'>[src] secretes a trickle of green liquid from its tail, refilling [target]'s nutrient tray.","\red You secrete a trickle of green liquid from your tail, refilling [target]'s nutrient tray.</span>")

/mob/living/simple_animal/diona/verb/eat_weeds()
	set category = "Diona"
	set name = "Eat Weeds"
	set desc = "Clean the weeds out of soil or a hydroponics tray."

	var/list/trays = list()
	for(var/obj/machinery/portable_atmospherics/hydroponics/tray in range(1))
		if(tray.weedlevel > 0)
			trays += tray

	var/obj/machinery/portable_atmospherics/hydroponics/target = input("Select a tray:") as null|anything in trays

	if(!src || !target || target.weedlevel == 0) return //Sanity check.

	src.nutrition += target.weedlevel * 15
	target.weedlevel = 0
	src.visible_message("<span class='danger'>[src] begins rooting through [target], ripping out weeds and eating them noisily.</span>","<span class='danger'>You begin rooting through [target], ripping out weeds and eating them noisily.</span>")

/mob/living/simple_animal/diona/verb/evolve()
	set category = "Diona"
	set name = "Evolve"
	set desc = "Grow to a more complex form."

	if(donors.len < 5)
		to_chat(src, "<span class='warning'>You need more blood in order to ascend to a new state of consciousness...</span>")
		return

	if(nutrition < 500)
		to_chat(src, "<span class='warning'>You need to binge on weeds in order to have the energy to grow...</span>")
		return

	src.split()
	src.visible_message("<span class='danger'>[src] begins to shift and quiver, and erupts in a shower of shed bark as it splits into a tangle of nearly a dozen new dionaea.</span>","<span class='danger'>You begin to shift and quiver, feeling your awareness splinter. All at once, we consume our stored nutrients to surge with growth, splitting into a tangle of at least a dozen new dionaea. We have attained our gestalt form.</span>")

	var/mob/living/carbon/human/diona/adult = new(get_turf(src.loc))
	adult.set_species("Diona")

	if(istype(loc,/obj/item/weapon/holder/diona))
		var/obj/item/weapon/holder/diona/L = loc
		src.loc = L.loc
		qdel(L)

	for(var/datum/language/L in languages)
		adult.add_language(L.name)
	adult.regenerate_icons()

	adult.name = "diona ([rand(100,999)])"
	adult.real_name = adult.name
	adult.ckey = src.ckey
	adult.real_name = pick(diona_names)	//I hate this being here of all places but unfortunately dna is based on real_name!
	adult.rename_self("diona")

	for(var/obj/item/W in src.contents)
		src.unEquip(W)

	qdel(src)

/mob/living/simple_animal/diona/verb/steal_blood()
	set category = "Diona"
	set name = "Steal Blood"
	set desc = "Take a blood sample from a suitable donor."

	var/list/choices = list()
	for(var/mob/living/carbon/human/H in oview(1,src))
		choices += H

	var/mob/living/carbon/human/M = input(src,"Who do you wish to take a sample from?") in null|choices

	if(!M || !src) return

	if(M.species.flags & NO_BLOOD)
		to_chat(src, "<span class='warning'>That donor has no blood to take.</span>")
		return

	if(donors.Find(M.real_name))
		to_chat(src, "<span class='warning'>That donor offers you nothing new.</span>")
		return

	src.visible_message("<span class='danger'>[src] flicks out a feeler and neatly steals a sample of [M]'s blood.</span>","<span class='danger'>You flick out a feeler and neatly steal a sample of [M]'s blood.</span>")
	donors += M.real_name
	for(var/datum/language/L in M.languages)
		if(!(L.flags & HIVEMIND))
			languages |= L

	spawn(25)
		update_progression()

/mob/living/simple_animal/diona/proc/update_progression()
	if(!donors.len)
		return

	if(donors.len == 5)
		ready_evolve = 1
		to_chat(src, "<span class='noticealien'>You feel ready to move on to your next stage of growth.</span>")
	else if(donors.len == 3)
		universal_understand = 1
		to_chat(src, "<span class='noticealien'>You feel your awareness expand, and realize you know how to understand the creatures around you.</span>")
	else
		to_chat(src, "<span class='noticealien'>The blood seeps into your small form, and you draw out the echoes of memories and personality from it, working them into your budding mind.</span>")


/mob/living/simple_animal/diona/put_in_hands(obj/item/W)
	W.loc = get_turf(src)
	W.layer = initial(W.layer)
	W.plane = initial(W.plane)
	W.dropped()

/mob/living/simple_animal/diona/put_in_active_hand(obj/item/W)
	to_chat(src, "<span class='warning'>You don't have any hands!</span>")
	return

/mob/living/simple_animal/diona/emote(var/act, var/m_type=1, var/message = null)
	if(stat)
		return

	var/on_CD = 0
	act = lowertext(act)
	switch(act)
		if("chirp")
			on_CD = handle_emote_CD()
		else
			on_CD = 0

	if(on_CD == 1)
		return

	switch(act) //IMPORTANT: Emotes MUST NOT CONFLICT anywhere along the chain.
		if("chirp")
			message = "<B>\The [src]</B> chirps!"
			m_type = 2 //audible
			playsound(src, 'sound/misc/nymphchirp.ogg', 40, 1, 1)

	..(act, m_type, message)