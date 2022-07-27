#define ABDUCTOR_MAX_TEAMS 4

/datum/antagonist/abductor
	name = "\improper Abductor"
	roundend_category = "abductors"
	job_rank = ROLE_ABDUCTOR
	special_role = SPECIAL_ROLE_ABDUCTOR
	antag_hud_name = "abductor"
	antag_hud_type = ANTAG_HUD_ABDUCTOR
	wiki_page_name = "Abductor"
	var/datum/team/abductor_team/team
	var/sub_role
	var/outfit
	var/landmark_type
	var/greet_text
	/// Type path for the associated job datum.
	//var/role_job = /datum/job/abductor_agent
