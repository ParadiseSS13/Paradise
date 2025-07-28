// Bluespace crystals, used in telescience and when crushed it will blink you to a random turf.
/obj/item/stack/ore/bluespace_crystal
	name = "bluespace crystal"
	desc = "A glowing bluespace crystal, not much is known about how they work. It looks very delicate."
	icon = 'icons/obj/stacks/minerals.dmi'
	icon_state = "bluespace_crystal" //This is the raw ore from lavaland, so should look like the ore.
	w_class = WEIGHT_CLASS_TINY
	materials = list(MAT_BLUESPACE = MINERAL_MATERIAL_AMOUNT)
	origin_tech = "bluespace=6;materials=3"
	points = 50
	var/blink_range = 8 // The teleport range when crushed/thrown at someone.
	refined_type = /obj/item/stack/ore/bluespace_crystal/refined
	usesound = 'sound/items/deconstruct.ogg'
	dynamic_icon_state = TRUE

/obj/item/stack/ore/bluespace_crystal/examine(mob/user)
	. = ..()
	. += "<span class='notice'>You can crush this to randomly teleport a short distance.</span>"
	. += "<span class='notice'>If you throw this at someone, they'll be randomly teleported a short distance away.</span>"

/obj/item/stack/ore/bluespace_crystal/examine_more(mob/user)
	. = ..()
	. += "Bluespace crystals are a form of exotic matter that is very poorly understood. The process of their creation is not known, nor how they end up in the places they do."
	. += ""
	. += "They are instrumental in the creation of new experimental bluespace-manipulative technologies, unlocking previously impossible feats or trivializing ones that less advanced technologies struggle with. \
	As plasma-based technologies become more mature and new radical innovations taper off, bluespace research is becoming new technological frontier."
	. += ""
	. += "Nanotrasen and many of its rivals are scrambling to be the first to develop practical mass-producible bluespace technologies so they they can become the hegemon of a new market monopoly."

/obj/item/stack/ore/bluespace_crystal/Initialize(mapload, new_amount, merge)
	. = ..()
	scatter_atom()

/obj/item/stack/ore/bluespace_crystal/attack_self__legacy__attackchain(mob/user)
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

/obj/item/stack/ore/bluespace_crystal/five
	amount = 5

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

/obj/item/stack/ore/bluespace_crystal/artificial/examine_more(mob/user)
	..()
	. = list()
	. += "The successful development of a process to create synthetic bluespace crystals was nothing short of a miracle. \
	Natural bluespace crystals are excruciatingly rare, an issue exacerbated by their tendency to blink out of existence if mishandled."
	. += ""
	. += "While the crystals produced by current synthetic processes are not as potent as natural ones, they can be used in most bluespace technologies with no noticeable loss in performance."
	. += ""
	. += "The manufacturing process is one of Nanotrasen's most closely guarded trade secrets, were it ever to get out, it would have severe consequences for the company."
