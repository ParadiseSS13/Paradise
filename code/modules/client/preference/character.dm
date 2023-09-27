// PSA To anyone who opens this:
// Good fucking luck. You will need this: https://www.youtube.com/watch?v=W9GaIbECisQ


/datum/character_save
	var/real_name							//our character's name
	var/be_random_name = FALSE				//whether we are a random name every round
	var/gender = MALE						//gender of character (well duh)
	var/age = 30							//age of character
	var/b_type = "A+"						//blood type (not-chooseable)
	var/underwear = "Nude"					//underwear type
	var/undershirt = "Nude"					//undershirt type
	var/socks = "Nude"						//socks type
	var/backbag = GBACKPACK					//backpack type
	var/ha_style = "None"					//Head accessory style
	var/hacc_colour = "#000000"				//Head accessory colour. If this line looks badly indented in vscode, its because of the shitty colour square
	var/list/m_styles = list(
		"head" = "None",
		"body" = "None",
		"tail" = "None",
		"wing" = "None"
		)			//Marking styles.
	var/list/m_colours = list(
		"head" = "#000000",
		"body" = "#000000",
		"tail" = "#000000"
		)		//Marking colours.
	var/h_style = "Bald"				//Hair type
	var/h_colour = "#000000"			//Hair color
	var/h_sec_colour = "#000000"		//Secondary hair color
	var/f_style = "Shaved"				//Facial hair type
	var/f_colour = "#000000"			//Facial hair color
	var/f_sec_colour = "#000000"		//Secondary facial hair color
	var/s_tone = 0						//Skin tone
	var/s_colour = "#000000"			//Skin color
	var/e_colour = "#000000"			//Eye color
	var/alt_head = "None"				//Alt head style.
	var/species = "Human"
	var/language = "None"				//Secondary language
	var/autohiss_mode = AUTOHISS_OFF	//Species autohiss level. OFF, BASIC, FULL.

	/// The body accessory name of the mob (e.g. wings, tail).
	var/body_accessory = null

	var/speciesprefs = 0 //I hate having to do this, I really do (Using this for oldvox code, making names universal I guess

	//Mob preview
	var/icon/preview_icon = null
	var/icon/preview_icon_front = null
	var/icon/preview_icon_side = null

	//Jobs, uses bitflags
	var/job_support_high = 0
	var/job_support_med = 0
	var/job_support_low = 0

	var/job_medsci_high = 0
	var/job_medsci_med = 0
	var/job_medsci_low = 0

	var/job_engsec_high = 0
	var/job_engsec_med = 0
	var/job_engsec_low = 0

	//Keeps track of preferrence for not getting any wanted jobs
	var/alternate_option = 2

	// maps each organ to either null(intact), "cyborg" or "amputated"
	// will probably not be able to do this for head and torso ;)
	var/list/organ_data = list()
	var/list/rlimb_data = list()

	var/list/player_alt_titles = new()		// the default name of a job like "Medical Doctor"
	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/disabilities = 0

	var/nanotrasen_relation = "Neutral"

	// OOC Metadata:
	var/metadata = ""

	//Gear stuff
	var/list/loadout_gear = list()

	/// Is this character from the DB?
	var/from_db = FALSE
	/// Is this character valid to be picked? This is necessary to avoid someone getting a bald human called "Character 30"
	var/valid_save = FALSE
	/// Character slot number, used for saves and stuff.
	var/slot_number = 0

	// Hair gradient
	var/h_grad_style = "None"
	var/h_grad_offset_x = 0
	var/h_grad_offset_y = 0
	var/h_grad_colour = "#000000"
	var/h_grad_alpha = 255
	/// Custom emote text ("name" = "emote text")
	var/list/custom_emotes = list()

// Fuckery to prevent null characters
/datum/character_save/New()
	real_name = random_name(gender, species)

