//cleansed 9/15/2012 17:48

/*
CONTAINS:
CIGARETTES
CIGARS
SMOKING PIPES

CIGARETTE PACKETS ARE IN FANCY.DM
LIGHTERS ARE IN LIGHTERS.DM
*/

//////////////////
//FINE SMOKABLES//
//////////////////
/obj/item/clothing/mask/cigarette
	name = "cigarette"
	desc = "A roll of tobacco and nicotine."
	icon_state = "cigoff"
	throw_speed = 0.5
	item_state = "cigoff"
	slot_flags = SLOT_EARS|SLOT_MASK
	w_class = 1
	body_parts_covered = null
	attack_verb = list("burnt", "singed")
	var/lit = 0
	var/icon_on = "cigon"  //Note - these are in masks.dmi not in cigarette.dmi
	var/icon_off = "cigoff"
	var/type_butt = /obj/item/weapon/cigbutt
	var/lastHolder = null
	var/smoketime = 300
	var/chem_volume = 30
	species_fit = list("Vox", "Unathi", "Tajaran", "Vulpkanin", "Grey")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/mask.dmi',
		"Grey" = 'icons/mob/species/grey/mask.dmi'
		)


/obj/item/clothing/mask/cigarette/New()
	..()
	flags |= NOREACT // so it doesn't react until you light it
	create_reagents(chem_volume) // making the cigarrete a chemical holder with a maximum volume of 30

/obj/item/clothing/mask/cigarette/Destroy()
	qdel(reagents)
	return ..()

/obj/item/clothing/mask/cigarette/attack(var/mob/living/M, var/mob/living/user, def_zone)
	if(istype(M) && M.on_fire)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(M)
		light("<span class='notice'>[user] coldly lights the [name] with the burning body of [M]. Clearly, they offer the warmest of regards...</span>")
		return 1
	else
		return ..()


/obj/item/clothing/mask/cigarette/fire_act()
	light()

