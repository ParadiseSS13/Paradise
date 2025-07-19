import { useState } from 'react';
import { Box, Button, Icon, Input, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const BioChipPad = (props) => {
  const { act, data } = useBackend();
  const { implant, contains_case, gps, tag } = data;
  const [newTag, setNewTag] = useState(tag);

  return (
    <Window width={410} height={325}>
      <Window.Content>
        <Section
          fill
          title="Bio-chip Mini-Computer"
          buttons={
            <Box>
              <Button content="Eject Case" icon="eject" disabled={!contains_case} onClick={() => act('eject_case')} />
            </Box>
          }
        >
          {implant && contains_case ? (
            <>
              <Box bold mb={2}>
                <img
                  src={`data:image/jpeg;base64,${implant.image}`}
                  style={{
                    verticalAlign: 'middle',
                    width: '32px',
                    marginLeft: 0,
                    marginRight: 2,
                  }}
                />
                {implant.name}
              </Box>
              <LabeledList>
                <LabeledList.Item label="Life">{implant.life}</LabeledList.Item>
                <LabeledList.Item label="Notes">{implant.notes}</LabeledList.Item>
                <LabeledList.Item label="Function">{implant.function}</LabeledList.Item>
                {!!gps && (
                  <LabeledList.Item label="Tag">
                    <Input
                      width="5.5rem"
                      value={tag}
                      onEnter={() => act('tag', { newtag: newTag })}
                      onChange={(value) => setNewTag(value)}
                    />
                    <Button
                      disabled={tag === newTag}
                      width="20px"
                      mb="0"
                      ml="0.25rem"
                      onClick={() => act('tag', { newtag: newTag })}
                    >
                      <Icon name="pen" />
                    </Button>
                  </LabeledList.Item>
                )}
              </LabeledList>
            </>
          ) : contains_case ? (
            <Box>This bio-chip case has no implant!</Box>
          ) : (
            <Box>Please insert a bio-chip casing!</Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
