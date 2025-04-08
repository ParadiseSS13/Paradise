#define SHELLEO_ERRORLEVEL 1
#define SHELLEO_STDOUT 2
#define SHELLEO_STDERR 3

#define SHELLEO_NAME "data/shelleo."
#define SHELLEO_ERR ".err"
#define SHELLEO_OUT ".out"

/world/proc/shelleo(command)
	var/static/list/shelleo_ids = list()
	var/stdout = ""
	var/stderr = ""
	var/errorcode = 1
	var/shelleo_id
	var/out_file = ""
	var/err_file = ""
	var/static/list/interpreters = list("[MS_WINDOWS]" = "cmd /c", "[UNIX]" = "sh -c")
	var/interpreter = interpreters["[world.system_type]"]
	if(interpreter)
		for(var/seo_id in shelleo_ids)
			if(!shelleo_ids[seo_id])
				shelleo_ids[seo_id] = TRUE
				shelleo_id = "[seo_id]"
				break
		if(!shelleo_id)
			shelleo_id = "[shelleo_ids.len + 1]"
			shelleo_ids += shelleo_id
			shelleo_ids[shelleo_id] = TRUE
		out_file = "[SHELLEO_NAME][shelleo_id][SHELLEO_OUT]"
		err_file = "[SHELLEO_NAME][shelleo_id][SHELLEO_ERR]"
		if(world.system_type == UNIX)
			errorcode = shell("[interpreter] \"[replacetext(command, "\"", "\\\"")]\" > [out_file] 2> [err_file]")
		else
			errorcode = shell("[interpreter] \"[command]\" > [out_file] 2> [err_file]")
		if(fexists(out_file))
			stdout = file2text(out_file)
			fdel(out_file)
		if(fexists(err_file))
			stderr = file2text(err_file)
			fdel(err_file)
		shelleo_ids[shelleo_id] = FALSE
	else
		CRASH("Operating System: [world.system_type] not supported") // If you encounter this error, you are encouraged to update this proc with support for the new operating system
	. = list(errorcode, stdout, stderr)

/proc/shell_url_scrub(url)
	var/static/regex/bad_chars_regex = regex("\[^#%&./:=?\\w]*", "g")
	var/scrubbed_url = ""
	var/bad_match = ""
	var/last_good = 1
	var/bad_chars = 1
	do
		bad_chars = bad_chars_regex.Find(url)
		scrubbed_url += copytext(url, last_good, bad_chars)
		if(bad_chars)
			bad_match = url_encode(bad_chars_regex.match)
			scrubbed_url += bad_match
			last_good = bad_chars + length(bad_chars_regex.match)
	while(bad_chars)
	. = scrubbed_url



/proc/apply_sound_effect(effect, filename_input, filename_output)
	if(!effect)
		CRASH("Invalid sound effect chosen.")

	var/taskset
	if(GLOB.configuration.tts.ffmpeg_cpuaffinity)
		taskset = "taskset -ac [GLOB.configuration.tts.ffmpeg_cpuaffinity]"

	var/list/output
	switch(effect)
		if(SOUND_EFFECT_RADIO)
			output = world.shelleo({"[taskset] ffmpeg -y -hide_banner -loglevel error -i [filename_input] -filter:a "highpass=f=1000, lowpass=f=3000, acrusher=1:1:50:0:log" [filename_output]"})
		if(SOUND_EFFECT_ROBOT)
			output = world.shelleo({"[taskset] ffmpeg -y -hide_banner -loglevel error -i [filename_input] -filter:a "afftfilt=real='hypot(re,im)*sin(0)':imag='hypot(re,im)*cos(0)':win_size=1024:overlap=0.5, deesser=i=0.4, volume=volume=1.5" [filename_output]"})
		if(SOUND_EFFECT_RADIO_ROBOT)
			output = world.shelleo({"[taskset] ffmpeg -y -hide_banner -loglevel error -i [filename_input] -filter:a "afftfilt=real='hypot(re,im)*sin(0)':imag='hypot(re,im)*cos(0)':win_size=1024:overlap=0.5, deesser=i=0.4, volume=volume=1.5, highpass=f=1000, lowpass=f=3000, acrusher=1:1:50:0:log" [filename_output]"})
		if(SOUND_EFFECT_MEGAPHONE)
			output = world.shelleo({"[taskset] ffmpeg -y -hide_banner -loglevel error -i [filename_input] -filter:a "highpass=f=500, lowpass=f=4000, volume=volume=10, acrusher=1:1:45:0:log" [filename_output]"})
		if(SOUND_EFFECT_MEGAPHONE_ROBOT)
			output = world.shelleo({"[taskset] ffmpeg -y -hide_banner -loglevel error -i [filename_input] -filter:a "afftfilt=real='hypot(re,im)*sin(0)':imag='hypot(re,im)*cos(0)':win_size=1024:overlap=0.5, deesser=i=0.4, highpass=f=500, lowpass=f=4000, volume=volume=10, acrusher=1:1:45:0:log" [filename_output]"})
		else
			CRASH("Invalid sound effect chosen.")
	var/errorlevel = output[SHELLEO_ERRORLEVEL]
	var/stdout = output[SHELLEO_STDOUT]
	var/stderr = output[SHELLEO_STDERR]
	if(errorlevel)
		error("Error: apply_sound_effect([effect], [filename_input], [filename_output]) - See debug logs.")
		log_debug("apply_sound_effect([effect], [filename_input], [filename_output]) STDOUT: [stdout]")
		log_debug("apply_sound_effect([effect], [filename_input], [filename_output]) STDERR: [stderr]")
		return FALSE
	return TRUE

#undef SHELLEO_ERRORLEVEL
#undef SHELLEO_STDOUT
#undef SHELLEO_STDERR

#undef SHELLEO_NAME
#undef SHELLEO_ERR
#undef SHELLEO_OUT
