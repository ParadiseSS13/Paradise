/obj/item/tome
	name = "arcane tome"
	desc = "An old, dusty tome with frayed edges and a sinister-looking cover."
	icon_state = "tome"
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL

/obj/item/tome/Initialize(mapload)
	. = ..()
	icon_state = GET_CULT_DATA(tome_icon, "tome")

/obj/item/melee/cultblade
	name = "cult blade"
	desc = "A powerful blade made of darkened metal. An aura of barely-perceptible red light seems to surround it."
	icon = 'icons/obj/cult.dmi'
	icon_state = "blood_blade"
	w_class = WEIGHT_CLASS_BULKY
	force = 30
	throwforce = 10
	sharp = TRUE
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sprite_sheets_inhand = list("Skrell" = 'icons/mob/clothing/species/skrell/held.dmi') // To stop skrell stabbing themselves in the head
	new_attack_chain = TRUE
	/// Can anyone use this cult tool? If true, anyone can use it. If false, only cult
	var/free_use = FALSE

/obj/item/melee/cultblade/Initialize(mapload)
	. = ..()
	icon_state = GET_CULT_DATA(sword_icon, "blood_blade")

/obj/item/melee/cultblade/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("This blade is a powerful weapon, capable of severing limbs easily. Nonbelievers are unable to use this weapon. Striking a nonbeliever after downing them with your cult magic will stun them completely.")

/obj/item/melee/cultblade/pre_attack(atom/target, mob/living/user, params)
	if(..())
		return FINISH_ATTACK

	if(!IS_CULTIST(user) && !free_use)
		user.Weaken(10 SECONDS)
		user.drop_item_to_ground(src, force = TRUE)
		user.visible_message(SPAN_WARNING("A powerful force shoves [user] away from [target]!"),
							SPAN_CULTLARGE("\"You shouldn't play with sharp things. You'll poke someone's eye out.\""))
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(rand(force/2, force), BRUTE, pick("l_arm", "r_arm"))
		else
			user.adjustBruteLoss(rand(force/2, force))

		return FINISH_ATTACK

/obj/item/melee/cultblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(..())
		return FINISH_ATTACK

	if(!IS_CULTIST(target))
		var/datum/status_effect/cult_stun_mark/S = target.has_status_effect(STATUS_EFFECT_CULT_STUN)
		if(S)
			S.trigger()

/obj/item/melee/cultblade/pickup(mob/living/user)
	. = ..()
	if(!IS_CULTIST(user) && !free_use)
		to_chat(user, SPAN_CULTLARGE("\"I wouldn't advise that.\""))
		to_chat(user, SPAN_WARNING("An overwhelming sense of nausea overpowers you!"))
		user.Confused(20 SECONDS)
		user.Jitter(12 SECONDS)

	if(HAS_TRAIT(user, TRAIT_HULK))
		to_chat(user, SPAN_DANGER("You can't seem to hold the blade properly!"))
		user.drop_item_to_ground(src, force = TRUE)


#define WIELDER_SPELLS "wielder_spell"
#define SWORD_SPELLS "sword_spell"
#define SWORD_PREFIX "sword_prefix"

/obj/item/melee/cultblade/haunted
	name = "haunted longsword"
	desc = "An eerie sword with a blade that is less 'black' than it is 'absolute nothingness'. It glows with furious, restrained green energy."
	icon_state = "hauntedblade"
	inhand_icon_state = "hauntedblade"
	throwforce = 25
	free_use = TRUE
	light_color = COLOR_HERETIC_GREEN
	light_range = 3
	sprite_sheets_inhand = null
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	/// holder for the actual action when created.
	var/list/datum/spell/path_sword_actions
	/// holder for the actual action when created.
	var/list/datum/spell/path_wielder_actions
	var/mob/living/trapped_entity
	/// The heretic path that the variable below uses to index abilities. Assigned when the heretic is ensouled.
	var/heretic_path
	/// If the blade is bound, it cannot utilize its abilities, but neither can its wielder. They must unbind it to use it to its full potential.
	var/bound = TRUE
	/// Are we in the process of binding the blade?
	var/binding = FALSE
	/// Nested static list used to index abilities and names.
	var/static/list/heretic_paths_to_haunted_sword_abilities = list(
		// Ash
		PATH_ASH = list(
			WIELDER_SPELLS = list(/datum/spell/ethereal_jaunt/ash),
			SWORD_SPELLS = list(/datum/spell/pointed/ash_beams),
			SWORD_PREFIX = "ashen",
		),
		// Flesh
		PATH_FLESH = list(
			WIELDER_SPELLS = list(/datum/spell/pointed/blood_siphon),
			SWORD_SPELLS = list(/datum/spell/pointed/cleave),
			SWORD_PREFIX = "sanguine",
		),
		// Void
		PATH_VOID = list(
			WIELDER_SPELLS = list(/datum/spell/pointed/void_phase),
			SWORD_SPELLS = list(/datum/spell/pointed/void_prison),
			SWORD_PREFIX = "tenebrous",
		),
		// Blade
		PATH_BLADE = list(
			WIELDER_SPELLS = list(/datum/spell/fireball/furious_steel/haunted),
			SWORD_SPELLS = list(/datum/spell/fireball/furious_steel/solo),
			SWORD_PREFIX = "keen",
		),
		// Rust
		PATH_RUST = list(
			WIELDER_SPELLS = list(/datum/spell/cone/staggered/entropic_plume),
			SWORD_SPELLS = list(/datum/spell/aoe/rust_conversion, /datum/spell/pointed/rust_construction),
			SWORD_PREFIX = "rusted",
		),
		// Cosmic
		PATH_COSMIC = list(
			WIELDER_SPELLS = list(/datum/spell/aoe/conjure/cosmic_expansion),
			SWORD_SPELLS = list(/datum/spell/fireball/star_blast),
			SWORD_PREFIX = "astral",
		),
		// Lock
		PATH_LOCK = list(
			WIELDER_SPELLS = list(/datum/spell/pointed/burglar_finesse),
			SWORD_SPELLS = list(/datum/spell/pointed/apetra_vulnera),
			SWORD_PREFIX = "incisive",
		),
		// Moon
		PATH_MOON = list(
			WIELDER_SPELLS = list(/datum/spell/fireball/moon_parade),
			SWORD_SPELLS = list(/datum/spell/pointed/moon_smile),
			SWORD_PREFIX = "shimmering",
		),
		// Starter
		PATH_START = list(
			WIELDER_SPELLS = null,
			SWORD_SPELLS = null,
			SWORD_PREFIX = "stillborn", // lol loser
		) ,
	)
	actions_types = list(/datum/action/item_action/haunted_blade)

/obj/item/melee/cultblade/haunted/examine(mob/user)
	. = ..()

	var/examine_text = ""
	if(bound)
		examine_text = "[src] shines a dull, sickly green, the power emanating from it clearly bound by the runes on its blade. You could unbind it, and wield its fearsome power. But is it worth loosening the bindings of the spirit inside?"
	else
		examine_text = "[src] flares a bright and malicious pale lime shade. Someone has unbound the spirit within, and power now clearly resonates from inside the blade, barely restrained and brimming with fury. You may attempt to bind it once more, sealing the horror, or try to harness its strength as a blade."

	. += SPAN_CULT("[examine_text]")

