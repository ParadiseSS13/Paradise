/**
* DNA 2: The Spaghetti Strikes Back
*
* @author N3X15 <nexisentertainment@gmail.com>
*/

// What each index means:
#define DNA_OFF_LOWERBOUND 1		// changed as lists start at 1 not 0
#define DNA_OFF_UPPERBOUND 2
#define DNA_ON_LOWERBOUND  3
#define DNA_ON_UPPERBOUND  4

// Define block bounds (off-low,off-high,on-low,on-high)
// Used in setupgame.dm
#define DNA_DEFAULT_BOUNDS list(1,2049,2050,4095)
#define DNA_HARDER_BOUNDS  list(1,3049,3050,4095)
#define DNA_HARD_BOUNDS    list(1,3490,3500,4095)

// UI Indices (can change to mutblock style, if desired)
#define DNA_UI_HAIR_R		1
#define DNA_UI_HAIR_G		2
#define DNA_UI_HAIR_B		3
#define DNA_UI_HAIR2_R		4
#define DNA_UI_HAIR2_G		5
#define DNA_UI_HAIR2_B		6
#define DNA_UI_BEARD_R		7
#define DNA_UI_BEARD_G		8
#define DNA_UI_BEARD_B		9
#define DNA_UI_BEARD2_R		10
#define DNA_UI_BEARD2_G		11
#define DNA_UI_BEARD2_B		12
#define DNA_UI_SKIN_TONE	13
#define DNA_UI_SKIN_R		14
#define DNA_UI_SKIN_G		15
#define DNA_UI_SKIN_B		16
#define DNA_UI_HACC_R		17
#define DNA_UI_HACC_G		18
#define DNA_UI_HACC_B		19
#define DNA_UI_HEAD_MARK_R	20
#define DNA_UI_HEAD_MARK_G	21
#define DNA_UI_HEAD_MARK_B	22
#define DNA_UI_BODY_MARK_R	23
#define DNA_UI_BODY_MARK_G	24
#define DNA_UI_BODY_MARK_B	25
#define DNA_UI_TAIL_MARK_R	26
#define DNA_UI_TAIL_MARK_G	27
#define DNA_UI_TAIL_MARK_B	28
#define DNA_UI_EYES_R		29
#define DNA_UI_EYES_G		30
#define DNA_UI_EYES_B		31
#define DNA_UI_GENDER		32
#define DNA_UI_BEARD_STYLE	33
#define DNA_UI_HAIR_STYLE	34
/*#define DNA_UI_BACC_STYLE	23*/
#define DNA_UI_HACC_STYLE	35
#define DNA_UI_HEAD_MARK_STYLE	36
#define DNA_UI_BODY_MARK_STYLE	37
#define DNA_UI_TAIL_MARK_STYLE	38
#define DNA_UI_LENGTH		38 // Update this when you add something, or you WILL break shit.

#define DNA_SE_LENGTH 55 // Was STRUCDNASIZE, size 27. 15 new blocks added = 42, plus room to grow.

// Defines which values mean "on" or "off".
//  This is to make some of the more OP superpowers a larger PITA to activate,
//  and to tell our new DNA datum which values to set in order to turn something
//  on or off.
var/global/list/dna_activity_bounds[DNA_SE_LENGTH]
var/global/list/assigned_gene_blocks[DNA_SE_LENGTH]

// Used to determine what each block means (admin hax and species stuff on /vg/, mostly)
var/global/list/assigned_blocks[DNA_SE_LENGTH]

var/global/list/datum/dna/gene/dna_genes[0]

var/global/list/good_blocks[0]
var/global/list/bad_blocks[0]

