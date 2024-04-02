import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';
import { Signaler } from './common/Signaler';

export const RemoteSignaler = (props, context) => {
  const { act, data } = useBackend(context);

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
