import { Button, Knob, LabeledList, ProgressBar, Section, Stack } from 'tgui-core/components';
import { formatPower } from 'tgui-core/format';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const TurbineComputer = (props) => {
  const { act, data } = useBackend();
  const {
    compressor,
    compressor_broken,
    turbine,
    turbine_broken,
    online,
    throttle,
    preBurnTemperature,
    bearingDamage,
  } = data;
  const operational = Boolean(compressor && !compressor_broken && turbine && !turbine_broken);
  return (
    <Window width={400} height={415}>
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

        {bearingDamage >= 100 ? (
          <Stack mb="30px" fontsize="256px">
            <Stack.Item bold color="red" fontsize="256px" textAlign="center">
              Bearings Inoperable, Repair Required
            </Stack.Item>
          </Stack>
        ) : (
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
                tickWhileDragging
                onChange={(e, value) =>
                  act('set_throttle', {
                    throttle: value,
                  })
                }
              />
            ) : (
              ''
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

// Element Tree for if the turbine is broken
const TurbineBroken = (props) => {
  const { data } = useBackend();
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
const TurbineWorking = (props) => {
  const { data } = useBackend();
  const {
    rpm,
    temperature,
    power,
    bearingDamage,
    preBurnTemperature,
    postBurnTemperature,
    thermalEfficiency,
    compressionRatio,
    gasThroughput,
  } = data;
  return (
    <LabeledList>
      <LabeledList.Item label="Turbine Speed">{rpm} RPM</LabeledList.Item>
      <LabeledList.Item label="Effective Compression Ratio">{compressionRatio}:1</LabeledList.Item>
      <LabeledList.Item label="Gasmix Pre Burn Temp">{preBurnTemperature} K</LabeledList.Item>
      <LabeledList.Item label="Gasmix Post Burn Temp">{postBurnTemperature} K</LabeledList.Item>
      <LabeledList.Item label="Compressor Temp">{temperature} K</LabeledList.Item>
      <LabeledList.Item label="Thermal Efficiency">{thermalEfficiency * 100} %</LabeledList.Item>
      <LabeledList.Item label="Gas Throughput">{gasThroughput / 2} mol/s</LabeledList.Item>
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
