import { useBackend } from '../backend';
import { Section, Box, LabeledList, RoundGauge, Slider, Flex, LabeledControls, Button, NoticeBox } from '../components';
import { formatPower } from '../format';
import { Window } from '../layouts';

// Common power multiplier
const POWER_MUL = 1e3;

export const Transformer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    wattage_setting,
    last_output,
    minimum_wattage,
    maximum_wattage,
    overheat_counter,
  } = data;

  return (
    <Window>
      <Window.Content scrollable>
        <Section label="Transformer">
          {overheat_counter >= 85
            ?
            <NoticeBox color="red">
              <b>DANGER:</b> Transformer Overheating, emergency shutdown imminent
            </NoticeBox>
            :
            <NoticeBox color="green">
              Transformer operating at safe coil temperature, monitor regularly for changes in power demand
            </NoticeBox>
          }

          <Flex direction="row" mt={2}>
            <Flex.Item grow="1">
              <WattageSettings />

              <CapacitorInfo />
            </Flex.Item>
            <Flex.Item>
              <Section>
                <Flex align="center" direction="column">
                  <TemperatureGauge overheat_counter={overheat_counter} />
                  <OutputGauge />
                </Flex>
              </Section>
            </Flex.Item>
          </Flex>
        </Section>
        <Section title="Usage Disclaimer">
          The Einstein Inc. Model-C transformer is built to step down high voltage electricity to low-voltage for use in
          commercial station systems. Usage by unauthorized personnel is prohibited. Ensure transformer is set to proper
          wattage settings to avoid overheating and damage to equipment.
        </Section>
      </Window.Content>
    </Window>
  );
};

const WattageSettings = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    capacitor,
    capacitor_in_hand,
    transformer_on,
    maintenance_panel_open,
    maximum_wattage,
    wattage_setting,
    overheat_counter } = data;
  return (
    <Section title="Wattage Setting" width="300px">
      <Flex inline width="100%">
        <Flex.Item>
          <Button
            icon="fast-backward"
            onClick={() => act('input', {
              target: 'min'
            })} />
          <Button
            icon="backward"
            onClick={() => act('input', {
              adjust: -10000
            })} />
        </Flex.Item>
        <Flex.Item grow={1} mx={1}>
          <Slider
            value={wattage_setting / POWER_MUL}
            fillValue={wattage_setting / POWER_MUL}
            minValue={5 * POWER_MUL}
            maxValue={maximum_wattage / POWER_MUL}
            step={5}
            stepPixelSize={4}
            format={(value) => formatPower(value * POWER_MUL, 1)}
            onChange={(e, value) => act('input', {
              target: value * POWER_MUL
            })} />
        </Flex.Item>
        <Flex.Item>
          <Button
            icon="forward"
            onClick={() => act('input', {
              adjust: 10000
            })} />
          <Button
            icon="fast-forward"
            onClick={() => act('input', {
              target: 'max'
            })} />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const CapacitorInfo = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    capacitor,
    capacitor_in_hand,
    maintenance_panel_open,
    overheat_counter,
    safety_buffer } = data;
  const capacitorButtonDisabled = (!capacitor && !capacitor_in_hand) || overheat_counter || maintenance_panel_open
  return (
    <Section title="Capacitor" width="300px">
      <LabeledList.Item label="Capacitor">{capacitor.name}</LabeledList.Item>
      <LabeledList.Item label="Safety Buffer">{safety_buffer}</LabeledList.Item>
      <LabeledList.Item label="Action">
        <Button
          icon="bolt"
          content={capacitor ? "Remove Capacitor" : "Install Capacitor"}
          disabled={capacitorButtonDisabled}
          onClick={() => act('capacitor_button')} /></LabeledList.Item>
    </Section>
  );
};


const OutputGauge = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    last_output = 0,
    maximum_wattage,
    wattage_setting,
    safety_buffer = 15000,
  } = data;
  let gaugePercent = (last_output / maximum_wattage) * 100
  let safetyLower = ((wattage_setting - safety_buffer) / maximum_wattage) * 100
  let safetyHigher = ((wattage_setting + safety_buffer) / maximum_wattage) * 100
  let kWMeasurement = `${Math.round(last_output / 1000, 0.1)} kW`
  return (
    <LabeledControls mt={3}>
      <LabeledControls.Item
        minWidth="66px"
        label={'Kw Output'}>
        <RoundGauge
          size={3}
          value={gaugePercent}
          minValue={0}
          maxValue={100}
          alertAfter={safetyHigher + 2}
          ranges={{
            "grey": [0, safetyLower],
            "good": [safetyLower, safetyHigher],
            "yellow": [safetyHigher, 95]
          }}
          format={(value) => kWMeasurement}
        />
      </LabeledControls.Item>
    </LabeledControls>
  );
};

const TemperatureGauge = (props, context) => {
  const { overheat_counter = 0 } = props;
  return (
    <Flex.Item>
      <LabeledControls>
        <LabeledControls.Item
          minWidth="66px"
          label="Coil Temperature">
          <RoundGauge
            size={3}
            value={overheat_counter}
            minValue={0}
            maxValue={105}
            alertAfter={85}
            content={'Temperature Gauge'}
            ranges={{
              'good': [0, 25],
              'yellow': [25, 80],
              'red': [80, 105],
            }}
            format={(value) => ''}
          />
        </LabeledControls.Item>
      </LabeledControls>
    </Flex.Item>
  );
};

const TransformerInputs = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    capacitor,
    capacitor_in_hand,
    transformer_on,
    maintenance_panel_open,
    maximum_wattage,
    wattage_setting,
    overheat_counter } = data;



  return (
    <Flex inline direction="column">
      <Flex.Item>
        {capacitor &&
          <img
            src={`data:image/jpeg;base64,${capacitor.img}`}
            style={{
              'vertical-align': 'middle',
              width: '64x',
              margin: '0px',
              'margin-left': '0px',
              'margin-right': '4px',
              'image-rendering': 'pixelated'
            }} />}
      </Flex.Item>
      <Button
        icon="bolt"
        content={transformer_on ? "Shutdown Transformer" : "Start Transformer"}
        disabled={maintenance_panel_open}
        onClick={() => act('toggle_power')} />
    </Flex>

  );
};
