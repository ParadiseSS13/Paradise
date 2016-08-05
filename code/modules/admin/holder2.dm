var/list/admin_datums = list()

/datum/admins
	var/rank			= "Temporary Admin"
	var/client/owner	= null
	var/rights = 0
	var/fakekey			= null
	var/big_brother		= 0

	var/datum/marked_datum

	var/admincaster_screen = 0	//See newscaster.dm under machinery for a full description
	var/datum/feed_message/admincaster_feed_message = new /datum/feed_message   //These two will act as holders.
	var/datum/feed_channel/admincaster_feed_channel = new /datum/feed_channel
	var/admincaster_signature	//What you'll sign the newsfeeds as

/datum/admins/New(initial_rank = "Temporary Admin", initial_rights = 0, ckey)
	if(!ckey)
		error("Admin datum created without a ckey argument. Datum has been deleted")
		qdel(src)
		return
	admincaster_signature = "Nanotrasen Officer #[rand(0,9)][rand(0,9)][rand(0,9)]"
	rank = initial_rank
	rights = initial_rights
	admin_datums[ckey] = src

/datum/admins/Destroy()
	..()
	return QDEL_HINT_HARDDEL_NOW

/datum/admins/proc/associate(client/C)
	if(istype(C))
		owner = C
		owner.holder = src
		owner.add_admin_verbs()	//TODO
		owner.verbs -= /client/proc/readmin
		admins |= C

/datum/admins/proc/disassociate()
	if(owner)
		admins -= owner
		owner.remove_admin_verbs()
		owner.holder = null
		owner = null

/*
checks if usr is an admin with at least ONE of the flags in rights_required. (Note, they don't need all the flags)
if rights_required == 0, then it simply checks if they are an admin.
if it doesn't return 1 and show_msg=1 it will prints a message explaining why the check has failed
generally it would be used like so:

proc/admin_proc()
	if(!check_rights(R_ADMIN)) return
	to_chat(world, "you have enough rights!")

NOTE: it checks usr! not src! So if you're checking somebody's rank in a proc which they did not call
you will have to do something like if(client.holder.rights & R_ADMIN) yourself.
*/
/proc/check_rights(rights_required, show_msg=1, var/mob/user = usr)
	if(user && user.client)
		if(rights_required)
			if(user.client.holder)
				if(rights_required & user.client.holder.rights)
					return 1
				else
					if(show_msg)
						to_chat(user, "<font color='red'>Error: You do not have sufficient rights to do that. You require one of the following flags:[rights2text(rights_required," ")].</font>")
		else
			if(user.client.holder)
				return 1
			else
				if(show_msg)
					to_chat(user, "<font color='red'>Error: You are not an admin.</font>")
	return 0

//probably a bit iffy - will hopefully figure out a better solution
/proc/check_if_greater_rights_than(client/other)
	if(usr && usr.client)
		if(usr.client.holder)
			if(!other || !other.holder)
				return 1
			if(usr.client.holder.rights != other.holder.rights)
				if( (usr.client.holder.rights & other.holder.rights) == other.holder.rights )
					return 1	//we have all the rights they have and more
		to_chat(usr, "<font color='red'>Error: Cannot proceed. They have more or equal rights to us.</font>")
	return 0

/client/proc/deadmin()
	admin_datums -= ckey
	if(holder)
		holder.disassociate()
		qdel(holder)
	return 1

//This proc checks whether subject has at least ONE of the rights specified in rights_required.
/proc/check_rights_for(client/subject, rights_required)
	if(subject && subject.holder)
		if(rights_required && !(rights_required & subject.holder.rights))
			return 0
		return 1
	return 0
