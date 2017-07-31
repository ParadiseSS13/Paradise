/* Tools!
 * Note: Multitools are /obj/item/device
 *
 * Contains:
 * 		Wrench
 * 		Screwdriver
 * 		Wirecutters
 * 		Welding Tool
 * 		Crowbar
 *		Revolver Conversion Kit
 */

//Wrench
/obj/item/weapon/wrench
	name = "wrench"
	desc = "A wrench with common uses. Can be found in your hand."
	icon = 'icons/obj/tools.dmi'
	icon_state = "wrench"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 5
	throwforce = 7
	usesound = 'sound/items/Ratchet.ogg'
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=150)
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")
	toolspeed = 1

/obj/item/weapon/wrench/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is beating themselves to death with [src]! It looks like they're trying to commit suicide!</span>")
	playsound(loc, 'sound/weapons/genhit.ogg', 50, 1, -1)
	return (BRUTELOSS)

/obj/item/weapon/wrench/cyborg
	name = "automatic wrench"
	desc = "An advanced robotic wrench. Can be found in construction cyborgs."
	toolspeed = 0.5

/obj/item/weapon/wrench/brass
	name = "brass wrench"
	desc = "A brass wrench. It's faintly warm to the touch."
	icon_state = "wrench_brass"
	toolspeed = 0.5

/obj/item/weapon/wrench/abductor
	name = "alien wrench"
	desc = "A polarized wrench. It causes anything placed between the jaws to turn."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "wrench"
	usesound = 'sound/effects/EMPulse.ogg'
	toolspeed = 0.1
	origin_tech = "materials=5;engineering=5;abductor=3"

/obj/item/weapon/wrench/power
	name = "hand drill"
	desc = "A simple powered drill with a bolt bit."
	icon_state = "drill_bolt"
	item_state = "drill"
	usesound = 'sound/items/drill_use.ogg'
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_GOLD=25)
	origin_tech = "materials=2;engineering=2" //done for balance reasons, making them high value for research, but harder to get
	force = 8 //might or might not be too high, subject to change
	throwforce = 8
	attack_verb = list("drilled", "screwed", "jabbed")
	toolspeed = 0.25

/obj/item/weapon/wrench/power/attack_self(mob/user)
	playsound(get_turf(user),'sound/items/change_drill.ogg', 50, 1)
	var/obj/item/weapon/wirecutters/power/s_drill = new /obj/item/weapon/screwdriver/power
	to_chat(user, "<span class='notice'>You attach the screwdriver bit to [src].</span>")
	qdel(src)
	user.put_in_active_hand(s_drill)

/obj/item/weapon/wrench/power/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is pressing [src] against their head! It looks like they're trying to commit suicide!")
	return (BRUTELOSS)

/obj/item/weapon/wrench/medical
	name = "medical wrench"
	desc = "A medical wrench with common (medical?) uses. Can be found in your hand."
	icon_state = "wrench_medical"
	force = 2 //MEDICAL
	throwforce = 4
	origin_tech = "materials=1;engineering=1;biotech=3"
	attack_verb = list("wrenched", "medicaled", "tapped", "jabbed", "whacked")

/obj/item/weapon/wrench/medical/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is praying to the medical wrench to take their soul. It looks like they're trying to commit suicide!</span>")
	// TODO Make them glow with the power of the M E D I C A L W R E N C H
	// during their ascension

	// Stun stops them from wandering off
	user.Stun(5)
	playsound(loc, 'sound/effects/pray.ogg', 50, 1, -1)

	// Let the sound effect finish playing
	sleep(20)

	if(!user)
		return

	for(var/obj/item/W in user)
		user.unEquip(W)

	var/obj/item/weapon/wrench/medical/W = new /obj/item/weapon/wrench/medical(loc)
	W.add_fingerprint(user)
	W.desc += " For some reason, it reminds you of [user.name]."

	if(!user)
		return

	user.dust()
	return OXYLOSS

