
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
