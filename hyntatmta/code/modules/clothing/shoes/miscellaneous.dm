/obj/item/clothing/shoes/atmta/hunter_boots
	name = "Hunter's boots"
	desc = "One of the standard articles of hunter attire, fashioned at the workshop."
	can_cut_open = 0
	icon_state = "hunter_boots"
	item_state = "hunter_boots"
	flags = NOSLIP
	armor = list(melee = 20, bullet = 40, laser = 10, energy = 0, bomb = 10, bio = 50, rad = 50)
	strip_delay = 70

/obj/item/clothing/shoes/atmta/hunter_boots/verb/roll_back()
	set name = "Roll"
	set category = "IC"
	set desc = "Allows you to step back at any time."

	for(var/i=0, i<1, i++)
		step(usr, usr.dir)
		usr.SpinAnimation(5,1)
		usr.visible_message("<span class = 'notice'>\ [usr] jumps aside!</span>")
		sleep(1)