import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const TurbineComputer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    compressor,
    compressor_broken,
    turbine,
    turbine_broken,
    online
  } = data;
  const operational = Boolean(compressor && !compressor_broken && turbine && !turbine_broken);
  return (
    <Window>
      <Window.Content>
        <Section title="Status"
          buttons={(
            <>
              <Button
                icon={online ? 'power-off' : 'times'}
                content={online ? 'Online' : 'Offline'}
                selected={online}
                disabled={!operational}
                onClick={() => act('toggle_power')}
              />
              <Button
                icon="sync"
                content="Reconnect"
                onClick={() => act('reconnect')}
              />
            </>
          )}>
          {!operational && (
            <LabeledList>
              <LabeledList.Item
                label="Compressor Status"
                color={(!compressor || compressor_broken) ? 'bad' : 'good'}>
                {compressor_broken ? compressor ? 'Offline' : 'Missing' : 'Online'}
              </LabeledList.Item>
              <LabeledList.Item
                label="Turbine Status"
                color={(!turbine || turbine_broken) ? 'bad' : 'good'}>
                {turbine_broken ? turbine ? 'Offline' : 'Missing' : 'Online'}
              </LabeledList.Item>
            </LabeledList>
          ) || (
            <LabeledList>
              <LabeledList.Item label="Turbine Speed">
                {data.rpm} RPM
              </LabeledList.Item>
              <LabeledList.Item label="Internal Temp">
                {data.temperature} K
              </LabeledList.Item>
              <LabeledList.Item label="Generated Power">
                {data.power} W
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
