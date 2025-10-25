/*
######################################################################################
##																					##
##								IMPORTANT README									##
##																					##
##	  Changing any /datum/gear typepaths --WILL-- break people's loadouts.			##
##	The typepaths are stored directly in the `characters.gear` column of the DB.	##
##		Please inform the server host if you wish to modify any of these.			##
##																					##
######################################################################################
*/


// Uniform slot
/datum/gear/uniform
	main_typepath = /datum/gear/uniform
	slot = ITEM_SLOT_JUMPSUIT
	sort_category = "Uniforms and Casual Dress"

/datum/gear/uniform/suit
	main_typepath = /datum/gear/uniform/suit

/datum/gear/uniform/suit/job
	main_typepath = /datum/gear/uniform/suit/job
	subtype_selection_cost = FALSE

/datum/gear/uniform/turtleneck
	main_typepath = /datum/gear/uniform/turtleneck

/datum/gear/uniform/turtleneck/job
	main_typepath = /datum/gear/uniform/turtleneck/job

//there's a lot more colors than I thought there were @_@

/datum/gear/uniform/suit/jumpsuitblack
	display_name = "Jumpsuit, black"
	path = /obj/item/clothing/under/color/black

/datum/gear/uniform/suit/jumpsuitblue
	display_name = "Jumpsuit, blue"
	path = /obj/item/clothing/under/color/blue

/datum/gear/uniform/suit/jumpsuitgreen
	display_name = "Jumpsuit, green"
	path = /obj/item/clothing/under/color/green

/datum/gear/uniform/suit/jumpsuitgrey
	display_name = "Jumpsuit, grey"
	path = /obj/item/clothing/under/color/grey

/datum/gear/uniform/suit/jumpsuitorange
	display_name = "Jumpsuit, orange"
	path = /obj/item/clothing/under/color/orange

/datum/gear/uniform/suit/jumpsuitpink
	display_name = "Jumpsuit, pink"
	path = /obj/item/clothing/under/color/pink

/datum/gear/uniform/suit/jumpsuitred
	display_name = "Jumpsuit, red"
	path = /obj/item/clothing/under/color/red

/datum/gear/uniform/suit/jumpsuitwhite
	display_name = "Jumpsuit, white"
	path = /obj/item/clothing/under/color/white

/datum/gear/uniform/suit/jumpsuityellow
	display_name = "Jumpsuit, yellow"
	path = /obj/item/clothing/under/color/yellow

/datum/gear/uniform/suit/jumpsuitlightblue
	display_name = "Jumpsuit, lightblue"
	path = /obj/item/clothing/under/color/lightblue

/datum/gear/uniform/suit/jumpsuitaqua
	display_name = "Jumpsuit, aqua"
	path = /obj/item/clothing/under/color/aqua

/datum/gear/uniform/suit/jumpsuitpurple
	display_name = "Jumpsuit, purple"
	path = /obj/item/clothing/under/color/purple

/datum/gear/uniform/suit/jumpsuitlightpurple
	display_name = "Jumpsuit, lightpurple"
	path = /obj/item/clothing/under/color/lightpurple

/datum/gear/uniform/suit/jumpsuitlightgreen
	display_name = "Jumpsuit, lightgreen"
	path = /obj/item/clothing/under/color/lightgreen

/datum/gear/uniform/suit/jumpsuitlightbrown
	display_name = "Jumpsuit, lightbrown"
	path = /obj/item/clothing/under/color/lightbrown

/datum/gear/uniform/suit/jumpsuitbrown
	display_name = "Jumpsuit, brown"
	path = /obj/item/clothing/under/color/brown

/datum/gear/uniform/suit/jumpsuityellowgreen
	display_name = "Jumpsuit, yellowgreen"
	path = /obj/item/clothing/under/color/yellowgreen

/datum/gear/uniform/suit/jumpsuitdarkblue
	display_name = "Jumpsuit, darkblue"
	path = /obj/item/clothing/under/color/darkblue

/datum/gear/uniform/suit/jumpsuitlightred
	display_name = "Jumpsuit, lightred"
	path = /obj/item/clothing/under/color/lightred

/datum/gear/uniform/suit/jumpsuitdarkred
	display_name = "Jumpsuit, darkred"
	path = /obj/item/clothing/under/color/darkred

/datum/gear/uniform/suit/jumpskirtblack
	display_name = "Jumpskirt, black"
	path = /obj/item/clothing/under/color/jumpskirt/black

