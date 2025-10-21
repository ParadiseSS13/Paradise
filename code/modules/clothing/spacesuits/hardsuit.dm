//Baseline hardsuits
/obj/item/clothing/head/helmet/space/hardsuit
	name = "hardsuit helmet"
	icon_state = null
	base_icon_state = "engineering"
	max_integrity = 300
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 5, RAD = 150, FIRE = 50, ACID = 150)
	allowed = list(/obj/item/flashlight)
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/toggle_geiger_counter)
	var/basestate = "hardsuit"
	var/brightness_on = 4 //luminosity when on
	var/on = FALSE
	var/obj/item/clothing/suit/space/hardsuit/suit

	var/scanning = TRUE
	var/current_tick_amount = 0
	var/radiation_count = 0
	var/grace = RAD_GEIGER_GRACE_PERIOD
	var/datum/looping_sound/geiger/soundloop

	//Species-specific stuff.
	sprite_sheets = list(
		"Unathi" = 'icons/mob/clothing/species/unathi/helmet.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/helmet.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/helmet.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/helmet.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/helmet.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/helmet.dmi'
		)

/obj/item/clothing/head/helmet/space/hardsuit/Initialize(mapload)
	. = ..()
	soundloop = new(list(), FALSE, TRUE)
	soundloop.volume = 5
	START_PROCESSING(SSobj, src)

/obj/item/clothing/head/helmet/space/hardsuit/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(soundloop)
	suit = null
	return ..()

/obj/item/clothing/head/helmet/space/hardsuit/attack_self__legacy__attackchain(mob/user)
	toggle_light(user)

/obj/item/clothing/head/helmet/space/hardsuit/proc/toggle_light(mob/user)
	on = !on
	icon_state = "[basestate][on]-[base_icon_state]"

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_head()

	if(on)
		set_light(brightness_on)
	else
		set_light(0)
	update_action_buttons()

/obj/item/clothing/head/helmet/space/hardsuit/extinguish_light(force = FALSE)
	if(on)
		toggle_light()
		visible_message("<span class='danger'>[src]'s light fades and turns off.</span>")

/obj/item/clothing/head/helmet/space/hardsuit/dropped(mob/user)
	..()
	if(suit)
		suit.RemoveHelmet()
		soundloop.stop(user)

/obj/item/clothing/head/helmet/space/hardsuit/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_HEAD)
		return 1

/obj/item/clothing/head/helmet/space/hardsuit/equipped(mob/user, slot)
	..()
	if(slot != ITEM_SLOT_HEAD)
		if(suit)
			suit.RemoveHelmet()
			soundloop.stop(user)
		else
			qdel(src)
	else if(scanning)
		soundloop.start(user)

/obj/item/clothing/head/helmet/space/hardsuit/proc/display_visor_message(msg)
	var/mob/wearer = loc
	if(msg && ishuman(wearer))
		wearer.show_message("<b><span class='robot'>[msg]</span></b>", 1)

/obj/item/clothing/head/helmet/space/hardsuit/rad_act(atom/source, amount, emission_type)
	current_tick_amount += amount

/obj/item/clothing/head/helmet/space/hardsuit/process()
	if(scanning)
		radiation_count -= radiation_count / RAD_GEIGER_MEASURE_SMOOTHING
		radiation_count += current_tick_amount / RAD_GEIGER_MEASURE_SMOOTHING

		if(current_tick_amount)
			grace = RAD_GEIGER_GRACE_PERIOD
		else
			grace--
			if(grace <= 0)
				radiation_count = 0

	current_tick_amount = 0

	if(ishuman(loc))
		update_sound()

/obj/item/clothing/head/helmet/space/hardsuit/proc/update_sound()
	var/datum/looping_sound/geiger/loop = soundloop
	if(!scanning || !radiation_count)
		loop.stop(loc)
		return
	loop.last_radiation = radiation_count
	loop.start(loc)

/obj/item/clothing/head/helmet/space/hardsuit/proc/toggle_geiger_counter()
	scanning = !scanning
	if(ishuman(loc))
		to_chat(loc, "<span class='notice'>You toggle [src]'s internal geiger counter [scanning ? "on" : "off"].</span>")

/obj/item/clothing/head/helmet/space/hardsuit/emp_act(severity)
	..()
	display_visor_message("[severity > EMP_HEAVY ? "Light" : "Strong"] electromagnetic pulse detected!")