/datum/action/item_action/haunted_blade
	name = "Unseal Spirit" // img is of a chained shade
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "spirit_sealed"

/datum/action/item_action/haunted_blade/build_button_icon(atom/movable/screen/movable/action_button/button, status_only, force)
	var/obj/item/melee/cultblade/haunted/blade = target
	if(istype(blade))
		button_icon_state = "spirit_[blade.bound ? "sealed" : "unsealed"]"
		name = "[blade.bound ? "Unseal" : "Seal"] Spirit"

	return ..()

/obj/item/melee/cultblade/haunted/ui_action_click(mob/living/user, actiontype)
	if(binding)
		return // gtfo
	if(bound)
		unbind_blade(user)
		return
	binding = TRUE
	if(HAS_MIND_TRAIT(user, TRAIT_HOLY))
		on_priest_handle(user)
	else if(IS_CULTIST(user))
		on_cultist_handle(user)
	else if(IS_HERETIC_OR_MONSTER(user))
		on_heresy_handle(user)
	else if(iswizard(user))
		on_wizard_handle(user)
	else
		on_normie_handle(user)
	return

/obj/item/melee/cultblade/haunted/proc/on_priest_handle(mob/living/user, actiontype)
	user.visible_message(SPAN_CULT("You begin chanting the holy hymns of [GET_CULT_DATA(entity_name, "Nar'Sie")]..."),\
		SPAN_CULT(SPAN_CULT("[user] begins chanting while holding [src] aloft...")))
	if(!do_after(user, 6 SECONDS, src))
		to_chat(user, SPAN_NOTICE("You were interrupted!"))
		binding = FALSE
		return
	playsound(user, 'sound/effects/pray_chaplain.ogg',60,TRUE)
	rebind_blade(user)
	return TRUE

/obj/item/melee/cultblade/haunted/proc/on_cultist_handle(mob/living/user, actiontype)
	var/binding_implements = list(/obj/item/melee/cultblade/dagger, /obj/item/melee/sickly_blade/cursed)
	if(!user.is_holding_item_of_types(binding_implements))
		to_chat(user, SPAN_NOTICE("You need to hold a ritual dagger to bind [src]!"))
		binding = FALSE
		return

	user.visible_message(SPAN_CULT("[user] begins slicing open [user.p_their()] palm on top of [src]..."),\
		SPAN_CULT("You begin slicing open your palm on top of [src]..."))
	if(!do_after(user, 6 SECONDS, src))
		binding = FALSE
		to_chat(user, SPAN_NOTICE("You were interrupted!"))
		return
	playsound(user, 'sound/weapons/bladeslice.ogg', 30, TRUE)
	rebind_blade(user)
	return TRUE

/obj/item/melee/cultblade/haunted/proc/on_heresy_handle(mob/living/user, actiontype)
	var/binding_implements = list(/obj/item/clothing/neck/eldritch_amulet, /obj/item/clothing/neck/heretic_focus)
	if(!user.is_holding_item_of_types(binding_implements))
		to_chat(user, SPAN_NOTICE("You need to hold a focus to bind [src]!"))
		binding = FALSE
		return

	user.visible_message(SPAN_CULT("You channel the Mansus through your focus, empowering the sealing runes..."), SPAN_CULT("[user] holds up their eldritch focus on top of [src] and begins concentrating..."))
	if(!do_after(user, 6 SECONDS, src))
		binding = FALSE
		to_chat(user, SPAN_NOTICE("You were interrupted!"))
		return
	rebind_blade(user)
	return TRUE

/obj/item/melee/cultblade/haunted/proc/on_wizard_handle(mob/living/user, actiontype)
	user.visible_message(SPAN_CULT("You begin quickly and nimbly casting the sealing runes."), SPAN_CULT("[user] begins tracing anti-light runes on [src]..."))
	if(!do_after(user, 3 SECONDS, src))
		binding = FALSE
		to_chat(user, SPAN_NOTICE("You were interrupted!"))
		return
	return TRUE

/obj/item/melee/cultblade/haunted/proc/on_normie_handle(mob/living/user, actiontype)
	var/binding_implements = list(/obj/item/storage/bible)
	if(!user.is_holding_item_of_types(binding_implements))
		to_chat(user, SPAN_NOTICE("You need to wield a bible to bind [src]!"))
		binding = FALSE
		return

	var/passage = "[pick(GLOB.first_names_male)] [rand(1,9)]:[rand(1,25)]" // Space Bibles will have Alejandro 9:21 passages, as part of the Very New Testament.
	user.visible_message(SPAN_CULT("You start reading aloud the passage in [passage]..."), SPAN_CULT("[user] starts reading aloud the passage in [passage]..."))
	if(!do_after(user, 12 SECONDS, src))
		binding = FALSE
		to_chat(user, SPAN_NOTICE("You were interrupted!"))
		return
	rebind_blade(user)
	return TRUE


/obj/item/melee/cultblade/haunted/proc/unbind_blade(mob/user)
	var/holup = tgui_alert(user, "Are you sure you wish to unseal the spirit within?", "Sealed Evil In A Jar", list("I need the power!", "Maybe not..."))
	if(holup != "I need the power!")
		return
	to_chat(user, SPAN_CULT("You start focusing on the power of the blade, letting it guide your fingers along the inscribed runes..."))
	if(!do_after(user, 5 SECONDS, src))
		to_chat(user, SPAN_NOTICE("You were interrupted!"))
		return
	visible_message(SPAN_DANGER("[user] has unbound [src]!"))
	bound = FALSE
	for(var/datum/spell/sword_spell as anything in path_sword_actions)
		trapped_entity.AddSpell(sword_spell)
	for(var/datum/spell/wielder_spell as anything in path_wielder_actions)
		user.AddSpell(wielder_spell)
	free_use = TRUE
	force += 5
	armor_penetration_flat += 10
	light_range += 3

	playsound(src ,'sound/spookoween/insane_low_laugh.ogg', 200, TRUE) //quiet
	binding_filters_update()
	AddElement(/datum/element/heretic_focus)

/obj/item/melee/cultblade/haunted/proc/rebind_blade(mob/user)
	visible_message(SPAN_DANGER("[user] has bound [src]!"))
	binding = FALSE
	bound = TRUE
	force -= 5
	armor_penetration_flat -= 10
	free_use = FALSE // it's a cult blade and you sealed away the other power.
	light_range -= 3
	for(var/datum/spell/sword_spell as anything in path_sword_actions)
		trapped_entity.RemoveSpell(sword_spell)
	for(var/datum/spell/wielder_spell as anything in path_wielder_actions)
		user.RemoveSpell(wielder_spell)

	playsound(src ,'sound/hallucinations/wail.ogg', 20, TRUE)	// add BOUND alert and UNBOUND
	rebuild_spells()
	binding_filters_update()
	RemoveElement(/datum/element/heretic_focus)

/obj/item/melee/cultblade/haunted/Initialize(mapload, mob/soul_to_bind, mob/awakener, do_bind = TRUE)
	. = ..()
	icon_state = GET_CULT_DATA(haunted_longsword, "hauntedblade")
	inhand_icon_state = GET_CULT_DATA(haunted_longsword, "hauntedblade")
	AddElement(/datum/element/heretic_focus)
	if(do_bind && !mapload)
		bind_soul(soul_to_bind, awakener)
	binding_filters_update()
	addtimer(CALLBACK(src, PROC_REF(start_glow_loop)), rand(0.1 SECONDS, 1.9 SECONDS))
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.4, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = (5 / 3) SECONDS) // 0.666667 seconds for 60% uptime.

/obj/item/melee/cultblade/haunted/proc/bind_soul(mob/soul_to_bind, mob/awakener)

	var/datum/mind/trapped_mind = soul_to_bind?.mind

	if(!trapped_mind)
		return // Can't do anything further down the list

	trapped_entity = new/mob/living/simple_animal/shade/sword/generic_item(src)
	trapped_entity.name = soul_to_bind.name

	// Get the heretic's new body and antag datum.
	trapped_entity.key = trapped_mind.key
	trapped_entity.mind = trapped_mind
	var/datum/antagonist/heretic/heretic_holder = IS_HERETIC(trapped_entity)
	if(!heretic_holder)
		stack_trace("[soul_to_bind] in but not a heretic on the heretic soul blade.")

	// Set the sword's path for spell selection.
	heretic_path = heretic_holder.heretic_path

	trapped_entity.mind.remove_antag_datum(/datum/antagonist/heretic)

	// Add the fallen antag datum, give them a heads-up of what's happening.
	var/datum/antagonist/soultrapped_heretic/bozo = new()
	trapped_entity.mind.add_antag_datum(bozo)

	// Assigning the spells to give to the wielder and spirit.
	// Let them cast the given spell.
	ADD_TRAIT(trapped_entity, TRAIT_ALLOW_HERETIC_CASTING, INNATE_TRAIT)

	var/list/path_spells = heretic_paths_to_haunted_sword_abilities[heretic_path]

	name = "[path_spells[SWORD_PREFIX]] [name]"


	rebuild_spells()

	binding_filters_update()

/obj/item/melee/cultblade/haunted/equipped(mob/user, slot, initial)
	. = ..()
	if((!(slot & ITEM_SLOT_BOTH_HANDS)) || bound)
		return
	for(var/datum/spell/wielder_spell in path_wielder_actions)
		user.AddSpell(wielder_spell)
	binding_filters_update()

/obj/item/melee/cultblade/haunted/dropped(mob/user, silent)
	. = ..()
	for(var/datum/spell/wielder_spell in path_wielder_actions)
		user.RemoveSpell(wielder_spell)
	rebuild_spells(wielder_only = TRUE)
	binding_filters_update()

/obj/item/melee/cultblade/haunted/proc/rebuild_spells(wielder_only = FALSE)
	var/list/path_spells = heretic_paths_to_haunted_sword_abilities[heretic_path]
	var/list/wielder_spells = path_spells[WIELDER_SPELLS]
	var/list/sword_spells = path_spells[SWORD_SPELLS]
	if(!wielder_only)
		QDEL_LIST_CONTENTS(path_sword_actions)
	QDEL_LIST_CONTENTS(path_wielder_actions)
	// Creating the path spells.
	// The sword is created bound - so we do not grant it the spells just yet, but we still create and store them.

	if(sword_spells && !wielder_only)
		for(var/datum/spell/sword_spell as anything in sword_spells)
			var/datum/spell/instanced_spell = new sword_spell(trapped_entity)
			LAZYADD(path_sword_actions, instanced_spell)
			instanced_spell.overlay_icon_state = "bg_cult_border" // for flavor, and also helps distinguish

	if(wielder_spells)
		for(var/datum/spell/wielder_spell as anything in wielder_spells)
			var/datum/spell/instanced_spell = new wielder_spell(trapped_entity)
			LAZYADD(path_wielder_actions, instanced_spell)
			instanced_spell.overlay_icon_state = "bg_cult_border"


/obj/item/melee/cultblade/haunted/proc/binding_filters_update(mob/user)

	var/h_color = heretic_path ? GLOB.heretic_path_to_color[heretic_path] : "#FF00FF"

	// on bound
	if(bound)
		add_filter("bind_glow", 2, list("type" = "outline", "color" = h_color, "size" = 0.1))
		remove_filter("unbound_ray")
		update_filters()
	// on unbound
	else
		// we re-add this every time it's picked up or dropped
		remove_filter("unbound_ray")
		add_filter(name = "unbound_ray", priority = 1, params = list(
			type = "rays",
			size = 16,
			color = COLOR_HERETIC_GREEN, // the sickly green of the heretic leaking through
			density = 16,
		))
		// because otherwise the animations stack and it looks ridiculous
		var/ray_filter = get_filter("unbound_ray")
		animate(ray_filter, offset = 100, time = 2 MINUTES, loop = -1, flags = ANIMATION_PARALLEL) // Absurdly long animate so nobody notices it hitching when it loops
		animate(offset = 0, time = 2 MINUTES) // I sure hope duration of animate doesnt have any performance effect

	update_filters()

/obj/item/melee/cultblade/haunted/proc/start_glow_loop()
	var/filter = get_filter("bind_glow")
	if(!filter)
		return

	animate(filter, alpha = 110, time = 1.5 SECONDS, loop = -1)
	animate(alpha = 40, time = 2.5 SECONDS)

/obj/item/melee/cultblade/haunted/proc/handle_haunted_movement()
	if(!isliving(loc))
		return TRUE
	if(bound)
		to_chat(trapped_entity, SPAN_WARNING("You are bound, and unable to move! Try to get someone to unbind you!"))
		return FALSE

	var/mob/loccer = loc
	var/resist_chance = 20
	var/fail_text = "You struggle, but [loccer] keeps [loccer.p_their()] grip on you!"
	var/particle_to_spawn = null
	if(IS_CULTIST(loccer))
		resist_chance = 5 // your mastahs
		fail_text = "You struggle, but [loccer]'s grip is unnaturally hard to resist!"
		particle_to_spawn = /obj/effect/temp_visual/cult/sparks
	if(IS_HERETIC_OR_MONSTER(loccer))
		resist_chance = 10
		fail_text = "You struggle, but [loccer] deftly handles the grip movement."
		particle_to_spawn = /obj/effect/temp_visual/revenant
	if(HAS_MIND_TRAIT(loccer, TRAIT_HOLY))
		resist_chance = 6
		fail_text = "You struggle, but [loccer]'s holy grip holds tight against your thrashing."
		particle_to_spawn = null
	if(iswizard(loccer))
		resist_chance = 3 // magic master
		fail_text = "You struggle, but [loccer]'s handle on magic easily neutralizes your movement."
		particle_to_spawn = /obj/effect/particle_effect/sparks

	new particle_to_spawn(get_turf(loccer))

	if(prob(resist_chance))
		return TRUE
		// flung by later code
	else
		to_chat(trapped_entity, SPAN_WARNING("[fail_text]"))
		return FALSE


#undef WIELDER_SPELLS
#undef SWORD_SPELLS
#undef SWORD_PREFIX

/obj/item/restraints/legcuffs/bola/cult
	name = "runed bola"
	desc = "A bola, crafted of dark metal and sinuous cords. The inscriptions covering the weights prevent it from striking the Faithful."
	icon_state = "bola_cult"
	breakouttime = 45
	knockdown_duration = 2 SECONDS

/obj/item/restraints/legcuffs/bola/cult/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback)
	if(thrower && !IS_CULTIST(thrower)) // A couple of objs actually proc throw_at, so we need to make sure that yes, we got tossed by a person before trying to send a message
		thrower.visible_message(SPAN_DANGER("The bola glows, and boomarangs back at [thrower]!"))
		throw_impact(thrower)
		return
	. = ..()

