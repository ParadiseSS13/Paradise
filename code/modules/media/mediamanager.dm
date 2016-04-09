/**********************
 * AWW SHIT IT'S TIME FOR RADIO
 *
 * Concept stolen from D2K5
 *
 * Rewritten (except for player HTML) by N3X15
 ***********************/

// Open up VLC and play musique.
// Converted to VLC for cross-platform and ogg support. - N3X
var/const/PLAYER_HTML={"
<embed type="application/x-vlc-plugin" pluginspage="http://www.videolan.org" />
<object classid="clsid:9BE31822-FDAD-461B-AD51-BE1D1C159921" codebase="http://download.videolan.org/pub/videolan/vlc/last/win32/axvlc.cab" version="VideoLAN.VLCPlugin.2" id="player"></object>
	<script>
var _volume = 50;
var vlc = document.getElementById('player');

function noErrorMessages () { return true; }
window.onerror = noErrorMessages;

function SetMusic(url, time, volume) {
	// scaling volume log-wise so that it's a more useful range
	_volume = Math.log(volume) / Math.LN10 * 50; // volume ranges from 0-200
	
	// Stop playing
	vlc.playlist.stop();

	// Clear playlist
	vlc.playlist.items.clear();

	// Add new playlist item.
	var id = vlc.playlist.add(url);

	// Play playlist item
	vlc.playlist.playItem(id);

	vlc.input.time = time*1000; // VLC takes milliseconds.
}

function UpdateVolume() {
	vlc.audio.volume = _volume;
}

// volume must be set after song already playing
if(vlc.attachEvent) {
	vlc.attachEvent("MediaPlayerBuffering", UpdateVolume);
} else {
	vlc.addEventListener("MediaPlayerBuffering", UpdateVolume, false);
}
	</script>
"}

// Hook into the events we desire.
/hook_handler/soundmanager
	// Set up player on login
	proc/OnLogin(var/list/args)
		//testing("Received OnLogin.")
		var/client/C = args["client"]
		C.media = new /datum/media_manager(args["mob"])
		C.media.open()
		spawn(20)
			C.media.update_music()

	// Update when moving between areas.
	proc/OnMobAreaChange(var/list/args)
		var/mob/M = args["mob"]
		//if(istype(M, /mob/living/carbon/human)||istype(M, /mob/dead/observer))
		//	testing("Received OnMobAreaChange for [M.type] [M] (M.client=[M.client==null?"null":"/client"]).")
		if(M.client)
			M.update_music()

/mob/proc/update_music()
	if (client && client.media)
		client.media.update_music()
	//else
	//	testing("[src] - client: [client?"Y":"N"]; client.media: [client && client.media ? "Y":"N"]")

/area
	// One media source per area.
	var/obj/machinery/media/media_source = null


#ifdef DEBUG_MEDIAPLAYER
to_chat(#define MP_DEBUG(x) owner, x)
#warning Please comment out #define DEBUG_MEDIAPLAYER before committing.
#else
#define MP_DEBUG(x)
#endif


/datum/media_manager
	var/url = ""
	var/start_time = 0

	var/client/owner
	var/mob/mob

	var/const/window = "rpane.hosttracker"
	//var/const/window = "mediaplayer" // For debugging.

	New(var/mob/holder)
		src.mob=holder
		owner=src.mob.client

	// Actually pop open the player in the background.
	proc/open()
		owner << browse(PLAYER_HTML, "window=[window]")
		send_update()

	// Tell the player to play something via JS.
	proc/send_update()
		if(!(owner.prefs.sound & SOUND_STREAMING) && url != "")
			return // Nope.
		MP_DEBUG("\green Sending update to WMP ([url])...")
		owner << output(list2params(list(url, (world.time - start_time) / 10, get_volume())), "[window]:SetMusic")

	proc/stop_music()
		url=""
		start_time=world.time
		send_update()

	// Scan for media sources and use them.
	proc/update_music()
		var/targetURL = ""
		var/targetStartTime = 0

		if (!owner)
			//testing("owner is null")
			return

		var/area/A = get_area_master(mob)
		if(!A)
			//testing("[owner] in [mob.loc].  Aborting.")
			stop_music()
			return
		var/obj/machinery/media/M = A.media_source
		if(M && M.playing)
			targetURL = M.media_url
			targetStartTime = M.media_start_time
//			to_chat(owner, "Found audio source: [M.media_url] @ [(world.time - start_time) / 10]s.")
		//else
		//	testing("M is not playing or null.")

		if (url != targetURL || abs(targetStartTime - start_time) > 1)
			url = targetURL
			start_time = targetStartTime
			send_update()
			
	proc/get_volume()
		return (owner && owner.prefs) ? owner.prefs.volume : 25

/client/verb/change_volume()
	set name = "Set Volume"
	set category = "Preferences"
	set desc = "Set jukebox volume"

	if(!media || !istype(media))
		to_chat(usr, "You have no media datum to change, if you're not in the lobby tell an admin.")
		return
	var/value = input("Choose your Jukebox volume.", "Jukebox volume", media.get_volume())
	value = round(max(0, min(100, value)))
	if(prefs)
		prefs.volume = value
		prefs.save_preferences(src)
		media.send_update()