/obj/item/clothing/suit/space/hardsuit
	name = "hardsuit"
	desc = "A special space suit for environments that might pose hazards beyond just the vacuum of space. Provides more protection than a standard space suit."
	icon_state = null
	inhand_icon_state = "eng_hardsuit"
	max_integrity = 300
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 5, RAD = 150, FIRE = 50, ACID = 150)
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals,/obj/item/t_scanner, /obj/item/rcd, /obj/item/rpd)
	siemens_coefficient = 0
	actions_types = list(/datum/action/item_action/toggle_helmet)

	hide_tail_by_species = list("Vox" , "Vulpkanin" , "Unathi" , "Tajaran")
	sprite_sheets = list(
		"Unathi" = 'icons/mob/clothing/species/unathi/suit.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/suit.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/suit.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi'
		)

	var/obj/item/clothing/head/helmet/space/hardsuit/helmet
	var/helmettype = /obj/item/clothing/head/helmet/space/hardsuit
	var/obj/item/tank/jetpack/suit/jetpack = null

/obj/item/clothing/suit/space/hardsuit/Initialize(mapload)
	. = ..()
	MakeHelmet()
	if(ispath(jetpack))
		jetpack = new jetpack(src)

/obj/item/clothing/suit/space/hardsuit/Destroy()
	QDEL_NULL(helmet)
	QDEL_NULL(jetpack)
	return ..()

/obj/item/clothing/suit/space/hardsuit/proc/MakeHelmet()
	if(!helmettype)
		return
	if(!helmet)
		var/obj/item/clothing/head/helmet/space/hardsuit/W = new helmettype(src)
		W.suit = src
		helmet = W

/obj/item/clothing/suit/space/hardsuit/attack_self__legacy__attackchain(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	..()

/obj/item/clothing/suit/space/hardsuit/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank/jetpack/suit))
		if(jetpack)
			to_chat(user, "<span class='warning'>[src] already has a jetpack installed.</span>")
			return
		if(src == user.get_item_by_slot(ITEM_SLOT_OUTER_SUIT)) //Make sure the player is not wearing the suit before applying the upgrade.
			to_chat(user, "<span class='warning'>You cannot install the upgrade to [src] while wearing it.</span>")
			return

		if(user.temperature_expose(I))
			I.forceMove(src)
			jetpack = I
			to_chat(user, "<span class='notice'>You successfully install the jetpack into [src].</span>")
			return
	return ..()

/obj/item/clothing/suit/space/hardsuit/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!jetpack)
		to_chat(user, "<span class='warning'>[src] has no jetpack installed.</span>")
		return
	if(src == user.get_item_by_slot(ITEM_SLOT_OUTER_SUIT))
		to_chat(user, "<span class='warning'>You cannot remove the jetpack from [src] while wearing it.</span>")
		return
	jetpack.turn_off(user)
	jetpack.forceMove(drop_location())
	jetpack = null
	to_chat(user, "<span class='notice'>You successfully remove the jetpack from [src].</span>")

/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot)
	..()
	if(helmettype && slot != ITEM_SLOT_OUTER_SUIT)
		RemoveHelmet()
	if(jetpack)
		if(slot == ITEM_SLOT_OUTER_SUIT)
			for(var/X in jetpack.actions)
				var/datum/action/A = X
				A.Grant(user)

/obj/item/clothing/suit/space/hardsuit/dropped(mob/user)
	..()
	RemoveHelmet()
	if(jetpack)
		for(var/X in jetpack.actions)
			var/datum/action/A = X
			A.Remove(user)

/obj/item/clothing/suit/space/hardsuit/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_OUTER_SUIT) //we only give the mob the ability to toggle the helmet if he's wearing the hardsuit.
		return 1

/obj/item/clothing/suit/space/hardsuit/on_mob_move(dir, mob/mob)
	if(jetpack && isturf(mob.loc))
		jetpack.on_mob_move(dir, mob)

//Syndicate hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/syndi
	name = "blood-red hardsuit helmet"
	desc = "A dual-mode advanced helmet designed for work in special operations. It is in travel mode. Property of Gorlex Marauders."
	alt_desc = "A dual-mode advanced helmet designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	base_icon_state = "syndi"
	armor = list(MELEE = 35, BULLET = 50, LASER = 20, ENERGY = 10, BOMB = 25, RAD = 50, FIRE = 50, ACID = 450)
	on = TRUE
	var/obj/item/clothing/suit/space/hardsuit/syndi/linkedsuit = null
	actions_types = list(/datum/action/item_action/toggle_helmet_mode)
	visor_flags_inv = HIDEMASK|HIDEEYES|HIDEFACE|HIDETAIL
	visor_flags = STOPSPRESSUREDMAGE