/obj/item/restraints/legcuffs/bola/cult/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(IS_CULTIST(hit_atom))
		hit_atom.visible_message(SPAN_WARNING("[src] bounces off of [hit_atom], as if repelled by an unseen force!"))
		return
	. = ..()

/obj/item/clothing/head/hooded/culthood
	name = "cult hood"
	icon_state = "culthood"
	desc = "An armored hood reinforced with dark metal and covered with esoteric inscriptions urging you toward martyrdom. Serve your purpose."
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	flags_cover = HEADCOVERSEYES
	armor = list(MELEE = 20, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 5, ACID = 5)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	magical = TRUE
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hood.dmi'

/obj/item/clothing/head/hooded/culthood/alt
	icon_state = "cult_hoodalt"

/obj/item/clothing/suit/hooded/cultrobes
	name = "cult robes"
	desc = "A set of armored robes worn by the followers of a cult."
	icon_state = "cultrobes"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/culthood
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor = list(MELEE = 35, BULLET = 20, LASER = 35, ENERGY = 10, BOMB = 15, RAD = 0, FIRE = 5, ACID = 5)
	flags_inv = HIDEJUMPSUIT
	magical = TRUE

/obj/item/clothing/suit/hooded/cultrobes/alt
	icon_state = "cultrobesalt"
	hoodtype = /obj/item/clothing/head/hooded/culthood/alt

