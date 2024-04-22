// TGUI Modal defines
#define UI_MODAL_INPUT_MAX_LENGTH 1024
#define UI_MODAL_INPUT_MAX_LENGTH_NAME 64 // Names for generally anything don't go past 32, let alone 64.

#define UI_MODAL_OPEN 1
#define UI_MODAL_DELEGATE 2
#define UI_MODAL_ANSWER 3
#define UI_MODAL_CLOSE 4

/// Green eye; fully interactive
#define UI_INTERACTIVE 2
/// Orange eye; updates but is not interactive
#define UI_UPDATE 1
/// Red eye; disabled, does not update
#define UI_DISABLED 0
/// UI Should close
#define UI_CLOSE -1

/// Maximum number of windows that can be suspended/reused
#define TGUI_WINDOW_SOFT_LIMIT 5
/// Maximum number of open windows
#define TGUI_WINDOW_HARD_LIMIT 9

/// Maximum ping timeout allowed to detect zombie windows
#define TGUI_PING_TIMEOUT (4 SECONDS)
/// Used for rate-limiting to prevent DoS by excessively refreshing a TGUI window
#define TGUI_REFRESH_FULL_UPDATE_COOLDOWN (1 SECONDS)

/// Window does not exist
#define TGUI_WINDOW_CLOSED 0
/// Window was just opened, but is still not ready to be sent data
#define TGUI_WINDOW_LOADING 1
/// Window is free and ready to receive data
#define TGUI_WINDOW_READY 2

/// Get a window id based on the provided pool index
#define TGUI_WINDOW_ID(index) "tgui-window-[index]"
/// Get a pool index of the provided window id
#define TGUI_WINDOW_INDEX(window_id) text2num(copytext(window_id, 13))

/// Creates a message packet for sending via output()
#define TGUI_CREATE_MESSAGE(type, payload) ( \
	url_encode(json_encode(list( \
		"type" = type, \
		"payload" = payload, \
	))))
