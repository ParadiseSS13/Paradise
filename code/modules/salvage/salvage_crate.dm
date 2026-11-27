/obj/item/storage/salvage_crate
	name = "base salvage crate"
	desc = "A sealed crate full of unknown salvage."
	icon = 'icons/obj/salvage/salvage_crates.dmi'
	icon_state = "salvage"
	base_icon_state = "salvage"
	use_sound = 'sound/effects/toolbox.ogg'
	/// Has this salvage crate been opened yet?
	var/opened = FALSE
	/// Is this salvage crate still locked
	var/locked = TRUE
	/// Is this salvage crate being unlocked
	var/unlocking = FALSE
	/// The loot table to spawn items from
	var/datum/salvage_loot_table/loot_datum = /datum/salvage_loot_table
	/// Minimum amount of loot items to spawn
	var/minimum_loot = 1
	/// Maximum amount of loot items to spawn
	var/maximum_loot = 5
	/// Types of crate upgrade schematic it can drop
	var/list/possible_schematics = list()
	/// Chance for a schematic to drop
	var/schem_chance = 15

/obj/item/storage/salvage_crate/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/storage/salvage_crate/examine()
	. = ..()
	if(locked)
		. += SPAN_NOTICE("It looks like a multitool could help in unlocking this crate.")
	if(!opened)
		. += SPAN_NOTICE("A small beacon flashes on the crate. It hasn't been tampered with.")

/obj/item/storage/salvage_crate/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][living_viewers() ? "_open" : ""]"

/obj/item/storage/salvage_crate/update_overlays()
	. = ..()
	if(unlocking)
		. += image(icon = icon, icon_state = "crate_unlocking")
	else
		. += image(icon = icon, icon_state = "[locked ? "crate_locked" : "crate_unlocked"]")
	if(!opened)
		. += image(icon = icon, icon_state = "crate_unopened")

/obj/item/storage/salvage_crate/populate_contents()
	var/loot_to_spawn = rand(minimum_loot, maximum_loot)
	while(loot_to_spawn > 0)
		var/list/loot_table = loot_datum.loot
		var/loot_type = pickweight(loot_table)
		if(!loot_type) // Break out if this shit is ever null
			log_debug("Attempted to create a [name] with null loot.")
			break
		var/atom/loot_atom = new loot_type(src)
		if(isitem(loot_atom))
			var/obj/item/loot_item = loot_atom
			loot_item.origin_tech = list()
		loot_to_spawn--
	if(prob(schem_chance))
		var/new_schematic_type = pick(possible_schematics)
		new new_schematic_type(src)

/obj/item/storage/salvage_crate/dropped(mob/user, silent)
	. = ..()
	if(icon_state == "[base_icon_state]_open")
		close(user)

/obj/item/storage/salvage_crate/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, dodgeable)
	. = ..()
	if(icon_state == "[base_icon_state]_open")
		close(thrower)

/obj/item/storage/salvage_crate/open(mob/user)
	if(locked)
		to_chat(user, SPAN_NOTICE("[src] is locked!"))
		return
	if(!opened)
		opened = TRUE
		update_appearance(UPDATE_OVERLAYS)
	. = ..()
	if(living_viewers())
		flick("[icon_state]_opening", src)
	update_appearance(UPDATE_ICON_STATE)
	for(var/mob/M in src.contents)
		M.forceMove(get_turf(src))
	for(var/obj/item/grenade/bomb in src.contents)
		if(prob(75))
			bomb.forceMove(get_turf(src))
			bomb.prime()

/obj/item/storage/salvage_crate/close(mob/user)
	. = ..()
	if(!living_viewers()) // I know it's inverse of open but if it ain't done this way you get broken animations
		update_appearance(UPDATE_ICON_STATE)
		flick("[icon_state]_closing", src)

/obj/item/storage/salvage_crate/can_be_inserted(obj/item/I)
	if(locked)
		return FALSE
	if(!opened)
		return FALSE
	. = ..()

/obj/item/storage/salvage_crate/multitool_act(mob/living/user, obj/item/I)
	if(!locked)
		to_chat(user, SPAN_NOTICE("[src] is already unlocked!"))
		return
	visible_message(
			SPAN_NOTICE("[user] connects [I] to [src] and starts to unlock it."),
			SPAN_NOTICE("[user] connects [I] to [src] and starts to unlock it."),
			SPAN_NOTICE("You hear something unlocking.")
	)
	unlocking = TRUE
	update_appearance(UPDATE_OVERLAYS)
	if(!do_after_once(user, 1 SECONDS, target = src))
		unlocking = FALSE
		update_appearance(UPDATE_OVERLAYS)
		return
	unlocking = FALSE
	locked = FALSE
	update_appearance(UPDATE_OVERLAYS)

/obj/item/storage/salvage_crate/proc/living_viewers()
	for(var/mob/M in mobs_viewing)
		if(!isobserver(M))
			return TRUE
	return FALSE

