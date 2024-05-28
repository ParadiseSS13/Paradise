/* Not specified */
// Primarly meant to be used on Centcomm z-level, as it can't be destroyed, and it doesn't affect perfomance
/obj/structure/light_fake
	name = "light fixture"
	desc = "A lighting fixture."
	icon = 'modular_ss220/aesthetics/lights/icons/lights.dmi'
	icon_state = "tube1"
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | FREEZE_PROOF | ACID_PROOF | UNACIDABLE
	light_color = "#FFFFFF"
	light_power = 1
	light_range = 8

/obj/structure/light_fake/small
	name = "light fixture"
	desc = "A small lighting fixture."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb1"
	light_color = "#a0a080"
	light_range = 4

/obj/structure/light_fake/spot
	name = "spotlight"
	light_range = 12
	light_power = 4

/obj/structure/light_fake/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/effects/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/* Awaymission - Gate Lizard */
//Trees
/obj/structure/flora/tree/great_tree
	name = "great tree"
	desc = "A colossal tree with the carved face of some deity."
	icon = 'modular_ss220/maps220/icons/trees.dmi'
	icon_state = "great_tree"

//Crates
/obj/structure/closet/crate/wooden
	icon = 'modular_ss220/maps220/icons/crates.dmi'
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'

/obj/structure/closet/crate/wooden/wooden_crate
	name = "wooden crate"
	desc = "A wooden crate."
	icon_state = "wooden"
	icon_opened = "wooden_open"
	icon_closed = "wooden"

/obj/structure/closet/crate/wooden/barrel
	name = "wooden barrel"
	desc = "A wooden barrel."
	icon_state = "crate_barrel"
	icon_opened = "crate_barrel_open"
	icon_closed = "crate_barrel"

/obj/structure/closet/crate/grave
	name = "grave mound"
	desc = "A simple and reliable way to keep the dead away."
	icon = 'modular_ss220/maps220/icons/crates.dmi'
	icon_state = "grave"
	icon_opened = "graveopen"
	icon_closed = "grave"
	open_sound = 'sound/effects/shovel_dig.ogg'
	close_sound = 'sound/effects/shovel_dig.ogg'

/obj/structure/closet/crate/grave/gravelead
	name = "ominous grave mound"
	icon_state = "grave_lead"
	icon_opened = "grave_leadopen"
	icon_closed = "grave_lead"

/* Syndicate Base - Mothership */
// Machinery
/obj/machinery/photocopier/syndie
	name = "Syndicate photocopier"
	desc = "They don't even try to hide it's theirs..."
	icon = 'modular_ss220/maps220/icons/machinery.dmi'
	icon_state = "syndiebigscanner"
	insert_anim = "syndiebigscanner1"

// Structure
/obj/structure/shuttle/engine
	name = "engine"
	icon = 'modular_ss220/maps220/icons/shuttle.dmi'
	resistance_flags = INDESTRUCTIBLE // То что у нас двигатели ломаются от пары пуль - бред
	var/list/obj/structure/fillers = list() // Для коллизии более больших двигателей

/obj/structure/shuttle/engine/Initialize(mapload)
	. = ..()
	set_light(2)

/obj/structure/shuttle/engine/heater
	name = "heater"
	icon_state = "heater"

/obj/structure/shuttle/engine/platform
	name = "platform"
	icon_state = "platform"

/obj/structure/shuttle/engine/propulsion
	name = "propulsion"
	icon_state = "propulsion"
	opacity = 1

/obj/structure/shuttle/engine/propulsion/burst

/obj/structure/shuttle/engine/propulsion/burst/left
	icon_state = "burst_l"

/obj/structure/shuttle/engine/propulsion/burst/right
	icon_state = "burst_r"

/obj/structure/shuttle/engine/router
	name = "router"
	icon_state = "router"

/obj/structure/shuttle/engine/large
	name = "engine"
	opacity = 1
	icon = 'modular_ss220/maps220/icons/2x2.dmi'
	icon_state = "large_engine"
	desc = "A very large bluespace engine used to propel very large ships."
//	bound_width = 64
//	bound_height = 64
	appearance_flags = 0