/datum/character_save/proc/save(client/C)
	var/organlist
	var/rlimblist
	var/playertitlelist
	var/gearlist

	var/markingcolourslist = list2params(m_colours)
	var/markingstyleslist = list2params(m_styles)
	if(!isemptylist(organ_data))
		organlist = list2params(organ_data)
	if(!isemptylist(rlimb_data))
		rlimblist = list2params(rlimb_data)
	if(!isemptylist(player_alt_titles))
		playertitlelist = list2params(player_alt_titles)
	if(!isemptylist(loadout_gear))
		gearlist = json_encode(loadout_gear)

	var/datum/db_query/firstquery = SSdbcore.NewQuery("SELECT slot FROM characters WHERE ckey=:ckey ORDER BY slot", list(
		"ckey" = C.ckey
	))
	if(!firstquery.warn_execute())
		qdel(firstquery)
		return
	while(firstquery.NextRow())
		if(text2num(firstquery.item[1]) == slot_number) // Check if the character exists
			var/datum/db_query/query = SSdbcore.NewQuery({"UPDATE characters
				SET
					OOC_Notes=:metadata,
					real_name=:real_name,
					name_is_always_random=:be_random_name,
					gender=:gender,
					age=:age,
					species=:species,
					language=:language,
					hair_colour=:h_colour,
					secondary_hair_colour=:h_sec_colour,
					facial_hair_colour=:f_colour,
					secondary_facial_hair_colour=:f_sec_colour,
					skin_tone=:s_tone,
					skin_colour=:s_colour,
					marking_colours=:markingcolourslist,
					head_accessory_colour=:hacc_colour,
					hair_style_name=:h_style,
					facial_style_name=:f_style,
					marking_styles=:markingstyleslist,
					head_accessory_style_name=:ha_style,
					alt_head_name=:alt_head,
					eye_colour=:e_colour,
					underwear=:underwear,
					undershirt=:undershirt,
					backbag=:backbag,
					b_type=:b_type,
					alternate_option=:alternate_option,
					job_support_high=:job_support_high,
					job_support_med=:job_support_med,
					job_support_low=:job_support_low,
					job_medsci_high=:job_medsci_high,
					job_medsci_med=:job_medsci_med,
					job_medsci_low=:job_medsci_low,
					job_engsec_high=:job_engsec_high,
					job_engsec_med=:job_engsec_med,
					job_engsec_low=:job_engsec_low,
					flavor_text=:flavor_text,
					med_record=:med_record,
					sec_record=:sec_record,
					gen_record=:gen_record,
					player_alt_titles=:playertitlelist,
					disabilities=:disabilities,
					organ_data=:organlist,
					rlimb_data=:rlimblist,
					nanotrasen_relation=:nanotrasen_relation,
					speciesprefs=:speciesprefs,
					socks=:socks,
					body_accessory=:body_accessory,
					gear=:gearlist,
					autohiss=:autohiss_mode,
					hair_gradient=:h_grad_style,
					hair_gradient_offset=:h_grad_offset,
					hair_gradient_colour=:h_grad_colour,
					hair_gradient_alpha=:h_grad_alpha,
					custom_emotes=:custom_emotes,
					tts_seed=:tts_seed
					WHERE ckey=:ckey
					AND slot=:slot"}, list(
						// OH GOD SO MANY PARAMETERS
						"metadata" = metadata,
						"real_name" = real_name,
						"be_random_name" = be_random_name,
						"gender" = gender,
						"age" = age,
						"species" = species,
						"language" = language,
						"h_colour" = h_colour,
						"h_sec_colour" = h_sec_colour,
						"f_colour" = f_colour,
						"f_sec_colour" = f_sec_colour,
						"s_tone" = s_tone,
						"s_colour" = s_colour,
						"markingcolourslist" = markingcolourslist,
						"hacc_colour" = hacc_colour,
						"h_style" = h_style,
						"f_style" = f_style,
						"markingstyleslist" = markingstyleslist,
						"ha_style" = ha_style,
						"alt_head" = (alt_head ? alt_head : ""), // This it intentional. It wont work without it!
						"e_colour" = e_colour,
						"underwear" = underwear,
						"undershirt" = undershirt,
						"backbag" = backbag,
						"b_type" = b_type,
						"alternate_option" = alternate_option,
						"job_support_high" = job_support_high,
						"job_support_med" = job_support_med,
						"job_support_low" = job_support_low,
						"job_medsci_high" = job_medsci_high,
						"job_medsci_med" = job_medsci_med,
						"job_medsci_low" = job_medsci_low,
						"job_engsec_high" = job_engsec_high,
						"job_engsec_med" = job_engsec_med,
						"job_engsec_low" = job_engsec_low,
						"flavor_text" = flavor_text,
						"med_record" = med_record,
						"sec_record" = sec_record,
						"gen_record" = gen_record,
						"playertitlelist" = (playertitlelist ? playertitlelist : ""), // This it intentnional. It wont work without it!
						"disabilities" = disabilities,
						"organlist" = (organlist ? organlist : ""),
						"rlimblist" = (rlimblist ? rlimblist : ""),
						"nanotrasen_relation" = nanotrasen_relation,
						"speciesprefs" = speciesprefs,
						"socks" = socks,
						"body_accessory" = (body_accessory ? body_accessory : ""),
						"gearlist" = (gearlist ? gearlist : ""),
						"autohiss_mode" = autohiss_mode,
						"h_grad_style" = h_grad_style,
						"h_grad_offset" = "[h_grad_offset_x],[h_grad_offset_y]",
						"h_grad_colour" = h_grad_colour,
						"h_grad_alpha" = h_grad_alpha,
						"custom_emotes" = json_encode(custom_emotes),
						"tts_seed" = tts_seed,
						"ckey" = C.ckey,
						"slot" = slot_number
					))

			if(!query.warn_execute())
				qdel(firstquery)
				qdel(query)
				return
			qdel(firstquery)
			qdel(query)
			return 1

	qdel(firstquery)

	var/datum/db_query/query = SSdbcore.NewQuery({"
		INSERT INTO characters (ckey, slot, OOC_Notes, real_name, name_is_always_random, gender,
			age, species, language,
			hair_colour, secondary_hair_colour,
			facial_hair_colour, secondary_facial_hair_colour,
			skin_tone, skin_colour,
			marking_colours,
			head_accessory_colour,
			hair_style_name,
			facial_style_name,
			marking_styles,
			head_accessory_style_name,
			alt_head_name,
			eye_colour,
			underwear, undershirt,
			backbag, b_type, alternate_option,
			job_support_high, job_support_med, job_support_low,
			job_medsci_high, job_medsci_med, job_medsci_low,
			job_engsec_high, job_engsec_med, job_engsec_low,
			flavor_text,
			med_record,
			sec_record,
			gen_record,
			player_alt_titles,
			disabilities, organ_data, rlimb_data, nanotrasen_relation, speciesprefs,
			socks, body_accessory, gear, autohiss,
			hair_gradient, hair_gradient_offset, hair_gradient_colour, hair_gradient_alpha, custom_emotes, tts_seed)
		VALUES
			(:ckey, :slot, :metadata, :name, :be_random_name, :gender,
			:age, :species, :language,
			:h_colour, :h_sec_colour,
			:f_colour, :f_sec_colour,
			:s_tone, :s_colour,
			:markingcolourslist,
			:hacc_colour,
			:h_style,
			:f_style,
			:markingstyleslist,
			:ha_style,
			:alt_head,
			:e_colour,
			:underwear, :undershirt,
			:backbag, :b_type, :alternate_option,
			:job_support_high, :job_support_med, :job_support_low,
			:job_medsci_high, :job_medsci_med, :job_medsci_low,
			:job_engsec_high, :job_engsec_med, :job_engsec_low,
			:flavor_text,
			:med_record,
			:sec_record,
			:gen_record,
			:playertitlelist,
			:disabilities, :organlist, :rlimblist, :nanotrasen_relation, :speciesprefs,
			:socks, :body_accessory, :gearlist, :autohiss_mode,
			:h_grad_style, :h_grad_offset, :h_grad_colour, :h_grad_alpha, :custom_emotes, :tts_seed)
	"}, list(
		// This has too many params for anyone to look at this without going insae
		"ckey" = C.ckey,
		"slot" = slot_number,
		"metadata" = metadata,
		"name" = real_name,
		"be_random_name" = be_random_name,
		"gender" = gender,
		"age" = age,
		"species" = species,
		"language" = language,
		"h_colour" = h_colour,
		"h_sec_colour" = h_sec_colour,
		"f_colour" = f_colour,
		"f_sec_colour" = f_sec_colour,
		"s_tone" = s_tone,
		"s_colour" = s_colour,
		"markingcolourslist" = markingcolourslist,
		"hacc_colour" = hacc_colour,
		"h_style" = h_style,
		"f_style" = f_style,
		"markingstyleslist" = markingstyleslist,
		"ha_style" = ha_style,
		"alt_head" = (alt_head ? alt_head : "None"), // bane of my fucking life
		"e_colour" = e_colour,
		"underwear" = underwear,
		"undershirt" = undershirt,
		"backbag" = backbag,
		"b_type" = b_type,
		"alternate_option" = alternate_option,
		"job_support_high" = job_support_high,
		"job_support_med" = job_support_med,
		"job_support_low" = job_support_low,
		"job_medsci_high" = job_medsci_high,
		"job_medsci_med" = job_medsci_med,
		"job_medsci_low" = job_medsci_low,
		"job_engsec_high" = job_engsec_high,
		"job_engsec_med" = job_engsec_med,
		"job_engsec_low" = job_engsec_low,
		"flavor_text" = flavor_text,
		"med_record" = med_record,
		"sec_record" = sec_record,
		"gen_record" = gen_record,
		"playertitlelist" = (playertitlelist ? playertitlelist : ""), // This it intentional. It wont work without it!
		"disabilities" = disabilities,
		"organlist" = (organlist ? organlist : ""),
		"rlimblist" = (rlimblist ? rlimblist : ""),
		"nanotrasen_relation" = nanotrasen_relation,
		"speciesprefs" = speciesprefs,
		"socks" = socks,
		"body_accessory" = (body_accessory ? body_accessory : ""),
		"gearlist" = (gearlist ? gearlist : ""),
		"autohiss_mode" = autohiss_mode,
		"h_grad_style" = h_grad_style,
		"h_grad_offset" = "[h_grad_offset_x],[h_grad_offset_y]",
		"h_grad_colour" = h_grad_colour,
		"h_grad_alpha" = h_grad_alpha,
		"custom_emotes" = json_encode(custom_emotes),
		"tts_seed" = tts_seed
	))

	if(!query.warn_execute())
		qdel(query)
		return

	qdel(query)
	from_db = TRUE
	return 1