/obj/item/clothing/head/helmet/space/cult
	name = "cult helmet"
	desc = "A space worthy helmet used by the followers of a cult."
	icon_state = "cult_helmet"
	armor = list(MELEE = 115, BULLET = 50, LASER = 20, ENERGY = 10, BOMB = 20, RAD = 20, FIRE = 35, ACID = 150)
	magical = TRUE
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/obj/item/clothing/suit/space/cult
	name = "cult armor"
	icon_state = "cult_armour"
	desc = "A bulky suit of armor, bristling with spikes. It looks space proof."
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade, /obj/item/tank/internals)
	armor = list(MELEE = 115, BULLET = 50, LASER = 20, ENERGY = 10, BOMB = 20, RAD = 20, FIRE = 35, ACID = 150)
	magical = TRUE
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/suit.dmi')

/obj/item/clothing/suit/hooded/cultrobes/cult_shield
	name = "empowered cultist robes"
	desc = "An imposing set of armored robes, heavily reinforced with dark metal. Strange sigils and glyphs cover the suit, crackling with unholy power."
	icon_state = "cult_armour"
	w_class = WEIGHT_CLASS_BULKY
	armor = list(MELEE = 50, BULLET = 35, LASER = 50, ENERGY = 20, BOMB = 50, RAD = 20, FIRE = 50, ACID = 75)
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie

/obj/item/clothing/head/hooded/cult_hoodie
	name = "empowered cultist hood"
	desc = "An armored hood, heavily reinforced with dark metal. The inscriptions covering the interior fill you with confidence and determination."
	icon_state = "cult_hoodalt"
	armor = list(MELEE = 35, BULLET = 20, LASER = 35, ENERGY = 10, BOMB = 15, RAD = 0, FIRE = 5, ACID = 5)
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	flags_cover = HEADCOVERSEYES
	magical = TRUE

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/equipped(mob/living/user, slot)
	..()
	if(!IS_CULTIST(user)) // Todo: Make this only happen when actually equipped to the correct slot. (For all cult items)
		to_chat(user, SPAN_CULTLARGE("\"I wouldn't advise that.\""))
		to_chat(user, SPAN_WARNING("An overwhelming sense of nausea overpowers you!"))
		user.drop_item_to_ground(src, force = TRUE)
		user.Confused(20 SECONDS)
		user.Weaken(10 SECONDS)


/obj/item/clothing/suit/hooded/cultrobes/cult_shield/setup_shielding()
	AddComponent(/datum/component/shielded, recharge_start_delay = 0 SECONDS, shield_icon_file = 'icons/effects/cult_effects.dmi', shield_icon = "shield-cult", run_hit_callback = CALLBACK(src, PROC_REF(shield_damaged)))

/// A proc for callback when the shield breaks, since cult robes are stupid and have different effects
/obj/item/clothing/suit/hooded/cultrobes/cult_shield/proc/shield_damaged(mob/living/wearer, attack_text, new_current_charges)
	wearer.visible_message(SPAN_DANGER("[attack_text] is deflected in a burst of blood-red sparks!"))
	new /obj/effect/temp_visual/cult/sparks(get_turf(wearer))
	if(new_current_charges == 0)
		wearer.visible_message(SPAN_DANGER("The runed shield around [wearer] suddenly disappears!"))

/obj/item/clothing/suit/hooded/cultrobes/flagellant_robe
	name = "flagellant's robes"
	desc = "A set of blood-soaked robes inscribed with unholy sigils. Wearing them greatly increases movement speed, but the cursed fabrics will take an additional tithe when the wearer is hit."
	icon_state = "flagellantrobe"
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor = list(MELEE = -25, BULLET = -25, LASER = -25, ENERGY = -25, BOMB = -25, RAD = -25, FIRE = 0, ACID = 0)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
		)
	hoodtype = /obj/item/clothing/head/hooded/flagellant_hood


/obj/item/clothing/suit/hooded/cultrobes/flagellant_robe/equipped(mob/living/user, slot)
	..()
	if(!IS_CULTIST(user))
		to_chat(user, SPAN_CULTLARGE("\"I wouldn't advise that.\""))
		to_chat(user, SPAN_WARNING("An overwhelming sense of nausea overpowers you!"))
		user.drop_item_to_ground(src, force = TRUE)
		user.Confused(20 SECONDS)
		user.Weaken(10 SECONDS)
	else if(slot == ITEM_SLOT_OUTER_SUIT)
		ADD_TRAIT(user, TRAIT_GOTTAGOFAST, "cultrobes[UID()]")

/obj/item/clothing/suit/hooded/cultrobes/flagellant_robe/dropped(mob/user)
	. = ..()
	if(user)
		REMOVE_TRAIT(user, TRAIT_GOTTAGOFAST, "cultrobes[UID()]")

