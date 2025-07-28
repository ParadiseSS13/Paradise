//Screwdriver
/obj/item/screwdriver
	name = "screwdriver"
	desc = "A common screwdriver made of plastic and steel, fitted with a Sector-standard Phillips head."
	icon = 'icons/obj/tools.dmi'
	icon_state = "screwdriver_map"
	belt_icon = "screwdriver"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 5
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL = 350)
	attack_verb = list("stabbed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	usesound = 'sound/items/screwdriver.ogg'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 30)
	drop_sound = 'sound/items/handling/screwdriver_drop.ogg'
	pickup_sound =  'sound/items/handling/screwdriver_pickup.ogg'
	tool_behaviour = TOOL_SCREWDRIVER
	var/random_color = TRUE //if the screwdriver uses random coloring

	new_attack_chain = TRUE

/obj/item/screwdriver/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/surgery_initiator/robo)
	RegisterSignal(src, COMSIG_ATTACK, PROC_REF(on_attack))
	RegisterSignal(src, COMSIG_BIT_ATTACH, PROC_REF(add_bit))
	RegisterSignal(src, COMSIG_CLICK_ALT, PROC_REF(remove_bit))

/obj/item/screwdriver/nuke
	desc = "A specialized screwdriver with an ultra-thin flathead tip, meant for accessing very specific machinery."
	icon_state = "screwdriver_nuke"
	belt_icon = "screwdriver_nuke"
	toolspeed = 0.5
	random_color = FALSE

/obj/item/screwdriver/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is stabbing [src] into [user.p_their()] [pick("temple", "heart")]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/screwdriver/New(loc, param_color = null)
	..()
	if(random_color)
		if(!param_color)
			param_color = pick("red","blue","pink","brown","green","cyan","yellow")
		icon_state = "screwdriver_[param_color]"
		belt_icon = "screwdriver_[param_color]"

	if(prob(75))
		src.pixel_y = rand(0, 16)

/obj/item/screwdriver/proc/on_attack(datum/source, mob/living/carbon/target, mob/living/user)
	if(!istype(target) || user.a_intent == INTENT_HELP)
		return
	if(user.zone_selected != "eyes" && user.zone_selected != "head")
		return
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		target = user
	eyestab(target, user)
	return COMPONENT_SKIP_ATTACK

/obj/item/screwdriver/brass
	name = "brass screwdriver"
	desc = "A screwdriver made of brass. The handle feels freezing cold."
	icon_state = "screwdriver_brass"
	belt_icon = "screwdriver_brass"
	toolspeed = 0.5
	random_color = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/screwdriver/cargo
	name = "cargo screwdriver"
	desc = "A brown screwdriver proudly bearing the (very small) heraldry of the Supply Department. It's faster than a typical screwdriver thanks to its magnetic tip."
	icon_state = "screwdriver_cargo"
	belt_icon = "screwdriver_cargo"
	toolspeed = 0.75
	random_color = FALSE

/obj/item/screwdriver/cargo/suicide_act(mob/living/user)

	if(!user)
		return
	user.visible_message("<span class='suicide'>[user] is trying to take [src]'s independence! It looks like [user.p_theyre()] trying to commit suicide!</span>")

	user.Immobilize(10 SECONDS)
	sleep(2 SECONDS)
	add_fingerprint(user)

	user.visible_message("<span class='warn'>[src] retaliates viciously!</span>", "<span class='userdanger'>[src] retaliates viciously!</span>")
	playsound(loc, hitsound, 50, TRUE, -1)

	return BRUTELOSS

/obj/item/screwdriver/power
	name = "hand drill"
	desc = "A powerful, hand-held drill fitted with a long-lasting battery. It has a screwdriver head attached."
	icon_state = "drill_screw"
	inhand_icon_state = "drill"
	belt_icon = "hand_drill"
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	origin_tech = "materials=2;engineering=2" //done for balance reasons, making them high value for research, but harder to get
	force = 8 //might or might not be too high, subject to change
	throwforce = 8
	throw_speed = 2
	throw_range = 3//it's heavier than a screw driver/wrench, so it does more damage, but can't be thrown as far
	attack_verb = list("drilled", "screwed", "jabbed","whacked")
	hitsound = 'sound/items/drill_hit.ogg'
	usesound = 'sound/items/drill_use.ogg'
	toolspeed = 0.25
	w_class = WEIGHT_CLASS_NORMAL
	random_color = FALSE

/obj/item/screwdriver/power/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ADVANCED_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/screwdriver/power/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is putting [src] to [user.p_their()] temple. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/screwdriver/power/activate_self(mob/user)
	if(..())
		return

	playsound(get_turf(user), 'sound/items/change_drill.ogg', 50, 1)
	var/obj/item/wrench/power/b_drill = new /obj/item/wrench/power
	to_chat(user, "<span class='notice'>You attach the bolt driver bit to [src].</span>")
	for(var/obj/item/smithed_item/tool_bit/bit in attached_bits)
		bit.on_detached()
		bit.forceMove(b_drill)
		b_drill.attached_bits += bit
		bit.on_attached(b_drill)
	qdel(src)
	user.put_in_active_hand(b_drill)

/obj/item/screwdriver/cyborg
	name = "powered screwdriver"
	desc = "A powered screwdriver typically found in construction and engineering robots."
	usesound = 'sound/items/drill_use.ogg'
	toolspeed = 0.5
