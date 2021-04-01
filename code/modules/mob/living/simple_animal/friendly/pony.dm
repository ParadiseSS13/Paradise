
/mob/living/simple_animal/pet/pony
	name = "pony"
	desc = "I used to wonder what friendship could be!"
	icon = 'icons/mob/pony.dmi'
	icon_state = "whooves"
	maxHealth = 300
	health = 300
	response_help  = "pets"
	response_disarm = "pushes"
	response_harm   = "kicks"
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "bucks"
	faction = list("pony")
	speak_chance = 1
	turns_per_move = 10
	universal_speak = TRUE
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_SHOE //Close enough to hooves

mob/living/simple_animal/pet/pony/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return
	visible_message("<span class='warning'>[src] falls to the floor and quickly fades into non-existence.</span>")
	qdel(src)

/mob/living/simple_animal/pet/pony/rainbow
	name = "Rainbow Dash"
	real_name = "Rainbow Dash"
	desc = "Big adventures!"
	icon_state = "rainbow"
	icon_living = "rainbow"

/mob/living/simple_animal/pet/pony/pinkie
	name = "Pinkie Pie"
	real_name = "Pinkie Pie"
	desc = "Tons of fun!"
	icon_state = "pinkie"
	icon_living = "pinkie"

mob/living/simple_animal/pet/pony/rarity
	name = "Rarity"
	real_name = "Rarity"
	desc = "A beautiful heart!"
	icon_state = "rarity"
	icon_living = "rarity"

mob/living/simple_animal/pet/pony/applejack
	name = "Applejack"
	real_name = "Applejack"
	desc = "Faithful and strong!"
	icon_state = "applejack"
	icon_living = "applejack"

mob/living/simple_animal/pet/pony/fluttershy
	name = "Fluttershy"
	real_name = "Fluttershy"
	desc = "Sharing kindness, it's an easy feat..."
	icon_state = "fluttershy"
	icon_living = "fluttershy"

/mob/living/simple_animal/pet/pony/twilight
	name = "Twilight Sparkle"
	real_name = "Twilight Sparkle"
	desc = "And magic makes it all complete!" //Myy litttle poonyyy, did you know that you're all my very best friieeeeeeeeeeeeeeheeeeennnddddss
	icon_state = "twilight"
	icon_living = "twilight"

mob/living/simple_animal/pet/pony/clownie
	name = "Clownie"
	real_name = "Clownie"
	desc = "Tons of honks!"
	icon_state = "clownie"
	icon_living = "clownie"

mob/living/simple_animal/pet/pony/tia
	name = "Princess Celestia"
	real_name = "Princess Celestia"
	desc = "A regal pony. Seems much smaller than it ought to be."
	icon_state = "tia"
	icon_living = "tia"

mob/living/simple_animal/pet/pony/luna
	name = "Princess Luna"
	real_name = "Princess Luna"
	desc = "An edgy regal pony. Seems a bit smaller than it ought to be."
	icon_state = "luna"
	icon_living = "luna"

mob/living/simple_animal/pet/pony/trixie
	name = "Trixie"
	real_name = "Trixie"
	desc = "Seems great and powerful."
	icon_state = "trixie_a_full"
	icon_living = "trixing_a_full"

mob/living/simple_animal/pet/pony/lyra
	name = "Lyra"
	real_name = "Lyra"
	desc = "Definitely straight."
	icon_state = "lyra"
	icon_living = "lyra"

mob/living/simple_animal/pet/pony/vinyl
	name = "Vinyl Scratch"
	real_name = "Vinyl"
	desc = "Also known as DJ-PON3 in the biz."
	icon_state = "vinyl"
	icon_living = "vinyl"

mob/living/simple_animal/pet/pony/whooves
	name = "Doctor Whooves"
	real_name = "Doctor Whooves"
	desc = "Carefully studying the world around him."
	icon_state = "whooves"
	icon_living = "whooves"

mob/living/simple_animal/pet/pony/mac
	name = "Big Mac"
	real_name = "Mac"
	desc = "Eeyup."
	icon_state = "mac"
	icon_living = "mac"