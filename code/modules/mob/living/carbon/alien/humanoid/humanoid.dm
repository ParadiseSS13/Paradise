/mob/living/carbon/alien/humanoid
	name = "alien"
	icon_state = "alien_s"

	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/xenomeat= 5, /obj/item/stack/sheet/animalhide/xeno = 1)
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/caste = ""
	var/alt_icon = 'icons/mob/alienleap.dmi' //used to switch between the two alien icon files.
	var/next_attack = 0
	var/pounce_cooldown = 0
	var/pounce_cooldown_time = 30
	var/leap_on_click = 0
	var/custom_pixel_x_offset = 0 //for admin fuckery.
	var/custom_pixel_y_offset = 0
	var/alien_disarm_damage = 30 //Aliens deal a good amount of stamina damage on disarm intent
	var/alien_slash_damage = 20 //Aliens deal a good amount of damage on harm intent
	var/alien_movement_delay = 0 //This can be + or -, how fast an alien moves
	pass_flags = PASSTABLE

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/humanoid/Initialize(mapload)
	if(name == "alien")
		name = text("alien ([rand(1, 1000)])")
	real_name = name
	add_language("Xenomorph")
	add_language("Hivemind")
	AddSpell(new /obj/effect/proc_holder/spell/alien_spell/regurgitate)
	. = ..()
	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_CLAW, 0.5, -11)

/mob/living/carbon/alien/humanoid/Process_Spacemove(check_drift = 0)
	if(..())
		return 1

	return 0

/mob/living/carbon/alien/humanoid/emp_act(severity)
	if(r_store) r_store.emp_act(severity)
	if(l_store) l_store.emp_act(severity)
	..()

/mob/living/carbon/alien/humanoid/ex_act(severity)
	..()

	var/shielded = 0

	var/b_loss = null
	var/f_loss = null
	switch(severity)
		if(1.0)
			gib()
			return

		if(2.0)
			if(!shielded)
				b_loss += 60

			f_loss += 60

			Deaf(2 MINUTES)
		if(3.0)
			b_loss += 30
			if(prob(50) && !shielded)
				Paralyse(2 SECONDS)
			Deaf(1 MINUTES)

	take_overall_damage(b_loss, f_loss)

/mob/living/carbon/alien/humanoid/restrained()
	if(handcuffed)
		return 1
	return 0


/mob/living/carbon/alien/humanoid/var/temperature_resistance = T0C+75

/mob/living/carbon/alien/humanoid/movement_delay() //Aliens have a varied movespeed
	. = ..()
	. += alien_movement_delay

/mob/living/carbon/alien/humanoid/show_inv(mob/user as mob)
	user.set_machine(src)

	var/dat = {"<table>
	<tr><td><B>Left Hand:</B></td><td><A href='?src=[UID()];item=[SLOT_HUD_LEFT_HAND]'>[(l_hand && !(l_hand.flags&ABSTRACT)) ? html_encode(l_hand) : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td><B>Right Hand:</B></td><td><A href='?src=[UID()];item=[SLOT_HUD_RIGHT_HAND]'>[(r_hand && !(r_hand.flags&ABSTRACT)) ? html_encode(r_hand) : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td>&nbsp;</td></tr>"}

	dat += "<tr><td><B>Head:</B></td><td><A href='?src=[UID()];item=[SLOT_HUD_HEAD]'>[(head && !(head.flags&ABSTRACT)) ? html_encode(head) : "<font color=grey>Empty</font>"]</A></td></tr>"

	dat += "<tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Exosuit:</B></td><td><A href='?src=[UID()];item=[SLOT_HUD_OUTER_SUIT]'>[(wear_suit && !(wear_suit.flags&ABSTRACT)) ? html_encode(wear_suit) : "<font color=grey>Empty</font>"]</A></td></tr>"
	dat += "<tr><td><B>Pouches:</B></td><td><A href='?src=[UID()];item=pockets'>[((l_store && !(l_store.flags&ABSTRACT)) || (r_store && !(r_store.flags&ABSTRACT))) ? "Full" : "<font color=grey>Empty</font>"]</A>"

	dat += {"</table>
	<A href='?src=[user.UID()];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 440, 500)
	popup.set_content(dat)
	popup.open()

/mob/living/carbon/alien/humanoid/canBeHandcuffed()
	return 1

/mob/living/carbon/alien/humanoid/cuff_resist(obj/item/I)
	playsound(src, 'sound/voice/hiss5.ogg', 40, 1, 1)  //Alien roars when starting to break free
	..(I, cuff_break = 1)

/mob/living/carbon/alien/humanoid/get_standard_pixel_y_offset()
	if(leaping)
		return -32
	else if(custom_pixel_y_offset)
		return custom_pixel_y_offset
	else
		return initial(pixel_y)

/mob/living/carbon/alien/humanoid/get_standard_pixel_x_offset(lying = 0)
	if(leaping)
		return -32
	else if(custom_pixel_x_offset)
		return custom_pixel_x_offset
	else
		return initial(pixel_x)

/mob/living/carbon/alien/humanoid/get_permeability_protection()
	return 0.8
