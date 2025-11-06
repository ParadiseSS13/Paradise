/obj/structure/flora
	resistance_flags = FLAMMABLE
	max_integrity = 150

//trees
/obj/structure/flora/tree
	name = "tree"
	anchored = TRUE
	density = TRUE
	pixel_x = -16
	layer = 9

//Adds the transparency component, exists to be overridden for different args.
/obj/structure/flora/tree/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency)

/obj/structure/flora/tree/pine
	name = "pine tree"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_1"

/obj/structure/flora/tree/pine/Initialize(mapload)
	. = ..()
	icon_state = "pine_[rand(1, 3)]"

/obj/structure/flora/tree/pine/xmas
	name = "xmas tree"
	icon_state = "pine_c"

/obj/structure/flora/tree/dead
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_1"

/obj/structure/flora/tree/dead/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency, 0, 1, 0, 0)
	icon_state = "tree_[rand(1, 6)]"

/obj/structure/flora/tree/palm
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm1"

/obj/structure/flora/tree/palm/Initialize(mapload)
	. = ..()
	icon_state = pick("palm1","palm2")

/obj/structure/flora/tree/jungle
	icon_state = "tree"
	desc = "It's seriously hampering your view of the jungle."
	icon = 'icons/obj/flora/jungletrees.dmi'
	pixel_x = -48
	pixel_y = -20
	///Hard ref to the tree's shadow
	var/obj/effect/abstract/shadow/shadow_reference

/obj/structure/flora/tree/jungle/Initialize(mapload)
	. = ..()

	icon_state = "[icon_state][rand(1, 6)]"
	add_transparency_component()
	//Code to create and place the tree's shadow
	shadow_reference = new /obj/effect/abstract/shadow(get_turf(src))
	shadow_reference.pixel_x = pixel_x
	shadow_reference.pixel_y = pixel_y
	shadow_reference.icon = icon
	shadow_reference.icon_state = "[icon_state]_shadow"

/obj/structure/flora/tree/jungle/Destroy()
	QDEL_NULL(shadow_reference)
	return ..()

/obj/structure/flora/tree/jungle/proc/add_transparency_component()
	AddComponent(/datum/component/largetransparency, -1, 1, 2, 2)

/obj/structure/flora/tree/jungle/small
	pixel_y = 0
	pixel_x = -32
	icon = 'icons/obj/flora/jungletreesmall.dmi'

/obj/structure/flora/tree/jungle/small/add_transparency_component()
	AddComponent(/datum/component/largetransparency)

/obj/effect/abstract/shadow
	name = "tree shadow, do not manually place"
	desc = "If you see this something has gone wrong, scream for a coder."
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = NONE

//grass
/obj/structure/flora/grass
	name = "grass"
	icon = 'icons/obj/flora/snowflora.dmi'
	anchored = TRUE
	max_integrity = 15

/obj/structure/flora/grass/brown
	icon_state = "snowgrass1bb"

/obj/structure/flora/grass/brown/Initialize(mapload)
	. = ..()
	icon_state = "snowgrass[rand(1, 3)]bb"


/obj/structure/flora/grass/green
	icon_state = "snowgrass1gb"

/obj/structure/flora/grass/green/Initialize(mapload)
	. = ..()
	icon_state = "snowgrass[rand(1, 3)]gb"

/obj/structure/flora/grass/both
	icon_state = "snowgrassall1"

/obj/structure/flora/grass/both/Initialize(mapload)
	. = ..()
	icon_state = "snowgrassall[rand(1, 3)]"


//bushes
/obj/structure/flora/bush
	name = "bush"
	icon = 'icons/obj/flora/snowflora.dmi'
	icon_state = "snowbush1"
	anchored = TRUE
	max_integrity = 15

/obj/structure/flora/bush/Initialize(mapload)
	. = ..()
	icon_state = "snowbush[rand(1, 6)]"

//newbushes

/obj/structure/flora/ausbushes
	name = "bush"
	icon = 'icons/obj/flora/ausflora.dmi'
	icon_state = "firstbush_1"
	anchored = TRUE
	max_integrity = 15

