// Bluespace crystals, used in telescience and when crushed it will blink you to a random turf.
/obj/item/weapon/ore/bluespace_crystal
	name = "bluespace crystal"
	desc = "A glowing bluespace crystal, not much is known about how they work. It looks very delicate."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "bluespace_crystal"
	w_class = 1
	origin_tech = "bluespace=4;materials=3"
	points = 50
	var/blink_range = 8 // The teleport range when crushed/thrown at someone.
	refined_type = /obj/item/stack/sheet/bluespace_crystal

/obj/item/weapon/ore/bluespace_crystal/New()
	..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/weapon/ore/bluespace_crystal/attack_self(var/mob/user)
	blink_mob(user)
	user.drop_item()
	user.visible_message("<span class='notice'>[user] crushes the [src]!</span>")
	qdel(src)

/obj/item/weapon/ore/bluespace_crystal/proc/blink_mob(var/mob/living/L)
	if(!is_teleport_allowed(L.z))
		src.visible_message("<span class=warning>[src]'s fragments begin rapidly vibrating and blink out of existence.<span>")
		qdel(src)
		return
	do_teleport(L, get_turf(L), blink_range, asoundin = 'sound/effects/phasein.ogg')

/obj/item/weapon/ore/bluespace_crystal/throw_impact(atom/hit_atom)
	..()
	if(isliving(hit_atom))
		blink_mob(hit_atom)
	qdel(src)
// Blueapce crystal fragments (stops point farming)
/obj/item/weapon/ore/bluespace_crystal/fragment
    points = 0
    refined_type = null

// Artifical bluespace crystal, doesn't give you much research.
/obj/item/weapon/ore/bluespace_crystal/artificial
	name = "artificial bluespace crystal"
	desc = "An artificially made bluespace crystal, it looks delicate."
	origin_tech = "bluespace=2"
	blink_range = 4 // Not as good as the organic stuff!
	points = 0 // nice try
	refined_type = null

// Polycrystals, aka stacks

var/global/list/datum/stack_recipe/bluespace_crystal_recipes = list(new/datum/stack_recipe("Breakdown into bluespace crystal", /obj/item/weapon/ore/bluespace_crystal/fragment, 1, one_per_turf = 0, on_floor = 1))

/obj/item/stack/sheet/bluespace_crystal
	name = "bluespace polycrystal"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "polycrystal"
	desc = "A stable polycrystal, made of fused-together bluespace crystals. You could probably break one off."
	origin_tech = "bluespace=4;materials=3"
	attack_verb = list("bluespace polybashed", "bluespace polybattered", "bluespace polybludgeoned", "bluespace polythrashed", "bluespace polysmashed")

/obj/item/stack/sheet/bluespace_crystal/New()
	..()
	recipes = bluespace_crystal_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
