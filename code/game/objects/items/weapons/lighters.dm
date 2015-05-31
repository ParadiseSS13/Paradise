/////////
//ZIPPO//
/////////
/obj/item/weapon/lighter
	name = "cheap lighter"
	desc = "A cheap-as-free lighter."
	icon = 'icons/obj/items.dmi'
	icon_state = "lighter-g"
	item_state = "lighter-g"
	var/icon_on = "lighter-g-on"
	var/icon_off = "lighter-g"
	w_class = 1
	throwforce = 4
	flags = CONDUCT
	slot_flags = SLOT_BELT
	attack_verb = list("burnt", "singed")
	var/lit = 0

/obj/item/weapon/lighter/zippo
	name = "Zippo lighter"
	desc = "The zippo."
	icon_state = "zippo"
	item_state = "zippo"
	icon_on = "zippoon"
	icon_off = "zippo"

/obj/item/weapon/lighter/random
	New()
		var/color = pick("r","c","y","g")
		icon_on = "lighter-[color]-on"
		icon_off = "lighter-[color]"
		icon_state = icon_off

/obj/item/weapon/lighter/attack_self(mob/living/user)
	if(user.r_hand == src || user.l_hand == src || isrobot(user))
		if(!lit)
			lit = 1
			w_class = 4
			icon_state = icon_on
			item_state = icon_on
			if(istype(src, /obj/item/weapon/lighter/zippo) )
				user.visible_message("<span class='rose'>Without even breaking stride, [user] flips open and lights [src] in one smooth movement.</span>")
				playsound(src.loc, 'sound/items/ZippoLight.ogg', 25, 1)
			else
				if(prob(75))
					user.visible_message("<span class='notice'>After a few attempts, [user] manages to light the [src].</span>")
				else
					user << "<span class='warning'>You burn yourself while lighting the lighter.</span>"
					user.adjustFireLoss(5)
					user.visible_message("<span class='notice'>After a few attempts, [user] manages to light the [src], they however burn their finger in the process.</span>")

			set_light(2)
			processing_objects.Add(src)
		else
			lit = 0
			w_class = 1
			icon_state = icon_off
			item_state = icon_off
			if(istype(src, /obj/item/weapon/lighter/zippo) )
				user.visible_message("<span class='rose'>You hear a quiet click, as [user] shuts off [src] without even looking at what they're doing. Wow.")
				playsound(src.loc, 'sound/items/ZippoClose.ogg', 25, 1)
			else
				user.visible_message("<span class='notice'>[user] quietly shuts off the [src].")

			set_light(0)
			processing_objects.Remove(src)
	else
		return ..()
	return


/obj/item/weapon/lighter/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!isliving(M))
		return
	M.IgniteMob()
	if(!istype(M, /mob))
		return

	if(istype(M.wear_mask, /obj/item/clothing/mask/cigarette) && user.zone_sel.selecting == "mouth" && lit)
		var/obj/item/clothing/mask/cigarette/cig = M.wear_mask
		if(M == user)
			cig.attackby(src, user)
		else
			if(istype(src, /obj/item/weapon/lighter/zippo))
				cig.light("<span class='rose'>[user] whips the [name] out and holds it for [M]. Their arm is as steady as the unflickering flame they light \the [cig] with.</span>")
			else
				cig.light("<span class='notice'>[user] holds the [name] out for [M], and lights the [cig.name].</span>")
	else
		..()

/obj/item/weapon/lighter/process()
	var/turf/location = get_turf(src)
	if(location)
		location.hotspot_expose(700, 5)
	return

//EXTRA LIGHTERS
/obj/item/weapon/lighter/zippo/fluff/li_matsuda_1 //mangled: Li Matsuda
	name = "blue zippo lighter"
	desc = "A zippo lighter made of some blue metal."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "bluezippo"
	icon_on = "bluezippoon"
	icon_off = "bluezippo"

/obj/item/weapon/lighter/zippo/fluff/michael_guess_1 //Dragor23: Michael Guess
	name = "engraved lighter"
	desc = "A golden lighter, engraved with some ornaments and a G."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "guessip"
	icon_on = "guessipon"
	icon_off = "guessip"

/obj/item/weapon/lighter/zippo/fluff/riley_rohtin_1 //rawrtaicho: Riley Rohtin
	name = "Riley's black zippo"
	desc = "A black zippo lighter, which holds some form of sentimental value."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "blackzippo"
	icon_on = "blackzippoon"
	icon_off = "blackzippo"

/obj/item/weapon/lighter/zippo/fluff/fay_sullivan_1 //furohman: Fay Sullivan
	name = "Graduation Lighter"
	desc = "A silver engraved lighter with 41 on one side and Tharsis University on the other. The lid reads Fay Sullivan, Cybernetic Engineering, 2541"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "gradzippo"
	icon_on = "gradzippoon"
	icon_off = "gradzippo"

/obj/item/weapon/lighter/zippo/fluff/executivekill_1 //executivekill: Hunter Duke
	name = "Gonzo Fist zippo"
	desc = "A Zippo lighter with the iconic Gonzo Fist on a matte black finish."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "gonzozippo"
	icon_on = "gonzozippoon"
	icon_off = "gonzozippo"

/obj/item/weapon/lighter/zippo/fluff/naples_1 //naples: Russell Vierson
	name = "Engraved zippo"
	desc = "A intricately engraved Zippo lighter."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "engravedzippo"
	icon_on = "engravedzippoon"
	icon_off = "engravedzippo"

/obj/item/weapon/lighter/zippo/fluff/nt_rep
	name = "gold engraved zippo"
	desc = "An engraved golden Zippo lighter with the letters NT on it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "zippo_nt_off"
	icon_on = "zippo_nt_on"
	icon_off = "zippo_nt_off"

/obj/item/weapon/lighter/zippo/fluff/purple
	name = "purple engraved zippo"
	desc = "All craftsspacemanship is of the highest quality. It is encrusted with refined plasma sheets. On the item is an image of a dwarf and the words 'Strike the Earth!' etched onto the side."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "purple_zippo_off"
	icon_on = "purple_zippo_on"
	icon_off = "purple_zippo_off"

///////////
//MATCHES//
///////////
/obj/item/weapon/match
	name = "match"
	desc = "A simple match stick, used for lighting fine smokables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	var/lit = 0
	var/smoketime = 5
	w_class = 1.0
	origin_tech = "materials=1"
	attack_verb = list("burnt", "singed")

/obj/item/weapon/match/process()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime < 1)
		icon_state = "match_burnt"
		lit = -1
		processing_objects.Remove(src)
		return
	if(location)
		location.hotspot_expose(700, 5)
		return

/obj/item/weapon/match/dropped(mob/user as mob)
	if(lit == 1)
		lit = -1
		damtype = "brute"
		icon_state = "match_burnt"
		item_state = "cigoff"
		name = "burnt match"
		desc = "A match. This one has seen better days."
		processing_objects.Remove(src)
	return ..()

/obj/item/weapon/match/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!isliving(M))
		return ..()
	if(lit == 1) M.IgniteMob()
	if(!istype(M, /mob))
		return ..()

	if(istype(M.wear_mask, /obj/item/clothing/mask/cigarette) && user.zone_sel.selecting == "mouth" && lit == 1)
		var/obj/item/clothing/mask/cigarette/cig = M.wear_mask
		if(M == user)
			cig.attackby(src, user)
		else
			cig.light("<span class='notice'>[user] holds the [name] out for [M], and lights the [cig.name].</span>")
	else
		..()
