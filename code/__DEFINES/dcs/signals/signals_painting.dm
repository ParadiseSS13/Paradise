// signals for painting canvases, tools and the /datum/component/palette component

///from base of /item/proc/set_painting_tool_color(): (chosen_color)
#define COMSIG_PAINTING_TOOL_SET_COLOR "painting_tool_set_color"

/// from base of /item/canvas/ui_data(): (data)
#define COMSIG_PAINTING_TOOL_GET_ADDITIONAL_DATA "painting_tool_get_data"

///from base of /item/canvas/ui_act(), "change_color" action: (chosen_color, color_index)
#define COMSIG_PAINTING_TOOL_PALETTE_COLOR_CHANGED "painting_tool_palette_color_changed"
