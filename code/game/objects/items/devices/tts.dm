/obj/item/ttsdevice
	name = "TTS device"
	desc = "A small device with a keyboard attached. Anything entered on the keyboard is played out the speaker."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-purple"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=200)
	tts_seed = "Xenia"

/obj/item/ttsdevice/Initialize(mapload)
	. = ..()
	desc = "A small device with a keyboard attached. Anything entered on the keyboard is played out the speaker. \n<span class='notice'>Alt-click the device to make it beep.</span> \n<span class='notice'>Ctrl-click to name the device."

/obj/item/ttsdevice/attack_self(mob/user)
	visible_message("[user] starts typing on [src].", "You begin typing on [src].", "You hear faint, continuous mechanical clicking noises.")
	playsound(src, "terminal_type", 50, TRUE)
	var/input = stripped_input(user,"What would you like the device to say?", ,"", 500)
	if(!src.Adjacent(user) || QDELETED(src))
		return

	if(!input)
		visible_message("[user] stops typing on [src].", "You stop typing on [src].", "You hear the clicking noises stop.")
		playsound(src, "terminal_type", 50, TRUE)
		return
	atom_say(input)
	add_say_logs(user, input, language = "TTS")

/obj/item/ttsdevice/AltClick(mob/living/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!Adjacent(user))
		return
	var/noisechoice = input(user, "What noise would you like to make?", "Robot Noises") as null|anything in list("Beep","Buzz","Ping")
	switch(noisechoice)
		if("Beep")
			user.visible_message("<span class='notice'>[user] has made their TTS beep!</span>", "You make your TTS beep!")
			playsound(user, 'sound/machines/twobeep.ogg', 50, 1, -1)
		if("Buzz")
			user.visible_message("<span class='notice'>[user] has made their TTS buzz!</span>", "You make your TTS buzz!")
			playsound(user, 'sound/machines/buzz-sigh.ogg', 50, 1, -1)
		if("Ping")
			user.visible_message("<span class='notice'>[user] has made their TTS ping!</span>", "You make your TTS ping!")
			playsound(user, 'sound/machines/ping.ogg', 50, 1, -1)

/obj/item/ttsdevice/CtrlClick(mob/living/user)
	if(!src.Adjacent(user))
		return
	var/new_name = input(user, "Name your Text-to-Speech device: \nThis matters for displaying it in the chat bar:", "TTS Device")  as text|null
	if(new_name)
		new_name = reject_bad_name(new_name)
		name = "[new_name]'s [initial(name)]"
	change_voice(user)
