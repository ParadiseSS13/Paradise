// The lighting system
//
// consists of light fixtures (/obj/machinery/light) and light tube/bulb items (/obj/item/light)


// status values shared between lighting fixtures and items
#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3

/obj/machinery/light_construct
	name = "light fixture frame"
	desc = "A light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-stage1"
	anchored = 1
	layer = 5
	armor = list(melee = 50, bullet = 10, laser = 10, energy = 0, bomb = 0, bio = 0, rad = 0)
	var/stage = 1
	var/fixture_type = "tube"
	var/sheets_refunded = 2
	var/obj/machinery/light/newlight = null

/obj/machinery/light_construct/New()
	..()
	if(fixture_type == "bulb")
		icon_state = "bulb-construct-stage1"

/obj/machinery/light_construct/examine(mob/user)
	if(..(user, 2))
		switch(src.stage)
			if(1)
				to_chat(usr, "It's an empty frame.")
			if(2)
				to_chat(usr, "It's wired.")
			if(3)
				to_chat(usr, "The casing is closed.")

/obj/machinery/light_construct/attackby(obj/item/W as obj, mob/living/user as mob, params)
	src.add_fingerprint(user)
	if(istype(W, /obj/item/wrench))
		if(src.stage == 1)
			playsound(src.loc, W.usesound, 75, 1)
			to_chat(usr, "You begin deconstructing [src].")
			if(!do_after(usr, 30 * W.toolspeed, target = src))
				return
			new /obj/item/stack/sheet/metal( get_turf(src.loc), sheets_refunded )
			user.visible_message("[user.name] deconstructs [src].", \
				"You deconstruct [src].", "You hear a noise.")
			playsound(src.loc, W.usesound, 75, 1)
			qdel(src)
		if(src.stage == 2)
			to_chat(usr, "You have to remove the wires first.")
			return

		if(src.stage == 3)
			to_chat(usr, "You have to unscrew the case first.")
			return

	if(istype(W, /obj/item/wirecutters))
		if(src.stage != 2) return
		src.stage = 1
		switch(fixture_type)
			if("tube")
				src.icon_state = "tube-construct-stage1"
			if("bulb")
				src.icon_state = "bulb-construct-stage1"
		new /obj/item/stack/cable_coil(get_turf(src.loc), 1, paramcolor = COLOR_RED)
		user.visible_message("[user.name] removes the wiring from [src].", \
			"You remove the wiring from [src].", "You hear a noise.")
		playsound(loc, W.usesound, 100, 1)
		return

	if(istype(W, /obj/item/stack/cable_coil))
		if(src.stage != 1) return
		var/obj/item/stack/cable_coil/coil = W
		coil.use(1)
		switch(fixture_type)
			if("tube")
				src.icon_state = "tube-construct-stage2"
			if("bulb")
				src.icon_state = "bulb-construct-stage2"
		src.stage = 2
		playsound(loc, coil.usesound, 50, 1)
		user.visible_message("[user.name] adds wires to [src].", \
			"You add wires to [src].")
		return

	if(istype(W, /obj/item/screwdriver))
		if(src.stage == 2)
			switch(fixture_type)
				if("tube")
					src.icon_state = "tube-empty"
				if("bulb")
					src.icon_state = "bulb-empty"
			src.stage = 3
			user.visible_message("[user.name] closes [src]'s casing.", \
				"You close [src]'s casing.", "You hear a noise.")
			playsound(src.loc, W.usesound, 75, 1)

			switch(fixture_type)

				if("tube")
					newlight = new /obj/machinery/light/built(src.loc)
				if("bulb")
					newlight = new /obj/machinery/light/small/built(src.loc)

			newlight.dir = src.dir
			src.transfer_fingerprints_to(newlight)
			qdel(src)
			return
	..()

/obj/machinery/light_construct/small
	name = "small light fixture frame"
	desc = "A small light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-construct-stage1"
	anchored = 1
	layer = 5
	stage = 1
	fixture_type = "bulb"
	sheets_refunded = 1


