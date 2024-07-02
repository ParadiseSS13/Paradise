/// Config holder for values relating to mob movement speeds
/datum/configuration_section/movement_configuration
	/// Base run speed before modifiers
	var/base_run_speed = 1
	/// Base walk speed before modifiers
	var/base_walk_speed = 4
	///crawling speed modifier
	var/crawling_speed_reduction = 4
	/// Move delay for humanoids
	var/human_delay = 1.5
	/// Move delay for cyborgs
	var/robot_delay = 1.5
	/// Move delay for xenomorphs
	var/alien_delay = 1.5
	/// Move delay for slimes (xenobio, not slimepeople)
	var/slime_delay = 1.5
	/// Move delay for other simple animals
	var/animal_delay = 2.5

/datum/configuration_section/movement_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_NUM(base_run_speed, data["base_run_speed"])
	CONFIG_LOAD_NUM(base_walk_speed, data["base_walk_speed"])
	CONFIG_LOAD_NUM(crawling_speed_reduction, data["crawling_speed_reduction"])
	CONFIG_LOAD_NUM(human_delay, data["human_delay"])
	CONFIG_LOAD_NUM(robot_delay, data["robot_delay"])
	CONFIG_LOAD_NUM(alien_delay, data["alien_delay"])
	CONFIG_LOAD_NUM(slime_delay, data["slime_delay"])
	CONFIG_LOAD_NUM(animal_delay, data["animal_delay"])
