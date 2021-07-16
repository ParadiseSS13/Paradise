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
	clipped = 1

/obj/item/clothing/gloves/cyborg
	name = "cyborg gloves"
	desc = "beep boop borp"
	icon_state = "black"
	item_state = "r_hands"


/obj/item/clothing/gloves/color/black/forensics
	name = "forensics gloves"
	desc = "These high-tech gloves don't leave any material traces on objects they touch. Perfect for leaving crime scenes undisturbed...both before and after the crime."
	icon_state = "forensics"
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
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 50)

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
	armor = list("melee" = 15, "bullet" = 25, "laser" = 15, "energy" = 15, "bomb" = 20, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)

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
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 30)

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
	var/stun_strength = 5
	var/stun_cost = 2000

/obj/item/clothing/gloves/color/yellow/stun/get_cell()
	return cell

/obj/item/clothing/gloves/color/yellow/stun/New()
	..()
	update_icon()

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
				playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
				H.do_attack_animation(C)
				visible_message("<span class='danger'>[C] has been touched with [src] by [H]!</span>")
				add_attack_logs(H, C, "Touched with stun gloves")
				C.Stun(stun_strength)
				C.Weaken(stun_strength)
				C.apply_effect(STUTTER, stun_strength)
			else
				to_chat(H, "<span class='notice'>Not enough charge!</span>")
			return TRUE
	return FALSE

/obj/item/clothing/gloves/color/yellow/stun/update_icon()
	..()
	overlays.Cut()
	overlays += "gloves_wire"
	if(cell)
		overlays += "gloves_cell"

/obj/item/clothing/gloves/color/yellow/stun/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		if(!cell)
			if(!user.drop_item())
				to_chat(user, "<span class='warning'>[W] is stuck to you!</span>")
				return
			W.forceMove(src)
			cell = W
			to_chat(user, "<span class='notice'>You attach [W] to [src].</span>")
			update_icon()
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
		update_icon()

/obj/item/clothing/gloves/fingerless/rapid
	name = "gloves of the North Star"
	desc = "Just looking at these fills you with an urge to beat the shit out of people."
	var/accepted_intents = list(INTENT_HARM)
	var/click_speed_modifier = CLICK_CD_RAPID

/obj/item/clothing/gloves/fingerless/rapid/Touch(mob/living/target, proximity = TRUE)
	var/mob/living/M = loc

	if(M.a_intent in accepted_intents)
		if(M.mind.martial_art || HAS_TRAIT(M, TRAIT_HULK))
			M.changeNext_move(CLICK_CD_MELEE)//normal attack speed for hulk, CQC and Carp.
		else
			M.changeNext_move(click_speed_modifier)
	.= FALSE

/obj/item/clothing/gloves/fingerless/rapid/admin
	name = "advanced interactive gloves"
	desc = "The gloves are covered in indecipherable buttons and dials, your mind warps by merely looking at them."
	accepted_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, INTENT_HARM)
	click_speed_modifier = 0
	siemens_coefficient = 0

/obj/item/clothing/gloves/fingerless/rapid/headpat
	name = "gloves of headpats"
	desc = "You feel the irresistable urge to give headpats by merely glimpsing these."
	accepted_intents = list(INTENT_HELP)