/obj/structure/shuttle/engine/huge
	name = "engine"
	opacity = 1
	icon = 'modular_ss220/maps220/icons/3x3.dmi'
	icon_state = "huge_engine"
	desc = "Almost gigantic bluespace engine used to propel very large ships at very high speed."
	pixel_x = -32
	pixel_y = -32
//	bound_width = 96
//	bound_height = 96
	appearance_flags = 0

/obj/structure/shuttle/engine/large/Initialize(mapload)
	. = ..()
	var/list/occupied = list()
	for(var/direct in list(EAST,NORTH,NORTHEAST))
		occupied += get_step(src,direct)

	for(var/T in occupied)
		var/obj/structure/filler/F = new(T)
		F.parent = src
		fillers += F

/obj/structure/shuttle/engine/huge/Initialize(mapload)
	. = ..()
	var/list/occupied = list()
	for(var/direct in list(EAST,WEST,NORTH,SOUTH,SOUTHEAST,SOUTHWEST,NORTHEAST,NORTHWEST))
		occupied += get_step(src,direct)

	for(var/T in occupied)
		var/obj/structure/filler/F = new(T)
		F.parent = src
		fillers += F

/obj/structure/chair/comfy/shuttle/dark
	icon = 'modular_ss220/maps220/icons/chairs.dmi'
	icon_state = "shuttle_chair_dark"

/obj/structure/chair/comfy/shuttle/dark/GetArmrest()
	return mutable_appearance('modular_ss220/maps220/icons/chairs.dmi', "shuttle_chair_dark_armrest")

/obj/structure/closet/secure_closet/syndicate/medbay
	name = "Syndicate Medical Doctor's Locker"
	req_access = list(ACCESS_SYNDICATE)
	icon_state = "tac"
	icon_closed = "tac"
	icon_opened = "tac_open"
	open_door_sprite = "syndicate_door"



