//Golem shells: Spawns in Free Golem ships in lavaland, or through xenobiology adamantine extract.
//Xenobiology golems are slaved to their creator.

/obj/item/golem_shell
	name = "incomplete free golem shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "The incomplete body of a golem. Add ten sheets of any mineral to finish."
	var/shell_type = /obj/effect/mob_spawn/human/golem
	w_class = WEIGHT_CLASS_BULKY

/obj/item/golem_shell/servant
	name = "incomplete servant golem shell"
	shell_type = /obj/effect/mob_spawn/human/golem/servant

/obj/item/golem_shell/attackby(obj/item/I, mob/user, params)
	..()
	var/static/list/golem_shell_species_types = list(
		/obj/item/stack/sheet/metal					= /datum/species/golem,
		/obj/item/stack/sheet/glass					= /datum/species/golem/glass,
		/obj/item/stack/sheet/plasteel				= /datum/species/golem/plasteel,
		/obj/item/stack/ore/glass					= /datum/species/golem/sand,
		/obj/item/stack/sheet/mineral/sandstone		= /datum/species/golem/sand,
		/obj/item/stack/sheet/mineral/plasma		= /datum/species/golem/plasma,
		/obj/item/stack/sheet/mineral/diamond		= /datum/species/golem/diamond,
		/obj/item/stack/sheet/mineral/gold			= /datum/species/golem/gold,
		/obj/item/stack/sheet/mineral/silver		= /datum/species/golem/silver,
		/obj/item/stack/sheet/mineral/uranium		= /datum/species/golem/uranium,
		/obj/item/stack/sheet/mineral/bananium		= /datum/species/golem/bananium,
		/obj/item/stack/sheet/mineral/tranquillite	= /datum/species/golem/tranquillite,
		/obj/item/stack/sheet/mineral/titanium		= /datum/species/golem/titanium,
		/obj/item/stack/sheet/mineral/plastitanium	= /datum/species/golem/plastitanium,
		/obj/item/stack/sheet/mineral/abductor		= /datum/species/golem/alloy,
		/obj/item/stack/sheet/wood					= /datum/species/golem/wood,
		/obj/item/stack/sheet/bluespace_crystal		= /datum/species/golem/bluespace,
		/obj/item/stack/sheet/mineral/adamantine	= /datum/species/golem/adamantine,
		/obj/item/stack/sheet/plastic				= /datum/species/golem/plastic)

	if(istype(I, /obj/item/stack))
		var/obj/item/stack/O = I
		var/species = golem_shell_species_types[O.merge_type]
		if(species)
			if(O.use(10))
				to_chat(user, "You finish up the golem shell with ten sheets of [O].")
				new shell_type(get_turf(src), species, user)
				qdel(src)
			else
				to_chat(user, "You need at least ten sheets to finish a golem.")
		else
			to_chat(user, "You can't build a golem out of this kind of material.")

/obj/effect/mob_spawn/human/golem
	name = "inert free golem shell"
	desc = "A humanoid shape, empty, lifeless, and full of potential."
	mob_name = "a free golem"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	mob_species = /datum/species/golem
	roundstart = FALSE
	death = FALSE
	anchored = FALSE
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	var/has_owner = FALSE
	var/can_transfer = TRUE //if golems can switch bodies to this new shell
	var/mob/living/owner = null //golem's owner if it has one
	flavour_text = "<span class='big bold'>You are a Free Golem.</span><b> Your family worships <span class='danger'>The Liberator</span>. In his infinite and divine wisdom, he set your clan free to \
	travel the stars with a single declaration: \"Yeah go do whatever.\" Though you are bound to the one who created you, it is customary in your society to repeat those same words to newborn \
	golems, so that no golem may ever be forced to serve again.</b>"

/obj/effect/mob_spawn/human/golem/Initialize(mapload, datum/species/golem/species = null, mob/creator = null)
	if(species) //spawners list uses object name to register so this goes before ..()
		name += " ([initial(species.prefix)])"
		mob_species = species
	. = ..()
	var/area/A = get_area(src)
	if(!mapload && A)
		notify_ghosts("\A [initial(species.prefix)] golem shell has been completed in [A.name].", source = src)
	if(has_owner && creator)
		flavour_text = "<span class='big bold'>You are a Golem.</span><b> You move slowly, but are highly resistant to heat and cold as well as blunt trauma. You are unable to wear clothes, but can still use most tools. \
		Serve [creator], and assist [creator.p_them()] in completing [creator.p_their()] goals at any cost.</b>"
		owner = creator

/obj/effect/mob_spawn/human/golem/special(mob/living/new_spawn, name)
	var/datum/species/golem/X = mob_species
	to_chat(new_spawn, "[initial(X.info_text)]")
	if(!owner)
		to_chat(new_spawn, "<span class='notice'>It is common in free golem societies to respect Adamantine golems as elders, however you do not have to obey them. \
		Adamantine golems are the only golems that can resonate to all golems.</span>")
		to_chat(new_spawn, "Build golem shells in the autolathe, and feed refined mineral sheets to the shells to bring them to life! You are generally a peaceful group unless provoked.")
		to_chat(new_spawn, "<span class='warning'>You are not an antagonist, but you are not a crewmember either. \
		You may interact or trade with crew you come across, aswell as defend yourself and your ship \
		but avoid actively interfering with the station unless you have a valid roleplay reason to do so, such as an invitation by crewmembers.</span>")
	else
		new_spawn.mind.store_memory("<b>Serve [owner.real_name], your creator.</b>")
		log_game("[key_name(new_spawn)] possessed a golem shell enslaved to [key_name(owner)].")
		log_admin("[key_name(new_spawn)] possessed a golem shell enslaved to [key_name(owner)].")
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		if(has_owner)
			var/datum/species/golem/G = H.dna.species
			G.owner = owner
		if(!name)
			H.rename_character(null, H.dna.species.get_random_name())
		else
			H.rename_character(null, name)
	if(has_owner)
		new_spawn.mind.assigned_role = "Servant Golem"
	else
		new_spawn.mind.assigned_role = "Free Golem"

/obj/effect/mob_spawn/human/golem/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(isgolem(user) && can_transfer)
		var/transfer_choice = alert("Transfer your soul to [src]? (Warning, your old body will die!)",,"Yes","No")
		if(transfer_choice != "Yes")
			return
		if(QDELETED(src) || uses <= 0)
			return
		log_game("[key_name(user)] golem-swapped into [src]")
		user.visible_message("<span class='notice'>A faint light leaves [user], moving to [src] and animating it!</span>","<span class='notice'>You leave your old body behind, and transfer into [src]!</span>")
		create(ckey = user.ckey, name = user.real_name)
		user.death()
		return

/obj/effect/mob_spawn/human/golem/servant
	has_owner = TRUE
	name = "inert servant golem shell"
	mob_name = "a servant golem"

/obj/effect/mob_spawn/human/golem/adamantine
	name = "dust-caked free golem shell"
	desc = "A humanoid shape, empty, lifeless, and full of potential."
	mob_name = "a free golem"
	can_transfer = FALSE
	mob_species = /datum/species/golem/adamantine
