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
          {operational
            ? <TurbineWorking />
            : <TurbineBroken />
          }
        </Section>
      </Window.Content>
    </Window>
  );
};

// Element Tree for if the turbine is broken
const TurbineBroken = (props, context) => {
  const { data } = useBackend(context);
  const {
    compressor,
    compressor_broken,
    turbine,
    turbine_broken,
    online
  } = data;
  return (
    <LabeledList>
      <LabeledList.Item
        label="Compressor Status"
        color={(!compressor || compressor_broken) ? 'bad' : 'good'}>
        {compressor_broken
        ? compressor ? 'Offline' : 'Missing'
        : 'Online'}
      </LabeledList.Item>
      <LabeledList.Item
        label="Turbine Status"
        color={(!turbine || turbine_broken) ? 'bad' : 'good'}>
        {turbine_broken
        ? turbine ? 'Offline' : 'Missing'
        : 'Online'}
      </LabeledList.Item>
    </LabeledList>
  );
};

// Element Tree for if the turbine is working
const TurbineWorking = (props, context) => {
  const { data } = useBackend(context);
  const {
    rpm,
    temperature,
    power
  } = data;
  return (
    <LabeledList>
      <LabeledList.Item label="Turbine Speed">
        {rpm} RPM
      </LabeledList.Item>
      <LabeledList.Item label="Internal Temp">
        {temperature} K
      </LabeledList.Item>
      <LabeledList.Item label="Generated Power">
        {power} W
      </LabeledList.Item>
    </LabeledList>
  );
};
