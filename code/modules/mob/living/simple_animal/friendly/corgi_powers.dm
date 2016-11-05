/mob/living/simple_animal/pet/corgi/verb/chasetail()
	set name = "Chase your tail"
	set desc = "d'awwww."
	set category = "Corgi"

	var/list/self_messages = list("You dance around","You chase your tail")
	var/list/others_messages = list("dances around","chases its tail")
	var/message_index = rand(1, self_messages.len)

	visible_message("[src] [others_messages[message_index]].","[self_messages[message_index]].")

	for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
		dir = i
		sleep(1)