// the standard tube light fixture
/obj/machinery/light
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	var/base_state = "tube"		// base description and icon_state
	icon_state = "tube1"
	desc = "A lighting fixture."
	anchored = 1
	layer = 5  					// They were appearing under mobs which is a little weird - Ostaf
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 20
	power_channel = LIGHT //Lights are calc'd via area so they dont need to be in the machine list
	var/on = FALSE					// 1 if on, 0 if off
	var/on_gs = 0
	var/static_power_used = 0
	var/brightness_range = 8	// luminosity when on, also used in power calculation
	var/brightness_power = 1
	var/brightness_color = "#FFFFFF"
	var/status = LIGHT_OK		// LIGHT_OK, _EMPTY, _BURNED or _BROKEN
	var/flickering = 0
	var/light_type = /obj/item/light/tube		// the type of light item
	var/fitting = "tube"
	var/switchcount = 0			// count of number of times switched on/off
								// this is used to calc the probability the light burns out

	var/rigged = 0				// true if rigged to explode
	var/lightmaterials = list(MAT_GLASS=100)	//stores the materials the light is made of to stop infinite glass exploit

	var/nightshift_enabled = FALSE	//Currently in night shift mode?
	var/nightshift_allowed = TRUE	//Set to FALSE to never let this light get switched to night mode.
	var/nightshift_light_range = 8
	var/nightshift_light_power = 0.45
	var/nightshift_light_color = "#FFDDCC"

// the smaller bulb light fixture

/obj/machinery/light/small
	icon_state = "bulb1"
	base_state = "bulb"
	fitting = "bulb"
	brightness_range = 4
	brightness_color = "#a0a080"
	nightshift_light_range = 4
	desc = "A small lighting fixture."
	light_type = /obj/item/light/bulb

/obj/machinery/light/spot
	name = "spotlight"
	fitting = "large tube"
	light_type = /obj/item/light/tube/large
	brightness_range = 12
	brightness_power = 4

/obj/machinery/light/built/New()
	status = LIGHT_EMPTY
	update(0)
	..()

/obj/machinery/light/small/built/New()
	status = LIGHT_EMPTY
	update(0)
	..()

// create a new lighting fixture
/obj/machinery/light/New()
	..()
	spawn(2)
		var/area/A = get_area(src)
		if(A && !A.requires_power)
			on = 1

		switch(fitting)
			if("tube")
				brightness_range = 8
				if(prob(2))
					broken(1)
			if("bulb")
				brightness_range = 4
				brightness_color = "#a0a080"
				if(prob(5))
					broken(1)
		spawn(1)
			update(0)

/obj/machinery/light/Destroy()
	var/area/A = get_area(src)
	if(A)
		on = FALSE
//		A.update_lights()
	return ..()

/obj/machinery/light/update_icon()

	switch(status)		// set icon_states
		if(LIGHT_OK)
			icon_state = "[base_state][on]"
		if(LIGHT_EMPTY)
			icon_state = "[base_state]-empty"
			on = FALSE
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
			on = FALSE
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
			on = FALSE
	return

/obj/machinery/light/get_spooked()
	flicker()

// update the icon_state and luminosity of the light depending on its state
/obj/machinery/light/proc/update(var/trigger = TRUE)
	switch(status)
		if(LIGHT_BROKEN, LIGHT_BURNED, LIGHT_EMPTY)
			on = FALSE
	update_icon()
	if(on)
		var/BR = nightshift_enabled ? nightshift_light_range : brightness_range
		var/PO = nightshift_enabled ? nightshift_light_power : brightness_power
		var/CO = nightshift_enabled ? nightshift_light_color : brightness_color
		var/matching = light_range == BR && light_power == PO && light_color == CO
		if(!matching)
			switchcount++
			if(rigged)
				if(status == LIGHT_OK && trigger)
					log_admin("LOG: Rigged light explosion, last touched by [fingerprintslast]")
					message_admins("LOG: Rigged light explosion, last touched by [fingerprintslast]")
					explode()
			else if(prob(min(60, switchcount * switchcount * 0.01)))
				if(status == LIGHT_OK && trigger)
					status = LIGHT_BURNED
					icon_state = "[base_state]-burned"
					on = FALSE
					set_light(0)
			else
				use_power = ACTIVE_POWER_USE
				set_light(BR, PO, CO)
	else
		use_power = IDLE_POWER_USE
		set_light(0)

	active_power_usage = (brightness_range * 10)
	if(on != on_gs)
		on_gs = on
		if(on)
			static_power_used = brightness_range * 20 //20W per unit luminosity
			addStaticPower(static_power_used, STATIC_LIGHT)
		else
			removeStaticPower(static_power_used, STATIC_LIGHT)

// attempt to set the light's on/off status
// will not switch on if broken/burned/empty
/obj/machinery/light/proc/seton(var/s)
	on = (s && status == LIGHT_OK)
	update()

// examine verb
/obj/machinery/light/examine(mob/user)
	if(..(user, 1))
		switch(status)
			if(LIGHT_OK)
				to_chat(user, "[desc] It is turned [on? "on" : "off"].")
			if(LIGHT_EMPTY)
				to_chat(user, "[desc] The [fitting] has been removed.")
			if(LIGHT_BURNED)
				to_chat(user, "[desc] The [fitting] is burnt out.")
			if(LIGHT_BROKEN)
				to_chat(user, "[desc] The [fitting] has been smashed.")