/datum/gear/uniform/suit/jumpskirtblue
	display_name = "Jumpskirt, blue"
	path = /obj/item/clothing/under/color/jumpskirt/blue

/datum/gear/uniform/suit/jumpskirtgreen
	display_name = "Jumpskirt, green"
	path = /obj/item/clothing/under/color/jumpskirt/green

/datum/gear/uniform/suit/jumpskirtgrey
	display_name = "Jumpskirt, grey"
	path = /obj/item/clothing/under/color/jumpskirt/grey

/datum/gear/uniform/suit/jumpskirtorange
	display_name = "Jumpskirt, orange"
	path = /obj/item/clothing/under/color/jumpskirt/orange

/datum/gear/uniform/suit/jumpskirtpink
	display_name = "Jumpskirt, pink"
	path = /obj/item/clothing/under/color/jumpskirt/pink

/datum/gear/uniform/suit/jumpskirtred
	display_name = "Jumpskirt, red"
	path = /obj/item/clothing/under/color/jumpskirt/red

/datum/gear/uniform/suit/jumpskirtwhite
	display_name = "Jumpskirt, white"
	path = /obj/item/clothing/under/color/jumpskirt/white

/datum/gear/uniform/suit/jumpskirtyellow
	display_name = "Jumpskirt, yellow"
	path = /obj/item/clothing/under/color/jumpskirt/yellow

/datum/gear/uniform/suit/jumpskirtlightblue
	display_name = "Jumpskirt, lightblue"
	path = /obj/item/clothing/under/color/jumpskirt/lightblue

/datum/gear/uniform/suit/jumpskirtaqua
	display_name = "Jumpskirt, aqua"
	path = /obj/item/clothing/under/color/jumpskirt/aqua

/datum/gear/uniform/suit/jumpskirtpurple
	display_name = "Jumpskirt, purple"
	path = /obj/item/clothing/under/color/jumpskirt/purple

/datum/gear/uniform/suit/jumpskirtlightpurple
	display_name = "Jumpskirt, lightpurple"
	path = /obj/item/clothing/under/color/jumpskirt/lightpurple

/datum/gear/uniform/suit/jumpskirtlightgreen
	display_name = "Jumpskirt, lightgreen"
	path = /obj/item/clothing/under/color/jumpskirt/lightgreen

/datum/gear/uniform/suit/jumpskirtlightbrown
	display_name = "Jumpskirt, lightbrown"
	path = /obj/item/clothing/under/color/jumpskirt/lightbrown

/datum/gear/uniform/suit/jumpskirtbrown
	display_name = "Jumpskirt, brown"
	path = /obj/item/clothing/under/color/jumpskirt/brown

/datum/gear/uniform/suit/jumpskirtyellowgreen
	display_name = "Jumpskirt, yellowgreen"
	path = /obj/item/clothing/under/color/jumpskirt/yellowgreen

/datum/gear/uniform/suit/jumpskirtdarkblue
	display_name = "Jumpskirt, darkblue"
	path = /obj/item/clothing/under/color/jumpskirt/darkblue

/datum/gear/uniform/suit/jumpskirtlightred
	display_name = "Jumpskirt, lightred"
	path = /obj/item/clothing/under/color/jumpskirt/lightred

/datum/gear/uniform/suit/jumpskirtdarkred
	display_name = "Jumpskirt, darkred"
	path = /obj/item/clothing/under/color/jumpskirt/darkred

/datum/gear/uniform/suit/soviet
	display_name = "Old USSP uniform"
	path = /obj/item/clothing/under/costume/soviet

/datum/gear/uniform/suit/kilt
	display_name = "Kilt"
	path = /obj/item/clothing/under/costume/kilt

/datum/gear/uniform/suit/executive
	display_name = "Executive Suit"
	path = /obj/item/clothing/under/suit/really_black

/datum/gear/uniform/suit/navyblue
	display_name = "Navy Suit"
	path = /obj/item/clothing/under/suit/navy

/datum/gear/uniform/suit/checkered
	display_name = "Checkered Suit"
	path = /obj/item/clothing/under/suit/checkered

/datum/gear/uniform/skirt
	main_typepath = /datum/gear/uniform/skirt

/datum/gear/uniform/skirt/blue
	display_name = "Plaid skirt, blue"
	path = /obj/item/clothing/under/dress/plaid_blue

/datum/gear/uniform/skirt/purple
	display_name = "Plaid skirt, purple"
	path = /obj/item/clothing/under/dress/plaid_purple

