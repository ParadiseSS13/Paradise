import { useBackend } from '../backend';
import { Button, LabeledList, Section, ProgressBar, Knob } from '../components';
import { formatPower } from '../format';
import { Window } from '../layouts';
import { toFixed } from 'common/math';

export const TurbineComputer = (props, context) => {
  const { act, data } = useBackend(context);
  const { compressor, compressor_broken, turbine, turbine_broken, online, throttle, preBurnTemperature } = data;
  const operational = Boolean(compressor && !compressor_broken && turbine && !turbine_broken);
  return (
    <Window width={400} height={380}>
      <Window.Content>
        <Section
          title="Status"
          buttons={
            <>
              <Button
                icon={online ? 'power-off' : 'times'}
                content={online ? 'Online' : 'Offline'}
                selected={online}
                disabled={!operational}
                onClick={() => act('toggle_power')}
              />
              <Button icon="times" content="Disconnect" onClick={() => act('disconnect')} />
            </>
          }
        >
          {operational ? <TurbineWorking /> : <TurbineBroken />}
        </Section>
        <Section title="Throttle">
          {operational ? (
            <Knob
              size={3}
              value={throttle}
              unit="%"
              minValue={0}
              maxValue={100}
              step={1}
              stepPixelSize={1}
              onDrag={(e, value) =>
                act('set_throttle', {
                  throttle: value,
                })
              }
            />
          ) : (
            ''
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

// Element Tree for if the turbine is broken
const TurbineBroken = (props, context) => {
  const { data } = useBackend(context);
  const { compressor, compressor_broken, turbine, turbine_broken, online } = data;
  return (
    <LabeledList>
      <LabeledList.Item label="Compressor Status" color={!compressor || compressor_broken ? 'bad' : 'good'}>
        {compressor_broken ? (compressor ? 'Offline' : 'Missing') : 'Online'}
      </LabeledList.Item>
      <LabeledList.Item label="Turbine Status" color={!turbine || turbine_broken ? 'bad' : 'good'}>
        {turbine_broken ? (turbine ? 'Offline' : 'Missing') : 'Online'}
      </LabeledList.Item>
    </LabeledList>
  );
};

// Element Tree for if the turbine is working
const TurbineWorking = (props, context) => {
  const { data } = useBackend(context);
  const { rpm, temperature, power, bearingDamage, preBurnTemperature, thermalEfficiency, compressionRatio } = data;
  return (
    <LabeledList>
      <LabeledList.Item label="Turbine Speed">{rpm} RPM</LabeledList.Item>
      <LabeledList.Item label="Effective Compression Ratio">{compressionRatio}:1</LabeledList.Item>
      <LabeledList.Item label="Pre Burn Temp">{preBurnTemperature} K</LabeledList.Item>
      <LabeledList.Item label="Internal Temp">{temperature} K</LabeledList.Item>
      <LabeledList.Item label="Thermal Efficiency">{thermalEfficiency * 100} %</LabeledList.Item>
      <LabeledList.Item label="Generated Power">{formatPower(power)}</LabeledList.Item>
      <LabeledList.Item label="Bearing Damage">
        <ProgressBar
          value={bearingDamage}
          minValue={0}
          maxValue={100}
          ranges={{
            good: [-Infinity, 60],
            average: [60, 90],
            bad: [90, Infinity],
          }}
        >
          {toFixed(bearingDamage) + '%'}
        </ProgressBar>
      </LabeledList.Item>
    </LabeledList>
  );
};
