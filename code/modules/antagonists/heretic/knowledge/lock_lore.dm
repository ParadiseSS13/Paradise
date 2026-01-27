
/datum/heretic_knowledge_tree_column/main/lock
	neighbour_type_left = /datum/heretic_knowledge_tree_column/moon_to_lock
	neighbour_type_right = /datum/heretic_knowledge_tree_column/lock_to_flesh

	route = PATH_LOCK
	ui_bgr = "node_lock"

	start = /datum/heretic_knowledge/limited_amount/starting/base_knock
	grasp = /datum/heretic_knowledge/lock_grasp
	tier1 = /datum/heretic_knowledge/key_ring
	mark = /datum/heretic_knowledge/mark/lock_mark
	ritual_of_knowledge = /datum/heretic_knowledge/knowledge_ritual/lock
	unique_ability = /datum/heretic_knowledge/limited_amount/concierge_rite
	tier2 = /datum/heretic_knowledge/spell/burglar_finesse
	blade = /datum/heretic_knowledge/blade_upgrade/flesh/lock
	tier3 =	/datum/heretic_knowledge/spell/caretaker_refuge
	ascension = /datum/heretic_knowledge/ultimate/lock_final

/datum/heretic_knowledge/limited_amount/starting/base_knock
	name = "A Steward's Secret"
	desc = "Opens up the Path of Lock to you. \
		Allows you to transmute a knife and a crowbar into a Key Blade. \
		You can only create two at a time and they function as fast crowbars. \
		In addition, they can fit into utility belts."
	gain_text = "The Locked Labyrinth leads to freedom. But only the trapped Stewards know the correct path."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/crowbar = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/lock)
	limit = 2
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "key_blade"

/datum/heretic_knowledge/lock_grasp
	name = "Grasp of Lock"
	desc = "Your mansus grasp allows you to access *mostly* anything! Alt click on an airlock or a locker to force it open. \
		DNA locks on mechs will be removed, and any pilot will be ejected. \
		Makes a distinctive knocking sound on use."
	gain_text = "Nothing may remain closed from my touch."
	cost = 1
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "grasp_lock"

/datum/heretic_knowledge/lock_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, PROC_REF(on_secondary_mansus_grasp))

/datum/heretic_knowledge/lock_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY)


/datum/heretic_knowledge/lock_grasp/proc/on_secondary_mansus_grasp(mob/living/source, atom/target)
	SIGNAL_HANDLER

	if(ismecha(target))
		var/obj/mecha/mecha = target
		mecha.dna = null
		mecha.operation_req_access = list()
		for(var/mob/living/occupant as anything in mecha.occupant)
			if(issilicon(occupant))
				continue
			INVOKE_ASYNC(src, PROC_REF(try_kick_out), mecha, occupant)
	else if(istype(target, /obj/machinery/door/airlock))
		INVOKE_ASYNC(src, PROC_REF(try_open_airlock), target)
	else if(istype(target, /obj/structure/closet))
		INVOKE_ASYNC(src, PROC_REF(try_open_closet), target)


	playsound(target, 'sound/magic/hereticknock.ogg', 100, TRUE, -1)

	return COMPONENT_USE_HAND

/datum/heretic_knowledge/lock_grasp/proc/try_open_airlock(obj/machinery/door/airlock/ourlock)
	ourlock.unlock()
	ourlock.open()

/datum/heretic_knowledge/lock_grasp/proc/try_open_closet(obj/structure/closet/C)
	if(istype(C, /obj/structure/closet/secure_closet))
		var/obj/structure/closet/secure_closet/SC = C
		SC.locked = FALSE
	C.open()

/datum/heretic_knowledge/lock_grasp/proc/try_kick_out(obj/mecha/mecha, mob/living/occupant)
	mecha.go_out(1)
	occupant.Weaken(5 SECONDS)


/datum/heretic_knowledge/key_ring
	name = "Key Keeper’s Burden"
	desc = "Allows you to transmute a wallet, an iron rod, and an ID card to create an Eldritch Card. \
		Hit a pair of airlocks with it to create a pair of portals, which will teleport you between them, but teleport non-heretics randomly. \
		You can ctrl-click the card to invert this behavior for created portals. \
		Each card may only sustain a single pair of portals at the same time. \
		It also functions and appears the same as a regular ID Card. \
		Attacking it with a normal ID card consumes it and gains its access, and you can use it in-hand to change its appearance to a card you fused. \
		Does not preserve the card originally used in the ritual."
	gain_text = "The Keeper sneered. \"These plastic rectangles are a mockery of keys, and I curse every door that desires them.\""
	required_atoms = list(
		/obj/item/storage/wallet = 1,
		/obj/item/stack/rods = 1,
		/obj/item/card/id = 1,
	)
	result_atoms = list(/obj/item/card/id/heretic)
	cost = 1
	research_tree_icon_path = 'icons/obj/card.dmi'
	research_tree_icon_state = "card_gold"
	/// passes the sacrificed ID's access to the card.
	var/list/accesses = list()

/datum/heretic_knowledge/key_ring/on_finished_recipe(mob/living/user, list/selected_atoms, turf/our_turf)
	if(!length(result_atoms))
		return FALSE
	for(var/obj/item/card/id/id in selected_atoms)
		accesses += id.access
	for(var/result in result_atoms)
		if(istype(result, /obj/item/card/id))
			var/obj/item/card/id/new_card = new result(our_turf)
			new_card.access = accesses
		else
			new result(our_turf)
	accesses = list()
	return TRUE