/datum/character_save/proc/load(datum/db_query/query)
	//Character
	metadata = query.item[1]
	real_name = query.item[2]
	be_random_name = text2num(query.item[3])
	gender = query.item[4]
	age = text2num(query.item[5])
	species = query.item[6]
	language = query.item[7]

	h_colour = query.item[8]
	h_sec_colour = query.item[9]
	f_colour = query.item[10]
	f_sec_colour = query.item[11]
	s_tone = text2num(query.item[12])
	s_colour = query.item[13]
	m_colours = params2list(query.item[14])
	hacc_colour = query.item[15]
	h_style = query.item[16]
	f_style = query.item[17]
	m_styles = params2list(query.item[18])
	ha_style = query.item[19]
	alt_head = query.item[20]
	e_colour = query.item[21]
	underwear = query.item[22]
	undershirt = query.item[23]
	backbag = query.item[24]
	b_type = query.item[25]


	//Jobs
	alternate_option = text2num(query.item[26])
	job_support_high = text2num(query.item[27])
	job_support_med = text2num(query.item[28])
	job_support_low = text2num(query.item[29])
	job_medsci_high = text2num(query.item[30])
	job_medsci_med = text2num(query.item[31])
	job_medsci_low = text2num(query.item[32])
	job_engsec_high = text2num(query.item[33])
	job_engsec_med = text2num(query.item[34])
	job_engsec_low = text2num(query.item[35])

	//Miscellaneous
	flavor_text = query.item[36]
	med_record = query.item[37]
	sec_record = query.item[38]
	gen_record = query.item[39]
	// Apparently, the preceding vars weren't always encoded properly...
	if(findtext(flavor_text, "<")) // ... so let's clumsily check for tags!
		flavor_text = html_encode(flavor_text)
	if(findtext(med_record, "<"))
		med_record = html_encode(med_record)
	if(findtext(sec_record, "<"))
		sec_record = html_encode(sec_record)
	if(findtext(gen_record, "<"))
		gen_record = html_encode(gen_record)
	disabilities = text2num(query.item[40])
	player_alt_titles = params2list(query.item[41])
	organ_data = params2list(query.item[42])
	rlimb_data = params2list(query.item[43])
	nanotrasen_relation = query.item[44]
	speciesprefs = text2num(query.item[45])

	//socks
	socks = query.item[46]
	body_accessory = query.item[47]
	loadout_gear = query.item[48]
	autohiss_mode = text2num(query.item[49])
	// Index [50] is the slot
	h_grad_style = query.item[51]
	h_grad_offset_x = query.item[52] // parsed down below
	h_grad_colour = query.item[53]
	h_grad_alpha = query.item[54]
	var/custom_emotes_tmp = query.item[55]
	tts_seed = query.item[56]

	//Sanitize
	var/datum/species/SP = GLOB.all_species[species]
	if(!SP)
		stack_trace("Couldn't find a species matching [species], character name is [real_name].")

	metadata = sanitize_text(metadata, initial(metadata))
	real_name = reject_bad_name(real_name, TRUE)

	if(isnull(species) || isnull(SP))
		SP = GLOB.all_species["Human"]
		species = "Human"
		stack_trace("Character doesn't have a species, character name is [real_name]. Defaulting to human.")

	if(isnull(language))
		language = "None"

	if(isnull(nanotrasen_relation))
		nanotrasen_relation = initial(nanotrasen_relation)

	if(isnull(speciesprefs))
		speciesprefs = initial(speciesprefs)

	if(!real_name)
		real_name = random_name(gender, species)

	be_random_name	= sanitize_integer(be_random_name, 0, 1, initial(be_random_name))
	gender			= sanitize_gender(gender, FALSE, !SP.has_gender)
	age				= sanitize_integer(age, SP.min_age, SP.max_age, initial(age))
	h_colour		= sanitize_hexcolor(h_colour)
	h_sec_colour	= sanitize_hexcolor(h_sec_colour)
	f_colour		= sanitize_hexcolor(f_colour)
	f_sec_colour	= sanitize_hexcolor(f_sec_colour)
	s_tone			= sanitize_integer(s_tone, -185, 34, initial(s_tone))
	s_colour		= sanitize_hexcolor(s_colour)

	for(var/marking_location in m_colours)
		m_colours[marking_location] = sanitize_hexcolor(m_colours[marking_location], DEFAULT_MARKING_COLOURS[marking_location])

	hacc_colour		= sanitize_hexcolor(hacc_colour)
	h_style			= sanitize_inlist(h_style, GLOB.hair_styles_public_list, initial(h_style))
	f_style			= sanitize_inlist(f_style, GLOB.facial_hair_styles_list, initial(f_style))

	for(var/marking_location in m_styles)
		m_styles[marking_location] = sanitize_inlist(m_styles[marking_location], GLOB.marking_styles_list, DEFAULT_MARKING_STYLES[marking_location])

	ha_style		= sanitize_inlist(ha_style, GLOB.head_accessory_styles_list, initial(ha_style))
	alt_head		= sanitize_inlist(alt_head, GLOB.alt_heads_list, initial(alt_head))
	e_colour		= sanitize_hexcolor(e_colour)
	underwear		= sanitize_text(underwear, initial(underwear))
	undershirt		= sanitize_text(undershirt, initial(undershirt))
	backbag			= sanitize_text(backbag, initial(backbag))
	b_type			= sanitize_text(b_type, initial(b_type))
	autohiss_mode	= sanitize_integer(autohiss_mode, 0, 2, initial(autohiss_mode))

	alternate_option = sanitize_integer(alternate_option, 0, 2, initial(alternate_option))
	job_support_high = sanitize_integer(job_support_high, 0, 65535, initial(job_support_high))
	job_support_med = sanitize_integer(job_support_med, 0, 65535, initial(job_support_med))
	job_support_low = sanitize_integer(job_support_low, 0, 65535, initial(job_support_low))
	job_medsci_high = sanitize_integer(job_medsci_high, 0, 65535, initial(job_medsci_high))
	job_medsci_med = sanitize_integer(job_medsci_med, 0, 65535, initial(job_medsci_med))
	job_medsci_low = sanitize_integer(job_medsci_low, 0, 65535, initial(job_medsci_low))
	job_engsec_high = sanitize_integer(job_engsec_high, 0, 65535, initial(job_engsec_high))
	job_engsec_med = sanitize_integer(job_engsec_med, 0, 65535, initial(job_engsec_med))
	job_engsec_low = sanitize_integer(job_engsec_low, 0, 65535, initial(job_engsec_low))
	disabilities = sanitize_integer(disabilities, 0, 65535, initial(disabilities))

	socks			= sanitize_text(socks, initial(socks))
	body_accessory	= sanitize_text(body_accessory, initial(body_accessory))
	h_grad_style = sanitize_text(length(h_grad_style) ? h_grad_style : null, "None")
	var/list/expl = splittext(h_grad_offset_x, ",")
	if(length(expl) == 2)
		h_grad_offset_x = text2num(expl[1]) || 0
		h_grad_offset_y = text2num(expl[2]) || 0
	h_grad_colour = sanitize_hexcolor(h_grad_colour)
	h_grad_alpha = sanitize_integer(h_grad_alpha, 0, 255, initial(h_grad_alpha))
	loadout_gear = sanitize_json(loadout_gear)
	custom_emotes_tmp = sanitize_json(custom_emotes_tmp)
	custom_emotes = init_custom_emotes(custom_emotes_tmp)

	if(!player_alt_titles)
		player_alt_titles = new()
	if(!organ_data)
		src.organ_data = list()
	if(!rlimb_data)
		src.rlimb_data = list()
	if(!loadout_gear)
		loadout_gear = list()

	// Check if the current body accessory exists
	if(!GLOB.body_accessory_by_name[body_accessory])
		body_accessory = null

	from_db = TRUE
	valid_save = TRUE

	return TRUE

/datum/character_save/proc/randomise(gender_override)
	b_type = pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")
	var/datum/species/S = GLOB.all_species[species]
	if(!istype(S)) //The species was invalid. Set the species to the default, fetch the datum for that species and generate a random character.
		species = initial(species)
		S = GLOB.all_species[species]
	var/datum/robolimb/robohead

	if(S.bodyflags & ALL_RPARTS)
		var/head_model = "[!rlimb_data["head"] ? "Morpheus Cyberkinetics" : rlimb_data["head"]]"
		robohead = GLOB.all_robolimbs[head_model]
	if(gender_override)
		gender = gender_override
	else
		gender = pick(MALE, FEMALE)
	underwear = random_underwear(gender, species)
	undershirt = random_undershirt(gender, species)
	socks = random_socks(gender, species)
	if(length(GLOB.body_accessory_by_species[species]))
		body_accessory = random_body_accessory(species, S.optional_body_accessory)
	if(S.bodyflags & (HAS_SKIN_TONE|HAS_ICON_SKIN_TONE))
		s_tone = random_skin_tone(species)
	h_style = random_hair_style(gender, species, robohead)
	f_style = random_facial_hair_style(gender, species, robohead)
	if(!(S.bodyflags & BALD))
		randomize_hair_color("hair")
	if(!(S.bodyflags & SHAVED))
		randomize_hair_color("facial")
	if(S.bodyflags & HAS_HEAD_ACCESSORY)
		ha_style = random_head_accessory(species)
		hacc_colour = randomize_skin_color(1)
	if(S.bodyflags & HAS_HEAD_MARKINGS)
		m_styles["head"] = random_marking_style("head", species, robohead, null, alt_head)
		m_colours["head"] = randomize_skin_color(1)
	if(S.bodyflags & HAS_BODY_MARKINGS)
		m_styles["body"] = random_marking_style("body", species)
		m_colours["body"] = randomize_skin_color(1)
	if(S.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
		m_styles["tail"] = random_marking_style("tail", species, null, body_accessory)
		m_colours["tail"] = randomize_skin_color(1)
	if(!(S.bodyflags & ALL_RPARTS))
		randomize_eyes_color()
	if(S.bodyflags & HAS_SKIN_COLOR)
		randomize_skin_color()
	backbag = 2
	age = rand(S.min_age, S.max_age)


/datum/character_save/proc/randomize_hair_color(target = "hair")
	if(prob (75) && target == "facial") // Chance to inherit hair color
		f_colour = h_colour
		return

	var/red
	var/green
	var/blue

	var/col = pick ("blonde", "black", "chestnut", "copper", "brown", "wheat", "old", "punk")
	switch(col)
		if("blonde")
			red = 255
			green = 255
			blue = 0
		if("black")
			red = 0
			green = 0
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 51
		if("copper")
			red = 255
			green = 153
			blue = 0
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("wheat")
			red = 255
			green = 255
			blue = 153
		if("old")
			red = rand (100, 255)
			green = red
			blue = red
		if("punk")
			red = rand (0, 255)
			green = rand (0, 255)
			blue = rand (0, 255)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	switch(target)
		if("hair")
			h_colour = rgb(red, green, blue)
		if("facial")
			f_colour = rgb(red, green, blue)

/datum/character_save/proc/randomize_eyes_color()
	var/red
	var/green
	var/blue

	var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
	switch(col)
		if("black")
			red = 0
			green = 0
			blue = 0
		if("grey")
			red = rand (100, 200)
			green = red
			blue = red
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 0
		if("blue")
			red = 51
			green = 102
			blue = 204
		if("lightblue")
			red = 102
			green = 204
			blue = 255
		if("green")
			red = 0
			green = 102
			blue = 0
		if("albino")
			red = rand (200, 255)
			green = rand (0, 150)
			blue = rand (0, 150)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	e_colour = rgb(red, green, blue)

/datum/character_save/proc/randomize_skin_color(pass_on)
	var/red
	var/green
	var/blue

	var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
	switch(col)
		if("black")
			red = 0
			green = 0
			blue = 0
		if("grey")
			red = rand (100, 200)
			green = red
			blue = red
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 0
		if("blue")
			red = 51
			green = 102
			blue = 204
		if("lightblue")
			red = 102
			green = 204
			blue = 255
		if("green")
			red = 0
			green = 102
			blue = 0
		if("albino")
			red = rand (200, 255)
			green = rand (0, 150)
			blue = rand (0, 150)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	if(pass_on)
		return rgb(red, green, blue)
	else
		s_colour = rgb(red, green, blue)

/datum/character_save/proc/blend_backpack(icon/clothes_s, backbag, satchel, backpack="backpack")
	switch(backbag)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', backpack), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', satchel), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
	return clothes_s