/obj/item/clothing/head/hooded/flagellant_hood
	name = "flagellant's robes"
	desc = "A blood-soaked hood inscribed with unholy sigils. The interior is covered in small barbs, reminding you of your duty."
	icon_state = "flagellanthood"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	flags_cover = HEADCOVERSEYES
	armor = list(MELEE = -25, BULLET = -25, LASER = -25, ENERGY = -25, BOMB = -25, RAD = -25, FIRE = 0, ACID = 0)
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hood.dmi'
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
		)

/obj/item/whetstone/cult
	name = "eldritch whetstone"
	desc = "A block of dark, cracked metal, criss-crossed by glowing lines of unholy power. The block can grant any blade a razor's edge, but is unlikely to survive imbuement."
	icon_state = "cult_sharpener"
	increment = 5
	max = 40
	prefix = "darkened"
	claw_damage_increase = 4

/obj/item/whetstone/cult/update_icon_state()
	icon_state = "cult_sharpener[used ? "_used" : ""]"

/obj/item/whetstone/cult/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	..()
	if(used)
		to_chat(user, SPAN_NOTICE("[src] crumbles to ashes."))
		qdel(src)

/obj/item/reagent_containers/drinks/bottle/unholywater
	name = "flask of unholy water"
	desc = "A small flask made of darkened glass, and covered with minute inscriptions. The dark liquid within rejuvenates believers, and scalds the faithless."
	icon_state = "holyflask"
	color = "#333333"
	list_reagents = list("unholywater" = 40)

/obj/item/clothing/glasses/hud/health/night/cultblind
	name = "zealot's blindfold"
	desc = "A thick blindfold made of dark cloth. The runes and sigils sewn into the fabric amplify the vision of the faithful."
	icon_state = "blindfold"
	invis_override = SEE_INVISIBLE_HIDDEN_RUNES
	flash_protect = FLASH_PROTECTION_FLASH
	prescription = TRUE
	origin_tech = null

/obj/item/clothing/glasses/hud/health/night/cultblind/equipped(mob/living/user, slot)
	..()
	if(!IS_CULTIST(user))
		to_chat(user, SPAN_CULTLARGE("\"You want to be blind, do you?\""))
		user.drop_item_to_ground(src, force = TRUE)
		user.Confused(60 SECONDS)
		user.Weaken(10 SECONDS)
		user.EyeBlind(60 SECONDS)

/obj/item/shuttle_curse
	name = "cursed orb"
	desc = "A small metal orb, crackling with the power of a barely-restrained curse. Crushing the orb will unleash its energy, targeting the vessel which attempts to save the station from its fate."
	icon = 'icons/obj/cult.dmi'
	icon_state ="shuttlecurse"
	var/global/curselimit = 0

/obj/item/shuttle_curse/attack_self__legacy__attackchain(mob/living/user)
	if(!IS_CULTIST(user))
		user.drop_item_to_ground(src, force = TRUE)
		user.Weaken(10 SECONDS)
		to_chat(user, SPAN_WARNING("A powerful force shoves you away from [src]!"))
		return
	if(curselimit > 1)
		to_chat(user, SPAN_NOTICE("We have exhausted our ability to curse the shuttle."))
		return
	if(locate(/obj/singularity/narsie) in GLOB.poi_list || locate(/mob/living/basic/demon/slaughter/cult) in GLOB.mob_list)
		to_chat(user, SPAN_DANGER("Nar'Sie or her avatars are already on this plane, there is no delaying the end of all things."))
		return

	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/cursetime = 3 MINUTES
		var/timer = SSshuttle.emergency.timeLeft(1) + cursetime
		SSshuttle.emergency.setTimer(timer)
		to_chat(user,SPAN_DANGER("You shatter the orb! A dark essence spirals into the air, then disappears."))
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 50, TRUE)
		curselimit++
		var/message = pick(CULT_CURSES)
		GLOB.major_announcement.Announce("[message] The shuttle will be delayed by [cursetime / 600] minute\s.", "System Failure", 'sound/misc/notice1.ogg')
		qdel(src)

/obj/item/cult_shift
	name = "veil shifter"
	desc = "A small rod of black metal, surrounded by red crystals that blaze with unholy power. The relic can shift the faithful forward in space with little more than a thought."
	icon = 'icons/obj/cult.dmi'
	icon_state ="shifter"
	var/uses = 4

/obj/item/cult_shift/examine(mob/user)
	. = ..()
	if(uses)
		. += SPAN_CULT("It has [uses] use\s remaining.")
	else
		. += SPAN_CULT("It seems drained.")

/obj/item/cult_shift/proc/handle_teleport_grab(turf/T, mob/user)
	var/mob/living/carbon/C = user
	if(C.pulling)
		var/atom/movable/pulled = C.pulling
		var/turf/turf_behind = get_turf(get_step(T, turn(C.dir, 180)))
		if(SEND_SIGNAL(pulled, COMSIG_MOVABLE_TELEPORTING, turf_behind) & COMPONENT_BLOCK_TELEPORT)
			return FALSE
		if(!pulled.anchored) //Item may have been anchored while pulling, and pulling state isn't updated until you move away, so we double check.
			pulled.forceMove(turf_behind)
			. = pulled