/obj/structure/flora/ausbushes/Initialize(mapload)
	. = ..()
	icon_state = "firstbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/reedbush
	icon_state = "reedbush_1"

/obj/structure/flora/ausbushes/reedbush/Initialize(mapload)
	. = ..()
	icon_state = "reedbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/leafybush
	icon_state = "leafybush_1"

/obj/structure/flora/ausbushes/leafybush/Initialize(mapload)
	. = ..()
	icon_state = "leafybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/palebush
	icon_state = "palebush_1"

/obj/structure/flora/ausbushes/palebush/Initialize(mapload)
	. = ..()
	icon_state = "palebush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/stalkybush
	icon_state = "stalkybush_1"

/obj/structure/flora/ausbushes/stalkybush/Initialize(mapload)
	. = ..()
	icon_state = "stalkybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/grassybush
	icon_state = "grassybush_1"

/obj/structure/flora/ausbushes/grassybush/Initialize(mapload)
	. = ..()
	icon_state = "grassybush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/fernybush
	icon_state = "fernybush_1"

/obj/structure/flora/ausbushes/fernybush/Initialize(mapload)
	. = ..()
	icon_state = "fernybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/sunnybush
	icon_state = "sunnybush_1"

/obj/structure/flora/ausbushes/sunnybush/Initialize(mapload)
	. = ..()
	icon_state = "sunnybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/genericbush
	icon_state = "genericbush_1"

/obj/structure/flora/ausbushes/genericbush/Initialize(mapload)
	. = ..()
	icon_state = "genericbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/pointybush
	icon_state = "pointybush_1"

/obj/structure/flora/ausbushes/pointybush/Initialize(mapload)
	. = ..()
	icon_state = "pointybush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/lavendergrass
	icon_state = "lavendergrass_1"

/obj/structure/flora/ausbushes/lavendergrass/Initialize(mapload)
	. = ..()
	icon_state = "lavendergrass_[rand(1, 4)]"

/obj/structure/flora/ausbushes/ywflowers
	icon_state = "ywflowers_1"

/obj/structure/flora/ausbushes/ywflowers/Initialize(mapload)
	. = ..()
	icon_state = "ywflowers_[rand(1, 3)]"

/obj/structure/flora/ausbushes/brflowers
	icon_state = "brflowers_1"

/obj/structure/flora/ausbushes/brflowers/Initialize(mapload)
	. = ..()
	icon_state = "brflowers_[rand(1, 3)]"

/obj/structure/flora/ausbushes/ppflowers
	icon_state = "ppflowers_1"

/obj/structure/flora/ausbushes/ppflowers/Initialize(mapload)
	. = ..()
	icon_state = "ppflowers_[rand(1, 3)]"

/obj/structure/flora/ausbushes/sparsegrass
	icon_state = "sparsegrass_1"

/obj/structure/flora/ausbushes/sparsegrass/Initialize(mapload)
	. = ..()
	icon_state = "sparsegrass_[rand(1, 3)]"

/obj/structure/flora/ausbushes/fullgrass
	icon_state = "fullgrass_1"

/obj/structure/flora/ausbushes/fullgrass/Initialize(mapload)
	. = ..()
	icon_state = "fullgrass_[rand(1, 3)]"

//////////////////////
////// MARK: Kirbyplants
//////////////////////

/obj/item/kirbyplants
	name = "potted plant"
	desc = "Some greenery, how nice."
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "random-medium"
	layer = ABOVE_MOB_LAYER
	force = 10
	throwforce = 13
	throw_range = 4
	/// Variable to track plant overlay on mob for later removal
	var/mutable_appearance/mob_overlay
	var/hideable = FALSE

/obj/item/kirbyplants/Initialize(mapload)
	. = ..()
	if(hideable)
		AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/obj/item/kirbyplants/examine(mob/user)
	. = ..()
	if(hideable)
		. += "<span class='notice'>You can hide behind [src] by picking it up with both hands free.</span>"
	else
		. += "<span class='notice'>It's too small to hide behind.</span>"

