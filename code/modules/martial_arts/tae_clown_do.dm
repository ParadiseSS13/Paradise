//HONK DUB-DUB WAJUB HONK!
/datum/martial_art/tae_clown_do
	name = "Tae Clown Do"
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/tae_clown_do/banana_pie_palm, /datum/martial_combo/tae_clown_do/clown_PUNch, /datum/martial_combo/tae_clown_do/disclownbobulate)

/datum/martial_art/tae_clown_do/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("slaps", "honkstomps", "wallops", "thwacks", "bifs")
	D.visible_message("<span class='danger'>[A] [atk_verb] [D]!</span>",
					  "<span class='userdanger'>[A] [atk_verb] you!</span>")
	D.apply_damage(13, BRUTE)
	playsound(D.loc, 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	if(prob(50))
		A.say(pick("POW!", "THUD!", "WHAP!", "ZUNK!", "BOOM!", "BLAP!", "KAPOW!"))
	if(prob(D.getBruteLoss()) && !D.lying)
		D.visible_message("<span class='warning'>[D] stumbles and falls!</span>", "<span class='userdanger'>The blow sends you to the ground!</span>")
		D.Weaken(3)
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : Punched", ATKLOG_ALL)
	return TRUE

/datum/martial_art/tae_clown_do/explaination_header(user)
	to_chat(user, "<b><i>You recall the teachings of Clown Honk Hi, internalizing them and becoming a master of Tae Clown Do.</i></b>")

/datum/martial_art/tae_clown_do/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/grab/G = D.grabbedby(A, TRUE)
	if(G && ishuman(D) && D.shoes)
		D.unEquip(D.shoes) // Removes shoes
		add_attack_logs(A, D, "Removed shoes with martial-art [src] : Grabbed", ATKLOG_ALL)
	return TRUE

/obj/effect/proc_holder/spell/targeted/click/fireball/honkdouken // This is a subtype of fireball. If you mess with fireball code, you will mess with Honkdouken code!
	name = "Honkdouken"
	desc = "Channel your comedic energy into the peak of slapstick comedy"

	charge_max = 60
	invocation = "HONKDOUKEN!"
	range = 5
	starts_charged = TRUE

	click_radius = -1
	selection_activated_message		= "<span class='notice'>Your prepare to shoot your honkdouken! <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>You release your pent up energy, and extinguish the honkdouken... for now.</span>"
	allowed_type = /atom

	fireball_type = /obj/item/projectile/magic/fireball/honkdouken
	action_icon_state = "honkdouken0"
	sound = 'sound/items/bikehorn.ogg'

	active = FALSE

/obj/effect/proc_holder/spell/targeted/click/fireball/honkdouken/update_icon()
	if(!action)
		return
	action.button_icon_state = "honkdouken[active]"
	action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/targeted/click/fireball/honkdouken/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
    if(user.incapacitated() || user.is_muzzled())
        return
    return ..()

/obj/item/projectile/magic/fireball/honkdouken
	name = "the honkdouken"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "honkdouken"
	nodamage = TRUE

/obj/item/projectile/magic/fireball/honkdouken/on_hit(target)
	if(ismob(target))
		var/mob/living/M = target
		M.Weaken(2)
		playsound(src, 'sound/misc/slip.ogg', 50, 1)
