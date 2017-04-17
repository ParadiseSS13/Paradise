
/*
VVVVVVVV           VVVVVVVV     OOOOOOOOO     RRRRRRRRRRRRRRRRR   EEEEEEEEEEEEEEEEEEEEEE
V::::::V           V::::::V   OO:::::::::OO   R::::::::::::::::R  E::::::::::::::::::::E
V::::::V           V::::::V OO:::::::::::::OO R::::::RRRRRR:::::R E::::::::::::::::::::E
V::::::V           V::::::VO:::::::OOO:::::::ORR:::::R     R:::::REE::::::EEEEEEEEE::::E
 V:::::V           V:::::V O::::::O   O::::::O  R::::R     R:::::R  E:::::E       EEEEEE
  V:::::V         V:::::V  O:::::O     O:::::O  R::::R     R:::::R  E:::::E
   V:::::V       V:::::V   O:::::O     O:::::O  R::::RRRRRR:::::R   E::::::EEEEEEEEEE
    V:::::V     V:::::V    O:::::O     O:::::O  R:::::::::::::RR    E:::::::::::::::E
     V:::::V   V:::::V     O:::::O     O:::::O  R::::RRRRRR:::::R   E:::::::::::::::E
      V:::::V V:::::V      O:::::O     O:::::O  R::::R     R:::::R  E::::::EEEEEEEEEE
       V:::::V:::::V       O:::::O     O:::::O  R::::R     R:::::R  E:::::E
        V:::::::::V        O::::::O   O::::::O  R::::R     R:::::R  E:::::E       EEEEEE
         V:::::::V         O:::::::OOO:::::::ORR:::::R     R:::::REE::::::EEEEEEEE:::::E
          V:::::V           OO:::::::::::::OO R::::::R     R:::::RE::::::::::::::::::::E
           V:::V              OO:::::::::OO   R::::::R     R:::::RE::::::::::::::::::::E
            VVV                 OOOOOOOOO     RRRRRRRR     RRRRRRREEEEEEEEEEEEEEEEEEEEEE

-Aro <3 */

var/UNATHI_EGG		= "Unathi"
var/TAJARAN_EGG 	= "Tajaran"
var/AKULA_EGG		= "Akula"
var/SKRELL_EGG		= "Skrell"
var/SERGAL_EGG		= "Sergal"
var/HUMAN_EGG		= "Human"
var/SLIME_EGG		= "Slime"
var/EGG_EGG			= "Egg"
var/XENOCHIMERA_EGG	= "Xenochimera"
var/XENOMORPH_EGG	= "Xenomorph"

//
// Overrides/additions to stock defines go here, as well as hooks. Sort them by
// the object they are overriding. So all /mob/living together, etc.
//
/datum/configuration
	var/items_survive_digestion = 1		//For configuring if the important_items survive digestion

//
// The datum type bolted onto normal preferences datums for storing Virgo stuff
//
/client
	var/datum/vore_preferences/prefs_vr

/hook/client_new/proc/add_prefs_vr(client/C)
	C.prefs_vr = new/datum/vore_preferences(C)
	if(C.prefs_vr)
		return 1

	return 0

/datum/vore_preferences
	//Actual preferences
	var/digestable = 1
	var/belly_prefs = ""
	var/vore_taste

	//Mechanically required
	var/slot
	var/client/client
	var/client_ckey

/datum/vore_preferences/New(client/C)
	if(istype(C))
		client = C
		client_ckey = C.ckey
		load_vore(C)

//
//	Check if an object is capable of eating things, based on vore_organs
//
/proc/is_vore_predator(var/mob/living/O)
	if(istype(O,/mob/living))
		if(O.vore_organs.len > 0)
			return 1

	return 0

//
//	Belly searching for simplifying other procs
//
/proc/check_belly(atom/movable/A)
	if(istype(A.loc,/mob/living))
		var/mob/living/M = A.loc
		for(var/I in M.vore_organs)
			var/datum/belly/B = M.vore_organs[I]
			if(A in B.internal_contents)
				return(B)

	return 0

//
// Save/Load Vore Preferences
//
/datum/vore_preferences/proc/load_vore()
	if(!client || !client_ckey)
		return 0 //No client, how can we save?

	slot = client.prefs.default_slot
	slot = sanitize_integer(slot, 1, client.prefs.max_save_slots, initial(client.prefs.default_slot))

	var/DBQuery/query = dbcon.NewQuery({"SELECT
		digestable,
		belly_prefs,
		vore_taste
		FROM [format_table_name("vore")]
		WHERE ckey='[client_ckey]' AND slot='[slot]'
	"})

	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during loading vore preferences. Error : \[[err]\]\n")
		message_admins("SQL ERROR during loading vore preferences. Error : \[[err]\]\n")
		return 0

	//general preferences
	while(query.NextRow())
		digestable = text2num(query.item[1])
		belly_prefs = query.item[2]
		vore_taste = query.item[3]

	digestable = sanitize_integer(digestable, 0, 1, initial(digestable))
	belly_prefs = sanitize_text(belly_prefs, initial(belly_prefs))
	vore_taste = sanitize_text(vore_taste, initial(vore_taste))

	return 1

/datum/vore_preferences/proc/save_vore()
	if(!slot)
		return 0

	var/DBQuery/firstquery = dbcon.NewQuery("SELECT slot FROM [format_table_name("vore")] WHERE ckey='[client_ckey]' ORDER BY slot")
	firstquery.Execute()
	while(firstquery.NextRow())
		if(text2num(firstquery.item[1]) == slot)
			var/DBQuery/query = dbcon.NewQuery({"UPDATE [format_table_name("vore")] SET
				digestable='[digestable]',
				belly_prefs='[sanitizeSQL(belly_prefs)]',
				vore_taste='[sanitizeSQL(vore_taste)]'
				WHERE ckey='[client_ckey]'
				AND slot='[slot]'
			"})
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during vore slot saving. Error : \[[err]\]\n")
				message_admins("SQL ERROR during vore slot saving. Error : \[[err]\]\n")
				return 0
			return 1

	var/DBQuery/query = dbcon.NewQuery({"
	INSERT INTO [format_table_name("vore")] (
		ckey,
		slot,

		digestable,
		belly_prefs,
		vore_taste
	) VALUES (
		'[client_ckey]',
		'[slot]',

		'[digestable]',
		'[sanitizeSQL(belly_prefs)]',
		'[sanitizeSQL(vore_taste)]'
	)"})
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR during vore slot saving. Error : \[[err]\]\n")
		message_admins("SQL ERROR during vore slot saving. Error : \[[err]\]\n")
		return
	return 1