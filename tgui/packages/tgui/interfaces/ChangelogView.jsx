import { useState } from 'react';
import { Box, Button, Icon, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const ChangelogView = (props) => {
  const { act, data } = useBackend();
  const [onlyRecent, showOnlyRecent] = useState(0);
  const { cl_data, last_cl } = data;

  const iconMap = {
    'FIX': <Icon name="tools" title="Fix" />,
    'WIP': <Icon name="hard-hat" title="WIP" color="orange" />,
    'TWEAK': <Icon name="sliders-h" title="Tweak" />,
    'SOUNDADD': <Icon name="volume-up" title="Sound Added" color="green" />,
    'SOUNDDEL': <Icon name="volume-mute" title="Sound Removed" color="red" />,
    'CODEADD': <Icon name="plus" title="Code Addition" color="green" />,
    'CODEDEL': <Icon name="minus" title="Code Removal" color="red" />,
    'IMAGEADD': <Icon name="folder-plus" title="Sprite Addition" color="green" />,
    'IMAGEDEL': <Icon name="folder-minus" title="Sprite Removal" color="red" />,
    'SPELLCHECK': <Icon name="font" title="Spelling/Grammar Fix" />,
    'EXPERIMENT': <Icon name="exclamation-triangle" title="Experimental" color="orange" />,
  };

  const cl2icon = (cl) => {
    if (cl in iconMap) {
      return iconMap[cl];
    }

    // Sane default if not in list
    return <Icon name="plus" color="green" />;
  };

  return (
    <Window width={750} height={800}>
      <Window.Content scrollable>
        <Section
          title="ParadiseSS13 Changelog"
          mt={2}
          buttons={
            <Button
              content={onlyRecent ? 'Showing all changes' : 'Showing changes since last connection'}
              onClick={() => showOnlyRecent(!onlyRecent)}
            />
          }
        >
          {cl_data.map(
            (e) =>
              (!onlyRecent && e.merge_ts <= last_cl) || (
                <Section
                  mb={2}
                  key={e}
                  title={e.author + ' - Merged on ' + e.merge_date}
                  buttons={<Button content={'#' + e.num} onClick={() => act('open_pr', { pr_number: e.num })} />}
                >
                  {e.entries.map((ent) => (
                    <Box key={ent} m={1}>
                      {cl2icon(ent.etype)} {ent.etext}
                    </Box>
                  ))}
                </Section>
              )
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
