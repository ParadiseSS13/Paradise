/mob/living/carbon/slime/death(gibbed)
	// uhhhhhhhhh
	// if an adult slime dies, it creates a new, angry, baby slime, then
	// becomes a baby slime itself again and comes back to life.
	// TODO: This code is REALLY ugly, needs to be made nice
	if(!gibbed)
		if(is_adult)
			var/mob/living/carbon/slime/M = new /mob/living/carbon/slime(loc)
			M.colour = colour
			M.rabid = 1
			is_adult = 0
			maxHealth = 150
			revive()
			regenerate_icons()
			number = rand(1, 1000)
			name = "[colour] [is_adult ? "adult" : "baby"] slime ([number])"
			return 0
	. = ..()
	if(!.)	return

	mood = ""
	regenerate_icons()
	visible_message("<b>The [name]</b> seizes up and falls limp...") //ded -- Urist