/obj/structure/closet/secure_closet/syndicate/medbay/populate_contents()
	new /obj/item/storage/backpack/duffel/syndie/med/surgery
	new /obj/item/storage/backpack/duffel/syndie/med/surgery
	new /obj/item/clothing/under/rank/medical(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/defibrillator/loaded(src)
	new /obj/item/handheld_defibrillator(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/clothing/head/headmirror(src)
	new /obj/item/clothing/shoes/sandal/white(src)
	new /obj/item/storage/backpack/duffel/syndie(src)

// Mecha equipment
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg/syndi
	name = "\improper AC 2 \"Special\""
	desc = "C-20r inside!"
	equip_cooldown = 8
	projectile = /obj/item/projectile/bullet/midbullet2
	fire_sound = 'sound/weapons/gunshots/gunshot_smg.ogg'
	projectile_energy_cost = 14

/* Caves awaymission */
/obj/item/clothing/gloves/ring/immortality_ring
	name = "старое кольцо"
	icon_state = "shadowring"
	ring_color = "shadow"
	material = "shadow"
	desc = "Кольцо цвета оникса из неизвестного материала. Позолоченные надписи на внешней стороне причудливо пульсируют, испуская зловещую дымку. Надеть его кажется не лучшей идеей..."
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	actions_types = list(/datum/action/item_action/immortality)
	var/ability_delay = 100 SECONDS
	var/invisibility_add = 101
	var/invisibility_rmv = 0

/datum/action/item_action/immortality
	name = "Ring ability"

/obj/item/clothing/gloves/ring/immortality_ring/proc/ring_ability(mob/user)
	if(cooldown > world.time)
		to_chat(user, span_warning("[name] еще перезаряжается!"))
		return
	cooldown = world.time + ability_delay
	user.status_flags |= GODMODE
	user.invisibility = invisibility_add
	visible_message(span_danger("[user] исчезает из реальности!"))
	to_chat(user, span_cultitalic("Ты чувствуешь чье-то ужасающее присутствие..."))
	SEND_SOUND (user, sound('sound/hallucinations/i_see_you2.ogg'))
	addtimer(CALLBACK(src, PROC_REF(ring_ability_end), user), 8 SECONDS)

/obj/item/clothing/gloves/ring/immortality_ring/proc/ring_ability_end(mob/user)
	user.status_flags &= ~GODMODE
	user.invisibility = invisibility_rmv
	visible_message(span_danger("[user] возвращается в реальность!"))
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	H.apply_damage(rand(10, 40), BURN, pick("r_hand"))
	H.adjustCloneLoss(25, TRUE)
	H.adjustBrainLoss(30, TRUE)

/obj/item/clothing/gloves/ring/immortality_ring/ui_action_click(mob/user, immortality)
	ring_ability(user)

/obj/item/clothing/gloves/ring/immortality_ring/item_action_slot_check(slot, mob/user, immortality)
	if(slot == SLOT_HUD_GLOVES)
		return TRUE

/obj/item/clothing/gloves/ring/immortality_ring/equipped(mob/user, slot)
	..()
	var/mob/living/carbon/human/H = user
	if(istype(H) && slot == SLOT_HUD_GLOVES)
		flags = NODROP
		to_chat(user, span_danger("[name] туго обвивается вокруг твоего пальца!"))
		SEND_SOUND (user, sound('modular_ss220/aesthetics_sounds/sound/creepy/demon2.ogg'))

/obj/item/emerald_stone
	name = "изумрудный камень"
	desc = "Маленькая серебряная побрякушка, инкрустированная ярким изумрудом бриллиантовой огранки. На верхушечной площадке камня выгравирован череп."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "necrostone"
	item_state = "electronic"
	origin_tech = "bluespace=4;materials=4"
	w_class = WEIGHT_CLASS_TINY
	var/list/skeletons = list()
	var/number = 2 // for ingame VV change

/obj/item/emerald_stone/attack(mob/living/carbon/human/undead, mob/living/carbon/human/user)

	if(!istype(undead))
		return ..()

	if(!istype(user))
		return

	if(undead.stat != DEAD)
		to_chat(user, span_warning("Этот артефакт подействует лишь на мертвеца!"))
		return

	if((!undead.mind || !undead.client) && !undead.grab_ghost())
		to_chat(user, span_warning("Это тело никогда не было обременено душой..."))
		return

	check_skeletons() // clean out/refresh the list

	if(length(skeletons) >= number)
		to_chat(user, span_warning("Этот артефакт может поддерживать только одного мертвеца!</span>"))
		return

	else
		undead.set_species(/datum/species/skeleton) // OP skellybones
		undead.visible_message(span_warning("[undead] отторгает бренную оболочку и предстает в виде скелета!"))
		undead.grab_ghost() // yoinks the ghost if its not in the body
		undead.revive()
		equip_undead(undead)
	skeletons |= undead
	to_chat(undead, span_danger("Вас возродил </span><B>[user.real_name]!</B>"))
	to_chat(undead, span_danger("[user.p_theyre(TRUE)] теперь ваш хозяин, служите ему, чего бы это вам не стоило!</span>"))

/obj/item/emerald_stone/proc/check_skeletons()
	for(var/count in skeletons)
		if(!ishuman(count))
			skeletons.Remove(count)
			continue
		var/mob/living/carbon/human/undead = count
		if(undead.stat == DEAD)
			skeletons.Remove(count)
			continue
	listclearnulls(skeletons)

/obj/item/emerald_stone/proc/equip_undead(mob/living/carbon/human/raised)
	for(var/obj/item/I in raised)
		raised.unEquip(I)
	var/randomUndead = "roman" // defualt
	randomUndead = pick("roman","pirate","clown")

	switch(randomUndead)
		if("roman")
			var/hat = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionaire)
			raised.equip_to_slot_or_del(new hat(raised), SLOT_HUD_HEAD)
			raised.equip_to_slot_or_del(new /obj/item/clothing/under/costume/roman(raised), SLOT_HUD_JUMPSUIT)
			raised.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(raised), SLOT_HUD_SHOES)
			raised.equip_to_slot_or_del(new /obj/item/shield/riot/roman(raised), SLOT_HUD_LEFT_HAND)
			raised.equip_to_slot_or_del(new /obj/item/claymore/ceremonial(raised), SLOT_HUD_RIGHT_HAND)
			raised.equip_to_slot_or_del(new /obj/item/spear(raised), SLOT_HUD_BACK)
		if("pirate")
			raised.equip_to_slot_or_del(new /obj/item/clothing/under/costume/pirate(raised), SLOT_HUD_JUMPSUIT)
			raised.equip_to_slot_or_del(new /obj/item/clothing/suit/pirate_brown(raised),  SLOT_HUD_OUTER_SUIT)
			raised.equip_to_slot_or_del(new /obj/item/clothing/head/bandana(raised), SLOT_HUD_HEAD)
			raised.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(raised), SLOT_HUD_SHOES)
			raised.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(raised), SLOT_HUD_GLASSES)
			raised.equip_to_slot_or_del(new /obj/item/claymore/ceremonial(raised), SLOT_HUD_RIGHT_HAND)
			raised.equip_to_slot_or_del(new /obj/item/spear(raised), SLOT_HUD_BACK)
			raised.equip_to_slot_or_del(new /obj/item/shield/riot/roman(raised), SLOT_HUD_LEFT_HAND)
		if("clown")
			raised.equip_to_slot_or_del(new /obj/item/clothing/under/rank/civilian/clown(raised), SLOT_HUD_JUMPSUIT)
			raised.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(raised), SLOT_HUD_SHOES)
			raised.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(raised), SLOT_HUD_WEAR_MASK)
			raised.equip_to_slot_or_del(new /obj/item/clothing/head/stalhelm(raised), SLOT_HUD_HEAD)
			raised.equip_to_slot_or_del(new /obj/item/bikehorn(raised), SLOT_HUD_LEFT_STORE)
			raised.equip_to_slot_or_del(new /obj/item/claymore/ceremonial(raised), SLOT_HUD_RIGHT_HAND)
			raised.equip_to_slot_or_del(new /obj/item/shield/riot/roman(raised), SLOT_HUD_LEFT_HAND)
			raised.equip_to_slot_or_del(new /obj/item/spear(raised), SLOT_HUD_BACK)