/datum/gear/uniform/skirt/red
	display_name = "Plaid skirt, red"
	path = /obj/item/clothing/under/dress/plaid_red

/datum/gear/uniform/skirt/black
	display_name = "Skirt, black"
	path = /obj/item/clothing/under/dress/blackskirt

/datum/gear/uniform/skirt/blue_tango
	display_name = "blue tango dress"
	path = /obj/item/clothing/under/dress/blacktango/blue

/datum/gear/uniform/skirt/job
	main_typepath = /datum/gear/uniform/skirt/job
	subtype_selection_cost = FALSE

//Engineering

/datum/gear/uniform/eng
	main_typepath = /datum/gear/uniform/eng

/datum/gear/uniform/eng/eng_alt
	display_name = "Uniform, engineering corporate"
	path = /obj/item/clothing/under/rank/engineering/engineer/corporate
	allowed_roles = list("Chief Engineer", "Station Engineer")

/datum/gear/uniform/eng/atmos_alt
	display_name = "Uniform, atmos corporate"
	path = /obj/item/clothing/under/rank/engineering/atmospheric_technician/corporate
	allowed_roles = list("Chief Engineer", "Life Support Specialist")


/datum/gear/uniform/skirt/job/atmos
	display_name = "Skirt, atmos"
	path = /obj/item/clothing/under/rank/engineering/atmospheric_technician/skirt
	allowed_roles = list("Chief Engineer","Life Support Specialist")

/datum/gear/uniform/skirt/job/eng
	display_name = "Skirt, engineer"
	path = /obj/item/clothing/under/rank/engineering/engineer/skirt
	allowed_roles = list("Chief Engineer","Station Engineer")

/datum/gear/uniform/skirt/job/ce
	display_name = "Skirt, ce"
	path = /obj/item/clothing/under/rank/engineering/chief_engineer/skirt
	allowed_roles = list("Chief Engineer")

/datum/gear/uniform/turtleneck/job/ce
	display_name = "Turtleneck, ce"
	path = /obj/item/clothing/under/rank/engineering/chief_engineer/turtleneck
	allowed_roles = list("Chief Engineer")

//Research
/datum/gear/uniform/skirt/job/sci
	display_name = "Skirt, scientist"
	path = /obj/item/clothing/under/rank/rnd/scientist/skirt
	allowed_roles = list("Research Director","Scientist")

/datum/gear/uniform/skirt/job/roboticist
	display_name = "Skirt, roboticist"
	path = /obj/item/clothing/under/rank/rnd/roboticist/skirt
	allowed_roles = list("Research Director","Roboticist")

/datum/gear/uniform/skirt/job/rd
	display_name = "Skirt, rd"
	path = /obj/item/clothing/under/rank/rnd/rd/skirt
	allowed_roles = list("Research Director")

/datum/gear/uniform/turtleneck/job/rd
	display_name = "Turtleneck, rd"
	path = /obj/item/clothing/under/rank/rnd/rd/turtleneck
	allowed_roles = list("Research Director")


//Medical
/datum/gear/uniform/skirt/job/chem
	display_name = "Skirt, chemist"
	path = /obj/item/clothing/under/rank/medical/chemist/skirt
	allowed_roles = list("Chief Medical Officer","Chemist")

/datum/gear/uniform/skirt/job/viro
	display_name = "Skirt, virologist"
	path = /obj/item/clothing/under/rank/medical/virologist/skirt
	allowed_roles = list("Virologist")

/datum/gear/uniform/skirt/job/para
	display_name = "Skirt, paramedic"
	path = /obj/item/clothing/under/rank/medical/paramedic/skirt
	allowed_roles = list("Chief Medical Officer", "Paramedic")

/datum/gear/uniform/skirt/job/med
	display_name = "Skirt, medical"
	path = /obj/item/clothing/under/rank/medical/doctor/skirt
	allowed_roles = list("Chief Medical Officer","Medical Doctor","Psychiatrist","Paramedic","Coroner")

/datum/gear/uniform/skirt/job/cmo
	display_name = "Skirt, cmo"
	path = /obj/item/clothing/under/rank/medical/cmo/skirt
	allowed_roles = list("Chief Medical Officer")

/datum/gear/uniform/turtleneck/job/cmo
	display_name = "Skirt, cmo"
	path = /obj/item/clothing/under/rank/medical/cmo/turtleneck
	allowed_roles = list("Chief Medical Officer")

