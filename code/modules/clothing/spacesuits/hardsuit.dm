//Baseline hardsuits
/obj/item/clothing/head/helmet/space/hardsuit
	name = "hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	icon_state = "hardsuit0-engineering"
	item_state = "eng_helm"
	max_integrity = 300
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 5, RAD = 150, FIRE = 50, ACID = 150)
	var/basestate = "hardsuit"
	allowed = list(/obj/item/flashlight)
	var/brightness_on = 4 //luminosity when on
	var/on = FALSE
	var/obj/item/clothing/suit/space/hardsuit/suit
	item_color = "engineering" //Determines used sprites: hardsuit[on]-[color] and hardsuit[on]-[color]2 (lying down sprite)
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/toggle_geiger_counter)

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
	sprite_sheets_obj = list(
		"Unathi" = 'icons/obj/clothing/species/unathi/hats.dmi',
		"Tajaran" = 'icons/obj/clothing/species/tajaran/hats.dmi',
		"Skrell" = 'icons/obj/clothing/species/skrell/hats.dmi',
		"Vox" = 'icons/obj/clothing/species/vox/hats.dmi',
		"Vulpkanin" = 'icons/obj/clothing/species/vulpkanin/hats.dmi'
		)

/obj/item/clothing/head/helmet/space/hardsuit/Initialize(mapload)
	. = ..()
	soundloop = new(list(), FALSE, TRUE)
	soundloop.volume = 5
	START_PROCESSING(SSobj, src)

/obj/item/clothing/head/helmet/space/hardsuit/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(soundloop)
	return ..()

/obj/item/clothing/head/helmet/space/hardsuit/attack_self(mob/user)
	toggle_light(user)

/obj/item/clothing/head/helmet/space/hardsuit/proc/toggle_light(mob/user)
	on = !on
	icon_state = "[basestate][on]-[item_color]"

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_head()

	if(on)
		set_light(brightness_on)
	else
		set_light(0)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

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
	if(slot == SLOT_HUD_HEAD)
		return 1

/obj/item/clothing/head/helmet/space/hardsuit/equipped(mob/user, slot)
	..()
	if(slot != SLOT_HUD_HEAD)
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

/obj/item/clothing/head/helmet/space/hardsuit/rad_act(amount)
	. = ..()
	if(amount <= RAD_BACKGROUND_RADIATION)
		return
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
	display_visor_message("[severity > 1 ? "Light" : "Strong"] electromagnetic pulse detected!")

/obj/item/clothing/suit/space/hardsuit
	name = "hardsuit"
	desc = "A special space suit for environments that might pose hazards beyond just the vacuum of space. Provides more protection than a standard space suit."
	icon_state = "hardsuit-engineering"
	item_state = "eng_hardsuit"
	max_integrity = 300
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 5, RAD = 150, FIRE = 50, ACID = 150)
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals,/obj/item/t_scanner, /obj/item/rcd, /obj/item/rpd)
	siemens_coefficient = 0
	var/obj/item/clothing/head/helmet/space/hardsuit/helmet
	actions_types = list(/datum/action/item_action/toggle_helmet)
	var/helmettype = /obj/item/clothing/head/helmet/space/hardsuit
	var/obj/item/tank/jetpack/suit/jetpack = null

	hide_tail_by_species = list("Vox" , "Vulpkanin" , "Unathi" , "Tajaran")
	sprite_sheets = list(
		"Unathi" = 'icons/mob/clothing/species/unathi/suit.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/suit.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/suit.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi'
		)
	sprite_sheets_obj = list(
		"Unathi" = 'icons/obj/clothing/species/unathi/suits.dmi',
		"Tajaran" = 'icons/obj/clothing/species/tajaran/suits.dmi',
		"Skrell" = 'icons/obj/clothing/species/skrell/suits.dmi',
		"Vox" = 'icons/obj/clothing/species/vox/suits.dmi',
		"Vulpkanin" = 'icons/obj/clothing/species/vulpkanin/suits.dmi'
		)

/obj/item/clothing/suit/space/hardsuit/Initialize(mapload)
	. = ..()
	MakeHelmet()
	if(ispath(jetpack))
		jetpack = new jetpack(src)

/obj/item/clothing/suit/space/hardsuit/Destroy()
	QDEL_NULL(helmet)
	QDEL_NULL(jetpack)
	return ..()

