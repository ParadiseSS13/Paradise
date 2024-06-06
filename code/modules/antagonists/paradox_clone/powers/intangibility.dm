/datum/spell/paradox_spell/self/intangibility
	name = "Intangibility"
	desc = "Just one moment of disappearance, and handcuffs, bolas and other obstacles aren't an issue. Freedom."
	action_icon_state = "intangibility"
	base_cooldown = 180 SECONDS

/datum/spell/paradox_spell/self/intangibility/cast(list/targets, mob/user)
	var/mob/living/carbon/human/H = user
	var/used = FALSE

	do_sparks(rand(1, 2), FALSE, user)

	var/list/obstacles = list()

	if(H.handcuffed)
		obstacles += H.get_item_by_slot(SLOT_HUD_HANDCUFFED)

	if(H.legcuffed)
		obstacles += H.get_item_by_slot(SLOT_HUD_LEGCUFFED)

	if(H.wear_suit && H.wear_suit.breakouttime)
		obstacles += H.get_item_by_slot(SLOT_HUD_OUTER_SUIT)

	if(istype(user.loc, /obj/structure/closet))
		var/obj/structure/closet/C = user.loc
		user.visible_message("<span class='warning'>[user] reaches [C]'s lock through it's wall and opens it!</span>")
		C.welded = FALSE
		C.locked = FALSE
		C.broken = TRUE
		C.open()
		used = TRUE

	for(var/obj/item/grab/G in user.grabbed_by)
		var/mob/living/carbon/M = G.assailant
		user.visible_message("<span class='warning'>[user] goes through [M]'s hands and slips out of their grab!</span>")
		M.Stun(1 SECONDS) // Drops the grab
		M.AdjustHallucinate(40 SECONDS)
		used = TRUE

	for(var/obj/item/I as anything in obstacles)
		user.unEquip(I, TRUE, TRUE)

	if(length(obstacles))
		used = TRUE

	if(used)
		playsound(H, 'sound/effects/paradox_intangibility.ogg', 40, TRUE)
		add_attack_logs(user, user, "(Paradox Clone) Intagbilited")
	else
		revert_cast()