// attack with item - insert light (if right type), otherwise try to break the light

/obj/machinery/light/attackby(obj/item/W, mob/living/user, params)
	user.changeNext_move(CLICK_CD_MELEE) //does not call parent requires manual definition
	//Light replacer code
	if(istype(W, /obj/item/lightreplacer))
		var/obj/item/lightreplacer/LR = W
		if(isliving(user))
			var/mob/living/U = user
			LR.ReplaceLight(src, U)
			return

	// attempt to insert light
	if(istype(W, /obj/item/light))
		if(status != LIGHT_EMPTY)
			to_chat(user, "There is a [fitting] already inserted.")
			return
		else
			src.add_fingerprint(user)
			var/obj/item/light/L = W
			if(istype(L, light_type))
				status = L.status
				to_chat(user, "You insert the [L.name].")
				switchcount = L.switchcount
				rigged = L.rigged
				brightness_range = L.brightness_range
				brightness_power = L.brightness_power
				brightness_color = L.brightness_color
				lightmaterials = L.materials
				on = has_power()
				update()

				user.drop_item()	//drop the item to update overlays and such
				qdel(L)

				if(on && rigged)

					log_admin("LOG: Rigged light explosion, last touched by [fingerprintslast]")
					message_admins("LOG: Rigged light explosion, last touched by [fingerprintslast]")

					explode()
			else
				to_chat(user, "This type of light requires a [fitting].")
				return

		// attempt to break the light
		//If xenos decide they want to smash a light bulb with a toolbox, who am I to stop them? /N

	else if(status != LIGHT_BROKEN && status != LIGHT_EMPTY)

		user.do_attack_animation(src)
		if(prob(1+W.force * 5))

			to_chat(user, "You hit the light, and it smashes!")
			for(var/mob/M in viewers(src))
				if(M == user)
					continue
				M.show_message("[user.name] smashed the light!", 3, "You hear a tinkle of breaking glass", 2)
			if(on && (W.flags & CONDUCT))
				if(prob(12))
					electrocute_mob(user, get_area(src), src, 0.3, TRUE)
			broken()

		else
			user.visible_message("<span class='danger'>[user.name] hits the light.</span>")
			playsound(src.loc, 'sound/effects/glasshit.ogg', 75, 1)

	// attempt to stick weapon into light socket
	else if(status == LIGHT_EMPTY)
		if(istype(W, /obj/item/screwdriver)) //If it's a screwdriver open it.
			playsound(src.loc, W.usesound, 75, 1)
			user.visible_message("[user.name] opens [src]'s casing.", \
				"You open [src]'s casing.", "You hear a noise.")
			var/obj/machinery/light_construct/newlight = null
			switch(fitting)
				if("tube")
					newlight = new /obj/machinery/light_construct(src.loc)
					newlight.icon_state = "tube-construct-stage2"

				if("bulb")
					newlight = new /obj/machinery/light_construct/small(src.loc)
					newlight.icon_state = "bulb-construct-stage2"
			newlight.dir = src.dir
			newlight.stage = 2
			newlight.fingerprints = src.fingerprints
			newlight.fingerprintshidden = src.fingerprintshidden
			newlight.fingerprintslast = src.fingerprintslast
			qdel(src)
			return

		to_chat(user, "You stick \the [W] into the light socket!")
		if(has_power() && (W.flags & CONDUCT))
			do_sparks(3, 1, src)
			if(prob(75))
				electrocute_mob(user, get_area(src), src, rand(0.7, 1), TRUE)


// returns whether this light has power
// true if area has power and lightswitch is on
/obj/machinery/light/proc/has_power()
	var/area/A = get_area(src)
	return A.lightswitch && A.power_light

/obj/machinery/light/proc/flicker(var/amount = rand(10, 20))
	if(flickering) return
	flickering = 1
	spawn(0)
		if(on && status == LIGHT_OK)
			for(var/i = 0; i < amount; i++)
				if(status != LIGHT_OK) break
				on = !on
				update(0)
				sleep(rand(5, 15))
			on = (status == LIGHT_OK)
			update(0)
		flickering = 0

// ai attack - make lights flicker, because why not
/obj/machinery/light/attack_ai(mob/user)
	src.flicker(1)
	return