/obj/item/kirbyplants/equipped(mob/living/carbon/user)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		hide_user(user)
		return
	unhide_user(user)

/obj/item/kirbyplants/Destroy()
	if(iscarbon(loc))
		unhide_user(loc)

	QDEL_NULL(mob_overlay)
	return ..()

/// User has decided to hold a plant, apply stealth.
/obj/item/kirbyplants/proc/hide_user(mob/living/carbon/user)
	RegisterSignal(user, COMSIG_CARBON_REGENERATE_ICONS, PROC_REF(reapply_hide))
	mob_overlay = mutable_appearance(icon, icon_state, user.layer, user.plane, 255, appearance_flags = RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | KEEP_APART)
	user.add_overlay(mob_overlay)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.set_alpha_tracking(0, src)
	else
		user.alpha = 0

/// User has either dropped the plant, or plant is being destroyed, restore user to normal.
/obj/item/kirbyplants/proc/unhide_user(mob/living/carbon/user)
	UnregisterSignal(user, COMSIG_CARBON_REGENERATE_ICONS)
	user.cut_overlay(mob_overlay)
	user.alpha = initial(user.alpha)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.set_alpha_tracking(ALPHA_VISIBLE, src)
	QDEL_NULL(mob_overlay)

/// Icon operation has occured, time to make sure we're showing a plant again if we need to be.
/obj/item/kirbyplants/proc/reapply_hide(mob/living/carbon/user)
	SIGNAL_HANDLER
	// Reset the state of the user
	unhide_user(user)
	hide_user(user)

/obj/item/kirbyplants/dropped(mob/living/carbon/user)
	..()
	unhide_user(user)

//Large Plants
/obj/item/kirbyplants/large
	name = "large potted plant"
	icon_state = "random-big"
	w_class = WEIGHT_CLASS_HUGE
	desc = "A big potted plant. In enclosed starships and space stations, a bit of greenery is good for morale."
	hideable = TRUE

/obj/item/kirbyplants/large/Initialize(mapload)
	. = ..()
	if(icon_state == "random-big")
		icon_state = "plant-[rand(1, 15)]"

/obj/item/kirbyplants/large/plant1
	icon_state = "plant-1"
/obj/item/kirbyplants/large/plant2
	icon_state = "plant-2"
/obj/item/kirbyplants/large/plant3
	icon_state = "plant-3"
/obj/item/kirbyplants/large/plant4
	icon_state = "plant-4"
/obj/item/kirbyplants/large/plant5
	icon_state = "plant-5"
/obj/item/kirbyplants/large/plant6
	icon_state = "plant-6"
/obj/item/kirbyplants/large/plant7
	icon_state = "plant-7"
/obj/item/kirbyplants/large/plant8
	icon_state = "plant-8"
/obj/item/kirbyplants/large/plant9
	icon_state = "plant-9"
/obj/item/kirbyplants/large/plant10
	icon_state = "plant-10"
/obj/item/kirbyplants/large/plant11
	icon_state = "plant-11"
/obj/item/kirbyplants/large/plant12
	icon_state = "plant-12"
/obj/item/kirbyplants/large/plant13
	icon_state = "plant-13"
/obj/item/kirbyplants/large/plant14
	icon_state = "plant-14"
/obj/item/kirbyplants/large/plant15
	icon_state = "plant-15"

/obj/item/kirbyplants/large/dead
	icon_state = "plant-dead"

/obj/item/kirbyplants/large/dead/rd
	name = "\improper RD's potted plant"
	desc = "A gift from the botanical staff, presented after the RD's reassignment. There's a tag on it that says \"Y'all come back now, y'hear?\"\nIt doesn't look very healthy..."

//Medium Plants
/obj/item/kirbyplants/medium
	desc = "An understated houseplant. In enclosed starships and space stations, a bit of greenery is good for morale."
	w_class = WEIGHT_CLASS_BULKY
	hideable = TRUE