//Screwdriver
/obj/item/weapon/screwdriver
	name = "screwdriver"
	desc = "You can be totally screwy with this."
	icon = 'icons/obj/tools.dmi'
	icon_state = null
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 5
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=75)
	attack_verb = list("stabbed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	usesound = 'sound/items/Screwdriver.ogg'
	toolspeed = 1

/obj/item/weapon/screwdriver/nuke
	name = "screwdriver"
	desc = "A screwdriver with an ultra thin tip."
	icon_state = "screwdriver_nuke"
	toolspeed = 0.5

/obj/item/weapon/screwdriver/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is stabbing [src] into their [pick("temple", "heart")]! It looks like they're trying to commit suicide!</span>")
	return(BRUTELOSS)

/obj/item/weapon/screwdriver/New(loc, var/param_color = null)
	..()
	if(!icon_state)
		if(!param_color)
			param_color = pick("red","blue","pink","brown","green","cyan","yellow")
		icon_state = "screwdriver_[param_color]"

	if (prob(75))
		src.pixel_y = rand(0, 16)

/obj/item/weapon/screwdriver/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M) || user.a_intent == INTENT_HELP)
		return ..()
	if(user.zone_sel.selecting != "eyes" && user.zone_sel.selecting != "head")
		return ..()
	if((CLUMSY in user.mutations) && prob(50))
		M = user
	return eyestab(M,user)

/obj/item/weapon/screwdriver/brass
	name = "brass screwdriver"
	desc = "A screwdriver made of brass. The handle feels freezing cold."
	icon_state = "screwdriver_brass"
	toolspeed = 0.5

/obj/item/weapon/screwdriver/abductor
	name = "alien screwdriver"
	desc = "An ultrasonic screwdriver."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "screwdriver"
	usesound = 'sound/items/PSHOOM.ogg'
	toolspeed = 0.1

/obj/item/weapon/screwdriver/power
	name = "hand drill"
	desc = "A simple hand drill with a screwdriver bit attached."
	icon_state = "drill_screw"
	item_state = "drill"
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_GOLD=25)
	origin_tech = "materials=2;engineering=2" //done for balance reasons, making them high value for research, but harder to get
	force = 8 //might or might not be too high, subject to change
	throwforce = 8
	throw_speed = 2
	throw_range = 3//it's heavier than a screw driver/wrench, so it does more damage, but can't be thrown as far
	attack_verb = list("drilled", "screwed", "jabbed","whacked")
	hitsound = 'sound/items/drill_hit.ogg'
	usesound = 'sound/items/drill_use.ogg'
	toolspeed = 0.25

/obj/item/weapon/screwdriver/power/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is putting [src] to their temple. It looks like they're trying to commit suicide!</span>")
	return(BRUTELOSS)

/obj/item/weapon/screwdriver/power/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_drill.ogg', 50, 1)
	var/obj/item/weapon/wrench/power/b_drill = new /obj/item/weapon/wrench/power
	to_chat(user, "<span class='notice'>You attach the bolt driver bit to [src].</span>")
	qdel(src)
	user.put_in_active_hand(b_drill)

/obj/item/weapon/screwdriver/cyborg
	name = "powered screwdriver"
	desc = "An electrical screwdriver, designed to be both precise and quick."
	usesound = 'sound/items/drill_use.ogg'
	toolspeed = 0.5

//Wirecutters
/obj/item/weapon/wirecutters
	name = "wirecutters"
	desc = "This cuts wires."
	icon = 'icons/obj/tools.dmi'
	icon_state = null
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 6
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=80)
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("pinched", "nipped")
	hitsound = 'sound/items/Wirecutter.ogg'
	usesound = 'sound/items/Wirecutter.ogg'
	sharp = 1
	toolspeed = 1

/obj/item/weapon/wirecutters/New(loc, param_color = null)
	..()
	if(!icon_state)
		if(!param_color)
			param_color = pick("yellow", "red")
		icon_state = "cutters_[param_color]"

/obj/item/weapon/wirecutters/attack(mob/living/carbon/C, mob/user)
	if(istype(C) && C.handcuffed && istype(C.handcuffed, /obj/item/weapon/restraints/handcuffs/cable))
		user.visible_message("<span class='notice'>[user] cuts [C]'s restraints with [src]!</span>")
		QDEL_NULL(C.handcuffed)
		if(C.buckled && C.buckled.buckle_requires_restraints)
			C.buckled.unbuckle_mob(C)
		C.update_handcuffed()
		return
	else
		..()

/obj/item/weapon/wirecutters/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is cutting at their arteries with [src]! It looks like they're trying to commit suicide!</span>")
	playsound(loc, usesound, 50, 1, -1)
	return (BRUTELOSS)

