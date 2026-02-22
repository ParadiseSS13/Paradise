#define DEFAULT_SHRAPNEL_RANGE 5

/obj/item/grenade/frag
	name = "fragmentation grenade"
	desc = "A grenade with a specially designed casing that will launch lethal fragments in all directions upon detonation. Fire in the hole!"
	icon_state = "frag"
	origin_tech = "materials=3;magnets=4"
	/// How much shrapnel the grenade will launch.
	var/shrapnel_contained = 20
	/// The type of projectile that will fired.
	var/embedded_type = /obj/projectile/bullet/shrapnel

/obj/item/grenade/frag/prime()
	update_mob()
	explosion(loc, 0, 1, DEFAULT_SHRAPNEL_RANGE, cause = name, breach = FALSE)
	create_shrapnel(loc, shrapnel_contained, shrapnel_type = embedded_type)
	qdel(src)

/obj/item/grenade/frag/stinger
	name = "stingball grenade"
	desc = "A specialized less-lethal hand grenade used for police action. Launches hard rubber balls in all directions upon detonation."
	icon_state = "stinger"
	modifiable_timer = FALSE
	shrapnel_contained = 50
	embedded_type = /obj/projectile/bullet/pellet/rubber/stinger

/obj/item/grenade/frag/stinger/prime()
	update_mob()
	explosion(loc, 0, 0, 0, 0, DEFAULT_SHRAPNEL_RANGE + 2, cause = name, breach = FALSE)
	create_shrapnel(loc, shrapnel_contained, shrapnel_type = embedded_type)
	qdel(src)

/obj/item/grenade/frag/holy
	name = "holy hand grenade"
	desc = "O Lord, bless this Thy Hand Grenade that, with it, Thou mayest blow Thine enemies to tiny bits in Thy mercy."
	icon_state = "holy_grenade"
	origin_tech = "materials=3;magnets=4;combat=5"
	modifiable_timer = FALSE
	embedded_type = /obj/projectile/bullet/shrapnel/holy

/obj/item/grenade/frag/holy/prime()
	playsound(loc, 'sound/effects/pray.ogg', 150, TRUE)
	for(var/turf/t in view(5))
		t.Bless()
		for(var/mob/living/basic/revenant/rev in t)
			rev.reveal(2 SECONDS)
			rev.adjustBruteLoss(150)
	return ..()

/obj/item/grenade/frag/holy/examine_more(mob/user)
	. = ..()
	. +=  "First shalt thou prime the Holy Pin. Then, shalt thou count to three. No more. No less. \
	Three shalt be the number thou shalt count, and the number of the counting shalt be three. Four shalt \
	thou not count, nor either count thou two, excepting that thou then proceed to three. Five is right out. \
	Once the number three, being the third number, be reached, then lobbest thou thy Holy Hand Grenade \
	towards thy foe, who, being naughty in My sight, shall snuff it."

/**
 * Shrapnel that flies through the air and hits you
 */
/obj/projectile/bullet/shrapnel
	name = "shrapnel"
	icon_state = "magspear"
	gender = PLURAL
	range = DEFAULT_SHRAPNEL_RANGE
	damage = 1 // 1 damage, to trigger stuff that reacts to damage. Rest of the damage is done through the physical shrapnel
	var/embed_prob = 100 //reduced by armor
	var/embedded_type = /obj/item/shrapnel

/obj/projectile/bullet/shrapnel/on_hit(atom/target, blocked)
	. = ..()
	var/obj/item/new_possible_embed = new embedded_type(get_turf(src)) // drop it on the floor if we hit somethig non-living
	if(!.)
		return
	if(!ishuman(target))
		return

	var/mob/living/carbon/human/human = target
	if(!prob(embed_prob - ARMOUR_VALUE_TO_PERCENTAGE(human.getarmor(armor_type = BOMB))))
		to_chat(human, SPAN_WARNING("Shrapnel bounces off your armor!"))
		return
	human.try_embed_object(new_possible_embed)

/obj/projectile/bullet/shrapnel/on_range()
	var/obj/item/we_missed = new embedded_type(get_turf(src)) // we missed, lets toss the shrapnel
	var/range = gaussian(4, 2)
	if(range > 0)
		var/atom/i_wasnt_aiming_for_the_truck = get_angle_target_turf(get_turf(src), Angle, range)
		we_missed.throw_at(i_wasnt_aiming_for_the_truck, 16, 3)
	return ..()

/obj/projectile/bullet/shrapnel/holy
	name = "blessed shrapnel"
	embedded_type = /obj/item/shrapnel/holy

/obj/projectile/bullet/shrapnel/holy/on_hit(atom/target, blocked)
	. = ..()
	if(!ishuman(target))
		return

	var/mob/living/carbon/human/human = target
	human.reagents.add_reagent("holy water", 5)

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
	scatter_distance = 8

/obj/item/shrapnel/Initialize(mapload)
	. = ..()
	icon_state = pick("shrapnel1", "shrapnel2", "shrapnel3")
	scatter_atom()

/obj/item/shrapnel/decompile_act(obj/item/matter_decompiler/C, mob/user)
	qdel(src)
	return TRUE

/obj/item/shrapnel/holy
	name = "blessed shrapnel"
	desc = "Shards of godlike judgement, launched at high velocity. The power of Christ propels you."
	force = 6
	color = "#FFFF00" // Yellow because it's holy yo

#undef DEFAULT_SHRAPNEL_RANGE
