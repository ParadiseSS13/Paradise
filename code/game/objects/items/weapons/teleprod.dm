/obj/item/melee/baton/cattleprod/teleprod
	name = "teleprod"
	desc = "A prod with a bluespace crystal on the end. The crystal doesn't look too fun to touch."
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	icon_state = "teleprod_nocell"
	base_icon = "teleprod"
	origin_tech = "combat=2;bluespace=4;materials=3"

/obj/item/melee/baton/cattleprod/teleprod/pre_attack(atom/A, mob/living/user, params)
	if(..())
		return FINISH_ATTACK

	if(!turned_on)
		return FINISH_ATTACK

	if(!ismob(A))
		return
	
	var/mob/living/carbon/M
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		user.visible_message(
			"<span class='danger'>[user] accidentally hits [user.p_themselves()] with [src]!</span>",
			"<span class='userdanger'>You accidentally hit yourself with [src]!</span>"
			)
		deductcharge(hitcost)
		do_teleport(user, get_turf(user), 50)//honk honk
	else if(isliving(M) && !M.anchored)
		do_teleport(M, get_turf(M), 15)