/obj/item/clothing/head/helmet/space/hardsuit/Destroy()
	suit = null
	return ..()

/obj/item/clothing/suit/space/hardsuit/proc/MakeHelmet()
	if(!helmettype)
		return
	if(!helmet)
		var/obj/item/clothing/head/helmet/space/hardsuit/W = new helmettype(src)
		W.suit = src
		helmet = W

/obj/item/clothing/suit/space/hardsuit/attack_self(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	..()

/obj/item/clothing/suit/space/hardsuit/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank/jetpack/suit))
		if(jetpack)
			to_chat(user, "<span class='warning'>[src] already has a jetpack installed.</span>")
			return
		if(src == user.get_item_by_slot(SLOT_HUD_OUTER_SUIT)) //Make sure the player is not wearing the suit before applying the upgrade.
			to_chat(user, "<span class='warning'>You cannot install the upgrade to [src] while wearing it.</span>")
			return

		if(user.unEquip(I))
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
	if(src == user.get_item_by_slot(SLOT_HUD_OUTER_SUIT))
		to_chat(user, "<span class='warning'>You cannot remove the jetpack from [src] while wearing it.</span>")
		return
	jetpack.turn_off(user)
	jetpack.forceMove(drop_location())
	jetpack = null
	to_chat(user, "<span class='notice'>You successfully remove the jetpack from [src].</span>")

/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot)
	..()
	if(jetpack)
		if(slot == SLOT_HUD_OUTER_SUIT)
			for(var/X in jetpack.actions)
				var/datum/action/A = X
				A.Grant(user)

/obj/item/clothing/suit/space/hardsuit/dropped(mob/user)
	..()
	if(jetpack)
		for(var/X in jetpack.actions)
			var/datum/action/A = X
			A.Remove(user)

/obj/item/clothing/suit/space/hardsuit/item_action_slot_check(slot)
	if(slot == SLOT_HUD_OUTER_SUIT) //we only give the mob the ability to toggle the helmet if he's wearing the hardsuit.
		return 1

/obj/item/clothing/suit/space/hardsuit/on_mob_move(dir, mob)
	if(jetpack)
		jetpack.on_mob_move(dir, mob)

//Syndicate hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/syndi
	name = "blood-red hardsuit helmet"
	desc = "A dual-mode advanced helmet designed for work in special operations. It is in travel mode. Property of Gorlex Marauders."
	alt_desc = "A dual-mode advanced helmet designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_helm"
	item_color = "syndi"
	armor = list(MELEE = 35, BULLET = 50, LASER = 20, ENERGY = 10, BOMB = 25, RAD = 50, FIRE = 50, ACID = 450)
	on = TRUE
	var/obj/item/clothing/suit/space/hardsuit/syndi/linkedsuit = null
	actions_types = list(/datum/action/item_action/toggle_helmet_mode)
	visor_flags_inv = HIDEMASK|HIDEEYES|HIDEFACE|HIDETAIL
	visor_flags = STOPSPRESSUREDMAGE

/obj/item/clothing/head/helmet/space/hardsuit/syndi/update_icon_state()
	icon_state = "hardsuit[on]-[item_color]"

/obj/item/clothing/head/helmet/space/hardsuit/syndi/Initialize(mapload)
	. = ..()
	if(istype(loc, /obj/item/clothing/suit/space/hardsuit/syndi))
		linkedsuit = loc

/obj/item/clothing/head/helmet/space/hardsuit/syndi/Destroy()
	linkedsuit = null
	return ..()