/obj/item/weapon/wirecutters/brass
	name = "brass wirecutters"
	desc = "A pair of wirecutters made of brass. The handle feels freezing cold to the touch."
	icon_state = "cutters_brass"
	toolspeed = 0.5

/obj/item/weapon/wirecutters/abductor
	name = "alien wirecutters"
	desc = "Extremely sharp wirecutters, made out of a silvery-green metal."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "cutters"
	toolspeed = 0.1
	origin_tech = "materials=5;engineering=4;abductor=3"

/obj/item/weapon/wirecutters/cyborg
	name = "wirecutters"
	desc = "This cuts wires."
	toolspeed = 0.5

/obj/item/weapon/wirecutters/power
	name = "jaws of life"
	desc = "A set of jaws of life, the magic of science has managed to fit it down into a device small enough to fit in a tool belt. It's fitted with a cutting head."
	icon_state = "jaws_cutter"
	item_state = "jawsoflife"
	origin_tech = "materials=2;engineering=2"
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_GOLD=25)
	usesound = 'sound/items/jaws_cut.ogg'
	toolspeed = 0.25

/obj/item/weapon/wirecutters/power/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is wrapping \the [src] around their neck. It looks like they're trying to rip their head off!</span>")
	playsound(loc, 'sound/items/jaws_cut.ogg', 50, 1, -1)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/head/head = H.bodyparts_by_name["head"]
		if(head)
			head.droplimb(0, DROPLIMB_BLUNT, FALSE, TRUE)
			playsound(loc,pick('sound/misc/desceration-01.ogg','sound/misc/desceration-02.ogg','sound/misc/desceration-01.ogg') ,50, 1, -1)
	return (BRUTELOSS)

/obj/item/weapon/wirecutters/power/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_jaws.ogg', 50, 1)
	var/obj/item/weapon/crowbar/power/pryjaws = new /obj/item/weapon/crowbar/power
	to_chat(user, "<span class='notice'>You attach the pry jaws to [src].</span>")
	qdel(src)
	user.put_in_active_hand(pryjaws)

//Welding Tool
/obj/item/weapon/weldingtool
	name = "welding tool"
	desc = "A standard edition welder provided by Nanotrasen."
	icon = 'icons/obj/tools.dmi'
	icon_state = "welder"
	item_state = "welder"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	hitsound = "swing_hit"
	usesound = 'sound/items/Welder.ogg'
	var/acti_sound = 'sound/items/WelderActivate.ogg'
	var/deac_sound = 'sound/items/WelderDeactivate.ogg'
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=70, MAT_GLASS=30)
	origin_tech = "engineering=1;plasmatech=1"
	toolspeed = 1
	var/welding = 0 	//Whether or not the welding tool is off(0), on(1) or currently welding(2)
	var/status = 1 		//Whether the welder is secured or unsecured (able to attach rods to it to make a flamethrower)
	var/max_fuel = 20 	//The max amount of fuel the welder can hold
	var/change_icons = 1
	var/can_off_process = 0
	var/light_intensity = 2 //how powerful the emitted light is when used.
	var/nextrefueltick = 0

/obj/item/weapon/weldingtool/New()
	..()
	create_reagents(max_fuel)
	reagents.add_reagent("fuel", max_fuel)
	update_icon()

/obj/item/weapon/weldingtool/examine(mob/user)
	if(..(user, 0))
		to_chat(user, "It contains [get_fuel()] unit\s of fuel out of [max_fuel].")

/obj/item/weapon/weldingtool/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] welds their every orifice closed! It looks like they're trying to commit suicide!</span>")
	return (FIRELOSS)

/obj/item/weapon/weldingtool/proc/update_torch()
	overlays.Cut()
	if(welding)
		overlays += "[initial(icon_state)]-on"
		item_state = "[initial(item_state)]1"
	else
		item_state = "[initial(item_state)]"

/obj/item/weapon/weldingtool/update_icon()
	if(change_icons)
		var/ratio = get_fuel() / max_fuel
		ratio = Ceiling(ratio*4) * 25
		if(ratio == 100)
			icon_state = initial(icon_state)
		else
			icon_state = "[initial(icon_state)][ratio]"
	update_torch()

