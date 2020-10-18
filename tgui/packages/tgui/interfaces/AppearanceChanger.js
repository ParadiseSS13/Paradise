import { useBackend } from "../backend";
import { LabeledList, Button } from "../components";
import { Window } from "../layouts";

export const AppearanceChanger = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    change_race,
    species,
    specimen,
    change_gender,
    gender,
    has_gender,
    change_eye_color,
    change_skin_tone,
    change_skin_color,
    change_head_accessory_color,
    change_hair_color,
    change_secondary_hair_color,
    change_facial_hair_color,
    change_secondary_facial_hair_color,
    change_head_marking_color,
    change_body_marking_color,
    change_tail_marking_color,
    change_head_accessory,
    head_accessory_styles,
    head_accessory_style,
    change_hair,
    hair_styles,
    hair_style,
    change_facial_hair,
    facial_hair_styles,
    facial_hair_style,
    change_head_markings,
    head_marking_styles,
    head_marking_style,
    change_body_markings,
    body_marking_styles,
    body_marking_style,
    change_tail_markings,
    tail_marking_styles,
    tail_marking_style,
    change_body_accessory,
    body_accessory_styles,
    body_accessory_style,
    change_alt_head,
    alt_head_styles,
    alt_head_style,
  } = data;

  let has_colours = false;
  // Yes this if statement is awful, but I would rather do it here than inside the template
  if (change_eye_color || change_skin_tone || change_skin_color || change_head_accessory_color || change_hair_color || change_secondary_hair_color || change_facial_hair_color || change_secondary_facial_hair_color || change_head_marking_color || change_body_marking_color || change_tail_marking_color) {
    has_colours = true;
  }

  return (
    <Window>
      <Window.Content scrollable>
        <LabeledList>
          {!!change_race && (
            <LabeledList.Item label="Species">
              {species.map(s => (
                <Button
                  key={s.specimen}
                  content={s.specimen}
                  selected={s.specimen === specimen}
                  onClick={
                    () => act('race', { race: s.specimen })
                  }
                />
              ))}
            </LabeledList.Item>
          )}
          {!!change_gender && (
            <LabeledList.Item label="Gender">
              <Button
                content="Male"
                selected={gender === "male"}
                onClick={
                  () => act('gender', { gender: "male" })
                }
              />
              <Button
                content="Female"
                selected={gender === "female"}
                onClick={
                  () => act('gender', { gender: "female" })
                }
              />
              {!has_gender && (
                <Button
                  content="Genderless"
                  selected={gender === "plural"}
                  onClick={
                    () => act('gender', { gender: "plural" })
                  }
                />
              )}
            </LabeledList.Item>
          )}
          {!!has_colours && (
            <LabeledList.Item label="Colors">
              {!!change_eye_color && (
                <Button
                  content="Change eye color"
                  onClick={
                    () => act('eye_color')
                  }
                />
              )}
              {!!change_skin_tone && (
                <Button
                  content="Change skin tone"
                  onClick={
                    () => act('skin_tone')
                  }
                />
              )}
              {!!change_skin_color && (
                <Button
                  content="Change skin color"
                  onClick={
                    () => act('skin_color')
                  }
                />
              )}
              {!!change_head_accessory_color && (
                <Button
                  content="Change head accessory color"
                  onClick={
                    () => act('head_accessory_color')
                  }
                />
              )}
              {!!change_hair_color && (
                <Button
                  content="Change hair color"
                  onClick={
                    () => act('hair_color')
                  }
                />
              )}
              {!!change_secondary_hair_color && (
                <Button
                  content="Change secondary hair color"
                  onClick={
                    () => act('secondary_hair_color')
                  }
                />
              )}
              {!!change_facial_hair_color && (
                <Button
                  content="Change facial hair color"
                  onClick={
                    () => act('facial_hair_color')
                  }
                />
              )}
              {!!change_secondary_facial_hair_color && (
                <Button
                  content="Change secondary facial hair color"
                  onClick={
                    () => act('secondary_facial_hair_color')
                  }
                />
              )}
              {!!change_head_marking_color && (
                <Button
                  content="Change head marking color"
                  onClick={
                    () => act('head_marking_color')
                  }
                />
              )}
              {!!change_body_marking_color && (
                <Button
                  content="Change body marking color"
                  onClick={
                    () => act('body_marking_color')
                  }
                />
              )}
              {!!change_tail_marking_color && (
                <Button
                  content="Change tail marking color"
                  onClick={
                    () => act('tail_marking_color')
                  }
                />
              )}
            </LabeledList.Item>
          )}
          {!!change_head_accessory && (
            <LabeledList.Item label="Head accessory">
              {head_accessory_styles.map(s => (
                <Button
                  key={s.headaccessorystyle}
                  content={s.headaccessorystyle}
                  selected={s.headaccessorystyle === head_accessory_style}
                  onClick={
                    () => act('head_accessory', { head_accessory: s.headaccessorystyle })
                  }
                />
              ))}
            </LabeledList.Item>
          )}
          {!!change_hair && (
            <LabeledList.Item label="Hair">
              {hair_styles.map(s => (
                <Button
                  key={s.hairstyle}
                  content={s.hairstyle}
                  selected={s.hairstyle === hair_style}
                  onClick={
                    () => act('hair', { hair: s.hairstyle })
                  }
                />
              ))}
            </LabeledList.Item>
          )}
          {!!change_facial_hair && (
            <LabeledList.Item label="Facial hair">
              {facial_hair_styles.map(s => (
                <Button
                  key={s.facialhairstyle}
                  content={s.facialhairstyle}
                  selected={s.facialhairstyle === facial_hair_style}
                  onClick={
                    () => act('facial_hair', { facial_hair: s.facialhairstyle })
                  }
                />
              ))}
            </LabeledList.Item>
          )}
          {!!change_head_markings && (
            <LabeledList.Item label="Head markings">
              {head_marking_styles.map(s => (
                <Button
                  key={s.headmarkingstyle}
                  content={s.headmarkingstyle}
                  selected={s.headmarkingstyle === head_marking_style}
                  onClick={
                    () => act('head_marking', { head_marking: s.headmarkingstyle })
                  }
                />
              ))}
            </LabeledList.Item>
          )}
          {!!change_body_markings && (
            <LabeledList.Item label="Body markings">
              {body_marking_styles.map(s => (
                <Button
                  key={s.bodymarkingstyle}
                  content={s.bodymarkingstyle}
                  selected={s.bodymarkingstyle === body_marking_style}
                  onClick={
                    () => act('body_marking', { body_marking: s.bodymarkingstyle })
                  }
                />
              ))}
            </LabeledList.Item>
          )}
          {!!change_tail_markings && (
            <LabeledList.Item label="Tail markings">
              {tail_marking_styles.map(s => (
                <Button
                  key={s.tailmarkingstyle}
                  content={s.tailmarkingstyle}
                  selected={s.tailmarkingstyle === tail_marking_style}
                  onClick={
                    () => act('tail_marking', { tail_marking: s.tailmarkingstyle })
                  }
                />
              ))}
            </LabeledList.Item>
          )}
          {!!change_body_accessory && (
            <LabeledList.Item label="Body accessory">
              {body_accessory_styles.map(s => (
                <Button
                  key={s.bodyaccessorystyle}
                  content={s.bodyaccessorystyle}
                  selected={s.bodyaccessorystyle === body_accessory_style}
                  onClick={
                    () => act('body_accessory', { body_accessory: s.bodyaccessorystyle })
                  }
                />
              ))}
            </LabeledList.Item>
          )}
          {!!change_alt_head && (
            <LabeledList.Item label="Alternate head">
              {alt_head_styles.map(s => (
                <Button
                  key={s.altheadstyle}
                  content={s.altheadstyle}
                  selected={s.altheadstyle === alt_head_style}
                  onClick={
                    () => act('alt_head', { alt_head: s.altheadstyle })
                  }
                />
              ))}
            </LabeledList.Item>
          )}
        </LabeledList>
      </Window.Content>
    </Window>
  );
};