/obj/item/kirbyplants/medium/Initialize(mapload)
	. = ..()
	if(icon_state == "random-medium")
		icon_state = "medium-[rand(1,8)]"

/obj/item/kirbyplants/medium/medium1
	icon_state = "medium-1"
/obj/item/kirbyplants/medium/medium2
	icon_state = "medium-2"
/obj/item/kirbyplants/medium/medium3
	icon_state = "medium-3"
/obj/item/kirbyplants/medium/medium4
	icon_state = "medium-4"
/obj/item/kirbyplants/medium/medium5
	icon_state = "medium-5"
/obj/item/kirbyplants/medium/medium6
	icon_state = "medium-6"
/obj/item/kirbyplants/medium/medium7
	icon_state = "medium-7"
/obj/item/kirbyplants/medium/medium8
	icon_state = "medium-8"

//Small Plants
/obj/item/kirbyplants/small
	name = "small potted plant"
	icon_state = "random-small"
	desc = "A small potted houseplant, for setting on tables and shelves."

/obj/item/kirbyplants/small/Initialize(mapload)
	. = ..()
	if(icon_state == "random-small")
		icon_state = "small-[rand(1,5)]"

/obj/item/kirbyplants/small/small1
	icon_state = "small-1"
/obj/item/kirbyplants/small/small2
	icon_state = "small-2"
/obj/item/kirbyplants/small/small3
	icon_state = "small-3"
/obj/item/kirbyplants/small/small4
	icon_state = "small-4"
/obj/item/kirbyplants/small/small5
	icon_state = "small-5"

//Alien Plants
/obj/item/kirbyplants/large/alien
	name = "potted alien plant"
	icon_state = "random-alien"
	desc = "An alien potted plant. Nanotrasen and the TSF usually favor Earthen plants for decor, so plants like this are an exotic novelty in this part of the galaxy."

/obj/item/kirbyplants/large/alien/Initialize(mapload)
	. = ..()
	if(icon_state == "random-alien")
		icon_state = "alien-[rand(1,8)]"

/obj/item/kirbyplants/large/alien/alien1
	icon_state = "alien-1"
/obj/item/kirbyplants/large/alien/alien3
	icon_state = "alien-3"
/obj/item/kirbyplants/large/alien/alien4
	icon_state = "alien-4"
/obj/item/kirbyplants/large/alien/alien5
	icon_state = "alien-5"
/obj/item/kirbyplants/large/alien/alien6
	icon_state = "alien-6"
/obj/item/kirbyplants/large/alien/alien7
	icon_state = "alien-7"
/obj/item/kirbyplants/large/alien/alien8
	icon_state = "alien-8"

//a rock is flora according to where the icon file is
//and now these defines
/obj/structure/flora/rock
	name = "rock"
	desc = "A rock."
	icon_state = "rock1"
	icon = 'icons/obj/flora/rocks.dmi'
	resistance_flags = FIRE_PROOF
	anchored = TRUE

/obj/structure/flora/rock/Initialize(mapload)
	. = ..()
	icon_state = "rock[rand(1,5)]"

/obj/structure/flora/rock/pile
	name = "rocks"
	desc = "Some rocks."
	icon_state = "rockpile1"

/obj/structure/flora/rock/pile/Initialize(mapload)
	. = ..()
	icon_state = "rockpile[rand(1,5)]"

/obj/structure/flora/rock/icy
	name = "icy rock"
	color = "#cce9eb"

/obj/structure/flora/rock/pile/icy
	name = "icy rocks"
	color = "#cce9eb"

/obj/structure/flora/corn_stalk
	name = "corn stalk"
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "cornstalk1"
	layer = 5

/obj/structure/flora/corn_stalk/alt_1
	icon_state = "cornstalk2"

/obj/structure/flora/corn_stalk/alt_2
	icon_state = "cornstalk3"

/obj/structure/flora/straw_bail
	name = "straw bail"
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "strawbail1"
	density = TRUE
	climbable = 1 // you can climb all over them.

