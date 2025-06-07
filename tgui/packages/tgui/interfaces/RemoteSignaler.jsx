import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Signaler } from './common/Signaler';

export const RemoteSignaler = (props) => {
  const { act, data } = useBackend();

  const { on } = data;

  return (
    <Window width={300} height={165}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Receiver">
              <Button
                icon={'power-off'}
                content={on ? 'On' : 'Off'}
                color={on ? null : 'red'}
                selected={on}
                onClick={() => act('recv_power')}
              />
            </LabeledList.Item>
          </LabeledList>
          <Signaler data={data} />
        </Section>
      </Window.Content>
    </Window>
  );
};