/obj/item/clothing/head/helmet/space/hardsuit/syndi/attack_self(mob/user) //Toggle Helmet
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
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

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
	item_state = "syndie_hardsuit"
	item_color = "syndi"
	origin_tech = "engineering=6;syndicate=4"
	w_class = WEIGHT_CLASS_NORMAL
	var/on = TRUE
	actions_types = list(/datum/action/item_action/toggle_hardsuit_mode)
	armor = list(MELEE = 35, BULLET = 50, LASER = 20, ENERGY = 10, BOMB = 25, RAD = 50, FIRE = 50, ACID = 450)
	allowed = list(/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi
	jetpack = /obj/item/tank/jetpack/suit

/obj/item/clothing/suit/space/hardsuit/syndi/update_icon_state()
	icon_state = "hardsuit[on]-[item_color]"

//Elite Syndie suit
/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	name = "elite syndicate hardsuit helmet"
	desc = "An elite version of the syndicate helmet, with improved armour and fire shielding. It is in travel mode. Property of Gorlex Marauders."
	icon_state = "hardsuit0-syndielite"
	item_color = "syndielite"
	armor = list(MELEE = 75, BULLET = 75, LASER = 50, ENERGY = 15, BOMB = 60, RAD = 115, FIRE = INFINITY, ACID = INFINITY)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/space/hardsuit/syndi/elite
	name = "elite syndicate hardsuit"
	desc = "An elite version of the syndicate hardsuit, with improved armour and fire shielding. It is in travel mode."
	icon_state = "hardsuit0-syndielite"
	item_color = "syndielite"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	armor = list(MELEE = 75, BULLET = 75, LASER = 50, ENERGY = 15, BOMB = 60, RAD = 115, FIRE = INFINITY, ACID = INFINITY)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

//Strike team hardsuits
/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/sst
	armor = list(MELEE = 115, BULLET = 115, LASER = 50, ENERGY = 35, BOMB = 200, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY) //Almost as good as DS gear, but unlike DS can switch to combat for mobility
	icon_state = "hardsuit0-sst"
	item_color = "sst"

/obj/item/clothing/suit/space/hardsuit/syndi/elite/sst
	armor = list(MELEE = 115, BULLET = 115, LASER = 50, ENERGY = 40, BOMB = 200, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)
	icon_state = "hardsuit0-sst"
	item_color = "sst"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/sst

/obj/item/clothing/suit/space/hardsuit/syndi/elite/sst/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_PUNCTURE_IMMUNE, ROUNDSTART_TRAIT)

/obj/item/clothing/suit/space/hardsuit/syndi/freedom
	name = "eagle suit"
	desc = "An advanced, light suit, fabricated from a mixture of synthetic feathers and space-resistant material. A gun holster appears to be integrated into the suit."
	icon_state = "freedom"
	item_state = "freedom"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/freedom
	sprite_sheets = null

/obj/item/clothing/suit/space/hardsuit/syndi/freedom/update_icon_state()
	return

/obj/item/clothing/head/helmet/space/hardsuit/syndi/freedom
	name = "eagle helmet"
	desc = "An advanced, space-proof helmet. It appears to be modeled after an old-world eagle."
	icon_state = "griffinhat"
	item_state = "griffinhat"
	sprite_sheets = null

/obj/item/clothing/head/helmet/space/hardsuit/syndi/freedom/update_icon_state()
	return

//Soviet hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/soviet
	name = "\improper Soviet hardsuit helmet"
	desc = "A military hardsuit helmet bearing the red star of the U.S.S.P."
	icon_state = "hardsuit0-soviet"
	item_state = "hardsuit0-soviet"
	item_color = "soviet"
	armor = list(MELEE = 35, BULLET = 15, LASER = 30, ENERGY = 10, BOMB = 10, RAD = 50, FIRE = 75, ACID = 75)

/obj/item/clothing/suit/space/hardsuit/soviet
	name = "\improper Soviet hardsuit"
	desc = "A soviet military hardsuit designed for maximum speed and mobility. Proudly displays the U.S.S.P flag on the chest."
	icon_state = "hardsuit-soviet"
	item_state = "hardsuit-soviet"
	slowdown = 0.5
	armor = list(MELEE = 35, BULLET = 15, LASER = 30, ENERGY = 10, BOMB = 10, RAD = 50, FIRE = 75, ACID = 75)
	allowed = list(/obj/item/gun, /obj/item/flashlight, /obj/item/tank/internals, /obj/item/melee/baton, /obj/item/reagent_containers/spray/pepper, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/restraints/handcuffs)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/soviet
	jetpack = /obj/item/tank/jetpack/suit

/obj/item/clothing/head/helmet/space/hardsuit/soviet/commander
	name = "\improper Soviet command hardsuit helmet"
	desc = "A military hardsuit helmet with a red command stripe."
	icon_state = "hardsuit0-soviet-commander"
	item_state = "hardsuit0-soviet-commander"
	item_color = "soviet-commander"

/obj/item/clothing/suit/space/hardsuit/soviet/commander
	name = "\improper Soviet command hardsuit"
	desc = "A soviet military command hardsuit designed for maximum speed and mobility."
	icon_state = "hardsuit-soviet-commander"
	item_state = "hardsuit-soviet-commander"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/soviet/commander