#define ICON_SHIFT_XY(I, X, Y)\
	if(X)\
		I.Shift(EAST, X);\
	if(Y)\
		I.Shift(NORTH, Y);\

/datum/character_save/proc/update_preview_icon(for_observer=0)		//seriously. This is horrendous.
	qdel(preview_icon_front)
	qdel(preview_icon_side)
	qdel(preview_icon)

	var/g = "m"
	if(gender == FEMALE)	g = "f"

	var/icon/icobase
	var/datum/species/current_species = GLOB.all_species[species]

	//Icon-based species colour.
	var/coloured_tail
	if(current_species)
		if(current_species.bodyflags & HAS_ICON_SKIN_TONE) //Handling species-specific icon-based skin tones by flagged race.
			var/mob/living/carbon/human/H = new
			H.dna.species = current_species
			H.s_tone = s_tone
			H.dna.species.updatespeciescolor(H, 0) //The mob's species wasn't set, so it's almost certainly different than the character's species at the moment. Thus, we need to be owner-insensitive.
			var/obj/item/organ/external/chest/C = H.get_organ("chest")
			icobase = C.icobase ? C.icobase : C.dna.species.icobase
			if(H.dna.species.bodyflags & HAS_TAIL)
				coloured_tail = H.tail ? H.tail : H.dna.species.tail

			qdel(H)
		else
			icobase = current_species.icobase
	else
		icobase = 'icons/mob/human_races/r_human.dmi'

	preview_icon = new /icon(icobase, "torso_[g]")
	preview_icon.Blend(new /icon(icobase, "groin_[g]"), ICON_OVERLAY)
	var/head = "head"
	if(alt_head && current_species.bodyflags & HAS_ALT_HEADS)
		var/datum/sprite_accessory/alt_heads/H = GLOB.alt_heads_list[alt_head]
		if(H.icon_state)
			head = H.icon_state
	preview_icon.Blend(new /icon(icobase, "[head]_[g]"), ICON_OVERLAY)

	for(var/name in list("chest", "groin", "head", "r_arm", "r_hand", "r_leg", "r_foot", "l_leg", "l_foot", "l_arm", "l_hand"))
		if(organ_data[name] == "amputated") continue
		if(organ_data[name] == "cyborg")
			var/datum/robolimb/R
			if(rlimb_data[name]) R = GLOB.all_robolimbs[rlimb_data[name]]
			if(!R) R = GLOB.basic_robolimb
			if(name == "chest")
				name = "torso"
			preview_icon.Blend(icon(R.icon, "[name]"), ICON_OVERLAY) // This doesn't check gendered_icon. Not an issue while only limbs can be robotic.
			continue
		preview_icon.Blend(new /icon(icobase, "[name]"), ICON_OVERLAY)

	// Skin color
	if(current_species && (current_species.bodyflags & HAS_SKIN_COLOR))
		preview_icon.Blend(s_colour, ICON_ADD)

	// Skin tone
	if(current_species && (current_species.bodyflags & HAS_SKIN_TONE))
		if(s_tone >= 0)
			preview_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
		else
			preview_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)

	// Body accessory
	if(current_species && (current_species.bodyflags & HAS_BODY_ACCESSORY))
		var/icon
		var/icon_state
		var/offset_x = 0
		var/offset_y = 0
		var/blend_mode = ICON_ADD
		var/icon/underlay = null

		if(body_accessory)
			var/datum/body_accessory/BA = GLOB.body_accessory_by_name[body_accessory]
			if(BA)
				icon = BA.icon
				icon_state = BA.icon_state
				blend_mode = BA.blend_mode || blend_mode
				offset_x = BA.pixel_x_offset
				offset_y = BA.pixel_y_offset
				// If the body accessory has an underlay, account for it.
				if(BA.has_behind)
					underlay = new(icon, "[icon_state]_BEHIND")
		else if(current_species.bodyflags & HAS_TAIL)
			icon = "icons/effects/species.dmi"
			if(coloured_tail)
				icon_state = "[coloured_tail]_s"
			else
				icon_state = "[current_species.tail]_s"

		if(icon)
			var/icon/temp = new(icon, icon_state)
			if(current_species.bodyflags & HAS_SKIN_COLOR)
				temp.Blend(s_colour, blend_mode)
			if(current_species.bodyflags & HAS_TAIL_MARKINGS)
				var/tail_marking = m_styles["tail"]
				var/datum/sprite_accessory/body_markings/BM = GLOB.marking_styles_list[tail_marking]
				if(BM)
					var/icon/t_marking_s = new(BM.icon, "[BM.icon_state]_s")
					t_marking_s.Blend(m_colours["tail"], ICON_ADD)
					temp.Blend(t_marking_s, ICON_OVERLAY)

			// Body accessory has an underlay, add it too.
			if(underlay)
				ICON_SHIFT_XY(underlay, offset_x, offset_y)
				preview_icon.Blend(underlay, ICON_UNDERLAY)

			ICON_SHIFT_XY(temp, offset_x, offset_y)
			preview_icon.Blend(temp, ICON_OVERLAY)

	//Markings
	if(current_species && ((current_species.bodyflags & HAS_HEAD_MARKINGS) || (current_species.bodyflags & HAS_BODY_MARKINGS)))
		if(current_species.bodyflags & HAS_BODY_MARKINGS) //Body markings.
			var/body_marking = m_styles["body"]
			var/datum/sprite_accessory/body_marking_style = GLOB.marking_styles_list[body_marking]
			if(body_marking_style && body_marking_style.species_allowed)
				var/icon/b_marking_s = new/icon("icon" = body_marking_style.icon, "icon_state" = "[body_marking_style.icon_state]_s")
				b_marking_s.Blend(m_colours["body"], ICON_ADD)
				preview_icon.Blend(b_marking_s, ICON_OVERLAY)
		if(current_species.bodyflags & HAS_HEAD_MARKINGS) //Head markings.
			var/head_marking = m_styles["head"]
			var/datum/sprite_accessory/head_marking_style = GLOB.marking_styles_list[head_marking]
			if(head_marking_style && head_marking_style.species_allowed)
				var/icon/h_marking_s = new/icon("icon" = head_marking_style.icon, "icon_state" = "[head_marking_style.icon_state]_s")
				h_marking_s.Blend(m_colours["head"], ICON_ADD)
				preview_icon.Blend(h_marking_s, ICON_OVERLAY)

	var/icon/hands_icon = icon(preview_icon)
	hands_icon.Blend(icon('icons/mob/clothing/masking_helpers.dmi', "l_hand_mask"), ICON_MULTIPLY)

	var/icon/face_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "bald_s")
	if(!(current_species.bodyflags & NO_EYES))
		var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = current_species ? current_species.eyes : "eyes_s")
		eyes_s.Blend(e_colour, ICON_ADD)
		face_s.Blend(eyes_s, ICON_OVERLAY)


	var/datum/sprite_accessory/hair_style = GLOB.hair_styles_full_list[h_style]
	if(hair_style)
		var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
		if(current_species.name == "Slime People") // whee I am part of the problem
			hair_s.Blend("[s_colour]A0", ICON_ADD)
		else if(hair_style.do_colouration)
			hair_s.Blend(h_colour, ICON_ADD)

		var/datum/sprite_accessory/hair_gradient/gradient = GLOB.hair_gradients_list[h_grad_style]
		if(gradient)
			var/icon/grad_s = new/icon("icon" = gradient.icon, "icon_state" = gradient.icon_state)
			if(h_grad_offset_x)
				grad_s.Shift(EAST, h_grad_offset_x)
			if(h_grad_offset_y)
				grad_s.Shift(NORTH, h_grad_offset_y)
			grad_s.Blend(hair_s, ICON_ADD)
			grad_s.MapColors(COLOR_BLACK, COLOR_BLACK, COLOR_BLACK, h_grad_colour)
			grad_s.ChangeOpacity(h_grad_alpha / 255)
			hair_s.Blend(grad_s, ICON_OVERLAY)

		if(hair_style.secondary_theme)
			var/icon/hair_secondary_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_[hair_style.secondary_theme]_s")
			if(!hair_style.no_sec_colour && hair_style.do_colouration )
				hair_secondary_s.Blend(h_sec_colour, ICON_ADD)
			hair_s.Blend(hair_secondary_s, ICON_OVERLAY)

		face_s.Blend(hair_s, ICON_OVERLAY)

	//Head Accessory
	if(current_species && (current_species.bodyflags & HAS_HEAD_ACCESSORY))
		var/datum/sprite_accessory/head_accessory_style = GLOB.head_accessory_styles_list[ha_style]
		if(head_accessory_style && head_accessory_style.species_allowed)
			var/icon/head_accessory_s = new/icon("icon" = head_accessory_style.icon, "icon_state" = "[head_accessory_style.icon_state]_s")
			head_accessory_s.Blend(hacc_colour, ICON_ADD)
			face_s.Blend(head_accessory_s, ICON_OVERLAY)

	var/datum/sprite_accessory/facial_hair_style = GLOB.facial_hair_styles_list[f_style]
	if(facial_hair_style && facial_hair_style.species_allowed)
		var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
		if(current_species.name == "Slime People") // whee I am part of the problem
			facial_s.Blend("[s_colour]A0", ICON_ADD)
		else if(facial_hair_style.do_colouration)
			facial_s.Blend(f_colour, ICON_ADD)

		if(facial_hair_style.secondary_theme)
			var/icon/facial_secondary_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_[facial_hair_style.secondary_theme]_s")
			if(!facial_hair_style.no_sec_colour && facial_hair_style.do_colouration)
				facial_secondary_s.Blend(f_sec_colour, ICON_ADD)
			facial_s.Blend(facial_secondary_s, ICON_OVERLAY)

		face_s.Blend(facial_s, ICON_OVERLAY)

	var/icon/underwear_s = null
	if(underwear && (current_species.clothing_flags & HAS_UNDERWEAR))
		var/datum/sprite_accessory/underwear/U = GLOB.underwear_list[underwear]
		if(U)
			var/u_icon = U.sprite_sheets && (current_species.sprite_sheet_name in U.sprite_sheets) ? U.sprite_sheets[current_species.sprite_sheet_name] : U.icon //Species-fit the undergarment.
			underwear_s = new/icon(u_icon, "uw_[U.icon_state]_s", ICON_OVERLAY)

	var/icon/undershirt_s = null
	if(undershirt && (current_species.clothing_flags & HAS_UNDERSHIRT))
		var/datum/sprite_accessory/undershirt/U2 = GLOB.undershirt_list[undershirt]
		if(U2)
			var/u2_icon = U2.sprite_sheets && (current_species.sprite_sheet_name in U2.sprite_sheets) ? U2.sprite_sheets[current_species.sprite_sheet_name] : U2.icon
			undershirt_s = new/icon(u2_icon, "us_[U2.icon_state]_s", ICON_OVERLAY)

	var/icon/socks_s = null
	if(socks && (current_species.clothing_flags & HAS_SOCKS))
		var/datum/sprite_accessory/socks/U3 = GLOB.socks_list[socks]
		if(U3)
			var/u3_icon = U3.sprite_sheets && (current_species.sprite_sheet_name in U3.sprite_sheets) ? U3.sprite_sheets[current_species.sprite_sheet_name] : U3.icon
			socks_s = new/icon(u3_icon, "sk_[U3.icon_state]_s", ICON_OVERLAY)

	var/icon/clothes_s = null
	var/has_gloves = FALSE

	if(job_support_low & JOB_ASSISTANT) //This gives the preview icon clothes depending on which job(if any) is set to 'high'
		clothes_s = new /icon('icons/mob/clothing/under/color.dmi', "grey_s")
		clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
		if(backbag == 2)
			clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
		else if(backbag == 3 || backbag == 4)
			clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)

	else if(job_support_high)//I hate how this looks, but there's no reason to go through this switch if it's empty
		switch(job_support_high)
			if(JOB_HOP)
				clothes_s = new /icon('icons/mob/clothing/under/civilian.dmi', "hop_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "ianshirt"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_BARTENDER)
				clothes_s = new /icon('icons/mob/clothing/under/civilian.dmi', "ba_suit_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "tophat"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_BOTANIST)
				clothes_s = new /icon('icons/mob/clothing/under/civilian.dmi', "hydroponics_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "ggloves"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "apron"), ICON_OVERLAY)
				has_gloves = TRUE
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "nymph"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-hyd"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_CHEF)
				clothes_s = new /icon('icons/mob/clothing/under/civilian.dmi', "chef_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "chef"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "apronchef"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_JANITOR)
				clothes_s = new /icon('icons/mob/clothing/under/civilian.dmi', "janitor_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "bio_janitor"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_LIBRARIAN)
				clothes_s = new /icon('icons/mob/clothing/under/civilian.dmi', "red_suit_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "hairflower"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_QUARTERMASTER)
				clothes_s = new /icon('icons/mob/clothing/under/cargo.dmi', "qm_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_OVERLAY)
				has_gloves = TRUE
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "poncho"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_CARGOTECH)
				clothes_s = new /icon('icons/mob/clothing/under/cargo.dmi', "cargo_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_OVERLAY)
				has_gloves = TRUE
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "flat_cap"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_MINER)
				clothes_s = new /icon('icons/mob/clothing/under/cargo.dmi', "explorer_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "explorer"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_OVERLAY)
				has_gloves = TRUE
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "bearpelt"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "explorerpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-explorer"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_LAWYER)
				clothes_s = new /icon('icons/mob/clothing/under/civilian.dmi', "internalaffairs_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/inhands/items_righthand.dmi', "briefcase"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "suitjacket_blue"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_CHAPLAIN)
				clothes_s = new /icon('icons/mob/clothing/under/civilian.dmi', "chapblack_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "imperium_monk"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_CLOWN)
				clothes_s = new /icon('icons/mob/clothing/under/civilian.dmi', "clown_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "clown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/mask.dmi', "clown"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "clownpack"), ICON_OVERLAY)
			if(JOB_MIME)
				clothes_s = new /icon('icons/mob/clothing/under/civilian.dmi', "mime_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "lgloves"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/mask.dmi', "mime"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "beret"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "suspenders"), ICON_OVERLAY)
				has_gloves = TRUE
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_EXPLORER)
				clothes_s = new /icon('icons/mob/clothing/under/color.dmi', "orange_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "workboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_OVERLAY)
				has_gloves = TRUE
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
	else if(job_medsci_high)
		switch(job_medsci_high)
			if(JOB_RD)
				clothes_s = new /icon('icons/mob/clothing/under/rnd.dmi', "director_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_open"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "petehat"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-tox"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_SCIENTIST)
				clothes_s = new /icon('icons/mob/clothing/under/rnd.dmi', "science_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_tox_open"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "metroid"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-tox"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_CHEMIST)
				clothes_s = new /icon('icons/mob/clothing/under/medical.dmi', "chemistry_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labgreen"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_chem_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-chem"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_CMO)
				clothes_s = new /icon('icons/mob/clothing/under/medical.dmi', "cmo_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "bio_cmo"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_cmo_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "medicalpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-med"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_DOCTOR)
				clothes_s = new /icon('icons/mob/clothing/under/medical.dmi', "medical_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "surgeon"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "medicalpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-med"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_CORONER)
				clothes_s = new /icon('icons/mob/clothing/under/medical.dmi', "medical_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "mortician"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "medicalpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-med"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_GENETICIST)
				clothes_s = new /icon('icons/mob/clothing/under/rnd.dmi', "genetics_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "monkeysuit"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_gen_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-gen"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_VIROLOGIST)
				clothes_s = new /icon('icons/mob/clothing/under/medical.dmi', "virology_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/mask.dmi', "sterile"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_vir_open"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "plaguedoctor"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "medicalpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-vir"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_PSYCHIATRIST)
				clothes_s = new /icon('icons/mob/clothing/under/medical.dmi', "psych_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "laceups"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_PARAMEDIC)
				clothes_s = new /icon('icons/mob/clothing/under/medical.dmi', "paramedic_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/mask.dmi', "cigoff"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "bluesoft"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "medicalpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-med"), ICON_OVERLAY)
			if(JOB_ROBOTICIST)
				clothes_s = new /icon('icons/mob/clothing/under/rnd.dmi', "robotics_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_open"), ICON_OVERLAY)
				has_gloves = TRUE
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/inhands/items_righthand.dmi', "toolbox_blue"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)

	else if(job_engsec_high)
		switch(job_engsec_high)
			if(JOB_CAPTAIN)
				clothes_s = new /icon('icons/mob/clothing/under/captain.dmi', "captain_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "centcomcaptain"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "captain"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-cap"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_HOS)
				clothes_s = new /icon('icons/mob/clothing/under/security.dmi', "hos_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_OVERLAY)
				has_gloves = TRUE
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "beret_hos"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "securitypack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-sec"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_WARDEN)
				clothes_s = new /icon('icons/mob/clothing/under/security.dmi', "warden_s")
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "slippers_worn"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_OVERLAY)
				has_gloves = TRUE
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "securitypack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-sec"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_DETECTIVE)
				clothes_s = new /icon('icons/mob/clothing/under/security.dmi', "detective_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/mask.dmi', "cigaron"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "detective"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "detective"), ICON_OVERLAY)
				has_gloves = TRUE
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_OFFICER)
				clothes_s = new /icon('icons/mob/clothing/under/security.dmi', "security_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "jackboots"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "beret_officer"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "securitypack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-sec"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_CHIEF)
				clothes_s = new /icon('icons/mob/clothing/under/engineering.dmi', "chief_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/belt.dmi', "utility"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "hardhat0_white"), ICON_OVERLAY)
				has_gloves = TRUE
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/inhands/items_righthand.dmi', "blueprints"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "engiepack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-eng"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_ENGINEER)
				clothes_s = new /icon('icons/mob/clothing/under/engineering.dmi', "engine_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "orange"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/belt.dmi', "utility"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "hardhat0_yellow"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "hazard"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "engiepack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-eng"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_ATMOSTECH)
				clothes_s = new /icon('icons/mob/clothing/under/engineering.dmi', "atmos_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/belt.dmi', "utility"), ICON_OVERLAY)
				has_gloves = TRUE
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "firesuit"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)

			if(JOB_AI)//Gives AI and borgs assistant-wear, so they can still customize their character
				clothes_s = new /icon('icons/mob/clothing/under/color.dmi', "grey_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "straight_jacket"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "cardborg_h"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
				else if(backbag == 3 || backbag == 4)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_CYBORG)
				clothes_s = new /icon('icons/mob/clothing/under/color.dmi', "grey_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "cardborg"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "cardborg_h"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
				else if(backbag == 3 || backbag == 4)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_JUDGE)
				clothes_s = new /icon('icons/mob/clothing/under/suit.dmi', "really_black_suit_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "laceups"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "mercy_hood"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "judge"), ICON_UNDERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_NANO)
				clothes_s = new /icon('icons/mob/clothing/under/centcom.dmi', "officer_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "laceups"), ICON_UNDERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_BLUESHIELD)
				clothes_s = new /icon('icons/mob/clothing/under/centcom.dmi', "officer_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "swat_gl"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "blueshield"), ICON_OVERLAY)
				has_gloves = TRUE
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "securitypack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)

	if(disabilities & DISABILITY_FLAG_NEARSIGHTED)
		preview_icon.Blend(new /icon('icons/mob/clothing/eyes.dmi', "glasses"), ICON_OVERLAY)

	// Observers get tourist outfit.
	if(for_observer)
		clothes_s = new /icon('icons/mob/clothing/under/costumes.dmi', "tourist_s")
		clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
		if(backbag == 2)
			clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
		else if(backbag == 3 || backbag == 4)
			clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)

	if(underwear_s)
		preview_icon.Blend(underwear_s, ICON_OVERLAY)
	if(undershirt_s)
		preview_icon.Blend(undershirt_s, ICON_OVERLAY)
	if(socks_s)
		preview_icon.Blend(socks_s, ICON_OVERLAY)
	if(clothes_s)
		preview_icon.Blend(clothes_s, ICON_OVERLAY)
	if(!has_gloves)
		preview_icon.Blend(hands_icon, ICON_OVERLAY)

	preview_icon.Blend(face_s, ICON_OVERLAY)
	preview_icon_front = new(preview_icon, dir = SOUTH)
	preview_icon_side = new(preview_icon, dir = WEST)

	qdel(face_s)
	qdel(underwear_s)
	qdel(undershirt_s)
	qdel(socks_s)
	qdel(clothes_s)

#undef ICON_SHIFT_XY

/datum/character_save/proc/get_gear_metadata(datum/gear/G) // NYI
	. = loadout_gear[G.type]
	if(!.)
		. = list()
		loadout_gear[G.type] = .

/datum/character_save/proc/get_tweak_metadata(datum/gear/G, datum/gear_tweak/tweak)
	var/list/metadata = get_gear_metadata(G)
	. = metadata["[tweak]"]
	if(!.)
		. = tweak.get_default()
		metadata["[tweak]"] = .

/datum/character_save/proc/set_tweak_metadata(datum/gear/G, datum/gear_tweak/tweak, new_metadata)
	var/list/metadata = get_gear_metadata(G)
	metadata["[tweak]"] = new_metadata


/datum/character_save/proc/SetJobPreferenceLevel(datum/job/job, level)
	if(!job)
		return 0

	if(level == 1) // to high
		// remove any other job(s) set to high
		job_support_med |= job_support_high
		job_engsec_med |= job_engsec_high
		job_medsci_med |= job_medsci_high
		job_support_high = 0
		job_engsec_high = 0
		job_medsci_high = 0

	if(job.department_flag == JOBCAT_SUPPORT)
		job_support_low &= ~job.flag
		job_support_med &= ~job.flag
		job_support_high &= ~job.flag

		switch(level)
			if(1)
				job_support_high |= job.flag
			if(2)
				job_support_med |= job.flag
			if(3)
				job_support_low |= job.flag

		return 1
	else if(job.department_flag == JOBCAT_ENGSEC)
		job_engsec_low &= ~job.flag
		job_engsec_med &= ~job.flag
		job_engsec_high &= ~job.flag

		switch(level)
			if(1)
				job_engsec_high |= job.flag
			if(2)
				job_engsec_med |= job.flag
			if(3)
				job_engsec_low |= job.flag

		return 1
	else if(job.department_flag == JOBCAT_MEDSCI)
		job_medsci_low &= ~job.flag
		job_medsci_med &= ~job.flag
		job_medsci_high &= ~job.flag

		switch(level)
			if(1)
				job_medsci_high |= job.flag
			if(2)
				job_medsci_med |= job.flag
			if(3)
				job_medsci_low |= job.flag

		return 1

	return 0

/datum/character_save/proc/ShowDisabilityState(mob/user, flag, label)
	return "<li><b>[label]:</b> <a href=\"?_src_=prefs;task=input;preference=disabilities;disability=[flag]\">[disabilities & flag ? "Yes" : "No"]</a></li>"

/datum/character_save/proc/SetDisabilities(mob/user)
	var/datum/species/S = GLOB.all_species[species]
	var/HTML = "<body>"
	HTML += "<tt><center>"

	if(CAN_WINGDINGS in S.species_traits)
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_WINGDINGS, "Speak in Wingdings")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_NEARSIGHTED, "Nearsighted")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_COLOURBLIND, "Colourblind")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_BLIND, "Blind")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_DEAF, "Deaf")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_MUTE, "Mute")
	if(!(TRAIT_NOFAT in S.inherent_traits))
		HTML += ShowDisabilityState(user, DISABILITY_FLAG_FAT, "Obese")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_NERVOUS, "Stutter")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_SWEDISH, "Swedish accent")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_CHAV, "Chav accent")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_LISP, "Lisp")
	HTML += ShowDisabilityState(user, DISABILITY_FLAG_DIZZY, "Dizziness")


	HTML += {"</ul>
		<a href=\"?_src_=prefs;task=close;preference=disabilities\">\[Done\]</a>
		<a href=\"?_src_=prefs;task=reset;preference=disabilities\">\[Reset\]</a>
		</center></tt>"}

	var/datum/browser/popup = new(user, "disabil", "<div align='center'>Choose Disabilities</div>", 350, 380)
	popup.set_content(HTML)
	popup.open(0)

/datum/character_save/proc/SetRecords(mob/user)
	var/HTML = "<body>"
	HTML += "<tt><center>"

	HTML += "<a href=\"byond://?_src_=prefs;preference=records;task=med_record\">Medical Records</a><br>"

	if(length(med_record) <= 40)
		HTML += "[med_record]"
	else
		HTML += "[copytext_char(med_record, 1, 37)]..."		// SS220 EDIT - ORIGINAL: copytext

	HTML += "<br><a href=\"byond://?_src_=prefs;preference=records;task=gen_record\">Employment Records</a><br>"

	if(length(gen_record) <= 40)
		HTML += "[gen_record]"
	else
		HTML += "[copytext_char(gen_record, 1, 37)]..."		// SS220 EDIT - ORIGINAL: copytext

	HTML += "<br><a href=\"byond://?_src_=prefs;preference=records;task=sec_record\">Security Records</a><br>"

	if(length(sec_record) <= 40)
		HTML += "[sec_record]<br>"
	else
		HTML += "[copytext_char(sec_record, 1, 37)]...<br>"	// SS220 EDIT - ORIGINAL: copytext

	HTML += "<a href=\"byond://?_src_=prefs;preference=records;records=-1\">\[Done\]</a>"
	HTML += "</center></tt>"

	var/datum/browser/popup = new(user, "records", "<div align='center'>Character Records</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(0)

/datum/character_save/proc/GetPlayerAltTitle(datum/job/job)
	if(player_alt_titles.Find(job.title) > 0) // Does it exist in the list
		if(player_alt_titles[job.title] in job.alt_titles) // Is it valid
			return player_alt_titles[job.title]
	return job.title // Use default

/datum/character_save/proc/SetPlayerAltTitle(datum/job/job, new_title)
	// remove existing entry
	if(player_alt_titles.Find(job.title))
		player_alt_titles -= job.title
	// add one if it's not default
	if(job.title != new_title)
		player_alt_titles[job.title] = new_title

/datum/character_save/proc/ResetJobs()
	job_support_high = 0
	job_support_med = 0
	job_support_low = 0

	job_medsci_high = 0
	job_medsci_med = 0
	job_medsci_low = 0

	job_engsec_high = 0
	job_engsec_med = 0
	job_engsec_low = 0

/datum/character_save/proc/GetJobDepartment(datum/job/job, level)
	if(!job || !level)	return 0
	switch(job.department_flag)
		if(JOBCAT_SUPPORT)
			switch(level)
				if(1)
					return job_support_high
				if(2)
					return job_support_med
				if(3)
					return job_support_low
		if(JOBCAT_MEDSCI)
			switch(level)
				if(1)
					return job_medsci_high
				if(2)
					return job_medsci_med
				if(3)
					return job_medsci_low
		if(JOBCAT_ENGSEC)
			switch(level)
				if(1)
					return job_engsec_high
				if(2)
					return job_engsec_med
				if(3)
					return job_engsec_low
	return 0

/datum/character_save/proc/SetJobDepartment(datum/job/job, level)
	if(!job || !level)	return 0
	switch(level)
		if(1)//Only one of these should ever be active at once so clear them all here
			job_support_high = 0
			job_medsci_high = 0
			job_engsec_high = 0
			return 1
		if(2)//Set current highs to med, then reset them
			job_support_med |= job_support_high
			job_medsci_med |= job_medsci_high
			job_engsec_med |= job_engsec_high
			job_support_high = 0
			job_medsci_high = 0
			job_engsec_high = 0

	switch(job.department_flag)
		if(JOBCAT_SUPPORT)
			switch(level)
				if(2)
					job_support_high = job.flag
					job_support_med &= ~job.flag
				if(3)
					job_support_med |= job.flag
					job_support_low &= ~job.flag
				else
					job_support_low |= job.flag
		if(JOBCAT_MEDSCI)
			switch(level)
				if(2)
					job_medsci_high = job.flag
					job_medsci_med &= ~job.flag
				if(3)
					job_medsci_med |= job.flag
					job_medsci_low &= ~job.flag
				else
					job_medsci_low |= job.flag
		if(JOBCAT_ENGSEC)
			switch(level)
				if(2)
					job_engsec_high = job.flag
					job_engsec_med &= ~job.flag
				if(3)
					job_engsec_med |= job.flag
					job_engsec_low &= ~job.flag
				else
					job_engsec_low |= job.flag
	return 1

/datum/character_save/proc/copy_to(mob/living/carbon/human/character)
	var/datum/species/S = GLOB.all_species[species]
	character.set_species(S.type) // Yell at me if this causes everything to melt
	if(be_random_name)
		real_name = random_name(gender, species)

	character.add_language(language)


	character.real_name = real_name
	character.dna.real_name = real_name
	character.name = character.real_name

	character.flavor_text = flavor_text
	character.med_record = med_record
	character.sec_record = sec_record
	character.gen_record = gen_record

	character.change_gender(gender)
	character.age = age

	//Head-specific
	var/obj/item/organ/external/head/H = character.get_organ("head")

	H.hair_colour = h_colour

	H.sec_hair_colour = h_sec_colour

	H.facial_colour = f_colour

	H.sec_facial_colour = f_sec_colour

	H.h_style = h_style
	H.f_style = f_style

	H.alt_head = alt_head

	H.h_grad_style = h_grad_style
	H.h_grad_offset_x = h_grad_offset_x
	H.h_grad_offset_y = h_grad_offset_y
	H.h_grad_colour = h_grad_colour
	H.h_grad_alpha = h_grad_alpha
	//End of head-specific.

	character.skin_colour = s_colour

	character.s_tone = s_tone

	// Destroy/cyborgize organs
	for(var/name in organ_data)

		var/status = organ_data[name]
		var/obj/item/organ/external/O = character.bodyparts_by_name[name]
		if(O)
			if(status == "amputated")
				qdel(O.remove(character))

			else if(status == "cyborg")
				if(rlimb_data[name])
					O.robotize(rlimb_data[name], convert_all = 0)
				else
					O.robotize()
		else
			var/obj/item/organ/internal/I = character.get_int_organ_tag(name)
			if(I)
				if(status == "cybernetic")
					I.robotize()

	character.dna.blood_type = b_type

	// Wheelchair necessary?
	var/obj/item/organ/external/l_foot = character.get_organ("l_foot")
	var/obj/item/organ/external/r_foot = character.get_organ("r_foot")
	if(!l_foot && !r_foot)
		var/obj/structure/chair/wheelchair/W = new /obj/structure/chair/wheelchair(character.loc)
		W.buckle_mob(character, TRUE)
	else if(!l_foot || !r_foot)
		character.put_in_r_hand(new /obj/item/cane)

	character.underwear = underwear
	character.undershirt = undershirt
	character.socks = socks

	if(character.dna.species.bodyflags & HAS_HEAD_ACCESSORY)
		H.headacc_colour = hacc_colour
		H.ha_style = ha_style
	if(character.dna.species.bodyflags & HAS_MARKINGS)
		character.m_colours = m_colours
		character.m_styles = m_styles

	if(body_accessory)
		character.body_accessory = GLOB.body_accessory_by_name[body_accessory]

	character.backbag = backbag

	//Debugging report to track down a bug, which randomly assigned the plural gender to people.
	if(character.dna.species.has_gender && (character.gender in list(PLURAL, NEUTER)))
		if(isliving(src)) //Ghosts get neuter by default
			message_admins("[key_name_admin(character)] has spawned with their gender as plural or neuter. Please notify coders.")
			character.change_gender(MALE)

	character.change_eye_color(e_colour)
	character.original_eye_color = e_colour

	if(disabilities & DISABILITY_FLAG_FAT)
		character.dna.SetSEState(GLOB.fatblock, TRUE, TRUE)
		character.overeatduration = 600
		character.dna.default_blocks.Add(GLOB.fatblock)

	if(disabilities & DISABILITY_FLAG_NEARSIGHTED)
		character.dna.SetSEState(GLOB.glassesblock, TRUE, TRUE)
		character.dna.default_blocks.Add(GLOB.glassesblock)

	if(disabilities & DISABILITY_FLAG_BLIND)
		character.dna.SetSEState(GLOB.blindblock, TRUE, TRUE)
		character.dna.default_blocks.Add(GLOB.blindblock)

	if(disabilities & DISABILITY_FLAG_DEAF)
		character.dna.SetSEState(GLOB.deafblock, TRUE, TRUE)
		character.dna.default_blocks.Add(GLOB.deafblock)

	if(disabilities & DISABILITY_FLAG_COLOURBLIND)
		character.dna.SetSEState(GLOB.colourblindblock, TRUE, TRUE)
		character.dna.default_blocks.Add(GLOB.colourblindblock)

	if(disabilities & DISABILITY_FLAG_MUTE)
		character.dna.SetSEState(GLOB.muteblock, TRUE, TRUE)
		character.dna.default_blocks.Add(GLOB.muteblock)

	if(disabilities & DISABILITY_FLAG_NERVOUS)
		character.dna.SetSEState(GLOB.nervousblock, TRUE, TRUE)
		character.dna.default_blocks.Add(GLOB.nervousblock)

	if(disabilities & DISABILITY_FLAG_SWEDISH)
		character.dna.SetSEState(GLOB.swedeblock, TRUE, TRUE)
		character.dna.default_blocks.Add(GLOB.swedeblock)

	if(disabilities & DISABILITY_FLAG_CHAV)
		character.dna.SetSEState(GLOB.chavblock, TRUE, TRUE)
		character.dna.default_blocks.Add(GLOB.chavblock)

	if(disabilities & DISABILITY_FLAG_LISP)
		character.dna.SetSEState(GLOB.lispblock, TRUE, TRUE)
		character.dna.default_blocks.Add(GLOB.lispblock)

	if(disabilities & DISABILITY_FLAG_DIZZY)
		character.dna.SetSEState(GLOB.dizzyblock, TRUE, TRUE)
		character.dna.default_blocks.Add(GLOB.dizzyblock)

	if(disabilities & DISABILITY_FLAG_WINGDINGS && (CAN_WINGDINGS in character.dna.species.species_traits))
		character.dna.SetSEState(GLOB.wingdingsblock, TRUE, TRUE)
		character.dna.default_blocks.Add(GLOB.wingdingsblock)

	character.dna.species.handle_dna(character)

	if(character.dna.dirtySE)
		character.dna.UpdateSE()
	domutcheck(character, MUTCHK_FORCED) //'Activates' all the above disabilities.

	character.dna.ready_dna(character, flatten_SE = FALSE)
	character.sync_organ_dna(assimilate = TRUE)
	character.UpdateAppearance()

	// Do the initial caching of the player's body icons.
	character.force_update_limbs()
	character.update_eyes()
	character.regenerate_icons()

//Check if the user has ANY job selected.
/datum/character_save/proc/check_any_job()
	return(job_support_high || job_support_med || job_support_low || job_medsci_high || job_medsci_med || job_medsci_low || job_engsec_high || job_engsec_med || job_engsec_low)


/datum/character_save/proc/SetChoices(mob/user, limit = 17, list/splitJobs = list("Head of Security", "Bartender"), widthPerColumn = 400, height = 700)
	if(!SSjobs)
		return

	//limit - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
	//widthPerColumn - Screen's width for every column.
	//height - Screen's height.
	var/width = widthPerColumn


	var/list/html = list()
	html += "<body>"
	if(!length(SSjobs.occupations))
		html += "The Jobs subsystem is not yet finished creating jobs, please try again later"
		html += "<center><a href='?_src_=prefs;preference=job;task=close'>Done</a></center><br>" // Easier to press up here.
	else
		html += "<tt><center>"
		html += "<b>Choose occupation chances</b><br>Unavailable occupations are crossed out.<br><br>"
		html += "<center><a href='?_src_=prefs;preference=job;task=close'>Save</a></center><br>" // Easier to press up here.
		html += "<div align='center'>Left-click to raise an occupation preference, right-click to lower it.<br></div>"
		html += "<script type='text/javascript'>function setJobPrefRedirect(level, rank) { window.location.href='?_src_=prefs;preference=job;task=setJobLevel;level=' + level + ';text=' + encodeURIComponent(rank); return false; }</script>"
		html += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
		html += "<table width='100%' cellpadding='1' cellspacing='0'>"
		var/index = -1

		//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
		var/datum/job/lastJob
		if(!SSjobs)
			return
		for(var/J in SSjobs.occupations)
			var/datum/job/job = J

			if(job.admin_only)
				continue

			if(job.hidden_from_job_prefs)
				continue

			index += 1
			if((index >= limit) || (job.title in splitJobs))
				if((index < limit) && (lastJob != null))
					// Dynamic window width
					width += widthPerColumn
					//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
					//the last job's selection color. Creating a rather nice effect.
					for(var/i in 1 to limit - index)
						html += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"
				html += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
				index = 0

			html += "<tr bgcolor='[job.selection_color]'><td width='60%' align='right'>"
			var/rank
			if(job.alt_titles)
				rank = "<a href=\"?_src_=prefs;preference=job;task=alt_title;job=\ref[job]\">[GetPlayerAltTitle(job)]</a>"
			else
				rank = job.title
			lastJob = job
			if(jobban_isbanned(user, job.title))
				html += "<del class='dark'>[rank]</del></td><td class='bad'><b> \[BANNED]</b></td></tr>"
				continue
			var/restrictions = job.get_exp_restrictions(user.client)
			if(restrictions)
				html += "<del class='dark'>[rank]</del></td><td class='bad'><b> \[[restrictions]]</b></td></tr>"
				continue
			if(job.barred_by_disability(user.client))
				html += "<del class='dark'>[rank]</del></td><td class='bad'><b> \[DISABILITY\]</b></td></tr>"
				continue
			if(job.barred_by_missing_limbs(user.client))
				html += "<del class='dark'>[rank]</del></td><td class='bad'><b> \[MISSING LIMBS\]</b></td></tr>"
				continue
			if(!job.player_old_enough(user.client))
				var/available_in_days = job.available_in_days(user.client)
				html += "<del class='dark'>[rank]</del></td><td class='bad'><b> \[IN [(available_in_days)] DAYS]</b></td></tr>"
				continue
			if((job_support_low & JOB_ASSISTANT) && (job.title != "Assistant"))
				html += "<font color=orange>[rank]</font></td><td></td></tr>"
				continue
			if((job.title in GLOB.command_positions) || (job.title == "AI"))//Bold head jobs
				html += "<b><span class='dark'>[rank]</span></b>"
			else
				html += "<span class='dark'>[rank]</span>"

			html += "</td><td width='40%'>"

			var/prefLevelLabel = "ERROR"
			var/prefLevelColor = "pink"
			var/prefUpperLevel = -1 // level to assign on left click
			var/prefLowerLevel = -1 // level to assign on right click

			if(GetJobDepartment(job, 1) & job.flag)
				prefLevelLabel = "High"
				prefLevelColor = "slateblue"
				prefUpperLevel = 4
				prefLowerLevel = 2
			else if(GetJobDepartment(job, 2) & job.flag)
				prefLevelLabel = "Medium"
				prefLevelColor = "green"
				prefUpperLevel = 1
				prefLowerLevel = 3
			else if(GetJobDepartment(job, 3) & job.flag)
				prefLevelLabel = "Low"
				prefLevelColor = "orange"
				prefUpperLevel = 2
				prefLowerLevel = 4
			else
				prefLevelLabel = "NEVER"
				prefLevelColor = "red"
				prefUpperLevel = 3
				prefLowerLevel = 1


			html += "<a class='white' href='?_src_=prefs;preference=job;task=setJobLevel;level=[prefUpperLevel];text=[job.title]' oncontextmenu='javascript:return setJobPrefRedirect([prefLowerLevel], \"[job.title]\");'>"

	//			HTML += "<a href='?_src_=prefs;preference=job;task=input;text=[rank]'>"

			if(job.title == "Assistant") // Assistant is special
				if(job_support_low & JOB_ASSISTANT)
					html += " <font color=green>Yes</font></a>"
				else
					html += " <font color=red>No</font></a>"
				html += "</td></tr>"
				continue
	/*
			if(GetJobDepartment(job, 1) & job.flag)
				HTML += " <font color=blue>\[High]</font>"
			else if(GetJobDepartment(job, 2) & job.flag)
				HTML += " <font color=green>\[Medium]</font>"
			else if(GetJobDepartment(job, 3) & job.flag)
				HTML += " <font color=orange>\[Low]</font>"
			else
				HTML += " <font color=red>\[NEVER]</font>"
				*/
			html += "<font color=[prefLevelColor]>[prefLevelLabel]</font></a>"

			html += "</td></tr>"

		for(var/i in 1 to limit - index) // Finish the column so it is even
			html += "<tr bgcolor='[lastJob ? lastJob.selection_color : "#ffffff"]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"

		html += "</td></tr></table>"
		html += "</center></table>"

		switch(alternate_option)
			if(GET_RANDOM_JOB)
				html += "<center><br><u><a href='?_src_=prefs;preference=job;task=random'><font color=white>Get random job if preferences unavailable</font></a></u></center><br>"
			if(BE_ASSISTANT)
				html += "<center><br><u><a href='?_src_=prefs;preference=job;task=random'><font color=white>Be an assistant if preferences unavailable</font></a></u></center><br>"
			if(RETURN_TO_LOBBY)
				html += "<center><br><u><a href='?_src_=prefs;preference=job;task=random'><font color=white>Return to lobby if preferences unavailable</font></a></u></center><br>"

		html += "<center><a href='?_src_=prefs;preference=job;task=reset'>Reset</a></center>"
		html += "<center><br><a href='?_src_=prefs;preference=job;task=learnaboutselection'>Learn About Job Selection</a></center>"
		html += "</tt>"

	user << browse(null, "window=preferences")
//		user << browse(HTML, "window=mob_occupation;size=[width]x[height]")
	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Occupation Preferences</div>", width, height)
	popup.set_window_options("can_close=0")
	var/html_string = html.Join()
	popup.set_content(html_string)
	popup.open(FALSE)


/datum/character_save/proc/clear_character_slot(client/C)
	. = FALSE
	// Is there a character in that slot?
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT slot FROM characters WHERE ckey=:ckey AND slot=:slot", list(
		"ckey" = C.ckey,
		"slot" = slot_number
	))

	if(!query.warn_execute())
		qdel(query)
		return

	if(!query.NextRow())
		qdel(query)
		return

	qdel(query)

	var/datum/db_query/delete_query = SSdbcore.NewQuery("DELETE FROM characters WHERE ckey=:ckey AND slot=:slot", list(
		"ckey" = C.ckey,
		"slot" = slot_number
	))

	if(!delete_query.warn_execute())
		qdel(delete_query)
		return

	qdel(delete_query)

	from_db = FALSE
	return TRUE

/datum/character_save/proc/init_custom_emotes(overrides)
	custom_emotes = overrides

	for(var/datum/keybinding/custom/custom_emote in GLOB.keybindings)
		var/emote_text = overrides && overrides[custom_emote.name]
		if(!emote_text)
			continue //we don't set anything without an override

		custom_emotes[custom_emote.name] = emote_text

	return custom_emotes
