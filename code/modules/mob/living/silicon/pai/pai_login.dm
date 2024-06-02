/mob/living/silicon/pai/Login()
	..()
	if(!custom_sprite)
		if(ckey in GLOB.configuration.custom_sprites.pai_holoform_ckeys)
			custom_sprite = TRUE