//Security
/obj/item/clothing/head/helmet/space/hardsuit/security
	name = "security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "hardsuit0-sec"
	item_state = "sec_helm"
	item_color = "sec"
	armor = list(MELEE = 25, BULLET = 10, LASER = 20, ENERGY = 5, BOMB = 5, RAD = 50, FIRE = 150, ACID = 150)

/obj/item/clothing/suit/space/hardsuit/security
	name = "security hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	icon_state = "hardsuit-sec"
	item_state = "sec_hardsuit"
	armor = list(MELEE = 25, BULLET = 10, LASER = 20, ENERGY = 5, BOMB = 5, RAD = 50, FIRE = 150, ACID = 150)
	allowed = list(/obj/item/gun,/obj/item/flashlight,/obj/item/tank/internals,/obj/item/melee/baton,/obj/item/reagent_containers/spray/pepper,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/restraints/handcuffs)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security

/obj/item/clothing/head/helmet/space/hardsuit/security/hos
	name = "head of security's hardsuit helmet"
	desc = "A special bulky helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "hardsuit0-hos"
	item_color = "hos"
	armor = list(MELEE = 40, BULLET = 15, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 50, FIRE = INFINITY, ACID = INFINITY)

/obj/item/clothing/suit/space/hardsuit/security/hos
	name = "head of security's hardsuit"
	desc = "A special bulky suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	icon_state = "hardsuit-hos"
	armor = list(MELEE = 40, BULLET = 15, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 50, FIRE = INFINITY, ACID = INFINITY)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security/hos
	jetpack = /obj/item/tank/jetpack/suit


//Singuloth armor
/obj/item/clothing/head/helmet/space/hardsuit/singuloth
	name = "singuloth knight's helmet"
	desc = "This is an adamantium helmet from the chapter of the Singuloth Knights. It shines with a holy aura."
	icon_state = "hardsuit0-singuloth"
	item_state = "singuloth_helm"
	item_color = "singuloth"
	armor = list(MELEE = 35, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 15, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)
	sprite_sheets = null

/obj/item/clothing/suit/space/hardsuit/singuloth
	name = "singuloth knight's armor"
	desc = "This is a ceremonial armor from the chapter of the Singuloth Knights. It's made of pure forged adamantium."
	icon_state = "hardsuit-singuloth"
	item_state = "singuloth_hardsuit"
	flags = STOPSPRESSUREDMAGE
	armor = list(MELEE = 35, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 15, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/singuloth
	sprite_sheets = null


/////////////SHIELDED//////////////////////////////////

/obj/item/clothing/suit/space/hardsuit/shielded
	name = "shielded hardsuit"
	desc = "A hardsuit with built in energy shielding. Will rapidly recharge when not under fire."
	icon_state = "hardsuit-hos"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals, /obj/item/gun,/obj/item/reagent_containers/spray/pepper,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs)
	armor = list(MELEE = 20, BULLET = 10, LASER = 20, ENERGY = 5, BOMB = 5, RAD = 50, FIRE = INFINITY, ACID = INFINITY)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/current_charges = 3
	var/max_charges = 3 //How many charges total the shielding has
	var/recharge_delay = 200 //How long after we've been shot before we can start recharging. 20 seconds here
	var/recharge_cooldown = 0 //Time since we've last been shot
	var/recharge_rate = 1 //How quickly the shield recharges once it starts charging
	var/shield_state = "shield-old"
	var/shield_on = "shield-old"

/obj/item/clothing/suit/space/hardsuit/shielded/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	recharge_cooldown = world.time + recharge_delay
	if(current_charges > 0)
		do_sparks(2, 1, src)
		owner.visible_message("<span class='danger'>[owner]'s shields deflect [attack_text] in a shower of sparks!</span>")
		current_charges--
		if(recharge_rate)
			START_PROCESSING(SSobj, src)
		if(istype(hitby, /obj/item/projectile))
			var/obj/item/projectile/P = hitby
			if(P.shield_buster)
				current_charges = max(0, current_charges - 3)
		if(current_charges <= 0)
			owner.visible_message("<span class='warning'>[owner]'s shield overloads!</span>")
			shield_state = "broken"
			owner.update_inv_wear_suit()
		return 1
	return 0