/datum/dna
	// READ-ONLY, GETS OVERWRITTEN
	// DO NOT FUCK WITH THESE OR BYOND WILL EAT YOUR FACE
	var/uni_identity="" // Encoded UI
	var/struc_enzymes="" // Encoded SE
	var/unique_enzymes="" // MD5 of player name

	// Original Encoded SE, for use with Ryetalin
	var/struc_enzymes_original="" // Encoded SE
	var/list/SE_original[DNA_SE_LENGTH]

	// Internal dirtiness checks
	var/dirtyUI=0
	var/dirtySE=0

	// Okay to read, but you're an idiot if you do.
	// BLOCK = VALUE
	var/list/SE[DNA_SE_LENGTH]
	var/list/UI[DNA_UI_LENGTH]

	// From old dna.
	var/blood_type = "A+"  // Should probably change to an integer => string map but I'm lazy.
	var/real_name          // Stores the real name of the person who originally got this dna datum. Used primarily for changelings,

	var/datum/species/species = new /datum/species/human //The type of mutant race the player is if applicable (i.e. potato-man)
	var/list/default_blocks = list() //list of all blocks toggled at roundstart

// Make a copy of this strand.
// USE THIS WHEN COPYING STUFF OR YOU'LL GET CORRUPTION!
/datum/dna/proc/Clone()
	var/datum/dna/new_dna = new()
	new_dna.unique_enzymes=unique_enzymes
	new_dna.struc_enzymes_original=struc_enzymes_original // will make clone's SE the same as the original, do we want this?
	new_dna.blood_type = blood_type
	new_dna.real_name=real_name
	new_dna.species = new species.type
	for(var/b=1;b<=DNA_SE_LENGTH;b++)
		new_dna.SE[b]=SE[b]
		if(b<=DNA_UI_LENGTH)
			new_dna.UI[b]=UI[b]
	new_dna.UpdateUI()
	new_dna.UpdateSE()
	return new_dna

///////////////////////////////////////
// UNIQUE IDENTITY
///////////////////////////////////////

// Create random UI.
/datum/dna/proc/ResetUI(var/defer=0)
	for(var/i=1,i<=DNA_UI_LENGTH,i++)
		switch(i)
			if(DNA_UI_SKIN_TONE)
				SetUIValueRange(DNA_UI_SKIN_TONE,rand(1,220),220,1) // Otherwise, it gets fucked
			else
				UI[i]=rand(0,4095)
	if(!defer)
		UpdateUI()

/datum/dna/proc/ResetUIFrom(var/mob/living/carbon/human/character)
	// INITIALIZE!
	ResetUI(1)
	// Hair
	// FIXME:  Species-specific defaults pls
	var/obj/item/organ/external/head/H = character.get_organ("head")
	var/obj/item/organ/internal/eyes/eyes_organ = character.get_int_organ(/obj/item/organ/internal/eyes)
	var/datum/species/S = character.dna.species

	/*// Body Accessory
	if(!character.body_accessory)
		character.body_accessory = null
	var/bodyacc	= character.body_accessory*/

	// Markings
	if(!character.m_styles)
		character.m_styles = DEFAULT_MARKING_STYLES

	var/head_marks	= GLOB.marking_styles_list.Find(character.m_styles["head"])
	var/body_marks	= GLOB.marking_styles_list.Find(character.m_styles["body"])
	var/tail_marks	= GLOB.marking_styles_list.Find(character.m_styles["tail"])

	head_traits_to_dna(H)
	eye_color_to_dna(eyes_organ)

	SetUIValueRange(DNA_UI_SKIN_R,		color2R(character.skin_colour),			255,	1)
	SetUIValueRange(DNA_UI_SKIN_G,		color2G(character.skin_colour),			255,	1)
	SetUIValueRange(DNA_UI_SKIN_B,		color2B(character.skin_colour),			255,	1)

	SetUIValueRange(DNA_UI_HEAD_MARK_R,	color2R(character.m_colours["head"]),	255,	1)
	SetUIValueRange(DNA_UI_HEAD_MARK_G,	color2G(character.m_colours["head"]),	255,	1)
	SetUIValueRange(DNA_UI_HEAD_MARK_B,	color2B(character.m_colours["head"]),	255,	1)

	SetUIValueRange(DNA_UI_BODY_MARK_R,	color2R(character.m_colours["body"]),	255,	1)
	SetUIValueRange(DNA_UI_BODY_MARK_G,	color2G(character.m_colours["body"]),	255,	1)
	SetUIValueRange(DNA_UI_BODY_MARK_B,	color2B(character.m_colours["body"]),	255,	1)

	SetUIValueRange(DNA_UI_TAIL_MARK_R,	color2R(character.m_colours["tail"]),	255,	1)
	SetUIValueRange(DNA_UI_TAIL_MARK_G,	color2G(character.m_colours["tail"]),	255,	1)
	SetUIValueRange(DNA_UI_TAIL_MARK_B,	color2B(character.m_colours["tail"]),	255,	1)

	SetUIValueRange(DNA_UI_SKIN_TONE,	35-character.s_tone,	220,	1) // Value can be negative.

	if(S.has_gender)
		SetUIState(DNA_UI_GENDER, character.gender!=MALE, 1)
	else
		SetUIState(DNA_UI_GENDER, pick(0,1), 1)

	/*SetUIValueRange(DNA_UI_BACC_STYLE,	bodyacc,	GLOB.facial_hair_styles_list.len,	1)*/
	SetUIValueRange(DNA_UI_HEAD_MARK_STYLE,	head_marks,		GLOB.marking_styles_list.len,		1)
	SetUIValueRange(DNA_UI_BODY_MARK_STYLE,	body_marks,		GLOB.marking_styles_list.len,		1)
	SetUIValueRange(DNA_UI_TAIL_MARK_STYLE,	tail_marks,		GLOB.marking_styles_list.len,		1)


	UpdateUI()