/*Black Mesa awaymission*/
//Xenodoor
/obj/structure/mineral_door/xen
	name = "strange door"
	icon = 'icons/obj/smooth_structures/alien/resin_door.dmi'
	icon_state = "resin"
	base_icon_state = "resin"
	open_sound = 'sound/machines/alien_airlock.ogg'
	close_sound = 'sound/machines/alien_airlock.ogg'
	color = "#ee5f1c"
	sheetType = null

//Xenoweeds
/obj/structure/alien/xenoweeds
	gender = PLURAL
	name = "xen weeds"
	desc = "A thick vine-like surface covers the floor."
	anchored = TRUE
	density = FALSE
	plane = FLOOR_PLANE
	icon = 'icons/obj/smooth_structures/alien/weeds.dmi'
	icon_state = "weeds"
	base_icon_state = "weeds"
	max_integrity = 15
	layer = ABOVE_ICYOVERLAY_LAYER
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_ALIEN_RESIN, SMOOTH_GROUP_ALIEN_WEEDS)
	canSmoothWith = list(SMOOTH_GROUP_ALIEN_WEEDS)
	creates_cover = TRUE
	color = "#ee5f1c"

//Fomka
/obj/item/crowbar/freeman
	name = "blood soaked crowbar"
	desc = "A heavy handed crowbar, it drips with blood."
	icon = 'modular_ss220/maps220/icons/freeman.dmi'
	icon_state = "crowbar"
	force = 30
	throwforce = 20
	toolspeed = 0.1

/obj/item/crowbar/freeman/ultimate
	name = "\improper Freeman's crowbar"
	desc = "A weapon wielded by an ancient physicist, the blood of hundreds seeps through this rod of iron and malice."
	force = 45

/obj/item/crowbar/freeman/ultimate/Initialize(mapload)
	. = ..()
	add_filter("rad_glow", 2, list("type" = "outline", "color" = "#fbff1479", "size" = 2))

//Brown vine
/obj/structure/spacevine/xen
	color = "#ac3b06"
	density = TRUE
	opacity = TRUE

/obj/structure/spacevine/xen/Initialize(mapload)
	. = ..()
	add_atom_colour("#ac3b06", FIXED_COLOUR_PRIORITY)

//Shock Plant
/obj/structure/shockplant
	name = "electrical plant"
	desc = "It glows with a warm buzz."
	icon = 'modular_ss220/maps220/icons/plants.dmi'
	icon_state = "electric_plant"
	density = TRUE
	anchored = TRUE
	max_integrity = 200
	light_range = 10
	light_power = 0.5
	light_color = "#53fafa"
	/// Our faction
	var/faction = "xen"
	/// Our range to shock folks in.
	var/shock_range = 6
	/// Our cooldown on the shocking.
	var/shock_cooldown = 3 SECONDS
	/// The zap power
	var/shock_power = 10000

	COOLDOWN_DECLARE(shock_cooldown_timer)