/obj/item/weapon/weldingtool/process()
	switch(welding)
		if(0)
			force = 3
			damtype = "brute"
			update_icon()
			if(!can_off_process)
				processing_objects.Remove(src)
			return
	//Welders left on now use up fuel, but lets not have them run out quite that fast
		if(1)
			force = 15
			damtype = "fire"
			if(prob(5))
				remove_fuel(1)
			update_icon()

	//This is to start fires. process() is only called if the welder is on.
	var/turf/location = loc
	if(ismob(location))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = get_turf(M)
	if(isturf(location))
		location.hotspot_expose(700, 5)

/obj/item/weapon/weldingtool/attackby(obj/item/I, mob/user, params)
	if(isscrewdriver(I))
		flamethrower_screwdriver(I, user)
	else if(istype(I, /obj/item/stack/rods))
		flamethrower_rods(I, user)
	else
		..()

/obj/item/weapon/weldingtool/attack(mob/M, mob/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/S = H.bodyparts_by_name[user.zone_sel.selecting]
		if(!S)
			return

		if(!(S.status & ORGAN_ROBOT) || user.a_intent != INTENT_HELP || S.open == 2)
			return ..()

		if(!isOn())		//why wasn't this being checked already?
			to_chat(user, "<span class='warning'>Turn on [src] before attempting repairs!</span>")
			return 1

		if(S.brute_dam)
			if(S.brute_dam < ROBOLIMB_SELF_REPAIR_CAP)
				if(get_fuel() >= 1)
					if(H == user)
						if(!do_mob(user, H, 10))
							return 1
					if(remove_fuel(1,null))
						playsound(src.loc, usesound, 50, 1)
						S.heal_damage(15,0,0,1)
						user.visible_message("<span class='alert'>\The [user] patches some dents on \the [M]'s [S.name] with \the [src].</span>")
				else if(S.open != 2)
					to_chat(user, "<span class='warning'>Need more welding fuel!</span>")
					return 1
			else
				to_chat(user, "<span class='danger'>The damage is far too severe to patch over externally.</span>")
			return 1
		else if(S.open != 2)
			to_chat(user, "<span class='notice'>Nothing to fix!</span>")
	else
		return ..()

/obj/item/weapon/weldingtool/afterattack(atom/O, mob/user, proximity)
	if(!proximity)
		return

	if(welding)
		remove_fuel(1)
		var/turf/location = get_turf(user)
		location.hotspot_expose(700, 50, 1)
		if(get_fuel() <= 0)
			set_light(0)

		if(isliving(O))
			var/mob/living/L = O
			if(L.IgniteMob())
				message_admins("[key_name_admin(user)] set [key_name_admin(L)] on fire")
				log_game("[key_name(user)] set [key_name(L)] on fire")

/obj/item/weapon/weldingtool/attack_self(mob/user)
	switched_on(user)
	if(welding)
		set_light(light_intensity)

	update_icon()

//Returns the amount of fuel in the welder
/obj/item/weapon/weldingtool/proc/get_fuel()
	return reagents.get_reagent_amount("fuel")

//Removes fuel from the welding tool. If a mob is passed, it will try to flash the mob's eyes. This should probably be renamed to use()
/obj/item/weapon/weldingtool/proc/remove_fuel(amount = 1, mob/living/M = null)
	if(!welding || !check_fuel())
		return FALSE
	if(get_fuel() >= amount)
		reagents.remove_reagent("fuel", amount)
		check_fuel()
		if(M)
			M.flash_eyes(light_intensity)
		return TRUE
	else
		if(M)
			to_chat(M, "<span class='notice'>You need more welding fuel to complete this task.</span>")
		return FALSE

//Returns whether or not the welding tool is currently on.
/obj/item/weapon/weldingtool/proc/isOn()
	return welding

//Turns off the welder if there is no more fuel (does this really need to be its own proc?)
/obj/item/weapon/weldingtool/proc/check_fuel(mob/user)
	if(get_fuel() <= 0 && welding)
		switched_on(user)
		update_icon()
		//mob icon update
		if(ismob(loc))
			var/mob/M = loc
			M.update_inv_r_hand(0)
			M.update_inv_l_hand(0)
		return 0
	return 1

//Switches the welder on
/obj/item/weapon/weldingtool/proc/switched_on(mob/user)
	if(!status)
		to_chat(user, "<span class='warning'>[src] can't be turned on while unsecured!</span>")
		return
	welding = !welding
	if(welding)
		if(get_fuel() >= 1)
			to_chat(user, "<span class='notice'>You switch [src] on.</span>")
			playsound(loc, acti_sound, 50, 1)
			force = 15
			damtype = "fire"
			hitsound = 'sound/items/welder.ogg'
			update_icon()
			processing_objects.Add(src)
		else
			to_chat(user, "<span class='warning'>You need more fuel!</span>")
			switched_off(user)
	else
		if(user)
			to_chat(user, "<span class='notice'>You switch [src] off.</span>")
		playsound(loc, deac_sound, 50, 1)
		switched_off(user)

//Switches the welder off
/obj/item/weapon/weldingtool/proc/switched_off(mob/user)
	welding = 0
	set_light(0)

	force = 3
	damtype = "brute"
	hitsound = "swing_hit"
	update_icon()

/obj/item/weapon/weldingtool/proc/flamethrower_screwdriver(obj/item/I, mob/user)
	if(welding)
		to_chat(user, "<span class='warning'>Turn it off first!</span>")
		return
	status = !status
	if(status)
		to_chat(user, "<span class='notice'>You resecure [src].</span>")
	else
		to_chat(user, "<span class='notice'>[src] can now be attached and modified.</span>")
	add_fingerprint(user)

/obj/item/weapon/weldingtool/proc/flamethrower_rods(obj/item/I, mob/user)
	if(!status)
		var/obj/item/stack/rods/R = I
		if(R.use(1))
			var/obj/item/weapon/flamethrower/F = new /obj/item/weapon/flamethrower(user.loc)
			if(!remove_item_from_storage(F))
				user.unEquip(src)
				loc = F
			F.weldtool = src
			add_fingerprint(user)
			to_chat(user, "<span class='notice'>You add a rod to a welder, starting to build a flamethrower.</span>")
			user.put_in_hands(F)
		else
			to_chat(user, "<span class='warning'>You need one rod to start building a flamethrower!</span>")

/obj/item/weapon/weldingtool/largetank
	name = "Industrial Welding Tool"
	desc = "A slightly larger welder with a larger tank."
	icon_state = "indwelder"
	max_fuel = 40
	materials = list(MAT_METAL=70, MAT_GLASS=60)
	origin_tech = "engineering=2;plasmatech=2"

/obj/item/weapon/weldingtool/largetank/cyborg
	name = "integrated welding tool"
	desc = "An advanced welder designed to be used in robotic systems."
	toolspeed = 0.5

/obj/item/weapon/weldingtool/largetank/flamethrower_screwdriver()
	return

/obj/item/weapon/weldingtool/mini
	name = "emergency welding tool"
	desc = "A miniature welder used during emergencies."
	icon_state = "miniwelder"
	max_fuel = 10
	w_class = WEIGHT_CLASS_TINY
	materials = list(MAT_METAL=30, MAT_GLASS=10)
	change_icons = 0

/obj/item/weapon/weldingtool/mini/flamethrower_screwdriver()
	return

/obj/item/weapon/weldingtool/abductor
	name = "alien welding tool"
	desc = "An alien welding tool. Whatever fuel it uses, it never runs out."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "welder"
	toolspeed = 0.1
	light_intensity = 0
	change_icons = 0
	origin_tech = "plasmatech=5;engineering=5;abductor=3"
	can_off_process = 1

/obj/item/weapon/weldingtool/abductor/process()
	if(get_fuel() <= max_fuel)
		reagents.add_reagent("fuel", 1)
	..()

/obj/item/weapon/weldingtool/hugetank
	name = "Upgraded Welding Tool"
	desc = "An upgraded welder based off the industrial welder."
	icon_state = "upindwelder"
	item_state = "upindwelder"
	max_fuel = 80
	materials = list(MAT_METAL=70, MAT_GLASS=120)
	origin_tech = "engineering=3;plasmatech=2"

/obj/item/weapon/weldingtool/experimental
	name = "Experimental Welding Tool"
	desc = "An experimental welder capable of self-fuel generation and less harmful to the eyes."
	icon_state = "exwelder"
	item_state = "exwelder"
	max_fuel = 40
	materials = list(MAT_METAL=70, MAT_GLASS=120)
	origin_tech = "materials=4;engineering=4;bluespace=3;plasmatech=4"
	change_icons = 0
	can_off_process = 1
	light_intensity = 1
	toolspeed = 0.5
	var/last_gen = 0

/obj/item/weapon/weldingtool/experimental/brass
	name = "brass welding tool"
	desc = "A brass welder that seems to constantly refuel itself. It is faintly warm to the touch."
	icon_state = "brasswelder"
	item_state = "brasswelder"

obj/item/weapon/weldingtool/experimental/process()
	..()
	if(get_fuel() < max_fuel && nextrefueltick < world.time)
		nextrefueltick = world.time + 10
		reagents.add_reagent("fuel", 1)

//Crowbar
/obj/item/weapon/crowbar
	name = "pocket crowbar"
	desc = "A small crowbar. This handy tool is useful for lots of things, such as prying floor tiles or opening unpowered doors."
	icon = 'icons/obj/tools.dmi'
	icon_state = "crowbar"
	item_state = "crowbar"
	usesound = 'sound/items/Crowbar.ogg'
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 5
	throwforce = 7
	item_state = "crowbar"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=50)
	origin_tech = "engineering=1;combat=1"
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	toolspeed = 1

