/obj/structure/closet/secure_closet/egg
	name = "egg"
	desc = "It's an egg; it's smooth to the touch." //This is the default egg.
	icon = 'icons/obj/egg_vr.dmi'
	icon_state = "egg"
	density = 0 //Just in case there's a lot of eggs, so it doesn't block hallways/areas.
	icon_closed = "egg"
	icon_opened = "egg_open"
	icon_locked = "egg"
	sound = 'sound/vore/schlorp.ogg'
	opened = 0
	welded = 0 //Don't touch this.
	health = 100

/obj/structure/closet/secure_closet/egg/attackby(obj/item/weapon/W, mob/user as mob) //This also prevents crew from welding the eggs and making them unable to be opened.
	if(istype(W, /obj/item/weapon/weldingtool))
		src.dump_contents()
		del(src)


/obj/structure/closet/secure_closet/egg/unathi
	name = "unathi egg"
	desc = "Some species of Unathi apparently lay soft-shelled eggs!"
	icon_state = "egg_unathi"
	icon_closed = "egg_unathi"
	icon_opened = "egg_unathi_open"

/obj/structure/closet/secure_closet/egg/nevrean
	name = "nevarean egg"
	desc = "Most Nevareans lay hard-shelled eggs!"
	icon_state = "egg_nevarean"
	icon_closed = "egg_nevarean"
	icon_opened = "egg_nevarean_open"

/obj/structure/closet/secure_closet/egg/human
	name = "human egg"
	desc = "Some humans lay eggs that are--wait, what?"
	icon_state = "egg_human"
	icon_closed = "egg_human"
	icon_opened = "egg_human_open"

/obj/structure/closet/secure_closet/egg/tajaran
	name = "tajaran egg"
	desc = "Apparently that's what a Tajaran egg looks like. Weird."
	icon_state = "egg_tajaran"
	icon_closed = "egg_tajaran"
	icon_opened = "egg_tajaran_open"

/obj/structure/closet/secure_closet/egg/skrell
	name = "skrell egg"
	desc = "Its soft and squishy"
	icon_state = "egg_skrell"
	icon_closed = "egg_skrell"
	icon_opened = "egg_skrell_open"

/obj/structure/closet/secure_closet/egg/shark
	name = "akula egg"
	desc = "Its soft and slimy to the touch"
	icon_state  = "egg_akula"
	icon_closed = "egg_akula"
	icon_opened = "egg_akula_open"

/obj/structure/closet/secure_closet/egg/sergal
	name = "sergal egg"
	desc = "An egg with a slightly fuzzy exterior, and a hard layer beneath."
	icon_state = "egg_sergal"
	icon_closed = "egg_sergal"
	icon_opened = "egg_sergal_open"

/obj/structure/closet/secure_closet/egg/slime
	name = "slime egg"
	desc = "An egg with a soft and squishy interior, coated with slime."
	icon_state = "egg_slime"
	icon_closed = "egg_slime"
	icon_opened = "egg_slime_open"

/obj/structure/closet/secure_closet/egg/special //Not actually used, but the sprites are in, and it's there in case any admins need to spawn in the egg for any specific reasons.
	name = "special egg"
	desc = "This egg has a very unique look to it."
	icon_state = "egg_unique"
	icon_closed = "egg_unique"
	icon_opened = "egg_unique_open"

/obj/structure/closet/secure_closet/egg/scree
	name = "Chimera egg"
	desc = "...You don't know what type of creature layed this egg."
	icon_state = "egg_scree"
	icon_closed = "egg_scree"
	icon_opened = "egg_scree_open"

/obj/structure/closet/secure_closet/egg/xenomorph
	name = "Xenomorph egg"
	desc = "Some type of pitch black egg. It has a slimy exterior coating."
	icon_state = "egg_xenomorph"
	icon_closed = "egg_xenomorph"
	icon_opened = "egg_xenomorph_open"


//In case anyone stumbles upon this, MAJOR thanks to Vorrakul and Nightwing. Without them, this wouldn't be a reality.
//Also, huge thanks for Ace for helping me through with this and getting me to work at my full potential instead of tapping out early, along with coding advice.
//Additionally, huge thanks to the entire Virgo community for giving suggestions about egg TF, the sprites, descriptions, etc etc. Cheers to everyone. Also, you should totally eat Cadence. ~CK