/obj/item/clothing/mask/cigarette/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.isOn())//Badasses dont get blinded while lighting their cig with a welding tool
			light("<span class='notice'>[user] casually lights the [name] with [W], what a badass.</span>")

	else if(istype(W, /obj/item/weapon/lighter/zippo))
		var/obj/item/weapon/lighter/zippo/Z = W
		if(Z.lit)
			light("<span class='rose'>With a single flick of their wrist, [user] smoothly lights their [name] with their [W]. Damn they're cool.</span>")

	else if(istype(W, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/L = W
		if(L.lit)
			light("<span class='notice'>After some fiddling, [user] manages to light their [name] with [W].</span>")

	else if(istype(W, /obj/item/weapon/match))
		var/obj/item/weapon/match/M = W
		if(M.lit == 1)
			light("<span class='notice'>[user] lights their [name] with their [W].</span>")

	else if(istype(W, /obj/item/weapon/melee/energy/sword/saber))
		var/obj/item/weapon/melee/energy/sword/saber/S = W
		if(S.active)
			light("<span class='warning'>[user] swings their [W], barely missing their nose. They light their [name] in the process.</span>")

	else if(istype(W, /obj/item/device/assembly/igniter))
		light("<span class='notice'>[user] fiddles with [W], and manages to light their [name].</span>")

	//can't think of any other way to update the overlays :<
	user.update_inv_wear_mask()
	user.update_inv_l_hand()
	user.update_inv_r_hand()
	return


/obj/item/clothing/mask/cigarette/afterattack(obj/item/weapon/reagent_containers/glass/glass, mob/user as mob, proximity)
	..()
	if(!proximity) return
	if(istype(glass))	//you can dip cigarettes into beakers
		var/transfered = glass.reagents.trans_to(src, chem_volume)
		if(transfered)	//if reagents were transfered, show the message
			to_chat(user, "<span class='notice'>You dip \the [src] into \the [glass].</span>")
		else			//if not, either the beaker was empty, or the cigarette was full
			if(!glass.reagents.total_volume)
				to_chat(user, "<span class='notice'>[glass] is empty.</span>")
			else
				to_chat(user, "<span class='notice'>[src] is full.</span>")


/obj/item/clothing/mask/cigarette/proc/light(flavor_text = null)
	if(!src.lit)
		src.lit = 1
		damtype = "fire"
		if(reagents.get_reagent_amount("plasma")) // the plasma explodes when exposed to fire
			var/datum/effect/system/reagents_explosion/e = new()
			e.set_up(round(reagents.get_reagent_amount("plasma") / 2.5, 1), get_turf(src), 0, 0)
			e.start()
			if(ismob(loc))
				var/mob/M = loc
				M.unEquip(src, 1)
			qdel(src)
			return
		if(reagents.get_reagent_amount("fuel")) // the fuel explodes, too, but much less violently
			var/datum/effect/system/reagents_explosion/e = new()
			e.set_up(round(reagents.get_reagent_amount("fuel") / 5, 1), get_turf(src), 0, 0)
			e.start()
			if(ismob(loc))
				var/mob/M = loc
				M.unEquip(src, 1)
			qdel(src)
			return
		flags &= ~NOREACT // allowing reagents to react after being lit
		reagents.handle_reactions()
		icon_state = icon_on
		item_state = icon_on
		if(flavor_text)
			var/turf/T = get_turf(src)
			T.visible_message(flavor_text)
		set_light(2, 0.25, "#E38F46")
		processing_objects.Add(src)


/obj/item/clothing/mask/cigarette/process()
	var/mob/living/M = loc
	if(isliving(loc))
		M.IgniteMob()
	smoketime--
	if(smoketime < 1)
		die()
		return
	smoke()
	return


/obj/item/clothing/mask/cigarette/attack_self(mob/user as mob)
	if(lit)
		user.visible_message("<span class='notice'>[user] calmly drops and treads on the lit [src], putting it out instantly.</span>")
		die()
	return ..()

/obj/item/clothing/mask/cigarette/proc/smoke()
	var/turf/location = get_turf(src)
	var/is_being_smoked = 0
	// Check whether this is actually in a mouth, being smoked
	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		if(src == C.wear_mask)
			// There used to be a species check here, but synthetics can smoke now
			is_being_smoked = 1
	if(location)
		location.hotspot_expose(700, 5)
	if(reagents && reagents.total_volume)	//	check if it has any reagents at all
		if(is_being_smoked) // if it's being smoked, transfer reagents to the mob
			var/mob/living/carbon/C = loc
			reagents.trans_to(C, REAGENTS_METABOLISM)
			if(!reagents.total_volume) // There were reagents, but now they're gone
				to_chat(C, "<span class='notice'>Your [name] loses its flavor.</span>")
		else // else just remove some of the reagents
			reagents.remove_any(REAGENTS_METABOLISM)
	return

/obj/item/clothing/mask/cigarette/proc/die()
	var/turf/T = get_turf(src)
	set_light(0)
	var/obj/item/butt = new type_butt(T)
	transfer_fingerprints_to(butt)
	if(ismob(loc))
		var/mob/living/M = loc
		to_chat(M, "<span class='notice'>Your [name] goes out.</span>")
		M.unEquip(src, 1)		//Force the un-equip so the overlays update
	processing_objects.Remove(src)
	qdel(src)


/obj/item/clothing/mask/cigarette/random

/obj/item/clothing/mask/cigarette/random/New()
	..()
	var/random_reagent = pick("fuel","saltpetre","synaptizine","green_vomit","potass_iodide","msg","lexorin","mannitol","spaceacillin","cryoxadone","holywater","tea","egg","haloperidol","mutagen","omnizine","carpet","aranesp","cryostylane","chocolate","bilk","cheese","rum","blood","charcoal","coffee","ectoplasm","space_drugs","milk","mutadone","antihol","teporone","insulin","salbutamol","toxin")
	reagents.add_reagent(random_reagent, 10)

/obj/item/clothing/mask/cigarette/joint
	name = "joint"
	desc = "A roll of ambrosium vulgaris wrapped in a thin paper. Dude."
	icon_state = "spliffoff"
	icon_on = "spliffon"
	icon_off = "spliffoff"
	type_butt = /obj/item/weapon/cigbutt/roach
	throw_speed = 0.5
	item_state = "spliffoff"
	smoketime = 180
	chem_volume = 50

/obj/item/clothing/mask/cigarette/joint/New()
	..()
	var/list/jointnames = list("joint","doobie","spliff","blunt")
	name = pick(jointnames)
	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)

/obj/item/clothing/mask/cigarette/joint/deus
	desc = "A roll of ambrosium deus wrapped in a thin paper. Dude."

/obj/item/weapon/cigbutt/roach
	name = "roach"
	desc = "A manky old roach."
	icon_state = "roach"

/obj/item/weapon/cigbutt/roach/New()
	..()
	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)

/obj/item/clothing/mask/cigarette/handroll
	name = "hand-rolled cigarette"
	desc = "A roll of tobacco and nicotine, freshly rolled by hand."
	icon_state = "hr_cigoff"
	item_state = "hr_cigoff"
	icon_on = "hr_cigon"  //Note - these are in masks.dmi not in cigarette.dmi
	icon_off = "hr_cigoff"
	type_butt = /obj/item/weapon/cigbutt
	chem_volume = 50

////////////
// CIGARS //
////////////
/obj/item/clothing/mask/cigarette/cigar
	name = "Premium Cigar"
	desc = "A brown roll of tobacco and... well, you're not quite sure. This thing's huge!"
	icon_state = "cigaroff"
	icon_on = "cigaron"
	icon_off = "cigaroff"
	type_butt = /obj/item/weapon/cigbutt/cigarbutt
	throw_speed = 0.5
	item_state = "cigaroff"
	smoketime = 1500
	chem_volume = 40

/obj/item/clothing/mask/cigarette/cigar/New()
	..()
	reagents.add_reagent("nicotine", chem_volume/2)

