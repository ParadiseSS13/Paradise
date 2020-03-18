/datum/data/pda/messenger_plugin
	var/datum/data/pda/app/messenger/messenger

/datum/data/pda/messenger_plugin/proc/user_act(mob/user as mob, obj/item/pda/P)


/datum/data/pda/messenger_plugin/virus
	name = "*Send Virus*"

/datum/data/pda/messenger_plugin/virus/user_act(mob/user as mob, obj/item/pda/P)
	var/datum/data/pda/app/messenger/M = P.find_program(/datum/data/pda/app/messenger)

	if(M && !M.toff && pda.cartridge.charges > 0)
		pda.cartridge.charges--
		return 1
	return 0


/datum/data/pda/messenger_plugin/virus/clown
	icon = "star"

/datum/data/pda/messenger_plugin/virus/clown/user_act(mob/user as mob, obj/item/pda/P)
	. = ..(user, P)
	if(.)
		user.show_message("<span class='notice'>Virus sent!</span>", 1)
		P.honkamt = (rand(15,20))
		P.ttone = "honk"


/datum/data/pda/messenger_plugin/virus/mime
	icon = "arrow-circle-down"

/datum/data/pda/messenger_plugin/virus/mime/user_act(mob/user as mob, obj/item/pda/P)
	. = ..(user, P)
	if(.)
		user.show_message("<span class='notice'>Virus sent!</span>", 1)
		var/datum/data/pda/app/M = P.find_program(/datum/data/pda/app/messenger)
		if(M)
			M.notify_silent = 1
		P.ttone = "silence"


/datum/data/pda/messenger_plugin/virus/detonate
	name = "*Detonate*"
	icon = "exclamation-circle"

/datum/data/pda/messenger_plugin/virus/detonate/user_act(mob/user as mob, obj/item/pda/P)
	. = ..(user, P)
	if(.)
		var/difficulty = 0

		if(pda.cartridge)
			difficulty += pda.cartridge.programs.len / 2
		else
			difficulty += 2

		if(!P.detonate || P.hidden_uplink)
			user.show_message("<span class='warning'>The target PDA does not seem to respond to the detonation command.</span>", 1)
			pda.cartridge.charges++
		else if(prob(difficulty * 12))
			user.show_message("<span class='warning'>An error flashes on your [pda].</span>", 1)
		else if(prob(difficulty * 3))
			user.show_message("<span class='danger'>Energy feeds back into your [pda]!</span>", 1)
			pda.close(user)
			pda.explode()
			log_admin("[key_name(user)] just attempted to blow up [P] with the Detomatix cartridge but failed, blowing themselves up")
			message_admins("[key_name_admin(user)] just attempted to blow up [P] with the Detomatix cartridge but failed, blowing themselves up", 1)
		else
			user.show_message("<span class='notice'>Success!</span>", 1)
			log_admin("[key_name(user)] just attempted to blow up [P] with the Detomatix cartridge and succeded")
			message_admins("[key_name_admin(user)] just attempted to blow up [P] with the Detomatix cartridge and succeded", 1)
			P.explode()

/datum/data/pda/messenger_plugin/virus/frame
	icon = "exclamation-circle"

/datum/data/pda/messenger_plugin/virus/frame/user_act(mob/user, obj/item/pda/P)
	. = ..(user, P)
	if(.)
		var/lock_code = "[rand(100,999)] [pick("Alpha","Bravo","Charlie","Delta","Echo","Foxtrot","Golf","Hotel","India","Juliet","Kilo","Lima","Mike","November","Oscar","Papa","Quebec","Romeo","Sierra","Tango","Uniform","Victor","Whiskey","X-ray","Yankee","Zulu")]"
		user.show_message("<span class='notice'>Virus Sent!  The unlock code to the target is: [lock_code]</span>")
		if(!P.hidden_uplink)
			var/obj/item/uplink/hidden/uplink = new(P)
			P.hidden_uplink = uplink
			P.lock_code = lock_code
		else
			P.hidden_uplink.hidden_crystals += P.hidden_uplink.uses //Temporarially hide the PDA's crystals, so you can't steal telecrystals.
		var/obj/item/cartridge/frame/parent_cart = pda.cartridge
		P.hidden_uplink.uses = parent_cart.telecrystals
		parent_cart.telecrystals = 0
		P.hidden_uplink.active = TRUE
