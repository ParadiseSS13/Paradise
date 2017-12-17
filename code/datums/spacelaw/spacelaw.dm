datum/spacelaw/
	var/name = "Law"
	var/max_fine = 0
	var/max_brig = 0
	var/reason = ""
	var/maxM_brig = 1
	var/desc = "Description"
	var/list/listofcrimes = list()

datum/spacelaw/minor
	max_fine = 1000
	max_brig = 5
	listofcrimes = list(
	"101 Resisting Arrest",
	"102 Battery",
	"103 Drug Possession",
	"106 Indecent Exposure",
	"107 Vandalism",
	"109 Tresspass"
	)

datum/spacelaw/medium
	max_fine = 2000
	max_brig = 10
	listofcrimes = list(
	"201 Assault",
	"202 Robbery",
	"203 Narcotics Possession",
	"204 Possession of a Weapon",
	"205 Kidnapping",
	"206 Rioting",
	"207 Creating a Workplace Hazard",
	"208 Petty Theft",
	"210 Breaking and Entry",
	"211 Abuse of Confiscated Equipment"
	)

datum/spacelaw/major
	max_fine = 3000
	max_brig = 15
	listofcrimes = list(
	"300 Possession of Contraband",
	"301 Kidnapping of an Officer",
	"302 Assault of an Officer",
	"303 Aggrevated Assault",
	"304 Possession of a Restricted Weapon",
	"305 Possession of Explosives",
	"306 Inciting a Riot",
	"307 Sabotage",
	"308 Theft",
	"309 Major Tresspass",
	"310 Breaking and Entry restricted area"
	)