//Supply
/datum/gear/uniform/skirt/job/cargo
	display_name = "Skirt, cargo"
	path = /obj/item/clothing/under/rank/cargo/tech/skirt
	allowed_roles = list("Quartermaster","Cargo Technician")

/datum/gear/uniform/skirt/job/expedition
	display_name = "Skirt, expedition"
	path = /obj/item/clothing/under/rank/cargo/expedition/skirt
	allowed_roles = list("Quartermaster", "Explorer")

/datum/gear/uniform/skirt/job/smith
	display_name = "Skirt, smith"
	path = /obj/item/clothing/under/rank/cargo/smith/skirt
	allowed_roles = list("Quartermaster", "Smith")

/datum/gear/uniform/skirt/job/qm
	display_name = "Skirt, quartermaster"
	path = /obj/item/clothing/under/rank/cargo/qm/skirt
	allowed_roles = list("Quartermaster")

/datum/gear/uniform/turtleneck/job/qm
	display_name = "Turtleneck, quartermaster"
	path = /obj/item/clothing/under/rank/cargo/qm/turtleneck
	allowed_roles = list("Quartermaster")

//Security
/datum/gear/uniform/skirt/job/warden
	display_name = "Skirt, warden"
	path = /obj/item/clothing/under/rank/security/warden/skirt
	allowed_roles = list("Head of Security", "Warden")

/datum/gear/uniform/turtleneck/job/warden
	display_name = "Turtleneck, warden"
	path = /obj/item/clothing/under/rank/security/warden/turtleneck
	allowed_roles = list("Warden")

/datum/gear/uniform/skirt/job/security
	display_name = "Skirt, security"
	path = /obj/item/clothing/under/rank/security/officer/skirt
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer")

/datum/gear/uniform/skirt/job/head_of_security
	display_name = "Skirt, hos"
	path = /obj/item/clothing/under/rank/security/head_of_security/skirt
	allowed_roles = list("Head of Security")

/datum/gear/uniform/turtleneck/job/head_of_security
	display_name = "Turtleneck, hos"
	path = /obj/item/clothing/under/rank/security/head_of_security/turtleneck
	allowed_roles = list("Head of Security")

//Service

/datum/gear/uniform/suit/job/hydroponics_alt
	display_name = "Jumpsuit, hydroponics brown"
	path = /obj/item/clothing/under/rank/civilian/hydroponics/alt
	allowed_roles = list("Botanist")

/datum/gear/uniform/skirt/job/clown
	display_name = "Skirt, clown"
	path = /obj/item/clothing/under/rank/civilian/clown/skirt
	allowed_roles = list("Clown")

/datum/gear/uniform/skirt/job/mime
	display_name = "Skirt, mime"
	path = /obj/item/clothing/under/rank/civilian/mime/skirt
	allowed_roles = list("Mime")

/datum/gear/uniform/skirt/job/janitor
	display_name = "Skirt, janitor"
	path = /obj/item/clothing/under/rank/civilian/janitor/skirt
	allowed_roles = list("Janitor")

/datum/gear/uniform/skirt/job/head_of_personnel
	display_name = "Skirt, hop"
	path = /obj/item/clothing/under/rank/civilian/hop/skirt
	allowed_roles = list("Head of Personnel")

/datum/gear/uniform/turtleneck/job/head_of_personnel
	display_name = "Turtleneck, hop"
	path = /obj/item/clothing/under/rank/civilian/hop/turtleneck
	allowed_roles = list("Head of Personnel")

/datum/gear/uniform/suit/job/chaplain/
	display_name = "Chaplain, black"
	path = /obj/item/clothing/under/rank/civilian/chaplain
	allowed_roles = list("Chaplain")

/datum/gear/uniform/suit/job/chaplain/white
	display_name = "Chaplain, white"
	path = /obj/item/clothing/under/rank/civilian/chaplain/white
	allowed_roles = list("Chaplain")

/datum/gear/uniform/suit/job/chaplain/bw
	display_name = "Chaplain, black and white"
	path = /obj/item/clothing/under/rank/civilian/chaplain/bw
	allowed_roles = list("Chaplain")

/datum/gear/uniform/suit/job/chaplain/orange
	display_name = "Chaplain, kasaya"
	path = /obj/item/clothing/under/rank/civilian/chaplain/orange
	allowed_roles = list("Chaplain")

/datum/gear/uniform/suit/job/chaplain/green
	display_name = "Chaplain, modest"
	path = /obj/item/clothing/under/rank/civilian/chaplain/green
	allowed_roles = list("Chaplain")

