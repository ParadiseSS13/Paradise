from dataclasses import dataclass

from avulto import DME, Dir, DMI, IconState, Path as p
from PIL import Image, ImageDraw, ImageFont, ImageColor

FONT_PATH = "tools/mapping/Microfont.ttf"
FONT_SIZE = 6
LINE_SPACING = 1
TEXT_COLOR = (255, 255, 255, 255)


@dataclass(frozen=True)
class AreaIconSpec:
    path: p
    icon_state: str
    area_icon_text: str | None
    area_icon_color: str | None


class AreaRepo:
    def __init__(self, dme: DME):
        self._areas: dict[p, AreaIconSpec] = {}

        for pth in dme.subtypesof("/area"):
            td = dme.types[pth]
            modified_vars = td.var_names(modified=True)

            if "icon_state" not in modified_vars:
                continue
            icon_state = td.var_decl("icon_state").const_val

            if "area_icon_text" not in modified_vars and "area_icon_color" not in modified_vars:
                continue

            area_icon_text = (td.var_decl("area_icon_text").const_val or "").replace("\\n", "\n")
            area_icon_color = td.var_decl("area_icon_color").const_val

            self._areas[pth] = AreaIconSpec(
                pth, icon_state, area_icon_text, area_icon_color
            )

    def icon_states(self) -> dict[str, tuple[str, str]]:
        result: dict[str, tuple[str, str]] = {}
        for spec in self._areas.values():
            if not spec.area_icon_text or not spec.area_icon_color:
                continue
            existing = result.get(spec.icon_state)
            if existing is not None and existing != (spec.area_icon_text, spec.area_icon_color):
                print(f"spec {spec} has conflicting area_icon_text/color vs existing {existing}")
                continue
            result[spec.icon_state] = (spec.area_icon_text, spec.area_icon_color)
        return result


def render_icon_state(
    name: str,
    text: str,
    color: str,
    font: ImageFont.FreeTypeFont,
) -> IconState:
    width, height = (32, 32)
    bg = ImageColor.getcolor(color, "RGBA")

    image = Image.new("RGBA", (width, height), bg)
    draw = ImageDraw.Draw(image)
    draw.multiline_text(
        (width / 2, height / 2),
        text,
        font=font,
        fill=TEXT_COLOR,
        spacing=LINE_SPACING,
        align="center",
        anchor="mm",
    )

    return IconState.from_data(
        data={Dir.SOUTH: [image.tobytes("raw", "RGBA")]},
        width=width,
        height=height,
        name=name,
    )


def main():
    font = ImageFont.truetype(FONT_PATH, FONT_SIZE)
    repo = AreaRepo(DME.from_file("paradise.dme"))
    icon_states = repo.icon_states()

    # copy all states from the original file since not all of them are
    # being regenerated
    dmi = DMI.from_file("icons/turf/areas.dmi")
    dmi.states[:] = [s for s in dmi.states if s.name not in icon_states]

    for icon_state_name, (text, color) in sorted(icon_states.items()):
        dmi.states.append(
            render_icon_state(icon_state_name, text, color, font)
        )

    dmi.save_to(dmi.filepath)
    print(f"{len(dmi.state_names())} states ({len(icon_states)} generated) to {dmi.filepath}")


if __name__ == "__main__":
    main()