// Set a DNA UI block's raw value.
/datum/dna/proc/SetUIValue(var/block,var/value,var/defer=0)
	if(block<=0) return
	ASSERT(value>0)
	ASSERT(value<=4095)
	UI[block]=value
	dirtyUI=1
	if(!defer)
		UpdateUI()

// Get a DNA UI block's raw value.
/datum/dna/proc/GetUIValue(var/block)
	if(block<=0) return 0
	return UI[block]

// Set a DNA UI block's value, given a value and a max possible value.
// Used in hair and facial styles (value being the index and maxvalue being the len of the hairstyle list)
/datum/dna/proc/SetUIValueRange(var/block,var/value,var/maxvalue,var/defer=0)
	if(block<=0)
		return
	if(value == 0)
		value = 1
	ASSERT(maxvalue<=4095)
	var/range = (4095 / maxvalue)
	if(value)
		SetUIValue(block,round(value * range),defer)

// Getter version of above.
/datum/dna/proc/GetUIValueRange(var/block,var/maxvalue)
	if(block<=0) return 0
	var/value = GetUIValue(block)
	return round(1 +(value / 4096)*maxvalue)

// Is the UI gene "on" or "off"?
// For UI, this is simply a check of if the value is > 2050.
/datum/dna/proc/GetUIState(var/block)
	if(block<=0) return
	return UI[block] > 2050


// Set UI gene "on" (1) or "off" (0)
/datum/dna/proc/SetUIState(var/block,var/on,var/defer=0)
	if(block<=0) return
	var/val
	if(on)
		val=rand(2050,4095)
	else
		val=rand(1,2049)
	SetUIValue(block,val,defer)

// Get a hex-encoded UI block.
/datum/dna/proc/GetUIBlock(var/block)
	return EncodeDNABlock(GetUIValue(block))

// Do not use this unless you absolutely have to.
// Set a block from a hex string.  This is inefficient.  If you can, use SetUIValue().
// Used in DNA modifiers.
/datum/dna/proc/SetUIBlock(var/block,var/value,var/defer=0)
	if(block<=0) return
	return SetUIValue(block,hex2num(value),defer)

// Get a sub-block from a block.
/datum/dna/proc/GetUISubBlock(var/block,var/subBlock)
	return copytext(GetUIBlock(block),subBlock,subBlock+1)