// Aliens smash the bulb but do not get electrocuted./N
/obj/machinery/light/attack_alien(mob/living/carbon/alien/humanoid/user)//So larva don't go breaking light bulbs.
	if(status == LIGHT_EMPTY||status == LIGHT_BROKEN)
		to_chat(user, "<span class=notice'>That object is useless to you.</span>")
		return
	else if(status == LIGHT_OK||status == LIGHT_BURNED)
		user.do_attack_animation(src)
		visible_message("<span class='danger'>[user.name] smashed the light!</span>", "You hear a tinkle of breaking glass")
		broken()
	return

/obj/machinery/light/attack_animal(mob/living/simple_animal/M)
	if(M.melee_damage_upper == 0)	return
	if(status == LIGHT_EMPTY||status == LIGHT_BROKEN)
		to_chat(M, "<span class='warning'>That object is useless to you.</span>")
		return
	else if(status == LIGHT_OK||status == LIGHT_BURNED)
		M.do_attack_animation(src)
		visible_message("<span class='danger'>[M.name] smashed the light!</span>", "You hear a tinkle of breaking glass")
		broken()
	return
// attack with hand - remove tube/bulb
// if hands aren't protected and the light is on, burn the player

/obj/machinery/light/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)

	if(status == LIGHT_EMPTY)
		to_chat(user, "There is no [fitting] in this light.")
		return

	// make it burn hands if not wearing fire-insulated gloves
	if(on)
		var/prot = 0
		var/mob/living/carbon/human/H = user

		if(istype(H))
			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves
				if(G.max_heat_protection_temperature)
					prot = (G.max_heat_protection_temperature > 360)
		else
			prot = 1

		if(prot > 0 || (HEATRES in user.mutations))
			to_chat(user, "You remove the light [fitting]")
		else if(TK in user.mutations)
			to_chat(user, "You telekinetically remove the light [fitting].")
		else
			if(user.a_intent == INTENT_DISARM || user.a_intent == INTENT_GRAB)
				to_chat(user, "You try to remove the light [fitting], but you burn your hand on it!")

				var/obj/item/organ/external/affecting = H.get_organ("[user.hand ? "l" : "r" ]_hand")
				if(affecting.receive_damage( 0, 5 ))		// 5 burn damage
					H.UpdateDamageIcon()
				H.updatehealth()
				return
			else
				to_chat(user, "You try to remove the light [fitting], but it's too hot to touch!")
				return
	else
		to_chat(user, "You remove the light [fitting].")


	// create a light tube/bulb item and put it in the user's hand
	var/obj/item/light/L = new light_type(get_turf(user))
	L.status = status
	L.rigged = rigged
	L.brightness_range = brightness_range
	L.brightness_power = brightness_power
	L.brightness_color = brightness_color
	L.materials = lightmaterials

	// light item inherits the switchcount, then zero it
	L.switchcount = switchcount
	switchcount = 0

	L.update()
	L.add_fingerprint(user)

	user.put_in_hands(L)	//puts it in our active hand

	status = LIGHT_EMPTY
	update()

// break the light and make sparks if was on

/obj/machinery/light/attack_tk(mob/user)
	if(status == LIGHT_EMPTY)
		to_chat(user, "There is no [fitting] in this light.")
		return

	to_chat(user, "You telekinetically remove the light [fitting].")
	// create a light tube/bulb item and put it in the user's hand
	var/obj/item/light/L = new light_type()
	L.status = status
	L.rigged = rigged
	L.brightness_range = brightness_range
	L.brightness_power = brightness_power
	L.brightness_color = brightness_color
	L.materials = lightmaterials

	// light item inherits the switchcount, then zero it
	L.switchcount = switchcount
	switchcount = 0

	L.update()
	L.add_fingerprint(user)
	L.loc = loc

	status = LIGHT_EMPTY
	update()

/obj/machinery/light/proc/broken(skip_sound_and_sparks = 0, overloaded = 0)
	if(status == LIGHT_EMPTY || status == LIGHT_BROKEN)
		return

	if(!skip_sound_and_sparks)
		if(status == LIGHT_OK || status == LIGHT_BURNED)
			playsound(src.loc, 'sound/effects/glasshit.ogg', 75, 1)
		if(on || overloaded)
			do_sparks(3, 1, src)
	status = LIGHT_BROKEN
	update()

/obj/machinery/light/proc/fix()
	if(status == LIGHT_OK)
		return
	status = LIGHT_OK
	on = 1
	update()

/obj/machinery/light/tesla_act(power, explosive = FALSE)
	if(explosive)
		explosion(loc,0,0,0,flame_range = 5, adminlog = 0)
	qdel(src)

// explosion effect
// destroy the whole light fixture or just shatter it