/obj/item/storage/salvage_crate/salvage
	name = "salvage crate"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/parts,
		/obj/item/salvage_decryptor_schematic/cooler,
		/obj/item/salvage_decryptor_schematic/lost
	)

/obj/item/storage/salvage_crate/illegal
	name = "operative dead drop"
	icon_state = "illegal"
	base_icon_state = "illegal"
	schem_chance = 0

/obj/item/storage/salvage_crate/parts
	name = "spare parts crate"
	icon_state = "parts"
	base_icon_state = "parts"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/industrial,
		/obj/item/salvage_decryptor_schematic/cooler
	)

/obj/item/storage/salvage_crate/cooler
	name = "abandoned cooler"
	icon_state = "cooler"
	base_icon_state = "cooler"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/parts,
		/obj/item/salvage_decryptor_schematic/lost,
		/obj/item/salvage_decryptor_schematic/freezer,
	)

/obj/item/storage/salvage_crate/lost
	name = "lost and found crate"
	icon_state = "lost"
	base_icon_state = "lost"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/cooler,
		/obj/item/salvage_decryptor_schematic/service,
		/obj/item/salvage_decryptor_schematic/backlog,
	)

/obj/item/storage/salvage_crate/service
	name = "service surplus crate"
	icon_state = "service"
	base_icon_state = "service"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/lost,
		/obj/item/salvage_decryptor_schematic/clown,
	)

/obj/item/storage/salvage_crate/industrial
	name = "industrial crate"
	icon_state = "industrial"
	base_icon_state = "industrial"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/hazmat
	)

/obj/item/storage/salvage_crate/freezer
	name = "deep freezer"
	icon_state = "freezer"
	base_icon_state = "freezer"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/med,
		/obj/item/salvage_decryptor_schematic/contain,
	)

/obj/item/storage/salvage_crate/med
	name = "dated medicine crate"
	icon_state = "med"
	base_icon_state = "med"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/live
	)

/obj/item/storage/salvage_crate/backlog
	name = "undelivered backlog crate"
	icon_state = "backlog"
	base_icon_state = "backlog"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/exotic
	)

/obj/item/storage/salvage_crate/clown
	name = "failed comedian's footlocker"
	icon_state = "clown"
	base_icon_state = "clown"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/industrial
	)

/obj/item/storage/salvage_crate/hazmat
	name = "hazmat crate"
	icon_state = "hazmat"
	base_icon_state = "hazmat"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/dno,
		/obj/item/salvage_decryptor_schematic/unstable,
	)

/obj/item/storage/salvage_crate/unstable
	name = "unstable samples crate"
	icon_state = "unstable"
	base_icon_state = "unstable"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/bluespace
	)

/obj/item/storage/salvage_crate/contain
	name = "long term containment crate"
	icon_state = "contain"
	base_icon_state = "contain"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/ancient
	)

/obj/item/storage/salvage_crate/live
	name = "live samples crate"
	icon_state = "live"
	base_icon_state = "live"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/exotic
	)

/obj/item/storage/salvage_crate/exotic
	name = "exotic imports crate"
	icon_state = "exotic"
	base_icon_state = "exotic"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/deposit
	)

/obj/item/storage/salvage_crate/dno
	name = "DO NOT OPEN crate"
	icon_state = "dno"
	base_icon_state = "dno"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/pandora
	)

/obj/item/storage/salvage_crate/bluespace
	name = "bluespace crate"
	icon_state = "bluespace"
	base_icon_state = "bluespace"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/ancient
	)

/obj/item/storage/salvage_crate/ancient
	name = "ancient crate"
	icon_state = "ancient"
	base_icon_state = "ancient"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/pandora
	)

/obj/item/storage/salvage_crate/deposit
	name = "safety deposit box"
	icon_state = "deposit"
	base_icon_state = "deposit"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/pandora
	)

/obj/item/storage/salvage_crate/pandora
	name = "pandora's box"
	icon_state = "pandora"
	base_icon_state = "pandora"
	possible_schematics = list(
		/obj/item/salvage_decryptor_schematic/parts,
		/obj/item/salvage_decryptor_schematic/cooler,
		/obj/item/salvage_decryptor_schematic/lost,
		/obj/item/salvage_decryptor_schematic/service,
		/obj/item/salvage_decryptor_schematic/industrial,
		/obj/item/salvage_decryptor_schematic/freezer,
		/obj/item/salvage_decryptor_schematic/med,
		/obj/item/salvage_decryptor_schematic/backlog,
		/obj/item/salvage_decryptor_schematic/clown,
		/obj/item/salvage_decryptor_schematic/hazmat,
		/obj/item/salvage_decryptor_schematic/unstable,
		/obj/item/salvage_decryptor_schematic/contain,
		/obj/item/salvage_decryptor_schematic/live,
		/obj/item/salvage_decryptor_schematic/exotic,
		/obj/item/salvage_decryptor_schematic/dno,
		/obj/item/salvage_decryptor_schematic/bluespace,
		/obj/item/salvage_decryptor_schematic/ancient,
		/obj/item/salvage_decryptor_schematic/deposit,
	)
