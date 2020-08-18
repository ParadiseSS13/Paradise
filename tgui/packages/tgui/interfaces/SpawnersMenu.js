import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

// a function that inserts linebreaks where the
// supplied text has an \n
let MakeLinebreaks = function (props) {
  return props.split("\n").map((item, idx) => {
    return (
      <span key={idx}>
        {item}
        <br />
      </span>
    );
  });
};

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
                mb={1}
                fontSize="16px">
                {MakeLinebreaks(spawner.desc)}
              </Box>
              {!!spawner.fluff && (
                <Box // lighter grey than default grey for better contrast.
                  textColor="#878787"
                  fontSize="14px">
                  {MakeLinebreaks(spawner.fluff)}
                </Box>
              )}
              {!!spawner.important_info && (
                <Box
                  mt={1}
                  bold
                  color="red"
                  fontSize="18px">
                  {MakeLinebreaks(spawner.important_info)}
                </Box>
              )}
            </Section>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
