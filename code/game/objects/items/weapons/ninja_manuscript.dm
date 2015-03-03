/obj/item/weapon/ninja_manuscript
	name = "Manuscript"
	desc = "A mysterious manuscript..."
	icon = 'icons/obj/library.dmi'
	icon_state = "book1"
	throw_speed = 1
	throw_range = 5
	w_class = 3
	attack_verb = list("bashed", "whacked", "educated")

	var/charges = 1

/obj/item/weapon/ninja_manuscript/attack_self(var/mob/user as mob)

	if(charges <= 0)
		user << "\red The manuscript's power appears spent..."
		return

	else
		user << "\blue You intently read the manuscript and come to the realization that true balance is achieved through self-will."
		user << "\blue You relax and concentrate deeply; something in your mind alights ablaze and you realize the only way to true balance is the way of the Ninja."

		charges--


		user.mind.assigned_role = "MODE"
		user.mind.special_role = "Ninja"

	return