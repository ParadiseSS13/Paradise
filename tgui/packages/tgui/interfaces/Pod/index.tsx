import {
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { formatSiUnit } from 'tgui-core/format';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { MainData } from './types';

export const Pod = () => {
  return (
    <Window theme={'ntos'} width={800} height={300}>
      <Window.Content>
        <Content />
      </Window.Content>
    </Window>
  );
};

export const Content = () => {
  const { act, data } = useBackend<MainData>();
  const { name } = data;
  return (
    <Stack fill>
      <Stack.Item grow={1}>
        <Stack vertical fill>
          <Stack.Item grow overflow="hidden">
            <Section
              fill
              title={name}
              buttons={
                <Button
                  icon="edit"
                  tooltip="Rename"
                  tooltipPosition="left"
                  onClick={() => act('changename')}
                />
              }
            >
              <Stack fill vertical>
                <Stack.Item>
                  <LabeledList>
                    <IntegrityBar />
                    <PowerBar />
                    <LightsBar />
                    <DNALock />
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const PowerBar = (props) => {
  const { data } = useBackend<MainData>();
  const { power_level, power_max } = data;
  return (
    <LabeledList.Item label="Fuel">
      <ProgressBar
        value={power_max ? power_level / power_max : 0}
        ranges={{
          good: [0.5, Infinity],
          average: [0.25, 0.5],
          bad: [-Infinity, 0.25],
        }}
        style={{
          textShadow: '1px 1px 0 black',
        }}
      >
        {power_max === null
          ? 'Fuel Tank Missing'
          : power_level === 1e31
            ? 'Infinite'
            : `${formatSiUnit(power_level * 1000, 0, 'L')} of ${formatSiUnit(
                power_max * 1000,
                0,
                'L',
              )}`}
      </ProgressBar>
    </LabeledList.Item>
  );
};

const IntegrityBar = (props) => {
  const { data } = useBackend<MainData>();
  const { integrity, integrity_max } = data;
  return (
    <LabeledList.Item label="Integrity">
      <ProgressBar
        value={integrity / integrity_max}
        ranges={{
          good: [0.5, Infinity],
          average: [0.25, 0.5],
          bad: [-Infinity, 0.25],
        }}
        style={{
          textShadow: '1px 1px 0 black',
        }}
      >
        {`${integrity} of ${integrity_max}`}
      </ProgressBar>
    </LabeledList.Item>
  );
};

const LightsBar = (props) => {
  const { act, data } = useBackend<MainData>();
  const { mecha_flags, mechflag_keys } = data;
  const lights_on = mecha_flags & mechflag_keys['LIGHTS_ON'];
  return (
    <LabeledList.Item label="Lights">
      <Button
        icon="lightbulb"
        content={lights_on ? 'On' : 'Off'}
        selected={lights_on}
        onClick={() => act('toggle_lights')}
      />
    </LabeledList.Item>
  );
};

const DNALock = (props) => {
  const { act, data } = useBackend<MainData>();
  const { dna_lock } = data;
  return (
    <LabeledList.Item label="DNA Lock">
      <Button
        onClick={() => act('dna_lock')}
        icon="syringe"
        content={dna_lock ? 'Enabled' : 'Unset'}
        tooltip="Set new DNA key"
        selected={!!dna_lock}
        tooltipPosition="top"
      />
      {!!dna_lock && (
        <>
          <Button
            icon="key"
            tooltip={`Key enzyme: ${dna_lock}`}
            tooltipPosition="top"
            disabled={!dna_lock}
          />
          <Button
            onClick={() => act('reset_dna')}
            icon="ban"
            tooltip="Reset DNA lock"
            tooltipPosition="top"
            disabled={!dna_lock}
          />
        </>
      )}
    </LabeledList.Item>
  );
};