// Do not use this unless you absolutely have to.
// Set a block from a hex string.  This is inefficient.  If you can, use SetUIValue().
// Used in DNA modifiers.
/datum/dna/proc/SetUISubBlock(var/block,var/subBlock, var/newSubBlock, var/defer=0)
	if(block<=0) return
	var/oldBlock=GetUIBlock(block)
	var/newBlock=""
	for(var/i=1, i<=length(oldBlock), i++)
		if(i==subBlock)
			newBlock+=newSubBlock
		else
			newBlock+=copytext(oldBlock,i,i+1)
	SetUIBlock(block,newBlock,defer)

///////////////////////////////////////
// STRUCTURAL ENZYMES
///////////////////////////////////////

// "Zeroes out" all of the blocks.
/datum/dna/proc/ResetSE()
	for(var/i = 1, i <= DNA_SE_LENGTH, i++)
		SetSEValue(i,rand(1,1024),1)
	UpdateSE()

// Set a DNA SE block's raw value.
/datum/dna/proc/SetSEValue(var/block,var/value,var/defer=0)

	if(block<=0) return
	ASSERT(value>=0)
	ASSERT(value<=4095)
	SE[block]=value
	dirtySE=1
	if(!defer)
		UpdateSE()
	//testing("SetSEBlock([block],[value],[defer]): [value] -> [GetSEValue(block)]")

// Get a DNA SE block's raw value.
/datum/dna/proc/GetSEValue(var/block)
	if(block<=0) return 0
	return SE[block]

// Set a DNA SE block's value, given a value and a max possible value.
// Might be used for species?
/datum/dna/proc/SetSEValueRange(var/block,var/value,var/maxvalue)
	if(block<=0) return
	ASSERT(maxvalue<=4095)
	var/range = round(4095 / maxvalue)
	if(value)
		SetSEValue(block, value * range - rand(1,range-1))

// Getter version of above.
/datum/dna/proc/GetSEValueRange(var/block,var/maxvalue)
	if(block<=0) return 0
	var/value = GetSEValue(block)
	return round(1 +(value / 4096)*maxvalue)

// Is the block "on" (1) or "off" (0)? (Un-assigned genes are always off.)
/datum/dna/proc/GetSEState(var/block)
	if(block<=0) return 0
	var/list/BOUNDS=GetDNABounds(block)
	var/value=GetSEValue(block)
	return (value >= BOUNDS[DNA_ON_LOWERBOUND])

// Set a block "on" or "off".
/datum/dna/proc/SetSEState(var/block,var/on,var/defer=0)
	if(block<=0) return
	var/list/BOUNDS=GetDNABounds(block)
	var/val
	if(on)
		val=rand(BOUNDS[DNA_ON_LOWERBOUND],BOUNDS[DNA_ON_UPPERBOUND])
	else
		val=rand(1,BOUNDS[DNA_OFF_UPPERBOUND])
	SetSEValue(block,val,defer)

// Get hex-encoded SE block.
/datum/dna/proc/GetSEBlock(var/block)
	return EncodeDNABlock(GetSEValue(block))

// Do not use this unless you absolutely have to.
// Set a block from a hex string.  This is inefficient.  If you can, use SetUIValue().
// Used in DNA modifiers.
/datum/dna/proc/SetSEBlock(var/block,var/value,var/defer=0)
	if(block<=0) return
	var/nval=hex2num(value)
	//testing("SetSEBlock([block],[value],[defer]): [value] -> [nval]")
	return SetSEValue(block,nval,defer)

/datum/dna/proc/GetSESubBlock(var/block,var/subBlock)
	return copytext(GetSEBlock(block),subBlock,subBlock+1)