/obj/item/clothing/head/helmet/space/hardsuit/syndi/update_icon_state()
	icon_state = "hardsuit[on]-[base_icon_state]"

/obj/item/clothing/head/helmet/space/hardsuit/syndi/Initialize(mapload)
	. = ..()
	if(istype(loc, /obj/item/clothing/suit/space/hardsuit/syndi))
		linkedsuit = loc

/obj/item/clothing/head/helmet/space/hardsuit/syndi/Destroy()
	linkedsuit = null
	return ..()

/obj/item/clothing/head/helmet/space/hardsuit/syndi/attack_self__legacy__attackchain(mob/user) //Toggle Helmet
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You cannot toggle your helmet while in this [user.loc]!</span>" )
		return
	on = !on
	if(on)
		to_chat(user, "<span class='notice'>You switch your hardsuit to EVA mode, sacrificing speed for space protection.</span>")
		name = initial(name)
		desc = initial(desc)
		set_light(brightness_on)
		flags |= visor_flags
		flags_cover |= HEADCOVERSEYES | HEADCOVERSMOUTH
		flags_inv |= visor_flags_inv
		cold_protection |= HEAD
	else
		to_chat(user, "<span class='notice'>You switch your hardsuit to combat mode and can now run at full speed.</span>")
		name += " (combat)"
		desc = alt_desc
		set_light(0)
		flags &= ~visor_flags
		flags_cover &= ~(HEADCOVERSEYES | HEADCOVERSMOUTH)
		flags_inv &= ~visor_flags_inv
		cold_protection &= ~HEAD
	update_icon()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	toggle_hardsuit_mode(user)
	user.update_inv_head()
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.head_update(src, forced = 1)
	update_action_buttons()

/obj/item/clothing/head/helmet/space/hardsuit/syndi/proc/toggle_hardsuit_mode(mob/user) //Helmet Toggles Suit Mode
	if(linkedsuit)
		if(on)
			linkedsuit.name = initial(linkedsuit.name)
			linkedsuit.desc = initial(linkedsuit.desc)
			linkedsuit.slowdown = 1
			linkedsuit.flags |= STOPSPRESSUREDMAGE
			linkedsuit.cold_protection |= UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
			linkedsuit.on = TRUE
		else
			linkedsuit.name += " (combat)"
			linkedsuit.desc = linkedsuit.alt_desc
			linkedsuit.slowdown = 0
			linkedsuit.flags &= ~STOPSPRESSUREDMAGE
			linkedsuit.cold_protection &= ~(UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS)
			linkedsuit.on = FALSE

		linkedsuit.update_icon()
		user.update_inv_wear_suit()
		user.update_inv_w_uniform()

/obj/item/clothing/suit/space/hardsuit/syndi
	name = "blood-red hardsuit"
	desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in travel mode. Property of Gorlex Marauders."
	alt_desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	inhand_icon_state = "syndie_hardsuit"
	base_icon_state = "syndi"
	origin_tech = "engineering=6;syndicate=4"
	w_class = WEIGHT_CLASS_NORMAL
	var/on = TRUE
	actions_types = list(/datum/action/item_action/toggle_hardsuit_mode)
	armor = list(MELEE = 35, BULLET = 50, LASER = 20, ENERGY = 10, BOMB = 25, RAD = 50, FIRE = 50, ACID = 450)
	allowed = list(/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi
	jetpack = /obj/item/tank/jetpack/suit

/obj/item/clothing/suit/space/hardsuit/syndi/update_icon_state()
	icon_state = "hardsuit[on]-[base_icon_state]"

//Elite Syndie suit
/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	name = "elite syndicate hardsuit helmet"
	desc = "An elite version of the syndicate helmet, with improved armour and fire shielding. It is in travel mode. Property of Gorlex Marauders."
	icon_state = "hardsuit0-syndielite"
	base_icon_state = "syndielite"
	armor = list(MELEE = 75, BULLET = 75, LASER = 50, ENERGY = 15, BOMB = 60, RAD = 115, FIRE = INFINITY, ACID = INFINITY)
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/space/hardsuit/syndi/elite
	name = "elite syndicate hardsuit"
	desc = "An elite version of the syndicate hardsuit, with improved armour and fire shielding. It is in travel mode."
	icon_state = "hardsuit0-syndielite"
	base_icon_state = "syndielite"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	armor = list(MELEE = 75, BULLET = 75, LASER = 50, ENERGY = 15, BOMB = 60, RAD = 115, FIRE = INFINITY, ACID = INFINITY)
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

//Strike team hardsuits
/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/sst
	armor = list(MELEE = 115, BULLET = 115, LASER = 50, ENERGY = 35, BOMB = 200, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY) //Almost as good as DS gear, but unlike DS can switch to combat for mobility
	flags_2 = RAD_PROTECT_CONTENTS_2
	icon_state = "hardsuit0-sst"
	base_icon_state = "sst"

/obj/item/clothing/suit/space/hardsuit/syndi/elite/sst
	armor = list(MELEE = 115, BULLET = 115, LASER = 50, ENERGY = 40, BOMB = 200, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)
	flags_2 = RAD_PROTECT_CONTENTS_2
	icon_state = "hardsuit0-sst"
	base_icon_state = "sst"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/sst

/obj/item/clothing/suit/space/hardsuit/syndi/elite/sst/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_HYPOSPRAY_IMMUNE, ROUNDSTART_TRAIT)
	ADD_TRAIT(src, TRAIT_RSG_IMMUNE, ROUNDSTART_TRAIT)

