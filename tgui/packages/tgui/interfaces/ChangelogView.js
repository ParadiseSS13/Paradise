import { useBackend, useLocalState } from '../backend';
import { Button, Section, Box, Icon } from '../components';
import { Window } from '../layouts';

export const ChangelogView = (props, context) => {
  const { act, data } = useBackend(context);
  const [onlyRecent, showOnlyRecent] = useLocalState(context, "onlyRecent", 0);
  const {
    cl_data,
    last_cl,
  } = data;

  const cl2icon = (cl) => {
    switch(cl) {
      case "FIX": {
        return <Icon name="tools" title="Fix" />;
      }
      case "WIP": {
        return <Icon name="hard-hat" title="WIP" color="orange" />;
      }
      case "TWEAK": {
        return <Icon name="sliders-h" title="Tweak" />;
      }
      case "SOUNDADD": {
        return <Icon name="volume-up" title="Sound Added" color="green" />;
      }
      case "SOUNDDEL": {
        return <Icon name="volume-mute" title="Sound Removed" color="red" />;
      }
      case "CODEADD": {
        return <Icon name="plus" title="Code Addition" color="green" />;
      }
      case "CODEDEL": {
        return <Icon name="minus" title="Code Removal" color="red" />;
      }
      case "IMAGEADD": {
        return <Icon name="folder-plus" title="Sprite Addition" color="green" />;
      }
      case "IMAGEDEL": {
        return <Icon name="folder-minus" title="Sprite Removal" color="red" />;
      }
      case "SPELLCHECK": {
        return <Icon name="font" title="Spelling/Grammar Fix" />;
      }
      case "EXPERIMENT": {
        return <Icon name="exclamation-triangle" title="Experimental" color="orange" />;
      }
    }

    return <Icon name="plus" color="green" />; // Sane default
  }

  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="ParadiseSS13 Changelog" mt={2} buttons={
          <Button
            content={onlyRecent ? "Showing all changes" : "Showing changes since last connection"}
            onClick={() => showOnlyRecent(!onlyRecent)}
          />
        }>
          {cl_data.map(e => (
            (!onlyRecent && (e.merge_ts <= last_cl) || (
              <Section mb={2}
                key={e}
                title={e.author + " - Merged on " + e.merge_date}
                buttons={
                  <Button content={"#" + e.num} onClick={() => act("open_pr", { pr_number: e.num })} />
              }>
                {e.entries.map(ent => (
                  <Box key={ent} m={1}>
                      {cl2icon(ent.etype)} {ent.etext}
                  </Box>
                ))}
              </Section>
            ))
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
