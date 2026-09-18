
#define DEPARTMENT_ENGINEERING	"Engineering"
#define DEPARTMENT_MEDICAL		"Medical"
#define DEPARTMENT_SCIENCE		"Science"
#define DEPARTMENT_SUPPLY		"Supply"
#define DEPARTMENT_SERVICE		"Service"
#define DEPARTMENT_SECURITY		"Security"
#define DEPARTMENT_ASSISTANT	"Assistant" // Does not have a corresponding bitflag
#define DEPARTMENT_SILICON		"Silicon" // Does not have a corresponding bitflag
#define DEPARTMENT_COMMAND		"Command"

#define DEP_FLAG_SUPPLY			(1<<0)
#define DEP_FLAG_SERVICE		(1<<1)
#define DEP_FLAG_COMMAND		(1<<2)
#define DEP_FLAG_LEGAL			(1<<3)
#define DEP_FLAG_ENGINEERING	(1<<4)
#define DEP_FLAG_MEDICAL		(1<<5)
#define DEP_FLAG_SCIENCE		(1<<6)
#define DEP_FLAG_SECURITY		(1<<7)


// ---- Unused, but here is an easy way to transfer from the department string,
// 		to the corresponding bitflag if it has one.

// GLOBAL_LIST_INIT(department_str_to_flag, list(
// 	DEPARTMENT_ENGINEERING = DEP_FLAG_ENGINEERING,
// 	DEPARTMENT_MEDICAL = DEP_FLAG_MEDICAL,
// 	DEPARTMENT_SCIENCE = DEP_FLAG_SCIENCE,
// 	DEPARTMENT_SUPPLY = DEP_FLAG_SUPPLY,
// 	DEPARTMENT_SERVICE = DEP_FLAG_SERVICE,
// 	DEPARTMENT_SECURITY = DEP_FLAG_SECURITY,
// 	DEPARTMENT_COMMAND = DEP_FLAG_COMMAND
// 	)
// )

#define DEP_MAIL_LIST_SECURITY list("Head of Security", "Security Officer", "Detective", "Warden")
#define DEP_MAIL_LIST_SCIENCE list("Research Director", "Roboticist", "Geneticist", "Scientist")
#define DEP_MAIL_LIST_SUPPLY list("Quartermaster", "Cargo Technician", "Shaft Miner", "Explorer")
#define DEP_MAIL_LIST_MEDICAL list("Chief Medical Officer", "Medical Doctor", "Coroner", "Chemist", "Virologist", "Psychiatrist", "Paramedic")
#define DEP_MAIL_LIST_ENGINEERING list("Chief Engineer", "Station Engineer", "Life Support Specialist")
#define DEP_MAIL_LIST_BREAD list("Bartender", "Chef", "Botanist", "Janitor", "Librarian")
#define DEP_MAIL_LIST_SERVICE list("Clown", "Mime", "Head of Personnel", "Chaplain")
#define DEP_MAIL_LIST_COMMAND list("Captain", "Magistrate", "Nanotrasen Representative", "Blueshield", "Internal Affairs Agent", "Nanotrasen Career Trainer")
#define DEP_MAIL_LIST_MISC list("Assistant")

GLOBAL_LIST_INIT(mail_crate_possible_contents, list(
	/obj/item/envelope/security = DEP_MAIL_LIST_SECURITY,
	/obj/item/envelope/science = DEP_MAIL_LIST_SCIENCE,
	/obj/item/envelope/supply = DEP_MAIL_LIST_SUPPLY,
	/obj/item/envelope/medical = DEP_MAIL_LIST_MEDICAL,
	/obj/item/envelope/engineering = DEP_MAIL_LIST_ENGINEERING,
	/obj/item/envelope/bread = DEP_MAIL_LIST_BREAD,
	/obj/item/envelope/circuses = DEP_MAIL_LIST_SERVICE,
	/obj/item/envelope/command = DEP_MAIL_LIST_COMMAND,
	/obj/item/envelope/misc = DEP_MAIL_LIST_MISC,
))
