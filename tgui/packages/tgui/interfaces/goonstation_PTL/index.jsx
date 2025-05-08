/**
 * @file
 * @copyright 2020
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Box, Button, LabeledList, NoticeBox, NumberInput, ProgressBar, Section, Stack } from 'tgui-core/components';
import { formatMoney, formatPower, formatSiUnit } from 'tgui-core/format';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';

export const goonstation_PTL = (props) => {
  const { data } = useBackend();
  const { total_earnings, total_energy, name = 'Power Transmission Laser' } = data;
  return (
    <Window title="Power Transmission Laser" width="310" height="485">
      <Window.Content>
        <Status />
        <InputControls />
        <OutputControls />
        <NoticeBox success>Earned Credits : {total_earnings ? formatMoney(total_earnings) : 0}</NoticeBox>
        <NoticeBox success>Energy Sold : {total_energy ? formatSiUnit(total_energy, 0, 'J') : '0 J'}</NoticeBox>
      </Window.Content>
    </Window>
  );
};

const Status = (props) => {
  const { data } = useBackend();
  const { max_capacity, held_power, input_total, max_grid_load } = data;

  return (
    <Section title="Status">
      <LabeledList>
        <LabeledList.Item label="Reserve energy">
          {held_power ? formatSiUnit(held_power, 0, 'J') : '0 J'}
        </LabeledList.Item>
      </LabeledList>
      <ProgressBar
        mt="0.5em"
        mb="0.5em"
        ranges={{
          good: [0.8, Infinity],
          average: [0.5, 0.8],
          bad: [-Infinity, 0.5],
        }}
        value={held_power / max_capacity}
      />
      <LabeledList>
        <LabeledList.Item label="Grid Saturation" />
      </LabeledList>
      <ProgressBar
        mt="0.5em"
        ranges={{
          good: [0.8, Infinity],
          average: [0.5, 0.8],
          bad: [-Infinity, 0.5],
        }}
        value={Math.min(input_total, max_capacity - held_power) / max_grid_load}
      />
    </Section>
  );
};

const InputControls = (props) => {
  const { act, data } = useBackend();
  const { input_total, accepting_power, sucking_power, input_number, power_format } = data;

  return (
    <Section title="Input Controls">
      <LabeledList>
        <LabeledList.Item
          label="Input Circuit"
          buttons={
            <Button icon="power-off" color={accepting_power ? 'green' : 'red'} onClick={() => act('toggle_input')}>
              {accepting_power ? 'Enabled' : 'Disabled'}
            </Button>
          }
        >
          <Box color={(sucking_power && 'good') || (accepting_power && 'average') || 'bad'}>
            {(sucking_power && 'Online') || (accepting_power && 'Idle') || 'Offline'}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Input Level">{input_total ? formatPower(input_total) : '0 W'}</LabeledList.Item>
      </LabeledList>
      <Box mt="0.5em">
        <NumberInput
          mr="0.5em"
          animated
          size={1.25}
          inline
          step={1}
          stepPixelSize={2}
          minValue={0}
          maxValue={999}
          value={input_number}
          onChange={(set_input) => act('set_input', { set_input })}
        />
        <Button selected={power_format === 1} onClick={() => act('inputW')}>
          W
        </Button>
        <Button selected={power_format === 10 ** 3} onClick={() => act('inputKW')}>
          KW
        </Button>
        <Button selected={power_format === 10 ** 6} onClick={() => act('inputMW')}>
          MW
        </Button>
        <Button selected={power_format === 10 ** 9} onClick={() => act('inputGW')}>
          GW
        </Button>
      </Box>
    </Section>
  );
};

const OutputControls = (props) => {
  const { act, data } = useBackend();
  const { output_total, firing, accepting_power, output_number, output_multiplier, target, held_power } = data;

  return (
    <Section title="Output Controls">
      <LabeledList>
        <LabeledList.Item
          label="Laser Circuit"
          buttons={
            <Stack>
              <Button icon="crosshairs" color={target === '' ? 'green' : 'red'} onClick={() => act('target')}>
                {target}
              </Button>
              <Button
                icon="power-off"
                color={firing ? 'green' : 'red'}
                disabled={!firing && held_power < 10 ** 6}
                onClick={() => act('toggle_output')}
              >
                {firing ? 'Enabled' : 'Disabled'}
              </Button>
            </Stack>
          }
        >
          <Box color={(firing && 'good') || (accepting_power && 'average') || 'bad'}>
            {(firing && 'Online') || (accepting_power && 'Idle') || 'Offline'}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Output Level">
          {output_total
            ? output_total < 0
              ? '-' + formatPower(Math.abs(output_total))
              : formatPower(output_total)
            : '0 W'}
        </LabeledList.Item>
      </LabeledList>
      <Box mt="0.5em">
        <NumberInput
          mr="0.5em"
          size={1.25}
          animated
          inline
          step={1}
          stepPixelSize={2}
          minValue={0}
          maxValue={999}
          ranges={{ bad: [-Infinity, -1] }}
          value={output_number}
          onChange={(set_output) => act('set_output', { set_output })}
        />
        <Button selected={output_multiplier === 10 ** 6} onClick={() => act('outputMW')}>
          MW
        </Button>
        <Button selected={output_multiplier === 10 ** 9} onClick={() => act('outputGW')}>
          GW
        </Button>
      </Box>
    </Section>
  );
};