/obj/item/clothing/mask/cigarette/cigar/cohiba
	name = "Cohiba Robusto Cigar"
	desc = "There's little more you could want from a cigar."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"

/obj/item/clothing/mask/cigarette/cigar/havana
	name = "Premium Havanian Cigar"
	desc = "A cigar fit for only the best for the best."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	smoketime = 7200
	chem_volume = 60

/obj/item/weapon/cigbutt
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "cigbutt"
	w_class = 1
	throwforce = 1

/obj/item/weapon/cigbutt/New()
	..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	transform = turn(transform,rand(0,360))

/obj/item/weapon/cigbutt/cigarbutt
	name = "cigar butt"
	desc = "A manky old cigar butt."
	icon_state = "cigarbutt"


/obj/item/clothing/mask/cigarette/cigar/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/match))
		..()
	else
		to_chat(user, "<span class='notice'>\The [src] straight out REFUSES to be lit by such uncivilized means.</span>")

/////////////////
//SMOKING PIPES//
/////////////////
/obj/item/clothing/mask/cigarette/pipe
	name = "smoking pipe"
	desc = "A pipe, for smoking. Probably made of meershaum or something."
	icon_state = "pipeoff"
	item_state = "pipeoff"
	icon_on = "pipeon"  //Note - these are in masks.dmi
	icon_off = "pipeoff"
	smoketime = 500
	chem_volume = 200

/obj/item/clothing/mask/cigarette/pipe/New()
	..()
	reagents.add_reagent("nicotine", chem_volume)

/obj/item/clothing/mask/cigarette/pipe/light(flavor_text = null)
	if(!src.lit)
		src.lit = 1
		damtype = "fire"
		icon_state = icon_on
		item_state = icon_on
		if(flavor_text)
			var/turf/T = get_turf(src)
			T.visible_message(flavor_text)
		processing_objects.Add(src)

/obj/item/clothing/mask/cigarette/pipe/process()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime < 1)
		new /obj/effect/decal/cleanable/ash(location)
		if(ismob(loc))
			var/mob/living/M = loc
			to_chat(M, "<span class='notice'>Your [name] goes out, and you empty the ash.</span>")
			lit = 0
			icon_state = icon_off
			item_state = icon_off
			M.update_inv_wear_mask(0)
		processing_objects.Remove(src)
		return
	smoke()
	return

/obj/item/clothing/mask/cigarette/pipe/attack_self(mob/user as mob) //Refills the pipe. Can be changed to an attackby later, if loose tobacco is added to vendors or something.
	if(lit)
		user.visible_message("<span class='notice'>[user] puts out [src].</span>")
		lit = 0
		icon_state = icon_off
		item_state = icon_off
		processing_objects.Remove(src)
		return
	if(smoketime <= 0)
		to_chat(user, "<span class='notice'>You refill the pipe with tobacco.</span>")
		reagents.add_reagent("nicotine", chem_volume)
		smoketime = initial(smoketime)
	return

/obj/item/clothing/mask/cigarette/pipe/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/match))
		..()
	else
		to_chat(user, "<span class='notice'>\The [src] straight out REFUSES to be lit by such means.</span>")

/obj/item/clothing/mask/cigarette/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen and kept popular in the modern age and beyond by space hipsters."
	icon_state = "cobpipeoff"
	item_state = "cobpipeoff"
	icon_on = "cobpipeon"  //Note - these are in masks.dmi
	icon_off = "cobpipeoff"
	smoketime = 800
	chem_volume = 40

///////////
//ROLLING//
///////////
obj/item/weapon/rollingpaper
	name = "rolling paper"
	desc = "A thin piece of paper used to make fine smokeables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper"
	w_class = 1


obj/item/weapon/rollingpaperpack
	name = "rolling paper pack"
	desc = "A pack of Nanotrasen brand rolling papers."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper_pack"
	w_class = 1
	var/papers = 25

obj/item/weapon/rollingpaperpack/attack_self(mob/user)
	if(papers > 1)
		var/obj/item/weapon/rollingpaper/P = new /obj/item/weapon/rollingpaper()
		user.put_in_inactive_hand(P)
		to_chat(user, "You take a paper out of the pack.")
		papers --
	else
		var/obj/item/weapon/rollingpaper/P = new /obj/item/weapon/rollingpaper()
		user.put_in_inactive_hand(P)
		to_chat(user, "You take the last paper out of the pack, and throw the pack away.")
		qdel(src)

/obj/item/weapon/rollingpaperpack/MouseDrop(atom/over_object)
	var/mob/M = usr
	if(M.restrained() || M.stat)
		return

	if(over_object == M)
		M.put_in_hands(src)

	else if(istype(over_object, /obj/screen))
		switch(over_object.name)
			if("r_hand")
				M.unEquip(src)
				M.put_in_r_hand(src)
			if("l_hand")
				M.unEquip(src)
				M.put_in_l_hand(src)

/obj/item/weapon/rollingpaperpack/examine(mob/user)
	..(user)
	to_chat(user, "There are [src.papers] left")