// Do not use this unless you absolutely have to.
// Set a sub-block from a hex character.  This is inefficient.  If you can, use SetUIValue().
// Used in DNA modifiers.
/datum/dna/proc/SetSESubBlock(var/block,var/subBlock, var/newSubBlock, var/defer=0)
	if(block<=0) return
	var/oldBlock=GetSEBlock(block)
	var/newBlock=""
	for(var/i=1, i<=length(oldBlock), i++)
		if(i==subBlock)
			newBlock+=newSubBlock
		else
			newBlock+=copytext(oldBlock,i,i+1)
	//testing("SetSESubBlock([block],[subBlock],[newSubBlock],[defer]): [oldBlock] -> [newBlock]")
	SetSEBlock(block,newBlock,defer)


/proc/EncodeDNABlock(var/value)
	return add_zero2(num2hex(value,1), 3)

/datum/dna/proc/UpdateUI()
	src.uni_identity=""
	for(var/block in UI)
		uni_identity += EncodeDNABlock(block)
	//testing("New UI: [uni_identity]")
	dirtyUI=0

/datum/dna/proc/UpdateSE()
	//var/oldse=struc_enzymes
	struc_enzymes=""
	for(var/block in SE)
		struc_enzymes += EncodeDNABlock(block)
	//testing("Old SE: [oldse]")
	//testing("New SE: [struc_enzymes]")
	dirtySE=0

// BACK-COMPAT!
//  Just checks our character has all the crap it needs.
/datum/dna/proc/check_integrity(var/mob/living/carbon/human/character)
	if(character)
		if(UI.len != DNA_UI_LENGTH)
			ResetUIFrom(character)

		if(length(struc_enzymes)!= 3*DNA_SE_LENGTH)
			ResetSE()

		if(length(unique_enzymes) != 32)
			unique_enzymes = md5(character.real_name)
	else
		if(length(uni_identity) != 3*DNA_UI_LENGTH)
			uni_identity = "00600200A00E0110148FC01300B0095BD7FD3F4"
		if(length(struc_enzymes)!= 3*DNA_SE_LENGTH)
			struc_enzymes = "43359156756131E13763334D1C369012032164D4FE4CD61544B6C03F251B6C60A42821D26BA3B0FD6"

// BACK-COMPAT!
//  Initial DNA setup.  I'm kind of wondering why the hell this doesn't just call the above.
//    ready_dna is (hopefully) only used on mob creation, and sets the struc_enzymes_original and SE_original only once - Bone White

/datum/dna/proc/ready_dna(mob/living/carbon/human/character, flatten_SE = 1)

	ResetUIFrom(character)

	if(flatten_SE)
		ResetSE()

	struc_enzymes_original = struc_enzymes // sets the original struc_enzymes when ready_dna is called
	SE_original = SE.Copy()

	unique_enzymes = md5(character.real_name)
	reg_dna[unique_enzymes] = character.real_name

// Hmm, I wonder how to go about this without a huge convention break
/datum/dna/serialize()
	var/data = list()
	data["UE"] = unique_enzymes
	data["SE"] = SE.Copy() // This is probably too lazy for my own good
	data["UI"] = UI.Copy()
	data["species"] = species.type
	// Because old DNA coders were insane or something
	data["blood_type"] = blood_type
	data["real_name"] = real_name
	return data

/datum/dna/deserialize(data)
	unique_enzymes = data["UE"]
	// The de-serializer is unlikely to tamper with the lists
	SE = data["SE"]
	UI = data["UI"]
	UpdateUI()
	UpdateSE()
	var/datum/species/S = data["species"]
	species = new S
	blood_type = data["blood_type"]
	real_name = data["real_name"]

/datum/dna/proc/transfer_identity(mob/living/carbon/human/destination)
	if(!istype(destination))
		return

	// We manually set the species to ensure all proper species change procs are called.
	destination.set_species(species.type, retain_damage = TRUE)
	var/datum/dna/new_dna = Clone()
	new_dna.species = destination.dna.species
	destination.dna = new_dna
	destination.dna.species.handle_dna(destination) // Handle DNA has to be re-called as the DNA was changed.

	destination.UpdateAppearance()
	domutcheck(destination, null, MUTCHK_FORCED)