/obj/structure/shockplant/Initialize(mapload)
	. = ..()
	for(var/turf/iterating_turf as anything in circleviewturfs(src, shock_range))
		RegisterSignal(iterating_turf, COMSIG_ATOM_ENTERED, PROC_REF(trigger))

/obj/structure/shockplant/proc/trigger(datum/source, atom/movable/entered_atom)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, shock_cooldown_timer))
		return

	if(isliving(entered_atom))
		var/mob/living/entering_mob = entered_atom
		if(faction in entering_mob.faction)
			return
		tesla_zap(src, shock_range, shock_power, shocked_targets = list(entering_mob))
		playsound(src, 'sound/magic/lightningbolt.ogg', 100, TRUE)
		COOLDOWN_START(src, shock_cooldown_timer, shock_cooldown)


//Xen Crystall
/obj/structure/xen_crystal
	name = "resonating crystal"
	desc = "A strange resinating crystal."
	icon = 'modular_ss220/maps220/icons/plants.dmi'
	icon_state = "crystal"
	light_power = 2
	light_range = 4
	density = TRUE
	anchored = TRUE
	/// Have we been harvested?
	var/harvested = FALSE

/obj/structure/xen_crystal/Initialize(mapload)
	. = ..()
	var/color_to_set = pick(COLOR_LIGHT_GREEN , COLOR_ASSEMBLY_YELLOW, COLOR_LIGHT_CYAN, LIGHT_COLOR_LAVENDER )
	color = color_to_set
	light_color = color_to_set

/obj/structure/xen_crystal/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(harvested)
		to_chat(user, span_warning("[src] has already been harvested!"))
		return
	to_chat(user, span_notice("You start harvesting [src]!"))
	if(do_after(user, 5 SECONDS, src))
		harvest(user)

/obj/structure/xen_crystal/proc/harvest(mob/living/user)
	if(harvested)
		return
	to_chat(user, span_notice("You harvest [src]!"))
	var/obj/item/grenade/xen_crystal/nade = new (get_turf(src))
	nade.color = color
	harvested = TRUE
	update_appearance()

/obj/structure/xen_crystal/update_icon_state()
	. = ..()
	if(harvested)
		icon_state = "crystal_harvested"
	else
		icon_state = "crystal"

/obj/item/grenade/xen_crystal
	name = "xen crystal"
	desc = "A crystal with anomalous properties."
	icon = 'modular_ss220/maps220/icons/plants.dmi'
	icon_state = "crystal_grenade"
	origin_tech = "material=8;biotech=8;magnets=8;bluespace=8;abductor=5"
	/// What range do we effect mobs?
	var/effect_range = 6
	/// The faction we convert the mobs to
	var/factions = null
	// Mobs in this list will not be affected by this grenade.
	var/list/blacklisted_mobs = list(
		/mob/living/simple_animal/hostile/megafauna,
		/mob/living/simple_animal/hostile/blackmesa/xen/headcrab_zombie/gordon_freeman,
		/mob/living/simple_animal/hostile/blackmesa/xen/nihilanth,
	)

/obj/item/grenade/xen_crystal/prime(mob/living/lanced_by)
	for(var/mob/living/mob_to_neutralize in view(src, effect_range))
		if(is_type_in_list(mob_to_neutralize, blacklisted_mobs))
			return
		mob_to_neutralize.faction |= factions
		mob_to_neutralize.visible_message(span_green("[mob_to_neutralize] is overcome by a wave of peace and tranquility!"))
		new /obj/effect/particle_effect/sparks(get_turf(mob_to_neutralize))
		playsound(src, 'sound/magic/charge.ogg', 100, TRUE)
	qdel(src)

//Flags
/obj/structure/sign/flag
	name = "blank flag"
	desc = "The flag of nothing. It has nothing on it. Magnificient."
	icon = 'modular_ss220/maps220/icons/flags.dmi'
	icon_state = "flag_coder"

/obj/structure/sign/flag/wrench_act(mob/living/user, obj/item/wrench/I)
	return

/obj/structure/sign/flag/welder_act(mob/living/user, obj/item/I)
	return

