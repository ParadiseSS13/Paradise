/obj/item/clothing/gloves/fingerless
	name = "fingerless gloves"
	desc = "Plain black gloves without fingertips for the hard working."
	icon_state = "fingerless"
	item_state = "fingerless"
	item_color = null	//So they don't wash.
	transfer_prints = TRUE
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	strip_delay = 40
	put_on_delay = 20
	clipped = TRUE
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/gloves.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/gloves.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/gloves.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/gloves.dmi',
		)

/obj/item/clothing/gloves/cyborg
	name = "cyborg gloves"
	desc = "beep boop borp"
	icon_state = "black"
	item_state = "r_hands"


/obj/item/clothing/gloves/color/black/forensics
	name = "forensics gloves"
	desc = "These high-tech gloves don't leave any material traces on objects they touch. Perfect for leaving crime scenes undisturbed...both before and after the crime."
	icon_state = "forensics"
	item_state = "forensics"
	can_leave_fibers = FALSE

/obj/item/clothing/gloves/combat
	name = "combat gloves"
	desc = "These tactical gloves are both insulated and offer protection from heat sources."
	icon_state = "combat"
	item_state = "swat_gl"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 200, ACID = 50)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/gloves.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/gloves.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/gloves.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/gloves.dmi',
		)

/obj/item/clothing/gloves/bracer
	name = "bone bracers"
	desc = "For when you're expecting to get slapped on the wrist. Offers modest protection to your arms."
	icon_state = "bracers"
	item_state = "bracers"
	item_color = null	//So they don't wash.
	transfer_prints = TRUE
	strip_delay = 40
	body_parts_covered = ARMS
	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list(MELEE = 10, BULLET = 15, LASER = 10, ENERGY = 10, BOMB = 10, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/gloves/botanic_leather
	name = "botanist's leather gloves"
	desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin."
	icon_state = "leather"
	item_state = "ggloves"
	permeability_coefficient = 0.9
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 115, ACID = 20)

/obj/item/clothing/gloves/batmangloves
	name = "batgloves"
	desc = "Used for handling all things bat related."
	icon_state = "bmgloves"
	item_state = "bmgloves"
	item_color="bmgloves"

/obj/item/clothing/gloves/cursedclown
	name = "cursed white gloves"
	desc = "These things smell terrible, and they're all lumpy. Gross."
	icon_state = "latex"
	item_state = "lgloves"
	flags = NODROP

/obj/item/clothing/gloves/color/yellow/stun
	name = "stun gloves"
	desc = "Horrendous and awful. It smells like cancer. The fact it has wires attached to it is incidental."
	var/obj/item/stock_parts/cell/cell = null
	var/stun_strength = 10 SECONDS
	var/stun_cost = 2000

/obj/item/clothing/gloves/color/yellow/stun/get_cell()
	return cell

/obj/item/clothing/gloves/color/yellow/stun/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/clothing/gloves/color/yellow/stun/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/clothing/gloves/color/yellow/stun/Touch(atom/A, proximity)
	if(!ishuman(loc))
		return FALSE //Only works while worn
	if(!iscarbon(A))
		return FALSE
	if(!proximity)
		return FALSE
	if(cell)
		var/mob/living/carbon/human/H = loc
		if(H.a_intent == INTENT_HARM)
			var/mob/living/carbon/C = A
			if(cell.use(stun_cost))
				do_sparks(5, 0, loc)
				playsound(loc, 'sound/weapons/egloves.ogg', 50, 1, -1)
				H.do_attack_animation(C)
				visible_message("<span class='danger'>[C] has been touched with [src] by [H]!</span>")
				add_attack_logs(H, C, "Touched with stun gloves")
				C.Weaken(stun_strength)
				C.Stuttering(stun_strength)
			else
				to_chat(H, "<span class='notice'>Not enough charge!</span>")
			return TRUE
	return FALSE

/obj/item/clothing/gloves/color/yellow/stun/update_overlays()
	. = ..()
	. += "gloves_wire"
	if(cell)
		. += "gloves_cell"

/obj/item/clothing/gloves/color/yellow/stun/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		if(!cell)
			if(!user.drop_item())
				to_chat(user, "<span class='warning'>[W] is stuck to you!</span>")
				return
			W.forceMove(src)
			cell = W
			to_chat(user, "<span class='notice'>You attach [W] to [src].</span>")
			update_icon(UPDATE_OVERLAYS)
		else
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")
	else
		return ..()

/obj/item/clothing/gloves/color/yellow/stun/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(cell)
		to_chat(user, "<span class='notice'>You cut [cell] away from [src].</span>")
		cell.forceMove(get_turf(loc))
		cell = null
		update_icon(UPDATE_OVERLAYS)

/obj/item/clothing/gloves/color/yellow/fake/examine(mob/user)
	. = ..()
	if(user.Adjacent(src))
		. += "<span class='notice'>They don't feel like rubber...</span>"

/obj/item/clothing/gloves/fingerless/rapid
	name = "gloves of the North Star"
	desc = "Just looking at these fills you with an urge to beat the shit out of people."
	var/accepted_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, INTENT_HARM)
	var/click_speed_modifier = CLICK_CD_RAPID

/obj/item/clothing/gloves/fingerless/rapid/Touch(mob/living/target, proximity = TRUE)
	var/mob/living/L = loc
	if(HAS_TRAIT(L, TRAIT_HULK))
		return FALSE

	// We don't use defines here so admingloves can work
	if(L.mind.martial_art?.can_use(L))
		click_speed_modifier = initial(click_speed_modifier) * 2 // 4
	else
		click_speed_modifier = initial(click_speed_modifier) // 2

	if((L.a_intent in accepted_intents))
		L.changeNext_move(click_speed_modifier)

	return FALSE

/obj/item/clothing/gloves/fingerless/rapid/admin
	name = "advanced interactive gloves"
	desc = "The gloves are covered in indecipherable buttons and dials, your mind warps by merely looking at them."
	click_speed_modifier = 0
	siemens_coefficient = 0

/obj/item/clothing/gloves/fingerless/rapid/headpat
	name = "gloves of headpats"
	desc = "You feel the irresistable urge to give headpats by merely glimpsing these."
	accepted_intents = list(INTENT_HELP)
