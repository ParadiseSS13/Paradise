/obj/item/clothing/mask/atmta/gas
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply."
	icon_state = "gas_alt"
	flags = MASKCOVERSMOUTH | MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | AIRTIGHT
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	w_class = 3
	item_state = "gas_alt"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	species_fit = list("Vox", "Unathi", "Tajaran", "Vulpkanin")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/mask.dmi',
		"Drask" = 'icons/mob/species/drask/mask.dmi'
		)

/obj/item/clothing/mask/atmta/gas/doom
	name = "DooM guy's Mask"
	desc = "Breath pure hatred and rage!"
	flags = MASKCOVERSMOUTH | MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | AIRTIGHT | NODROP
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	icon_state = "doomguy"
	actions_types = list(/datum/action/item_action/ripandtear)
	flash_protect = 2

/obj/item/clothing/mask/atmta/gas/doom/attack_self()
	riptear()

/obj/item/clothing/mask/atmta/gas/doom/verb/riptear()
	set category = "Object"
	set name = "RIP AND TEAR"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return

	var/phrase = 0	//selects which phrase to use
	var/phrase_text = null
	var/phrase_sound = null


	if(cooldown < world.time - 35) // A cooldown, to stop people being jerks
		phrase = rand(1,16)	// brutal RANDOM
		switch(phrase)	//sets the properties of the chosen phrase
			if(1)				// good cop
				phrase_text = "I'M OUTTA CONTROL!!"
				phrase_sound = "control"
			if(2)
				phrase_text = "GROOVY!"
				phrase_sound = "groovy"
			if(3)
				phrase_text = "HOI, HOI, I AM THE BOY!"
				phrase_sound = "hoyhoy"
			if(4)
				phrase_text = "I AM MAN, I PSYCHOPAT!"
				phrase_sound = "iamman"
			if(5)
				phrase_text = "KNOCK KNOCK! WHO'S THERE? MEEE!"
				phrase_sound = "knockknock"
			if(6)
				phrase_text = "I FEEL MY TEMPERATURE RISING!"
				phrase_sound = "lord"
			if(7)
				phrase_text = "HERE COMES THE NIGHT TRAIN!"
				phrase_sound = "nighttrain"
			if(8)
				phrase_text = "YOU WANNA PIECE OF ME? COME ON, COME ON!"
				phrase_sound = "piece"
			if(9)
				phrase_text = "RIP AND TEAAAAAR!!!!!"
				phrase_sound = "ripandtear"
			if(10)
				phrase_text = "RIP AND TEAR YOUR GUTS!!!"
				phrase_sound = "ripandtear2"
			if(11)
				phrase_text = "COME HERE BOYS! I GOT SOMETHING TO SAY!"
				phrase_sound = "smthsay"
			if(12)
				phrase_text = "STUPID! STUPID AND DEAD!"
				phrase_sound = "stupidanddead"
			if(13)
				phrase_text = "RIP AND TEAAAAAR!!!!!"
				phrase_sound = "ripandtear"
			if(14)
				phrase_text = "RIP AND TEAR YOUR GUTS!!!"
				phrase_sound = "ripandtear2"
			if(15)
				phrase_text = "RIP AND TEAAAAAR!!!!!"
				phrase_sound = "ripandtear"
			if(16)
				phrase_text = "RIP AND TEAR YOUR GUTS!!!"
				phrase_sound = "ripandtear2"

		usr.visible_message("[usr] shouted : <font color='red' size='4'><b>[phrase_text]</b></font>")
		playsound(src.loc, "sound/voice/doom/[phrase_sound].ogg", 80, 0, 4)
		cooldown = world.time