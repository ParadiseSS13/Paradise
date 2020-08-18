import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

export const SpawnersMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const spawners = data.spawners || [];
  return (
    <Window
      resizable>
      <Window.Content scrollable>
        <Section>
          {spawners.map(spawner => (
            <Section
              mb={0.5}
              key={spawner.name}
              title={spawner.name + ' (' + spawner.amount_left + ' left)'}
              level={2}
              buttons={(
                <Fragment>
                  <Button
                    icon="chevron-circle-right"
                    content="Jump"
                    onClick={() => act('jump', {
                      ID: spawner.uids,
                    })} />
                  <Button
                    icon="chevron-circle-right"
                    content="Spawn"
                    onClick={() => act('spawn', {
                      ID: spawner.uids,
                    })} />
                </Fragment>
              )}>
              <Box
                style={{ "white-space": "pre-wrap" }} // preserve newline
                mb={1}
                fontSize="16px">
                {spawner.desc}
              </Box>
              {!!spawner.fluff && (
                <Box // lighter grey than default grey for better contrast.
                  style={{ "white-space": "pre-wrap" }}
                  textColor="#878787"
                  fontSize="14px">
                  {spawner.fluff}
                </Box>
              )}
              {!!spawner.important_info && (
                <Box
                  style={{ "white-space": "pre-wrap" }}
                  mt={1}
                  bold
                  color="red"
                  fontSize="18px">
                  {spawner.important_info}
                </Box>
              )}
            </Section>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