/obj/item/cult_shift/attack_self__legacy__attackchain(mob/user)

	if(!uses || !iscarbon(user))
		to_chat(user, SPAN_WARNING("[src] is dull and unmoving in your hands."))
		return
	if(!IS_CULTIST(user))
		user.drop_item_to_ground(src, force = TRUE)
		step(src, pick(GLOB.alldirs))
		to_chat(user, SPAN_WARNING("[src] flickers out of your hands, too eager to move!"))
		return
	if(SEND_SIGNAL(user, COMSIG_MOVABLE_TELEPORTING, get_turf(user)) & COMPONENT_BLOCK_TELEPORT)
		return FALSE
	if(user.holy_check())
		return
	var/outer_tele_radius = 9

	var/mob/living/carbon/C = user
	var/list/turfs = list()
	for(var/turf/T in orange(user, outer_tele_radius))
		if(!is_teleport_allowed(T.z))
			break
		if(get_dir(C, T) != C.dir) // This seems like a very bad way to do this
			continue
		if(isspaceturf(T))
			continue
		if(T.x > world.maxx-outer_tele_radius || T.x < outer_tele_radius)
			continue	//putting them at the edge is dumb
		if(T.y > world.maxy-outer_tele_radius || T.y < outer_tele_radius)
			continue
		turfs += T

	if(length(turfs))
		uses--
		var/turf/mobloc = get_turf(C)
		var/turf/destination = pick(turfs)
		if(uses <= 0)
			icon_state = "shifter_drained"
		playsound(src, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		new /obj/effect/temp_visual/dir_setting/cult/phase/out(mobloc, C.dir)

		handle_teleport_grab(destination, C)
		C.forceMove(destination)

		new /obj/effect/temp_visual/dir_setting/cult/phase(destination, C.dir)
		playsound(destination, 'sound/effects/phasein.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		playsound(destination, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

	else
		to_chat(C, SPAN_DANGER("The veil cannot be torn here!"))

/obj/item/melee/cultblade/ghost
	name = "eldritch sword"
	force = 15
	flags = NODROP | DROPDEL

/obj/item/clothing/head/hooded/culthood/alt/ghost
	flags = NODROP | DROPDEL

/obj/item/clothing/suit/cultrobesghost
	name = "ghostly cult robes"
	desc = "A set of ethereal armored robes worn by the undead followers of a cult."
	icon_state = "cultrobesalt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor = list(MELEE = 50, BULLET = 20, LASER = 50, ENERGY = 10, BOMB = 15, RAD = 0, FIRE = 5, ACID = 5)
	flags_inv = HIDEJUMPSUIT
	flags = NODROP | DROPDEL


/obj/item/clothing/shoes/cult/ghost
	flags = NODROP | DROPDEL

/obj/item/clothing/under/color/black/ghost
	flags = NODROP | DROPDEL

/datum/outfit/ghost_cultist
	name = "Cultist Ghost"

	uniform = /obj/item/clothing/under/color/black/ghost
	suit = /obj/item/clothing/suit/cultrobesghost
	shoes = /obj/item/clothing/shoes/cult/ghost
	head = /obj/item/clothing/head/hooded/culthood/alt/ghost
	r_hand = /obj/item/melee/cultblade/ghost

/obj/item/shield/mirror
	name = "mirror shield"
	desc = "A small shield of polished metal. The surface glows with eldritch power, and is capable of reflecting incoming attacks."
	icon = 'icons/obj/cult.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "mirror_shield"
	force = 5
	throwforce = 15
	throw_speed = 1
	throw_range = 3
	attack_verb = list("bumped", "prodded")
	hitsound = 'sound/weapons/smash.ogg'
	/// Chance that energy projectiles will be reflected
	var/reflect_chance = 70
	/// The number of clone illusions remaining
	var/illusions = 2

	// Any damage higher than these values will have a chance to shatter the shield
	/// Shatter threshold for Ballistic weapons
	var/ballistic_threshold = 10
	/// Shatter threshold for Energy weapons
	var/energy_threshold = 20

/obj/item/shield/mirror/Initialize(mapload)
	. = ..()
	GLOB.mirrors += src

/obj/item/shield/mirror/Destroy()
	GLOB.mirrors -= src
	return ..()

/**
  * Reflect/Block/Shatter proc.
  *
  * Projectiles:
  * If you have been hit by a projectile, the 'threshold' will be set depending on the damage type.
  * By default, energy weapons have a 70% chance of being reflected, so you're going to want to use ballistics against mirror shields. (Reflection is calculated beforehand in [/mob/living/carbon/human/bullet_act])
  * For every point of damage above the threshold, the shield will have a 3% chance to shatter. (Up to a maximum of 75%)
  * If a ballistic projectile doesn't shatter the shield, it will move on to the melee section.
  *
  * Melee and blocked projectiles:
  * Melee attacks and bullets have a 50|50 chance of being blocked by the mirror shield. (Based on the 'block_chance' variable)
  * If they are blocked, and the shield has an illusion charge, an illusion will be spawned at src.
  * The illusion has a 60% chance to be hostile and attack non-cultists, and a 40% chance to just run away from the user.
  */
/obj/item/shield/mirror/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	// Incase they get one by some magic
	if(!SSticker.mode.cult_team.mirror_shields_active)
		to_chat(owner, SPAN_WARNING("This shield is powerless! You must perform the required sacrifice to empower it!"))
		return

	if(IS_CULTIST(owner) && !owner.holy_check()) // Cultist holding the shield

		// Hit by a projectile
		if(isprojectile(hitby))
			var/obj/projectile/P = hitby
			var/shatter_chance = 0 // Percent chance of the shield shattering on a projectile hit
			var/threshold // Depends on the damage Type (Brute or Burn)
			if(P.damage_type == BRUTE)
				threshold = ballistic_threshold
			else if(P.damage_type == BURN)
				threshold = energy_threshold
			else
				return FALSE
			// Assuming the projectile damage is 20 (WT-550), 'shatter_chance' will be 10
			// 10 * 3 gives it a 30% chance to shatter per hit.
			shatter_chance = min((P.damage - threshold) * 3, 75) // Maximum of 75% chance

			if(prob(shatter_chance) || P.shield_buster)
				var/turf/T = get_turf(owner)
				T.visible_message(SPAN_WARNING("The sheer force from [P] shatters the mirror shield!"))
				new /obj/effect/temp_visual/cult/sparks(T)
				playsound(T, 'sound/effects/glassbr3.ogg', 100)
				owner.Weaken(6 SECONDS)
				qdel(src)
				return FALSE

			if(P.is_reflectable(REFLECTABILITY_ENERGY))
				return FALSE //To avoid reflection chance double-dipping with block chance

		// Hit by a melee weapon or blocked a projectile
		. = ..()
		if(.) // they did parry the attack
			playsound(src, 'sound/weapons/parry.ogg', 100, TRUE)
			if(illusions > 0)
				illusions--
				addtimer(CALLBACK(src, PROC_REF(readd)), 45 SECONDS)
				if(prob(60))
					spawn_illusion(owner, TRUE) // Hostile illusion
				else
					spawn_illusion(owner, FALSE) // Running illusion
			return TRUE

	else // Non-cultist holding the shield
		if(prob(50))
			spawn_illusion(owner, TRUE, TRUE)
		return FALSE

/obj/item/shield/mirror/proc/spawn_illusion(mob/living/carbon/human/user, hostile, betray)
	if(hostile)
		var/mob/living/simple_animal/hostile/illusion/cult/H = new(user.loc)
		H.faction = list("cult")
		if(!betray)
			H.Copy_Parent(user, 70, 10, 5)
		else
			H.Copy_Parent(user, 100, 20, 5)
			H.GiveTarget(user)
			to_chat(user, SPAN_DANGER("[src] betrays you!"))
	else
		var/mob/living/simple_animal/hostile/illusion/escape/cult/E = new(user.loc)
		E.Copy_Parent(user, 70, 10)
		E.GiveTarget(user)
		E.Goto(user, E.move_to_delay, E.minimum_distance)

/obj/item/shield/mirror/proc/readd()
	if(illusions < initial(illusions))
		illusions++
	else if(isliving(loc))
		var/mob/living/holder = loc
		if(IS_CULTIST(holder))
			to_chat(holder, SPAN_CULTITALIC("The shield's illusions are back at full strength!"))
		else
			to_chat(holder, "<span class='warning'>[src] vibrates slightly, and starts glowing.")

/obj/item/shield/mirror/IsReflect()
	if(prob(reflect_chance))
		if(ismob(loc))
			var/mob/user = loc
			if(user.holy_check())
				return FALSE
		return TRUE
	return FALSE

/obj/item/cult_spear
	name = "blood spear"
	desc = "A mighty polearm made entirely of crystalized blood, held together with eldritch power. Throwing the weapon will cause its enchantments to discharge violently on impact."
	icon = 'icons/obj/cult.dmi'
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	base_icon_state = "bloodspear"
	icon_state = "bloodspear0"
	force = 17
	throwforce = 30
	armor_penetration_percentage = 50
	attack_verb = list("attacked", "impaled", "stabbed", "torn", "gored")
	sharp = TRUE
	no_spin_thrown = TRUE
	hitsound = 'sound/weapons/bladeslice.ogg'
	needs_permit = TRUE
	var/datum/action/innate/cult/spear/spear_act

/obj/item/cult_spear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.4, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = (5 / 3) SECONDS) // 0.666667 seconds for 60% uptime.
	AddComponent(/datum/component/two_handed, force_wielded = 24, force_unwielded = force, icon_wielded = "[base_icon_state]1")

/obj/item/cult_spear/Destroy()
	if(spear_act)
		qdel(spear_act)
	return ..()

/obj/item/cult_spear/update_icon_state()
	icon_state = "[base_icon_state]0"

/obj/item/cult_spear/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/turf/T = get_turf(hit_atom)
	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		if(IS_CULTIST(L))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			if(!L.restrained() && L.put_in_active_hand(src))
				L.visible_message(SPAN_WARNING("[L] catches [src] out of the air!"))
			else
				L.visible_message(SPAN_WARNING("[src] bounces off of [L], as if repelled by an unseen force!"))
		else if(!..())
			if(L.null_rod_check())
				return
			var/datum/status_effect/cult_stun_mark/S = L.has_status_effect(STATUS_EFFECT_CULT_STUN)
			if(S)
				S.trigger()
			else if(!IS_HERETIC(L))
				L.KnockDown(10 SECONDS)
				L.apply_damage(60, STAMINA)
				L.apply_status_effect(STATUS_EFFECT_CULT_STUN)
				L.flash_eyes(1, TRUE)
				if(issilicon(L))
					L.emp_act(EMP_HEAVY)
				else if(iscarbon(L))
					L.Silence(6 SECONDS)
					L.Stuttering(16 SECONDS)
					L.CultSlur(20 SECONDS)
					L.Jitter(16 SECONDS)
			break_spear(T)
	else
		..()

/obj/item/cult_spear/proc/break_spear(turf/T)
	if(!T)
		T = get_turf(src)
	if(T)
		T.visible_message(SPAN_WARNING("[src] shatters and melts back into blood!"))
		new /obj/effect/temp_visual/cult/sparks(T)
		new /obj/effect/decal/cleanable/blood/splatter(T)
		playsound(T, 'sound/effects/glassbr3.ogg', 100)
	qdel(src)

/obj/item/cult_spear/attack__legacy__attackchain(mob/living/M, mob/living/user, def_zone)
	. = ..()
	var/datum/status_effect/cult_stun_mark/S = M.has_status_effect(STATUS_EFFECT_CULT_STUN)
	if(S && HAS_TRAIT(src, TRAIT_WIELDED))
		S.trigger()

/datum/action/innate/cult/spear
	name = "Bloody Bond"
	desc = "Recall the blood spear to your hand."
	button_icon_state = "bloodspear"
	default_button_position = "11:31,4:-2"
	var/obj/item/cult_spear/spear
	var/cooldown = 0

/datum/action/innate/cult/spear/Grant(mob/user, obj/blood_spear)
	. = ..()
	spear = blood_spear

/datum/action/innate/cult/spear/Activate()
	if(owner == spear.loc || cooldown > world.time || owner.holy_check())
		return
	var/ST = get_turf(spear)
	var/OT = get_turf(owner)
	if(get_dist(OT, ST) > 10)
		to_chat(owner,SPAN_WARNING("The spear is too far away!"))
	else
		cooldown = world.time + 20
		if(isliving(spear.loc))
			var/mob/living/L = spear.loc
			L.drop_item_to_ground(spear)
			L.visible_message(SPAN_WARNING("An unseen force pulls the blood spear from [L]'s hands!"))
		spear.throw_at(owner, 10, 2, null, dodgeable = FALSE)

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/blood
	name = "blood bolt barrage"
	desc = "A crackling orb of blood-red energy, straining for the chance to kill. Simply point at the target, and let it loose."
	color = COLOR_RED
	guns_left = 24
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/blood
	fire_sound = 'sound/magic/wand_teleport.ogg'
	flags = NOBLUDGEON | DROPDEL

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/blood/afterattack__legacy__attackchain(atom/target, mob/living/user, flag, params)
	if(user.holy_check())
		return
	..()

/obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/blood
	ammo_type = /obj/item/ammo_casing/magic/arcane_barrage/blood

/obj/item/ammo_casing/magic/arcane_barrage/blood
	projectile_type = /obj/projectile/magic/arcane_barrage/blood
	muzzle_flash_effect = /obj/effect/temp_visual/emp/cult

/obj/projectile/magic/arcane_barrage/blood
	name = "blood bolt"
	icon_state = "blood_bolt"
	damage_type = BRUTE
	impact_effect_type = /obj/effect/temp_visual/dir_setting/bloodsplatter
	hitsound = 'sound/effects/splat.ogg'

/obj/projectile/magic/arcane_barrage/blood/prehit(atom/target)
	if(IS_CULTIST(target))
		damage = 0
		nodamage = TRUE
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.stat != DEAD)
				H.reagents.add_reagent("unholywater", 4)
		if(isshade(target) || isconstruct(target))
			var/mob/living/simple_animal/M = target
			if(M.health + 5 < M.maxHealth)
				M.adjustHealth(-5)
		new /obj/effect/temp_visual/cult/sparks(target)
	..()