/obj/item/weapon/crowbar/red
	icon_state = "crowbar_red"
	item_state = "crowbar_red"
	force = 8

/obj/item/weapon/crowbar/brass
	name = "brass crowbar"
	desc = "A brass crowbar. It feels faintly warm to the touch."
	icon_state = "crowbar_brass"
	item_state = "crowbar_brass"
	toolspeed = 0.5

/obj/item/weapon/crowbar/abductor
	name = "alien crowbar"
	desc = "A hard-light crowbar. It appears to pry by itself, without any effort required."
	icon = 'icons/obj/abductor.dmi'
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	icon_state = "crowbar"
	toolspeed = 0.1
	origin_tech = "combat=4;engineering=4;abductor=3"

/obj/item/weapon/crowbar/large
	name = "crowbar"
	desc = "It's a big crowbar. It doesn't fit in your pockets, because its too big."
	force = 12
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 3
	materials = list(MAT_METAL=70)
	icon_state = "crowbar_large"
	item_state = "crowbar_large"
	toolspeed = 0.5

/obj/item/weapon/crowbar/cyborg
	name = "hydraulic crowbar"
	desc = "A hydraulic prying tool, compact but powerful. Designed to replace crowbar in construction cyborgs."
	usesound = 'sound/items/jaws_pry.ogg'
	force = 10
	toolspeed = 0.5