/obj/item/clothing/suit/space/hardsuit/shielded/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/suit/space/hardsuit/shielded/process()
	if(world.time > recharge_cooldown && current_charges < max_charges)
		current_charges = clamp((current_charges + recharge_rate), 0, max_charges)
		playsound(loc, 'sound/magic/charge.ogg', 50, TRUE)
		if(current_charges == max_charges)
			playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
			STOP_PROCESSING(SSobj, src)
		shield_state = "[shield_on]"
		if(ishuman(loc))
			var/mob/living/carbon/human/C = loc
			C.update_inv_wear_suit()

/obj/item/clothing/suit/space/hardsuit/shielded/special_overlays()
	return mutable_appearance('icons/effects/effects.dmi', shield_state, MOB_LAYER + 0.01)

/obj/item/clothing/head/helmet/space/hardsuit/shielded
	name = "shielded hardsuit helmet"
	desc = "A hardsuit helmet with built in energy shielding. Will rapidly recharge when not under fire."
	icon_state = "hardsuit0-sec"
	item_state = "sec_helm"
	item_color = "sec"
	armor = list(MELEE = 20, BULLET = 10, LASER = 20, ENERGY = 5, BOMB = 5, RAD = 50, FIRE = INFINITY, ACID = INFINITY)
	resistance_flags = FIRE_PROOF | ACID_PROOF


//////Syndicate Version

/obj/item/clothing/suit/space/hardsuit/shielded/syndi
	name = "blood-red hardsuit"
	desc = "An advanced hardsuit with built in energy shielding."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_hardsuit"
	shield_state = "shield-red"
	shield_on = "shield-red"
	item_color = "syndi"
	armor = list(MELEE = 35, BULLET = 50, LASER = 20, ENERGY = 10, BOMB = 25, RAD = 50, FIRE = INFINITY, ACID = INFINITY)
	allowed = list(/obj/item/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/melee/energy/sword/saber,/obj/item/restraints/handcuffs,/obj/item/tank/internals)
	slowdown = 0
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi
	jetpack = /obj/item/tank/jetpack/suit

/obj/item/clothing/suit/space/hardsuit/shielded/syndi/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(shield_state == "broken")
		to_chat(user, "<span class='warning'>You can't interface with the hardsuit's software if the shield's broken!</span>")
		return

	if(shield_state == "shield-red")
		shield_state = "shield-old"
		shield_on = "shield-old"
		to_chat(user, "<span class='warning'>You roll back the hardsuit's software, changing the shield's color!</span>")

	else
		shield_state = "shield-red"
		shield_on = "shield-red"
		to_chat(user, "<span class='warning'>You update the hardsuit's hardware, changing back the shield's color to red.</span>")
	user.update_inv_wear_suit()

/obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi
	name = "blood-red hardsuit helmet"
	desc = "An advanced hardsuit helmet with built in energy shielding."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_helm"
	item_color = "syndi"
	armor = list(MELEE = 35, BULLET = 50, LASER = 20, ENERGY = 10, BOMB = 25, RAD = 50, FIRE = INFINITY, ACID = INFINITY)


//////Security Version (Gamma armory only)

/obj/item/clothing/suit/space/hardsuit/shielded/gamma
	name = "shielded security hardsuit"
	desc = "A more advanced version of the normal security hardsuit. Comes with built in energy shielding."
	icon_state = "hardsuit-sec"
	item_state = "sec-hardsuit"
	armor = list(MELEE = 25, BULLET = 10, LASER = 20, ENERGY = 5, BOMB = 5, RAD = 50, FIRE = 150, ACID = 150)
	allowed = list(/obj/item/gun,/obj/item/flashlight,/obj/item/tank,/obj/item/melee/baton,/obj/item/reagent_containers/spray/pepper,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/restraints/handcuffs)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/gamma

/obj/item/clothing/head/helmet/space/hardsuit/shielded/gamma
	name = "shielded security hardsuit helmet"
	desc = "A more advanced version of the normal security hardsuit helmet. Comes with built in energy shielding."
	icon_state = "hardsuit0-sec"
	item_state = "sec_helm"
	item_color = "sec"
	armor = list(MELEE = 25, BULLET = 10, LASER = 20, ENERGY = 5, BOMB = 5, RAD = 50, FIRE = 150, ACID = 150)

