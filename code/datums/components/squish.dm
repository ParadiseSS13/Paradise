#define SHORT_SCALE (5/7)
#define TALL_SCALE (7/5)

/**
 * squish.dm
 *
 * It's an element that squishes things. After the duration passes, it reverses the transformation it squished with, taking into account if they are a different orientation than they started (read: rotationally-fluid)
 *
 * Normal squishes apply vertically, as if the target is being squished from above, but you can set reverse to TRUE if you want to squish them from the sides, like if they pancake into a wall from the East or West
*/
/datum/element/squish
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/squish/Attach(datum/target, duration = 20 SECONDS, reverse = FALSE)
	. = ..()
	if(!iscarbon(target))
		return ELEMENT_INCOMPATIBLE

	var/mob/living/carbon/C = target
	var/was_lying = C.body_position == LYING_DOWN
	addtimer(CALLBACK(src, PROC_REF(Detach), C, was_lying, reverse), duration)
	ADD_TRAIT(target, TRAIT_FLATTENED, "vendor_flattening")

	if(reverse)
		C.transform = C.transform.Scale(SHORT_SCALE, TALL_SCALE)
	else
		C.transform = C.transform.Scale(TALL_SCALE, SHORT_SCALE)

/datum/element/squish/Detach(mob/living/carbon/C, was_lying, reverse)
	. = ..()
	if(!istype(C))
		return
	var/is_lying = C.body_position == LYING_DOWN
	REMOVE_TRAIT(C, TRAIT_FLATTENED, "vendor_flattening")
	if(reverse)
		is_lying = !is_lying

	if(was_lying == is_lying)
		C.transform = C.transform.Scale(SHORT_SCALE, TALL_SCALE)
	else
		C.transform = C.transform.Scale(TALL_SCALE, SHORT_SCALE)

#undef SHORT_SCALE
#undef TALL_SCALE
