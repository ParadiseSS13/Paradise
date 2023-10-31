/mob/living/carbon/human

	hud_possible = list(
		HEALTH_HUD, STATUS_HUD, SPECIALROLE_HUD, // from /mob/living
		ID_HUD, WANTED_HUD, IMPMINDSHIELD_HUD, IMPCHEM_HUD, IMPTRACK_HUD, GLAND_HUD,
		DIAG_STAT_HUD, DIAG_HUD // for IPCs
	)
	pressure_resistance = 25
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	//Marking colour and style
	var/list/m_colours = DEFAULT_MARKING_COLOURS //All colours set to #000000.
	var/list/m_styles = DEFAULT_MARKING_STYLES //All markings set to None.

	var/s_tone = 0	//Skin tone

	//Skin colour
	var/skin_colour = "#000000"

	var/lip_style = null	//no lipstick by default- arguably misleading, as it could be used for general makeup
	var/lip_color = "white"

	var/age = 30		//Player's age (pure fluff)
	/// Players' height (more fluff)
	var/height = "average height"
	/// Players physique (even MORE fluff)
	var/physique = "average"

	var/underwear = "Nude"	//Which underwear the player wants
	var/undershirt = "Nude"	//Which undershirt the player wants
	var/socks = "Nude" //Which socks the player wants
	var/backbag = 2		//Which backpack type the player has chosen. Nothing, Satchel or Backpack.

	//Equipment slots
	var/obj/item/clothing/under/w_uniform = null
	var/obj/item/clothing/shoes = null
	var/obj/item/belt = null
	var/obj/item/clothing/gloves = null
	var/obj/item/clothing/glasses = null
	var/obj/item/l_ear = null
	var/obj/item/r_ear = null
	var/obj/item/wear_id = null
	var/obj/item/wear_pda = null
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/obj/item/s_store = null

	var/icon/stand_icon = null

	var/voice = ""	//Instead of new say code calling GetVoice() over and over and over, we're just going to ask this variable, which gets updated in Life()

	var/datum/personal_crafting/handcrafting

	var/special_voice = "" // For changing our voice. Used by a symptom.

	var/hand_blood_color

	var/name_override //For temporary visible name changes

	var/datum/physiology/physiology

	var/xylophone = 0 //For the spoooooooky xylophone cooldown

	var/mob/remoteview_target = null
	var/meatleft = 3 //For chef item
	var/decaylevel = 0 // For rotting bodies
	var/max_blood = BLOOD_VOLUME_NORMAL // For stuff in the vessel
	var/bleed_rate = 0
	var/bleedsuppress = 0 //for stopping bloodloss

	var/check_mutations=0 // Check mutations on next life tick

	var/heartbeat = 0
	var/receiving_cpr = FALSE

	var/fire_dmi = 'icons/mob/OnFire.dmi'
	var/fire_sprite = "Standing"

	var/datum/body_accessory/body_accessory = null
	/// Name of tail image in species effects icon file.
	var/tail
	/// Same as tail but wing
	var/wing

	var/list/splinted_limbs = list() //limbs we know are splinted
	var/original_eye_color = "#000000"
