import { Box, Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const TankDispenser = (props) => {
  const { act, data } = useBackend();
  const { o_tanks, p_tanks } = data;
  return (
    <Window width={250} height={105}>
      <Window.Content>
        <Section>
          <Box>
            <Button
              fluid
              content={'Dispense Oxygen Tank (' + o_tanks + ')'}
              disabled={o_tanks === 0}
              icon="arrow-circle-down"
              onClick={() => act('oxygen')}
            />
          </Box>
          <Box>
            <Button
              mt={1}
              fluid
              content={'Dispense Plasma Tank (' + p_tanks + ')'}
              disabled={p_tanks === 0}
              icon="arrow-circle-down"
              onClick={() => act('plasma')}
            />
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
