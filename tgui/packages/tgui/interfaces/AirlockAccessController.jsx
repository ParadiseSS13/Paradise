import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const AirlockAccessController = (props) => {
  const { act, data } = useBackend();
  const { exterior_status, interior_status, processing } = data;
  let exteriorbutton;
  let interiorbutton;
  // If exterior is open, then it can be locked, if closed, it can be cycled to. Vice versa for interior

  if (exterior_status === 'open') {
    exteriorbutton = (
      <Button
        width="50%"
        content={'Lock Exterior Door'}
        icon={'exclamation-triangle'}
        disabled={processing}
        onClick={() => act('force_ext')}
      />
    );
  } else {
    exteriorbutton = (
      <Button
        width="50%"
        content={'Cycle to Exterior'}
        icon={'arrow-circle-left'}
        disabled={processing}
        onClick={() => act('cycle_ext_door')}
      />
    );
  }
  if (interior_status === 'open') {
    interiorbutton = (
      <Button
        width="49%"
        content={'Lock Interior Door'}
        icon={'exclamation-triangle'}
        disabled={processing}
        color={interior_status === 'open' ? 'red' : processing ? 'yellow' : null}
        onClick={() => act('force_int')}
      />
    );
  } else {
    interiorbutton = (
      <Button
        width="49%"
        content={'Cycle to Interior'}
        icon={'arrow-circle-right'}
        disabled={processing}
        onClick={() => act('cycle_int_door')}
      />
    );
  }
  return (
    <Window width={330} height={200}>
      <Window.Content>
        <Section title="Information">
          <LabeledList>
            <LabeledList.Item label="External Door Status">
              {exterior_status === 'closed' ? 'Locked' : 'Open'}
            </LabeledList.Item>
            <LabeledList.Item label="Internal Door Status">
              {interior_status === 'closed' ? 'Locked' : 'Open'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Actions">
          <Box>
            {exteriorbutton}
            {interiorbutton}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