/obj/item/weapon/crowbar/power
	name = "jaws of life"
	desc = "A set of jaws of life, the magic of science has managed to fit it down into a device small enough to fit in a tool belt. It's fitted with a prying head."
	icon_state = "jaws_pry"
	item_state = "jawsoflife"
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_DIAMOND=25)
	origin_tech = "materials=2;engineering=2"
	usesound = 'sound/items/jaws_pry.ogg'
	force = 15
	toolspeed = 0.25
	var/airlock_open_time = 100 // Time required to open powered airlocks

/obj/item/weapon/crowbar/power/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is putting their head in [src], it looks like they're trying to commit suicide!</span>")
	playsound(loc, 'sound/items/jaws_pry.ogg', 50, 1, -1)
	return (BRUTELOSS)

/obj/item/weapon/crowbar/power/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_jaws.ogg', 50, 1)
	var/obj/item/weapon/wirecutters/power/cutjaws = new /obj/item/weapon/wirecutters/power
	to_chat(user, "<span class='notice'>You attach the cutting jaws to [src].</span>")
	qdel(src)
	user.put_in_active_hand(cutjaws)

// Conversion kit
/obj/item/weapon/conversion_kit
	name = "\improper Revolver Conversion Kit"
	desc = "A professional conversion kit used to convert any knock off revolver into the real deal capable of shooting lethal .357 rounds without the possibility of catastrophic failure."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "kit"
	flags = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "combat=2"
	var/open = 0

/obj/item/weapon/conversion_kit/New()
	..()
	update_icon()

/obj/item/weapon/conversion_kit/update_icon()
	icon_state = "[initial(icon_state)]_[open]"

/obj/item/weapon/conversion_kit/attack_self(mob/user)
	open = !open
	to_chat(user, "<span class='notice'>You [open ? "open" : "close"] the conversion kit.</span>")
	update_icon()
