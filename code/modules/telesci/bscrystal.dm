// Bluespace crystals, used in telescience and when crushed it will blink you to a random turf.
/obj/item/stack/ore/bluespace_crystal
	name = "bluespace crystal"
	desc = "A glowing bluespace crystal, not much is known about how they work. It looks very delicate."
	icon = 'icons/obj/stacks/minerals.dmi'
	icon_state = "bluespace_crystal" //This is the raw ore from lavaland, so should look like the ore.
	item_state = "bluespace_crystal"
	w_class = WEIGHT_CLASS_TINY
	materials = list(MAT_BLUESPACE = MINERAL_MATERIAL_AMOUNT)
	origin_tech = "bluespace=6;materials=3"
	points = 50
	var/blink_range = 8 // The teleport range when crushed/thrown at someone.
	refined_type = /obj/item/stack/ore/bluespace_crystal/refined
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'
	dynamic_icon_state = TRUE

/obj/item/stack/ore/bluespace_crystal/New(loc, new_amount, merge = TRUE)
	..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/stack/ore/bluespace_crystal/attack_self(mob/user)
	if(use(1))
		blink_mob(user)
		user.visible_message("<span class='notice'>[user] crushes a [singular_name]!</span>")

/obj/item/stack/ore/bluespace_crystal/proc/blink_mob(mob/living/L)
	if(!is_teleport_allowed(L.z))
		src.visible_message("<span class='warning'>[src]'s fragments begin rapidly vibrating and blink out of existence.</span>")
		qdel(src)
		return
	do_teleport(L, get_turf(L), blink_range, sound_in = 'sound/effects/phasein.ogg')
	L.apply_status_effect(STATUS_EFFECT_TELEPORTSICK)

/obj/item/stack/ore/bluespace_crystal/throw_impact(atom/hit_atom)
	..()
	if(isliving(hit_atom))
		blink_mob(hit_atom)
	qdel(src)

// Refined Bluespace crystal fragments (stops point farming)
/obj/item/stack/ore/bluespace_crystal/refined
	name = "refined bluespace crystal"
	icon_state = "refined_bluespace_crystal"
	points = 0
	refined_type = null

// Artifical bluespace crystal, doesn't give you much research.
/obj/item/stack/ore/bluespace_crystal/artificial
	name = "artificial bluespace crystal"
	icon_state = "synthetic_bluespace_crystal"
	desc = "An artificially made bluespace crystal, it looks delicate."
	origin_tech = "bluespace=3;plasmatech=4"
	materials = list(MAT_BLUESPACE=MINERAL_MATERIAL_AMOUNT * 0.5)
	blink_range = 4 // Not as good as the organic stuff!
	points = 0 // nice try
	refined_type = null
