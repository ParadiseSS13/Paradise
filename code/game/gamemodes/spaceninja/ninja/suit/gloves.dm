/**
 * # Ninja Gloves
 *
 * Space ninja's gloves.  Gives access to a number of special interactions.
 *
 * Gloves only found from space ninjas.  Allows the wearer to access special interactions with various objects.
 * These interactions are detailed in ninjaDrainAct.dm in the suit file.
 * These interactions are toggled by an action tied to the gloves.  The interactions will not activate if the user is also not wearing a ninja suit.
 *
 */
/obj/item/clothing/gloves/space_ninja
	desc = "These nano-enhanced gloves insulate from electricity and provide fire resistance."
	name = "ninja gloves"
	icon = 'icons/obj/ninjaobjects.dmi'
	lefthand_file = 'icons/mob/inhands/antag/ninja_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/ninja_righthand.dmi'
	icon_state = "ninja_gloves"
	item_state = "ninja_gloves" //Нужен спрайт
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	strip_delay = 120
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 40, "bullet" = 30, "laser" = 20,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 25, "fire" = 100, "acid" = 100)
	///Ниндзя украл ваше бельё ( ͡° ͜ʖ ͡°)
	pickpocket = 1
	///Whether or not we're currently draining something
	var/draining = FALSE
	///Minimum amount of power we can drain in a single drain action
	var/mindrain = 800
	///Maximum amount of power we can drain in a single drain action
	var/maxdrain = 1600

/obj/item/clothing/gloves/space_ninja/Touch(atom/A,proximity,modifiers)
	var/mob/living/carbon/human/wearer = loc
	var/obj/item/clothing/suit/space/space_ninja/suit = wearer.wear_suit

	if(wearer.a_intent != INTENT_DISARM || draining)
		return FALSE
	if(!ishuman(loc))
		return FALSE //Only works while worn
	if(!istype(suit))
		return FALSE
	if(isturf(A))
		return FALSE
	if(!proximity)
		return FALSE

	A.add_fingerprint(wearer)

	draining = TRUE
	. = A.ninjadrain_act(suit,wearer,src)
	draining = FALSE

	if(isnum(.)) //Numerical values of drained handle their feedback here, Alpha values handle it themselves (Research hacking)
		if(.)
			to_chat(wearer, span_notice("Gained <B>[.]</B> of energy from [A]."))
		else
			to_chat(wearer, span_danger("The connection with [A] has been cancelled."))
	else
		. = FALSE //as to not cancel attack_hand()

/obj/item/clothing/gloves/space_ninja/examine(mob/user)
	. = ..() + "[p_their(TRUE)] energy drain mechanism is activated by touching objects in a disarming manner."