/obj/structure/sign/flag/nanotrasen
	name = "flag of Nanotrasen"
	desc = "The official corporate flag of Nanotrasen. Mostly flown as a ceremonial piece, or to mark land on a new frontier."
	icon_state = "flag_nt"

/obj/structure/sign/flag/mars
	name = "flag of the Teshari League for Self-Determination"
	desc = "The flag of the Teshari League for Self-Determination. Originally a revolutionary flag during the time of the Republic of the Golden Feather, it has since been adopted as the official flag of the planet, as a reminder of how Teshari fought for representation and independence."
	icon_state = "flag_mars"

/obj/structure/sign/flag/terragov
	name = "flag of Sol Federation"
	desc = "The flag of Sol Federation. It's a symbol of humanity no matter where they go, or how much they wish it wasn't."
	icon_state = "flag_solfed"

/obj/structure/sign/flag/nri
	name = "flag of the Novaya Rossiyskaya Imperiya"
	desc = "The flag of the Novaya Rossiyskaya Imperiya. The yellow, black and white colours represent its sovereignity, spirituality and pureness."
	icon_state = "flag_nri"

/obj/structure/sign/flag/syndicate
	name = "flag of the Syndicate"
	desc = "The flag of the Sothran Syndicate. Previously used by the Sothran people as a way of declaring opposition against the Nanotrasen, now it became an intergalactic symbol of the same, yet way more skewed purpose, as more groups of interest have joined the rebellion's side for their own gain."
	icon_state = "flag_syndi"

/obj/structure/sign/flag/usa
	name = "flag of the United States of America"
	desc = "'Stars and Stripes', the flag of the United States of America. Its red color represents endurance and valor; blue one shows diligence, vigilance and justice, and the white one signs at pureness. Its thirteen red-and-white stripes show the initial thirteen founding colonies, and fifty stars designate the current fifty states."
	icon_state = "flag_usa"

//Shiel pylon
/mob/living/simple_animal/hostile/blackmesa/xen
	/// Can we be shielded by pylons?
	var/can_be_shielded = TRUE
	/// If we have support pylons, this is true.
	var/shielded = FALSE
	/// How many shields we have protecting us
	var/shield_count = 0
	faction = list("xen")
	gold_core_spawnable = NO_SPAWN
	del_on_death = TRUE

/mob/living/simple_animal/hostile/blackmesa/xen/update_overlays()
	. = ..()
	if(shielded)
		. += mutable_appearance('modular_ss220/maps220/icons/effects.dmi', "shield-yellow", ABOVE_MOB_LAYER)

/mob/living/simple_animal/hostile/blackmesa/xen/proc/lose_shield()
	shield_count--
	if(shield_count <= 0)
		shielded = FALSE
		update_appearance()

/mob/living/simple_animal/hostile/blackmesa/xen/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = FALSE, forced = FALSE, spread_damage = FALSE, wound_bonus = 0, bare_wound_bonus = 0, sharp = NONE, used_weapon, attack_direction = null, attacking_item)
	if(shielded)
		visible_message("ineffective!")
		return FALSE
	return ..()

/obj/structure/xen_pylon
	name = "shield plant"
	desc = "It seems to be some kind of force field generator."
	icon = 'modular_ss220/maps220/icons/plants.dmi'
	icon_state = "crystal_pylon"
	max_integrity = 70
	density = TRUE
	anchored = TRUE
	/// The range at which we provide shield support to a mob.
	var/shield_range = 6
	/// A list of mobs we are currently shielding with attached beams.
	var/list/shielded_mobs = list()

/obj/structure/xen_pylon/Initialize(mapload)
	. = ..()
	for(var/mob/living/simple_animal/hostile/blackmesa/xen/iterating_mob in range(shield_range, src))
		if(!iterating_mob.can_be_shielded)
			continue
		register_mob(iterating_mob)
	for(var/turf/iterating_turf in RANGE_TURFS(shield_range, src))
		RegisterSignal(iterating_turf, COMSIG_ATOM_ENTERED, PROC_REF(mob_entered_range))

/obj/structure/xen_pylon/proc/mob_entered_range(datum/source, atom/movable/entered_atom)
	SIGNAL_HANDLER
	if(!ismob(entered_atom))
		return
	var/mob/living/simple_animal/hostile/blackmesa/xen/entered_xen_mob = entered_atom
	if(!entered_xen_mob)
		return
	register_mob(entered_xen_mob)