/obj/item/clothing/suit/space/hardsuit/syndi/freedom
	name = "eagle suit"
	desc = "An advanced, light suit, fabricated from a mixture of synthetic feathers and space-resistant material. A gun holster appears to be integrated into the suit."
	icon_state = "freedom"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/freedom
	sprite_sheets = null

/obj/item/clothing/suit/space/hardsuit/syndi/freedom/update_icon_state()
	return

/obj/item/clothing/head/helmet/space/hardsuit/syndi/freedom
	name = "eagle helmet"
	desc = "An advanced, space-proof helmet. It appears to be modeled after an old-world eagle."
	icon_state = "griffinhat"
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hat.dmi'
	sprite_sheets = null

/obj/item/clothing/head/helmet/space/hardsuit/syndi/freedom/update_icon_state()
	return

//Soviet hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/soviet
	name = "\improper Soviet hardsuit helmet"
	desc = "A military hardsuit helmet bearing the red star of the U.S.S.P."
	icon_state = "hardsuit0-soviet"
	base_icon_state = "soviet"
	armor = list(MELEE = 35, BULLET = 15, LASER = 30, ENERGY = 10, BOMB = 10, RAD = 50, FIRE = 75, ACID = 75)

/obj/item/clothing/suit/space/hardsuit/soviet
	name = "\improper Soviet hardsuit"
	desc = "A soviet military hardsuit designed for maximum speed and mobility. Proudly displays the U.S.S.P flag on the chest."
	icon_state = "hardsuit-soviet"
	inhand_icon_state = null
	slowdown = 0.5
	armor = list(MELEE = 35, BULLET = 15, LASER = 30, ENERGY = 10, BOMB = 10, RAD = 50, FIRE = 75, ACID = 75)
	allowed = list(/obj/item/gun, /obj/item/flashlight, /obj/item/tank/internals, /obj/item/melee/baton, /obj/item/reagent_containers/spray/pepper, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/restraints/handcuffs)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/soviet
	jetpack = /obj/item/tank/jetpack/suit

/obj/item/clothing/head/helmet/space/hardsuit/soviet/commander
	name = "\improper Soviet command hardsuit helmet"
	desc = "A military hardsuit helmet with a red command stripe."
	icon_state = "hardsuit0-soviet-commander"
	base_icon_state = "soviet-commander"

/obj/item/clothing/suit/space/hardsuit/soviet/commander
	name = "\improper Soviet command hardsuit"
	desc = "A soviet military command hardsuit designed for maximum speed and mobility."
	icon_state = "hardsuit-soviet-commander"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/soviet/commander

//Singuloth armor
/obj/item/clothing/head/helmet/space/hardsuit/singuloth
	name = "singuloth knight's helmet"
	desc = "This is an adamantium helmet from the chapter of the Singuloth Knights. It shines with a holy aura."
	icon_state = "hardsuit0-singuloth"
	base_icon_state = "singuloth"
	armor = list(MELEE = 35, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 15, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)
	flags_2 = RAD_PROTECT_CONTENTS_2
	sprite_sheets = null

/obj/item/clothing/suit/space/hardsuit/singuloth
	name = "singuloth knight's armor"
	desc = "This is a ceremonial armor from the chapter of the Singuloth Knights. It's made of pure forged adamantium."
	icon_state = "hardsuit-singuloth"
	flags = STOPSPRESSUREDMAGE
	flags_2 = RAD_PROTECT_CONTENTS_2
	armor = list(MELEE = 35, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 15, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/singuloth
	sprite_sheets = null