/obj/structure/flora/straw_bail/alt_1
	icon_state = "strawbail2"

/obj/structure/flora/straw_bail/alt_2
	icon_state = "strawbail3"

/obj/structure/bush
	name = "foliage"
	desc = "Pretty thick scrub, it'll take something sharp and a lot of determination to clear away."
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "bush1"
	density = TRUE
	anchored = TRUE
	layer = 3.2
	var/indestructable = 0
	var/stump = 0

/obj/structure/bush/Initialize(mapload)
	. = ..()
	if(prob(20))
		set_opacity(TRUE)

/*
/obj/structure/bush/Bumped(M as mob)
	if(istype(M, /mob/living/simple_animal))
		var/mob/living/simple_animal/A = M
		A.loc = get_turf(src)
	else if(istype(M, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/A = M
		A.loc = get_turf(src)
*/

/obj/structure/bush/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	//hatchets can clear away undergrowth
	if(istype(I, /obj/item/hatchet) && !stump)
		if(indestructable)
			//this bush marks the edge of the map, you can't destroy it
			to_chat(user, "<span class='warning'>You flail away at the undergrowth, but it's too thick here.</span>")
		else
			user.visible_message("<span class='danger'>[user] begins clearing away [src].</b>","<span class='warning'><b>You begin clearing away [src].</span></span>")
			spawn(rand(15,30))
				if(get_dist(user,src) < 2)
					to_chat(user, "<span class='notice'>You clear away [src].</span>")
					var/obj/item/stack/sheet/wood/W = new(src.loc)
					W.amount = rand(3,15)
					if(prob(50))
						icon_state = "stump[rand(1,2)]"
						name = "cleared foliage"
						desc = "There used to be dense undergrowth here."
						density = FALSE
						stump = 1
						pixel_x = rand(-6,6)
						pixel_y = rand(-6,6)
					else
						qdel(src)
		return ITEM_INTERACT_COMPLETE

//Jungle grass

/obj/structure/flora/grass/jungle
	name = "jungle grass"
	desc = "Thick alien flora."
	icon = 'icons/obj/flora/jungleflora.dmi'
	icon_state = "grass1"
	base_icon_state = "grass"
	/// Controls how many variants of the sprite exists
	var/variations = 10

/obj/structure/flora/grass/jungle/Initialize(mapload)
	icon_state = "[base_icon_state][rand(1, variations)]"
	. = ..()

//Jungle rocks

/obj/structure/flora/rock/jungle
	icon_state = "rock"
	desc = "A pile of rocks."
	icon = 'icons/obj/flora/jungleflora.dmi'

/obj/structure/flora/rock/jungle/Initialize(mapload)
	. = ..()
	icon_state = "[initial(icon_state)][rand(1,5)]"

//Jungle bushes

/obj/structure/flora/junglebush
	name = "bush"
	desc = "A wild plant that is found in jungles."
	icon = 'icons/obj/flora/jungleflora.dmi'
	icon_state = "bush1"
	base_icon_state = "bush"
	anchored = TRUE
	/// Controls how many variants of the sprite exists
	var/variations = 9

/obj/structure/flora/junglebush/Initialize(mapload)
	icon_state = "[base_icon_state][rand(1, variations)]"
	. = ..()

/obj/structure/flora/junglebush/large
	icon = 'icons/obj/flora/largejungleflora.dmi'
	pixel_x = -16
	pixel_y = -12
	layer = ABOVE_ALL_MOB_LAYER
	variations = 3

/obj/structure/flora/junglebush/large/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency, 0, 0, 0, 0)

/obj/structure/flora/rock/pile/largejungle
	icon_state = "rocks1"
	base_icon_state = "rocks"
	icon = 'icons/obj/flora/largejungleflora.dmi'
	pixel_x = -16
	pixel_y = -16

/obj/structure/flora/rock/pile/largejungle/Initialize(mapload)
	. = ..()
	icon_state = "[initial(base_icon_state)][rand(1,3)]"