/obj/structure/xen_pylon/proc/register_mob(mob/living/simple_animal/hostile/blackmesa/xen/mob_to_register)
	if(mob_to_register in shielded_mobs)
		return
	if(!istype(mob_to_register))
		return
	shielded_mobs += mob_to_register
	mob_to_register.shielded = TRUE
	mob_to_register.shield_count++
	mob_to_register.update_appearance()
	var/datum/beam/created_beam = Beam(mob_to_register, icon_state = "sm_arc_dbz_referance", time = 10 MINUTES, maxdistance = (shield_range - 1))
	shielded_mobs[mob_to_register] = created_beam
	RegisterSignal(created_beam, COMSIG_PARENT_QDELETING, PROC_REF(beam_died), override = TRUE)
	RegisterSignal(mob_to_register, COMSIG_PARENT_QDELETING, PROC_REF(mob_died), override = TRUE)

/obj/structure/xen_pylon/proc/beam_died(datum/beam/beam_to_kill)
	SIGNAL_HANDLER
	for(var/mob/living/simple_animal/hostile/blackmesa/xen/iterating_mob as anything in shielded_mobs)
		// if(shielded_mobs[iterating_mob] == beam_to_kill)
		iterating_mob.lose_shield()
		shielded_mobs[iterating_mob] = null
		shielded_mobs -= iterating_mob

/obj/structure/xen_pylon/proc/mob_died(atom/movable/source, force)
	SIGNAL_HANDLER
	var/datum/beam/beam = shielded_mobs[source]
	QDEL_NULL(beam)
	shielded_mobs[source] = null
	shielded_mobs -= source

/obj/structure/xen_pylon/Destroy()
	for(var/mob/living/simple_animal/hostile/blackmesa/xen/iterating_mob as anything in shielded_mobs)
		iterating_mob.lose_shield()
		var/datum/beam/beam = shielded_mobs[iterating_mob]
		QDEL_NULL(beam)
		shielded_mobs[iterating_mob] = null
		shielded_mobs -= iterating_mob
	shielded_mobs = null
	playsound(src, 'sound/magic/lightningbolt.ogg', 100, TRUE)
	new /obj/item/grenade/xen_crystal(get_turf(src))
	return ..()

//Porta turrets
/obj/machinery/porta_turret/syndicate/black_mesa
	faction = "xen"
	lethal = TRUE
	max_integrity = 70
	projectile = /obj/item/projectile/beam/emitter
	eprojectile = /obj/item/projectile/beam/emitter
	shot_sound = 'sound/weapons/laser.ogg'
	eshot_sound = 'sound/weapons/laser.ogg'

/obj/machinery/porta_turret/syndicate/black_mesa/hecu
	faction = "hecu"

/obj/machinery/porta_turret/syndicate/black_mesa/blackops
	faction = "blackops"

/obj/machinery/porta_turret/syndicate/black_mesa/heavy
	name = "Heavy Defence Turret"
	max_integrity = 120
	projectile = /obj/item/projectile/beam/laser/heavylaser
	eprojectile = /obj/item/projectile/beam/laser/heavylaser
	shot_sound = 'sound/weapons/lasercannonfire.ogg'
	eshot_sound = 'sound/weapons/lasercannonfire.ogg'

//healing puddle
/obj/structure/sink/puddle/healing
	name = "healing puddle"
	desc = "By some otherworldy power, this puddle of water seems to slowly regenerate things!"
	color = "#71ffff"
	light_range = 3
	light_color = "#71ffff"
	/// How much do we heal the current person?
	var/heal_amount = 2

/obj/structure/sink/puddle/healing/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/sink/puddle/healing/process(seconds_per_tick)
	for(var/mob/living/iterating_mob in loc)
		iterating_mob.heal_overall_damage(heal_amount, heal_amount)
		playsound(src, 'sound/effects/slosh.ogg', 100)

// hev suit storage
/obj/machinery/suit_storage_unit/hev_suit
	name = "HEV suit storage unit"
	helmet_type = /obj/item/clothing/head/helmet/hev_helmet
	suit_type = /obj/item/clothing/suit/space/hev