/datum/heretic_knowledge/mark/lock_mark
	name = "Mark of Lock"
	desc = "Your Mansus Grasp now applies the Mark of Lock. \
		Attack a marked person to bar them from all passages for the duration of the mark. \
		This will make it so that they have no access whatsoever, even public access doors will reject them."
	gain_text = "The Gatekeeper was a corrupt Steward. She hindered her fellows for her own twisted amusement."
	mark_type = /datum/status_effect/eldritch/lock

/datum/heretic_knowledge/knowledge_ritual/lock

/datum/heretic_knowledge/limited_amount/concierge_rite // item that creates 3 max at a time heretic only barriers, probably should limit to 1 only, holy people can also pass
	name = "Concierge's Rite"
	desc = "Allows you to transmute a crayon, a wooden plank, and a multitool to create a Labyrinth Handbook. \
		It can materialize a barricade at range that only you and people resistant to magic can pass. 3 uses."
	gain_text = "The Concierge scribbled my name into the Handbook. \"Welcome to your new home, fellow Steward.\""
	required_atoms = list(
		/obj/item/toy/crayon = 1,
		/obj/item/stack/sheet/wood = 1,
		/obj/item/multitool = 1,
	)
	result_atoms = list(/obj/item/heretic_labyrinth_handbook)
	limit = 2
	cost = 1
	research_tree_icon_path = 'icons/obj/library.dmi'
	research_tree_icon_state = "heretichandbook"

/datum/heretic_knowledge/spell/burglar_finesse
	name = "Burglar's Finesse"
	desc = "Grants you Burglar's Finesse, a single-target spell \
		that puts a random item from the victims backpack into your hand."
	gain_text = "Consorting with Burglar spirits is frowned upon, but a Steward will always want to learn about new doors."

	action_to_add = /datum/spell/pointed/burglar_finesse
	cost = 1

/datum/heretic_knowledge/blade_upgrade/flesh/lock //basically a chance-based limb opening
	name = "Opening Blade"
	desc = "Your blade has a chance to open an limb on attack."
	gain_text = "The Pilgrim-Surgeon was not an Steward. Nonetheless, its blades and sutures proved a match for their keys."
	research_tree_icon_state = "blade_upgrade_lock"
	var/chance = 35

/datum/heretic_knowledge/blade_upgrade/flesh/lock/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(prob(chance) && ishuman(target))
		var/obj/item/organ/external/lockbox = target.get_organ(source.zone_selected)
		lockbox.open = ORGAN_ORGANIC_VIOLENT_OPEN
		return ..()

/datum/heretic_knowledge/spell/caretaker_refuge
	name = "Caretaker’s Last Refuge"
	desc = "Gives you a spell that makes you transparent and not dense. Cannot be used near living sentient beings. \
		While in refuge, you cannot use your hands or spells, and you are immune to slowdown. \
		You are invincible but unable to harm anything. Cancelled by being hit with an anti-magic item."
	gain_text = "Jealously, the Guard and the Hound hunted me. But I unlocked my form, and was but a haze, untouchable."
	action_to_add = /datum/spell/caretaker
	cost = 1

/datum/heretic_knowledge/ultimate/lock_final
	name = "Unlock the Labyrinth"
	desc = "The ascension ritual of the Path of Knock. \
		Bring 3 corpses without organs in their torso to a transmutation rune to complete the ritual. \
		When completed, you will create a tear to the Labyrinth's heart; \
		a tear in reality located at the site of this ritual. \
		Eldritch creatures will endlessly pour from this rift \
		who are bound to obey your instructions, \
		and your keyblades will become even deadlier."
	gain_text = "The Stewards guided me, and I guided them. \
		My foes were the Locks and my blades were the Key! \
		The Labyrinth will be Locked no more, and freedom will be ours! WITNESS US!"
	required_atoms = list(/mob/living/carbon/human = 3)

	announcement_text = "Delta-class dimensional anomaly detec%SPOOKY% Reality rended, torn. Gates open, doors open, %NAME% has ascended! Fear the tide! %SPOOKY%"
	announcement_sound = 'sound/ambience/antag/heretic/ascend_knock.ogg'
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/ascension.dmi'
	research_tree_icon_state = "lockascend"

/datum/heretic_knowledge/ultimate/lock_final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/our_turf)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD)
			continue
		var/obj/item/organ/external/affecting = body.get_organ(BODY_ZONE_CHEST)
		if(length(affecting.contents))
			to_chat(user, SPAN_HIEROPHANT_WARNING("[body] has organs in their chest."))
			continue

		selected_atoms += body

	if(!LAZYLEN(selected_atoms))
		to_chat(user, SPAN_HIEROPHANT_WARNING("The ritual has failed, you do not have enough valid bodies."))
		return FALSE
	return TRUE

/datum/heretic_knowledge/ultimate/lock_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/our_turf)
	. = ..()
	// buffs
//	var/datum/spell/shapeshift/eldritch/ascension/transform_spell = new(user.mind)
//	user.mind.AddSpell(transform_spell) //qwertodo after tm, needs tweaks of shapeshift spell

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	var/datum/heretic_knowledge/blade_upgrade/flesh/lock/blade_upgrade = heretic_datum.get_knowledge(/datum/heretic_knowledge/blade_upgrade/flesh/lock)
	blade_upgrade.chance += 30
	new /obj/structure/lock_tear(our_turf, user.mind)
