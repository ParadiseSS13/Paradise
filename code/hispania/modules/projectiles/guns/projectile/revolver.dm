///////Probabilidad de Fallo Escopeta Improvisada //
/obj/item/gun/projectile/revolver/doublebarrel/improvised/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override = "")
	if(prob(4))
		var/obj/item/organ/external/affecting = user.get_organ("[user.hand ? "l" : "r" ]_hand")
		var/obj/item/ammo_casing/AC = magazine.get_round() //Carga la siguiente bala, pero al no existir "destruye" la bala actual.
		playsound(user, fire_sound, 50, 1)
		to_chat(user, "<span class='userdanger'>[src] malfunctions in your hand!</span>")
		affecting.receive_damage(20)
		chambered = AC
		user.Weaken(3)
		user.Stun(3)
		return FALSE
	..()