/obj/machinery/light/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			broken()
		if(3.0)
			broken()
	return

//blob effect

/obj/machinery/light/blob_act()
	if(prob(75))
		qdel(src)


// timed process
// use power

// called when area power state changes
/obj/machinery/light/power_change()
	var/area/A = get_area(src)
	if(A)
		seton(A.lightswitch && A.power_light)

// called when on fire

/obj/machinery/light/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(prob(max(0, exposed_temperature - 673)))   //0% at <400C, 100% at >500C
		broken()

// explode the light

/obj/machinery/light/proc/explode()
	var/turf/T = get_turf(src.loc)
	spawn(0)
		broken()	// break it first to give a warning
		sleep(2)
		explosion(T, 0, 0, 2, 2)
		sleep(1)
		qdel(src)

// the light item
// can be tube or bulb subtypes
// will fit into empty /obj/machinery/light of the corresponding type

/obj/item/light
	icon = 'icons/obj/lighting.dmi'
	force = 2
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	var/status = 0		// LIGHT_OK, LIGHT_BURNED or LIGHT_BROKEN
	var/base_state
	var/switchcount = 0	// number of times switched
	materials = list(MAT_GLASS=100)
	var/rigged = 0		// true if rigged to explode
	var/brightness_range = 2 //how much light it gives off
	var/brightness_power = 1
	var/brightness_color = null

/obj/item/light/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "ltube"
	base_state = "ltube"
	item_state = "c_tube"
	brightness_range = 8

/obj/item/light/tube/large
	w_class = WEIGHT_CLASS_SMALL
	name = "large light tube"
	brightness_range = 15
	brightness_power = 2

/obj/item/light/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
	icon_state = "lbulb"
	base_state = "lbulb"
	item_state = "contvapour"
	brightness_range = 5
	brightness_color = "#a0a080"

/obj/item/light/throw_impact(atom/hit_atom)
	..()
	shatter()

/obj/item/light/bulb/fire
	name = "fire bulb"
	desc = "A replacement fire bulb."
	icon_state = "fbulb"
	base_state = "fbulb"
	item_state = "egg4"
	brightness_range = 5

// update the icon state and description of the light

/obj/item/light/proc/update()
	switch(status)
		if(LIGHT_OK)
			icon_state = base_state
			desc = "A replacement [name]."
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
			desc = "A burnt-out [name]."
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
			desc = "A broken [name]."


/obj/item/light/New()
	..()
	switch(name)
		if("light tube")
			brightness_range = rand(6,9)
		if("light bulb")
			brightness_range = rand(4,6)
	update()


// attack bulb/tube with object
// if a syringe, can inject plasma to make it explode
/obj/item/light/attackby(var/obj/item/I, var/mob/user, params)
	..()
	if(istype(I, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/syringe/S = I

		to_chat(user, "You inject the solution into the [src].")

		if(S.reagents.has_reagent("plasma", 5) || S.reagents.has_reagent("plasma_dust", 5))

			log_admin("LOG: [key_name(user)] injected a light with plasma, rigging it to explode.")
			message_admins("LOG: [key_name_admin(user)] injected a light with plasma, rigging it to explode.")

			rigged = 1

		S.reagents.clear_reagents()
	else
		..()
	return

// called after an attack with a light item
// shatter light, unless it was an attempt to put it in a light socket
// now only shatter if the intent was harm

/obj/item/light/afterattack(atom/target, mob/user, proximity)
	if(!proximity) return
	if(istype(target, /obj/machinery/light))
		return
	if(user.a_intent != INTENT_HARM)
		return

	shatter()

/obj/item/light/proc/shatter()
	if(status == LIGHT_OK || status == LIGHT_BURNED)
		src.visible_message("<span class='warning'>[name] shatters.</span>","<span class='warning'>You hear a small glass object shatter.</span>")
		status = LIGHT_BROKEN
		force = 5
		sharp = 1
		playsound(src.loc, 'sound/effects/glasshit.ogg', 75, 1)
		update()

/obj/item/light/suicide_act(mob/living/carbon/human/user)
	user.visible_message("<span class=suicide>[user] touches [src], burning [user.p_their()] hands off!</span>", "<span class=suicide>You touch [src], burning your hands off!</span>")

	for(var/oname in list("l_hand", "r_hand"))
		var/obj/item/organ/external/limb = user.get_organ(oname)
		if(limb)
			limb.droplimb(0, DROPLIMB_BURN)
	return FIRELOSS

/obj/machinery/light/extinguish_light()
	on = FALSE
	visible_message("<span class='danger'>[src] flickers and falls dark.</span>")
	update(0)
