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

/obj/structure/shuttle/engine/large/Initialize()
	..()
	var/list/occupied = list()
	for(var/direct in list(EAST,NORTH,NORTHEAST))
		occupied += get_step(src,direct)

	for(var/T in occupied)
		var/obj/structure/filler/F = new(T)
		F.parent = src
		fillers += F

/obj/structure/shuttle/engine/huge/Initialize()
	..()
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

	if(undead.skeleton)
		to_chat(user, span_warning("Этот воин уже отслужил свое."))
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
		undead.visible_message(span_warning ("[undead] отторгает бренную оболочку и предстает в виде скелета!"))
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
