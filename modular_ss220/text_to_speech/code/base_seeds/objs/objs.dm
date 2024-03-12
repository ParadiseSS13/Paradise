/obj/machinery
	tts_seed = "Glados"

/obj/machinery/computer
	tts_seed = null

/obj/machinery/autolathe
	tts_seed = null

/obj/machinery/mecha_part_fabricator
	tts_seed = null

/obj/item/taperecorder
	tts_seed = "Xenia"

/obj/item/ttsdevice
	tts_seed = "Xenia"

/obj/structure/mirror/magic/Initialize(mapload, newdir, building)
	. = ..()
	options |= list("Voice TTS")

/obj/structure/mirror/magic/proc/tts_choose(choice, mob/living/carbon/human/human_to_update)
	if(choice == "Voice TTS")
		human_to_update.change_voice(human_to_update, TRUE, TRUE)
