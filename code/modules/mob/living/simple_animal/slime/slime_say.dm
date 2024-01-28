/mob/living/simple_animal/slime/say_quote(text, datum/language/speaking)
	var/verb = "blorbles"
	var/ending = copytext(text, length(text))

	if(ending == "?")
		verb = "inquisitively blorbles"
	else if(ending == "!")
		verb = "loudly blorbles"

	return verb