/obj/item/blood_orb
	name = "orb of blood"
	desc = "A solid orb of crystalized blood, likely taken unwillingly. The orb can be used to transfer vitae between the faithful."
	icon = 'icons/obj/cult.dmi'
	icon_state = "summoning_orb"
	var/blood = 50

/obj/item/portal_amulet
	name = "reality sunderer"
	desc = "An elaborately carved amulet resembling a human eye. Looking directly at it sends shivers down your spine. Allows cultists to open portals over teleport runes, destroying the rune in the process."
	icon = 'icons/obj/cult.dmi'
	icon_state = "amulet"
	w_class = WEIGHT_CLASS_SMALL


/obj/item/portal_amulet/afterattack__legacy__attackchain(atom/O, mob/user, proximity)
	. = ..()
	if(!IS_CULTIST(user))
		if(!iscarbon(user))
			return
		var/mob/living/carbon/M = user
		to_chat(M, SPAN_CULTLARGE("\"So, you want to explore space?\""))
		to_chat(M, SPAN_WARNING("Space flashes around you as you are moved somewhere else!"))
		M.Confused(20 SECONDS)
		M.flash_eyes(override_blindness_check = TRUE)
		M.EyeBlind(20 SECONDS)
		do_teleport(M, get_turf(M), 5, sound_in = 'sound/magic/cult_spell.ogg')
		qdel(src)
		return

	if(istype(O, /obj/effect/rune))
		if(!istype(O, /obj/effect/rune/teleport))
			to_chat(user, SPAN_WARNING("[src] only works on teleport runes."))
			return
		if(!proximity)
			to_chat(user, SPAN_WARNING("You are too far away from the teleport rune."))
			return
		var/obj/effect/rune/teleport/R = O
		attempt_portal(R, user)