/datum/gear/uniform/suit/job/chaplain/thobe
	display_name = "Chaplain, thobe"
	path = /obj/item/clothing/under/rank/civilian/chaplain/thobe
	allowed_roles = list("Chaplain")

//Command and dignitary
/datum/gear/uniform/skirt/captain
	display_name = "Skirt, captain"
	path = /obj/item/clothing/under/rank/captain/skirt
	allowed_roles = list("Captain")

/datum/gear/uniform/skirt/job/magistrate
	display_name = "Skirt, magistrate"
	path = /obj/item/clothing/under/rank/procedure/magistrate/skirt
	allowed_roles = list("Magistrate")

/datum/gear/uniform/skirt/job/ntrep
	display_name = "Skirt, nt rep"
	path = /obj/item/clothing/under/rank/procedure/representative/skirt
	allowed_roles = list("Nanotrasen Representative")

/datum/gear/uniform/skirt/job/blueshield
	display_name = "Skirt, blueshield"
	path = /obj/item/clothing/under/rank/procedure/blueshield/skirt
	allowed_roles = list("Blueshield")

/datum/gear/uniform/turtleneck/job/blueshield
	display_name = "Turtleneck, blueshield"
	path = /obj/item/clothing/under/rank/procedure/blueshield/turtleneck
	allowed_roles = list("Blueshield")

/datum/gear/uniform/medical
	main_typepath = /datum/gear/uniform/medical

/datum/gear/uniform/medical/pscrubs
	display_name = "Medical scrubs, purple"
	path = /obj/item/clothing/under/rank/medical/scrubs/purple
	allowed_roles = list("Chief Medical Officer", "Medical Doctor")

/datum/gear/uniform/medical/gscrubs
	display_name = "Medical scrubs, green"
	path = /obj/item/clothing/under/rank/medical/scrubs/green
	allowed_roles = list("Chief Medical Officer", "Medical Doctor")

/datum/gear/uniform/cargo
	main_typepath = /datum/gear/uniform/cargo

/datum/gear/uniform/cargo/delivery
	display_name = "Cargo uniform, delivery"
	path = /obj/item/clothing/under/rank/cargo/tech/delivery
	allowed_roles = list("Quartermaster", "Cargo Technician")

/datum/gear/uniform/overalls
	main_typepath = /datum/gear/uniform/overalls

/datum/gear/uniform/overalls/job
	main_typepath = /datum/gear/uniform/overalls/job
	subtype_selection_cost = FALSE

/datum/gear/uniform/overalls/job/janitor
	display_name = "Overalls, janitor"
	path = /obj/item/clothing/under/rank/civilian/janitor/overalls
	allowed_roles = list("Janitor")

/datum/gear/uniform/overalls/job/cargo
	display_name = "Overalls, cargo tech"
	path = /obj/item/clothing/under/rank/cargo/tech/overalls
	allowed_roles = list("Quartermaster", "Cargo Technician")

/datum/gear/uniform/overalls/job/expedition
	display_name = "Overalls, expedition"
	path = /obj/item/clothing/under/rank/cargo/expedition/overalls
	allowed_roles = list("Quartermaster", "Explorer")

/datum/gear/uniform/overalls/job/atmos
	display_name = "Overalls, atmos"
	path = /obj/item/clothing/under/rank/engineering/atmospheric_technician/overalls
	allowed_roles = list("Chief Engineer", "Life Support Specialist")

/datum/gear/uniform/overalls/job/eng
	display_name = "Overalls, engineer"
	path = /obj/item/clothing/under/rank/engineering/engineer/overalls
	allowed_roles = list("Chief Engineer", "Station Engineer")

/datum/gear/uniform/sec
	main_typepath = /datum/gear/uniform/sec

/datum/gear/uniform/sec/formal
	display_name = "Security uniform, formal"
	path = /obj/item/clothing/under/rank/security/formal
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer")

/datum/gear/uniform/sec/secorporate
	display_name = "Security uniform, corporate"
	path = /obj/item/clothing/under/rank/security/officer/corporate
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer")

/datum/gear/uniform/sec/dispatch
	display_name = "Security uniform, dispatch"
	path = /obj/item/clothing/under/rank/security/officer/dispatch
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer")

/datum/gear/uniform/sec/casual
	display_name = "Security uniform, casual"
	path = /obj/item/clothing/under/rank/security/officer/uniform
	allowed_roles = list("Head of Security", "Warden", "Security Officer", "Detective")

