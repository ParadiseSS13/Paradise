#define DEFAULT_SHRAPNEL_RANGE 5

/obj/item/grenade/frag
	name = "frag grenade"
	desc = "Fire in the hole."
	icon_state = "frag"
	item_state = "grenade"
	origin_tech = "materials=3;magnets=4"
	var/shrapnel_contained = 20
	var/embedded_type = /obj/item/projectile/bullet/shrapnel

/obj/item/grenade/frag/prime()
	update_mob()
	explosion(loc, 0, 1, DEFAULT_SHRAPNEL_RANGE, breach = FALSE)
	create_shrapnel(loc, shrapnel_contained, shrapnel_type = embedded_type)
	qdel(src)

/**
 * Shrapnel that flies through the air and hits you
 */
/obj/item/projectile/bullet/shrapnel
	name = "shrapnel"
	icon_state = "magspear"
	gender = PLURAL
	range = DEFAULT_SHRAPNEL_RANGE
	damage = 1 // 1 damage, to trigger stuff that reacts to damage. Rest of the damage is done through the physical shrapnel
	var/embed_prob = 100 //reduced by armor
	var/embedded_type = /obj/item/shrapnel

/obj/item/projectile/bullet/shrapnel/on_hit(atom/target, blocked)
	. = ..()
	var/obj/item/new_possible_embed = new embedded_type(get_turf(src)) // drop it on the floor if we hit somethig non-living
	if(!.)
		return
	if(!ishuman(target))
		return

	var/mob/living/carbon/human/H = target
	if(!prob(embed_prob - ARMOUR_VALUE_TO_PERCENTAGE(H.getarmor(null, BOMB))))
		to_chat(H, "<span class='warning'>Shrapnel bounces off your armor!</span>")
		return
	H.try_embed_object(new_possible_embed)

/obj/item/projectile/bullet/shrapnel/on_range()
	var/obj/item/we_missed = new embedded_type(get_turf(src)) // we missed, lets toss the shrapnel
	var/range = gaussian(4, 2)
	if(range > 0)
		var/atom/i_wasnt_aiming_for_the_truck = get_angle_target_turf(get_turf(src), Angle, range)
		we_missed.throw_at(i_wasnt_aiming_for_the_truck, 16, 3)
	return ..()

/**
 * Shrapnel projectiles turn into this after trying to embed
 */
/obj/item/shrapnel
	name = "shrapnel"
	desc = "Metal shards at high velocity, a classic method of blowing your enemies up."
	icon = 'icons/obj/shards.dmi'
	icon_state = "shrapnel1"
	force = 8 // its a sharp piece of metal, but still not very effective
	gender = PLURAL
	embed_chance = 100
	embedded_fall_chance = 0
	w_class = WEIGHT_CLASS_SMALL
	sharp = TRUE
	hitsound = 'sound/weapons/pierce.ogg'

/obj/item/shrapnel/Initialize(mapload)
	. = ..()
	icon_state = pick("shrapnel1", "shrapnel2", "shrapnel3")
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 8)

#undef DEFAULT_SHRAPNEL_RANGE
