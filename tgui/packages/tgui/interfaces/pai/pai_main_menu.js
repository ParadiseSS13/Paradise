import { useBackend } from "../../backend";
import { LabeledList, Box, Button } from "../../components";

export const pai_main_menu = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    available_software,
    installed_software,
    installed_toggles,
    available_ram,
    emotions,
    current_emotion,
  } = data.app_data;

  const installedSoftwareKeys = [];
  installed_software.map(s => (
    installedSoftwareKeys[s.key] = s.name
  ));
  installed_toggles.map(s => (
    installedSoftwareKeys[s.key] = s.name
  ));

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Available RAM">
          {available_ram}
        </LabeledList.Item>
        <LabeledList.Item label="Available Software">
          {available_software.filter(s => !installedSoftwareKeys[s.key]).map(s => (
            <Button key={s.key} content={s.name + " (" + s.cost + ")"} icon={s.icon} disabled={s.cost > available_ram} onClick={
              () => act('purchaseSoftware', { key: s.key })
            } />
          ))}
          {available_software.filter(s => !installedSoftwareKeys[s.key]).length === 0 && (
            "No software available!"
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Installed Software">
          {installed_software.filter(s => s.key !== "mainmenu").map(s => (
            <Button key={s.key} content={s.name} icon={s.icon} onClick={
              () => act('startSoftware', { software_key: s.key })
            } />
          ))}
          {installed_software.length === 0 && (
            "No software installed!"
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Installed Toggles">
          {installed_toggles.map(t => (
            <Button key={t.key} content={t.name} icon={t.icon} selected={t.active} onClick={
              () => act('setToggle', { toggle_key: t.key })
            } />
          ))}
          {installed_toggles.length === 0 && (
            "No toggles installed!"
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Select Emotion">
          {emotions.map(e => (
            <Button key={e.id} content={e.name} selected={e.id === current_emotion} onClick={
              () => act('setEmotion', { emotion: e.id })
            } />
          ))}
        </LabeledList.Item>
      </LabeledList>
    </Box>
  );
};