/obj/item/portal_amulet/proc/attempt_portal(obj/effect/rune/teleport/R, mob/user)
	var/list/potential_runes = list()
	var/list/teleport_names = list()
	var/list/duplicate_rune_count = list()
	var/turf/T = get_turf(src) //used to tell the other rune where we came from

	for(var/I in GLOB.teleport_runes)
		var/obj/effect/rune/teleport/target = I
		var/result_key = target.listkey
		if(target == R || !is_level_reachable(target.z))
			continue
		if(result_key in teleport_names)
			duplicate_rune_count[result_key]++
			result_key = "[result_key] ([duplicate_rune_count[result_key]])"
		else
			teleport_names += result_key
			duplicate_rune_count[result_key] = 1
		potential_runes[result_key] = target

	if(!length(potential_runes))
		to_chat(user, SPAN_WARNING("There are no valid runes to teleport to!"))
		return

	if(!is_level_reachable(user.z))
		to_chat(user, SPAN_CULTITALIC("You are not in the right dimension!"))
		return

	var/input_rune_key = tgui_input_list(user, "Choose a rune to make a portal to", "Rune to make a portal to", potential_runes) //we know what key they picked
	var/obj/effect/rune/teleport/actual_selected_rune = potential_runes[input_rune_key] //what rune does that key correspond to?
	if(QDELETED(R) || QDELETED(actual_selected_rune) || !Adjacent(user) || user.incapacitated())
		return

	if(is_mining_level(R.z) && !is_mining_level(actual_selected_rune.z))
		actual_selected_rune.handle_portal("lava")
	else if(!is_station_level(R.z) || isspacearea(get_area(src)))
		actual_selected_rune.handle_portal("space", T)
	new /obj/effect/portal/cult(get_turf(R), get_turf(actual_selected_rune), src, 4 MINUTES)
	to_chat(user, SPAN_CULTITALIC("You use the magic of the amulet to turn [R] into a portal."))
	playsound(src, 'sound/magic/cult_spell.ogg', 100, TRUE)
	qdel(R)
	qdel(src)

/obj/effect/portal/cult
	name = "eldritch portal"
	desc = "An evil portal made by dark magics. Surprisingly stable."
	icon_state = "portal1"
	var/obj/effect/cult_portal_exit/exit = null

/obj/effect/portal/cult/Initialize(mapload, target, creator, lifespan)
	. = ..()
	if(target)
		exit = new /obj/effect/cult_portal_exit(target)

/obj/effect/portal/cult/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if((istype(used, /obj/item/melee/cultblade/dagger) && IS_CULTIST(user)) || (istype(used, /obj/item/nullrod) && HAS_MIND_TRAIT(user, TRAIT_HOLY)))
		to_chat(user, SPAN_NOTICE("You close the portal with your [used]."))
		playsound(src, 'sound/magic/magic_missile.ogg', 100, TRUE)
		qdel(src)
		return ITEM_INTERACT_COMPLETE

/obj/effect/portal/cult/Destroy()
	QDEL_NULL(exit)
	return ..()

/obj/effect/cult_portal_exit
	name = "eldritch rift"
	desc = "An exit point for some cult portal. Be on guard, more things may come out of it"
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	color = "red"

#define GATEWAY_TURF_SCAN_RANGE 40
GLOBAL_LIST_EMPTY(proteon_portals)

/obj/item/proteon_orb
	name = "summoning orb"
	desc = "An eerie translucent orb that feels impossibly light. Legends say summoning orbs are created from corrupted scrying orbs. If you hold it close to your ears, you can hear the screams of the damned."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scrying_orb"
	light_range = 3
	light_color = LIGHT_COLOR_RED
	new_attack_chain = TRUE
	/// A nice blood colour matrix
	var/list/blood_color_matrix = list(1.25,-0.1,-0.1,0, 0,0.15,0,0, 0,0,0.15,0, 0,0,0,1, 0,0,0,0)


/obj/item/proteon_orb/Initialize(mapload)
	. = ..()
	color = blood_color_matrix


/obj/item/proteon_orb/examine(mob/user)
	. = ..()
	if(!IS_CULTIST(user) && isliving(user))
		var/mob/living/living_user = user
		living_user.adjustBrainLoss(5)
		. += SPAN_DANGER("It hurts just to look at it. Better keep away.")
	else
		. += SPAN_CULT("It can be used to create a gateway to Nar'Sie's domain, which will summon weak, sentient constructs over time.")

/obj/item/proteon_orb/activate_self(mob/user)
	if(..())
		return

	var/list/portals_to_scan = GLOB.proteon_portals

	if(!IS_CULTIST(user))
		to_chat(user, SPAN_CULTLARGE("\"You want to enter my domain? Go ahead.\""))
		portals_to_scan = null // narsie wants to have some fun and the veil wont stop her

	for(var/obj/structure/spawner/sentient/proteon_spawner/P as anything in portals_to_scan)
		if(get_dist(P, src) <= 40)
			to_chat(user, SPAN_CULT("<b>There's a gateway too close nearby. The veil is not yet weak enough to allow such close rips in its fabric.</b>"))
			return
	to_chat(user, SPAN_CULTITALIC("<b>You focus on [src] and direct it into the ground. It rumbles...</b>"))

	var/turf/hole_spot = get_turf(user)
	if(!isfloorturf(hole_spot))
		to_chat(user, SPAN_NOTICE("This is not a suitable spot."))
		return

	INVOKE_ASYNC(hole_spot, TYPE_PROC_REF(/turf/simulated/floor, quake_gateway), user)
	qdel(src)

/**
 * Bespoke proc that happens when a proteon orb is activated, creating a gateway.
 * If activated by a non-cultist, they get an unusual game over.
*/
/turf/simulated/floor/proc/quake_gateway(mob/living/user)
	ChangeTurf(/turf/simulated/floor/engine/cult)
	Shake(4, 4, 5 SECONDS)
	var/fucked = FALSE
	if(!IS_CULTIST(user))
		fucked = TRUE
		user.notransform = TRUE
		user.add_atom_colour(LIGHT_COLOR_RED, TEMPORARY_COLOUR_PRIORITY)
		user.visible_message(SPAN_CULT("<b>Dark tendrils appear from the ground and root [user] in place!</b>"))
	sleep(5 SECONDS) // can we still use these or. i mean its async
	new /obj/structure/spawner/sentient/proteon_spawner(src)
	visible_message(SPAN_CULT("<b>A mysterious hole appears out of nowhere!</b>"))
	if(!fucked || QDELETED(user))
		return
	if(get_turf(user) != src) // they get away. for now
		user.notransform = FALSE
	user.visible_message(SPAN_CULT("<b>[user] is pulled into the portal through an infinitesmally minuscule hole, shredding [user.p_their()] body!</b>"))
	add_attack_logs(user, user, "Killed themselfs via use of a proteon orb as a non cultist", ATKLOG_ALL)
	user.gib() // total destruction
	sleep(5 SECONDS)
	user.visible_message(SPAN_CULTITALIC("An unusually large construct appears through the portal!"))
	var/mob/living/simple_animal/hostile/construct/proteon/hostile/remnant = new(get_step_rand(src))
	remnant.name = "[user]" // no, they do not become it
	remnant.appearance_flags += PIXEL_SCALE
	remnant.transform *= 1.5

#undef GATEWAY_TURF_SCAN_RANGE