/datum/gear/uniform/shorts
	main_typepath = /datum/gear/uniform/shorts

/datum/gear/uniform/shorts/red
	display_name = "Shorts, red"
	path = /obj/item/clothing/under/pants/shorts/red

/datum/gear/uniform/shorts/green
	display_name = "Shorts, green"
	path = /obj/item/clothing/under/pants/shorts/green

/datum/gear/uniform/shorts/blue
	display_name = "Shorts, blue"
	path = /obj/item/clothing/under/pants/shorts/blue

/datum/gear/uniform/shorts/black
	display_name = "Shorts, black"
	path = /obj/item/clothing/under/pants/shorts/black

/datum/gear/uniform/shorts/grey
	display_name = "Shorts, grey"
	path = /obj/item/clothing/under/pants/shorts/grey

/datum/gear/uniform/pants
	main_typepath = /datum/gear/uniform/pants

/datum/gear/uniform/pants/jeans
	display_name = "Jeans, classic"
	path = /obj/item/clothing/under/pants/classicjeans

/datum/gear/uniform/pants/mjeans
	display_name = "Jeans, mustang"
	path = /obj/item/clothing/under/pants/mustangjeans

/datum/gear/uniform/pants/bljeans
	display_name = "Jeans, black"
	path = /obj/item/clothing/under/pants/blackjeans

/datum/gear/uniform/pants/yfjeans
	display_name = "Jeans, Young Folks"
	path = /obj/item/clothing/under/pants/youngfolksjeans

/datum/gear/uniform/pants/whitepants
	display_name = "Pants, white"
	path = /obj/item/clothing/under/pants/white

/datum/gear/uniform/pants/redpants
	display_name = "Pants, red"
	path = /obj/item/clothing/under/pants/red

/datum/gear/uniform/pants/blackpants
	display_name = "Pants, black"
	path = /obj/item/clothing/under/pants/black

/datum/gear/uniform/pants/tanpants
	display_name = "Pants, tan"
	path = /obj/item/clothing/under/pants/tan

/datum/gear/uniform/pants/bluepants
	display_name = "Pants, blue"
	path = /obj/item/clothing/under/pants/blue

/datum/gear/uniform/pants/trackpants
	display_name = "Trackpants"
	path = /obj/item/clothing/under/pants/track

/datum/gear/uniform/pants/khakipants
	display_name = "Pants, khaki"
	path = /obj/item/clothing/under/pants/khaki

/datum/gear/uniform/pants/caopants
	display_name = "Pants, camo"
	path = /obj/item/clothing/under/pants/camo

/datum/gear/uniform/suit/tacticool
	display_name = "Tacticool turtleneck"
	description = "A sleek black turtleneck paired with some khakis (WARNING DOES NOT HAVE SUIT SENSORS)"
	path = /obj/item/clothing/under/syndicate/tacticool

/datum/gear/uniform/suit/greyman
	display_name = "Greyman Henley"
	description = "Khaki henley paired up with some grey cargo pants (WARNING DOES NOT HAVE SUIT SENSORS)"
	path = /obj/item/clothing/under/syndicate/greyman

/datum/gear/uniform/suit/assistantformal
	display_name = "Assistant's Formal Uniform"
	description = "Formal attire fit for an Assistant."
	path = /obj/item/clothing/under/misc/assistantformal

/datum/gear/uniform/suit/redhawaiianshirt
	display_name = "Red Hawaiian T-Shirt"
	description = "A nice t-shirt to remind about warm beaches. This one is red."
	path = /obj/item/clothing/under/misc/redhawaiianshirt

/datum/gear/uniform/suit/bluehawaiianshirt
	display_name = "Blue Hawaiian T-Shirt"
	description = "A nice t-shirt to remind about warm beaches. This one is blue."
	path = /obj/item/clothing/under/misc/bluehawaiianshirt

/datum/gear/uniform/suit/pinkhawaiianshirt
	display_name = "Pink Hawaiian T-Shirt"
	description = "A nice t-shirt to remind about warm beaches. This one is pink."
	path = /obj/item/clothing/under/misc/pinkhawaiianshirt

/datum/gear/uniform/suit/orangehawaiianshirt
	display_name = "Orange Hawaiian T-Shirt"
	description = "A nice t-shirt to remind about warm beaches. This one is orange."
	path = /obj/item/clothing/under/misc/orangehawaiianshirt
