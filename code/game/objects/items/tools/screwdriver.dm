//Screwdriver
/obj/item/screwdriver
	name = "screwdriver"
	desc = "You can be totally screwy with this."
	icon = 'icons/obj/tools.dmi'
	icon_state = "screwdriver_map"
	belt_icon = "screwdriver"
	flags = CONDUCT
	slot_flags = SLOT_FLAG_BELT
	force = 5
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL = 350)
	attack_verb = list("stabbed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	usesound = 'sound/items/screwdriver.ogg'
	toolspeed = 1
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 30)
	drop_sound = 'sound/items/handling/screwdriver_drop.ogg'
	pickup_sound =  'sound/items/handling/screwdriver_pickup.ogg'
	tool_behaviour = TOOL_SCREWDRIVER
	var/random_color = TRUE //if the screwdriver uses random coloring

/obj/item/screwdriver/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/surgery_initiator/robo)

/obj/item/screwdriver/nuke
	name = "screwdriver"
	desc = "A screwdriver with an ultra thin tip."
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

/obj/item/screwdriver/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M) || user.a_intent == INTENT_HELP)
		return ..()
	if(user.zone_selected != "eyes" && user.zone_selected != "head")
		return ..()
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		M = user
	return eyestab(M,user)

/obj/item/screwdriver/brass
	name = "brass screwdriver"
	desc = "A screwdriver made of brass. The handle feels freezing cold."
	icon_state = "screwdriver_brass"
	toolspeed = 0.5
	random_color = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/screwdriver/cargo
	name = "cargo screwdriver"
	desc = "A brownish screwdriver belonging to the supply department. Unfortunately, it can't do all the paperwork for you..."
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

/obj/item/screwdriver/abductor
	name = "alien screwdriver"
	desc = "An ultrasonic screwdriver."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "screwdriver"
	usesound = 'sound/items/pshoom.ogg'
	toolspeed = 0.1
	random_color = FALSE

/obj/item/screwdriver/power
	name = "hand drill"
	desc = "A simple hand drill with a screwdriver bit attached."
	icon_state = "drill_screw"
	item_state = "drill"
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

/obj/item/screwdriver/power/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_drill.ogg', 50, 1)
	var/obj/item/wrench/power/b_drill = new /obj/item/wrench/power
	to_chat(user, "<span class='notice'>You attach the bolt driver bit to [src].</span>")
	qdel(src)
	user.put_in_active_hand(b_drill)

/obj/item/screwdriver/cyborg
	name = "powered screwdriver"
	desc = "An electrical screwdriver, designed to be both precise and quick."
	usesound = 'sound/items/drill_use.ogg'
	toolspeed = 0.5
