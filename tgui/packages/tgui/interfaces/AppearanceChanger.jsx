import { Button, LabeledList } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const AppearanceChanger = (props) => {
  const { act, data } = useBackend();
  const {
    change_race,
    species,
    specimen,
    change_gender,
    gender,
    change_eye_color,
    change_skin_tone,
    change_skin_color,
    change_runechat_color,
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
    change_hair_gradient,
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
  if (
    change_eye_color ||
    change_skin_tone ||
    change_skin_color ||
    change_head_accessory_color ||
    change_runechat_color ||
    change_hair_color ||
    change_secondary_hair_color ||
    change_facial_hair_color ||
    change_secondary_facial_hair_color ||
    change_head_marking_color ||
    change_body_marking_color ||
    change_tail_marking_color
  ) {
    has_colours = true;
  }

  return (
    <Window width={800} height={450}>
      <Window.Content scrollable>
        <LabeledList>
          {!!change_race && (
            <LabeledList.Item label="Species">
              {species.map((s) => (
                <Button
                  key={s.specimen}
                  content={s.specimen}
                  selected={s.specimen === specimen}
                  onClick={() => act('race', { race: s.specimen })}
                />
              ))}
            </LabeledList.Item>
          )}
          {!!change_gender && (
            <LabeledList.Item label="Gender">
              <Button content="Male" selected={gender === 'male'} onClick={() => act('gender', { gender: 'male' })} />
              <Button
                content="Female"
                selected={gender === 'female'}
                onClick={() => act('gender', { gender: 'female' })}
              />
              {
                <Button
                  content="Genderless"
                  selected={gender === 'plural'}
                  onClick={() => act('gender', { gender: 'plural' })}
                />
              }
            </LabeledList.Item>
          )}
          {!!has_colours && <ColorContent />}
          {!!change_head_accessory && (
            <LabeledList.Item label="Head accessory">
              {head_accessory_styles.map((s) => (
                <Button
                  key={s.headaccessorystyle}
                  content={s.headaccessorystyle}
                  selected={s.headaccessorystyle === head_accessory_style}
                  onClick={() =>
                    act('head_accessory', {
                      head_accessory: s.headaccessorystyle,
                    })
                  }
                />
              ))}
            </LabeledList.Item>
          )}
          {!!change_hair && (
            <LabeledList.Item label="Hair">
              {hair_styles.map((s) => (
                <Button
                  key={s.hairstyle}
                  content={s.hairstyle}
                  selected={s.hairstyle === hair_style}
                  onClick={() => act('hair', { hair: s.hairstyle })}
                />
              ))}
            </LabeledList.Item>
          )}
          {!!change_hair_gradient && (
            <LabeledList.Item label="Hair Gradient">
              <Button content="Change Style" onClick={() => act('hair_gradient')} />
              <Button content="Change Offset" onClick={() => act('hair_gradient_offset')} />
              <Button content="Change Color" onClick={() => act('hair_gradient_colour')} />
              <Button content="Change Alpha" onClick={() => act('hair_gradient_alpha')} />
            </LabeledList.Item>
          )}
          {!!change_facial_hair && (
            <LabeledList.Item label="Facial hair">
              {facial_hair_styles.map((s) => (
                <Button
                  key={s.facialhairstyle}
                  content={s.facialhairstyle}
                  selected={s.facialhairstyle === facial_hair_style}
                  onClick={() => act('facial_hair', { facial_hair: s.facialhairstyle })}
                />
              ))}
            </LabeledList.Item>
          )}
          {!!change_head_markings && (
            <LabeledList.Item label="Head markings">
              {head_marking_styles.map((s) => (
                <Button
                  key={s.headmarkingstyle}
                  content={s.headmarkingstyle}
                  selected={s.headmarkingstyle === head_marking_style}
                  onClick={() => act('head_marking', { head_marking: s.headmarkingstyle })}
                />
              ))}
            </LabeledList.Item>
          )}
          {!!change_body_markings && (
            <LabeledList.Item label="Body markings">
              {body_marking_styles.map((s) => (
                <Button
                  key={s.bodymarkingstyle}
                  content={s.bodymarkingstyle}
                  selected={s.bodymarkingstyle === body_marking_style}
                  onClick={() => act('body_marking', { body_marking: s.bodymarkingstyle })}
                />
              ))}
            </LabeledList.Item>
          )}
          {!!change_tail_markings && (
            <LabeledList.Item label="Tail markings">
              {tail_marking_styles.map((s) => (
                <Button
                  key={s.tailmarkingstyle}
                  content={s.tailmarkingstyle}
                  selected={s.tailmarkingstyle === tail_marking_style}
                  onClick={() => act('tail_marking', { tail_marking: s.tailmarkingstyle })}
                />
              ))}
            </LabeledList.Item>
          )}
          {!!change_body_accessory && (
            <LabeledList.Item label="Body accessory">
              {body_accessory_styles.map((s) => (
                <Button
                  key={s.bodyaccessorystyle}
                  content={s.bodyaccessorystyle}
                  selected={s.bodyaccessorystyle === body_accessory_style}
                  onClick={() =>
                    act('body_accessory', {
                      body_accessory: s.bodyaccessorystyle,
                    })
                  }
                />
              ))}
            </LabeledList.Item>
          )}
          {!!change_alt_head && (
            <LabeledList.Item label="Alternate head">
              {alt_head_styles.map((s) => (
                <Button
                  key={s.altheadstyle}
                  content={s.altheadstyle}
                  selected={s.altheadstyle === alt_head_style}
                  onClick={() => act('alt_head', { alt_head: s.altheadstyle })}
                />
              ))}
            </LabeledList.Item>
          )}
        </LabeledList>
      </Window.Content>
    </Window>
  );
};

const ColorContent = (props) => {
  const { act, data } = useBackend();

  const colorOptions = [
    { key: 'change_eye_color', text: 'Change eye color', action: 'eye_color' },
    { key: 'change_skin_tone', text: 'Change skin tone', action: 'skin_tone' },
    {
      key: 'change_skin_color',
      text: 'Change skin color',
      action: 'skin_color',
    },
    {
      key: 'change_runechat_color',
      text: 'Change runechat color',
      action: 'runechat_color',
    },
    {
      key: 'change_head_accessory_color',
      text: 'Change head accessory color',
      action: 'head_accessory_color',
    },
    {
      key: 'change_hair_color',
      text: 'Change hair color',
      action: 'hair_color',
    },
    {
      key: 'change_secondary_hair_color',
      text: 'Change secondary hair color',
      action: 'secondary_hair_color',
    },
    {
      key: 'change_facial_hair_color',
      text: 'Change facial hair color',
      action: 'facial_hair_color',
    },
    {
      key: 'change_secondary_facial_hair_color',
      text: 'Change secondary facial hair color',
      action: 'secondary_facial_hair_color',
    },
    {
      key: 'change_head_marking_color',
      text: 'Change head marking color',
      action: 'head_marking_color',
    },
    {
      key: 'change_body_marking_color',
      text: 'Change body marking color',
      action: 'body_marking_color',
    },
    {
      key: 'change_tail_marking_color',
      text: 'Change tail marking color',
      action: 'tail_marking_color',
    },
  ];

  return (
    <LabeledList.Item label="Colors">
      {colorOptions.map((c) => !!data[c.key] && <Button key={c.key} content={c.text} onClick={() => act(c.action)} />)}
    </LabeledList.Item>
  );
};
