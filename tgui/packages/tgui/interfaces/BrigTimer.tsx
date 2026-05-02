import { ReactNode, useState } from 'react';
import { Box, Button, Divider, Dropdown, LabeledList, Section, Stack } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

interface SpaceLawEntry {
  name: string;
  description?: string;
  severity: string;
  timeAdded?: number;
  timeMultiplier?: number;
}

interface Severity {
  minTime: number;
  maxTime: number;
}

interface SpaceLaw {
  codes: Record<string, Record<string, SpaceLawEntry>>;
  modifiers: Record<string, Record<string, SpaceLawEntry>>;
  severities: Record<string, Severity>;
}

declare const spaceLaw: SpaceLaw;

interface BrigData {
  isAllowed: boolean;
  timing: boolean;
  cell_id?: string;
  occupant?: string;
  crimes?: string;
  brigged_by?: string;
  time_set?: string;
  time_left?: string;
  prisoner_name?: string;
  prisoner_notes?: string;
  prisoner_time?: string;
  prisoner_hasrec?: boolean;
  spns: string[];
  all_crimes: Record<string, Record<string, any>>;
  all_modifiers: Record<string, Record<string, any>>;
  nameText?: ReactNode;
}

export const BrigTimer = (props: any) => {
  const { act, data } = useBackend<BrigData>();

  const [selectedCrimes, setSelectedCrimes] = useState<Record<string, string | null>>(
    Object.fromEntries(Object.keys(spaceLaw.codes).map((code) => [code, null]))
  );

  const [selectedModifiers, setSelectedModifiers] = useState<Record<string, string | null>>(
    Object.fromEntries(Object.keys(spaceLaw.modifiers).map((modifier) => [modifier, null]))
  );

  const formattedCrimes = Object.entries(selectedCrimes)
    .filter(([_, value]) => value !== null)
    .map(([code, crime]) => spaceLaw.codes[code][crime!].name)
    .join(', ');

  const formattedModifiers = Object.entries(selectedModifiers)
    .filter(([_, value]) => value !== null)
    .map(([modifierGroup, modifier]) => spaceLaw.modifiers[modifierGroup][modifier!].name)
    .join(', ');

  const crimeSummary =
    (data.prisoner_notes
      ? data.prisoner_notes && formattedCrimes
        ? `${data.prisoner_notes} - `
        : data.prisoner_notes
      : '') +
    (formattedCrimes ? formattedCrimes : '') +
    (formattedModifiers ? ` (${formattedModifiers})` : '');

  const baseTimer = Object.entries(selectedCrimes)
    .filter(([_, value]) => value !== null)
    .map(([code, crime]) => spaceLaw.codes[code][crime!].severity)
    .map((testingseverity) => spaceLaw.severities[testingseverity])
    .reduce((acc, val) => ({ minTime: acc.minTime + val.minTime, maxTime: acc.maxTime + val.maxTime }), {
      minTime: 0,
      maxTime: 0,
    });

  const baseModifiers = Object.entries(selectedModifiers)
    .filter(([_, value]) => value !== null)
    .map(([modifierGroup, modifier]) => spaceLaw.modifiers[modifierGroup][modifier!]);

  const summedTimer = baseModifiers.reduce(
    (acc, val) => ({ minTime: acc.minTime + (val.timeAdded ?? 0), maxTime: acc.maxTime + (val.timeAdded ?? 0) }),
    baseTimer
  );

  const multipliedTimer = baseModifiers.reduce(
    (acc, val) => ({
      minTime: acc.minTime * (val.timeMultiplier ?? 1),
      maxTime: acc.maxTime * (val.timeMultiplier ?? 1),
    }),
    summedTimer
  );

  const suggestedTime = {
    suggestedMin: Math.min(Math.ceil(multipliedTimer.minTime), 60),
    suggestedMax: Math.min(Math.ceil(multipliedTimer.maxTime), 60),
  };

  const formatSuggestedTimer = ({ suggestedMin, suggestedMax }: { suggestedMin: number; suggestedMax: number }) => {
    if (suggestedMin === 60 && suggestedMax === 60) return 'Permanent Confinement';
    if (suggestedMax === 60) return `${suggestedMin} Minutes to Permanent Confinement`;
    if (suggestedMin === suggestedMax && suggestedMin !== 0) return `${suggestedMin} Minutes`;
    if (suggestedMin && suggestedMax) return `${suggestedMin} to ${suggestedMax} Minutes`;
    return 'Select Crimes for Suggestion';
  };

  const formattedSuggestedTimer = formatSuggestedTimer(suggestedTime);

  let nameText: ReactNode = data.occupant;
  if (data.timing) {
    nameText = <Box color={data.prisoner_hasrec ? 'green' : 'red'}>{data.occupant}</Box>;
  }

  let nameIcon = 'pencil-alt';
  if (data.prisoner_name && !data.prisoner_hasrec) {
    nameIcon = 'exclamation-triangle';
  }

  return (
    <Window width={580} height={data.timing ? 270 : 710}>
      <Window.Content scrollable>
        {data.timing ? (
          <Stack fill>
            <Section title="Cell Information" fill>
              <LabeledList>
                <LabeledList.Item label="Cell ID">{data.cell_id}</LabeledList.Item>
                <LabeledList.Item label="Occupant">{nameText}</LabeledList.Item>
                <LabeledList.Item label="Crimes">{data.crimes}</LabeledList.Item>
                <LabeledList.Item label="Brigged By">{data.brigged_by}</LabeledList.Item>
                <LabeledList.Item label="Time Brigged For">{data.time_set}</LabeledList.Item>
                <LabeledList.Item label="Time Left">{data.time_left}</LabeledList.Item>
                <LabeledList.Item label="Actions">
                  <Stack fill>
                    <Stack.Item grow={1} basis={0}>
                      <Button
                        fluid
                        icon="lightbulb-o"
                        content="Flash"
                        disabled={!data.isAllowed}
                        onClick={() => act('flash')}
                      />
                    </Stack.Item>
                    <Stack.Item grow={1} basis={0}>
                      <Button
                        fluid
                        icon="plus"
                        content="+10m"
                        disabled={!data.timing || !data.isAllowed}
                        onClick={() => act('add_time')}
                      />
                    </Stack.Item>
                    <Stack.Item grow={1} basis={0}>
                      <Button
                        fluid
                        icon="sync"
                        content="Reset"
                        disabled={!data.timing || !data.isAllowed}
                        onClick={() => act('restart_timer')}
                      />
                    </Stack.Item>
                    <Stack.Item grow={1} basis={0}>
                      <Button
                        fluid
                        icon="eject"
                        content="Release"
                        disabled={!data.timing || !data.isAllowed}
                        onClick={() => act('stop')}
                      />
                    </Stack.Item>
                  </Stack>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack>
        ) : (
          <Stack vertical fill>
            <Stack.Item>
              <Section title="New Prisoner">
                <Stack fill>
                  <Stack.Item grow={1} basis={0}>
                    <LabeledList>
                      <LabeledList.Item label="Prisoner Name">
                        <Button
                          fluid
                          icon={nameIcon}
                          content={data.prisoner_name ? data.prisoner_name : '-----'}
                          disabled={!data.isAllowed}
                          onClick={() => act('prisoner_name')}
                        />
                        {!!data.spns.length && (
                          <Box mt="0.3rem">
                            <Dropdown
                              fluid
                              disabled={!data.isAllowed || !data.spns.length}
                              options={data.spns}
                              selected={data.prisoner_name}
                              onSelected={(value) => act('prisoner_name', { prisoner_name: value })}
                            />
                          </Box>
                        )}
                      </LabeledList.Item>
                      <LabeledList.Item label="Notes">
                        <Button
                          fluid
                          icon="pencil-alt"
                          content={data.prisoner_notes ? data.prisoner_notes : '-----'}
                          disabled={!data.isAllowed}
                          onClick={() => act('prisoner_notes')}
                        />
                      </LabeledList.Item>
                      <LabeledList.Item label="Timer">{formattedSuggestedTimer}</LabeledList.Item>
                      <LabeledList.Item label="Set Time">
                        <Button
                          fluid
                          icon="clock-o"
                          content={data.prisoner_time ? data.prisoner_time : '-----'}
                          disabled={!data.isAllowed}
                          onClick={() => act('prisoner_time')}
                        />
                      </LabeledList.Item>
                      <LabeledList.Item label="Action">
                        <Button
                          fluid
                          icon="gavel"
                          content="Start Sentence"
                          color="success"
                          disabled={!data.prisoner_name || !crimeSummary || !data.prisoner_time || !data.isAllowed}
                          onClick={() => act('start', { final_crimes: crimeSummary })}
                        />
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                  <Stack.Item grow={1} basis={0} ml={2}>
                    <Box bold color="label">
                      Selected Charges:
                    </Box>
                    <Box italic>{formattedCrimes || 'None'}</Box>
                    <Divider />
                    <Box bold color="label">
                      Modifiers:
                    </Box>
                    <Box italic>{formattedModifiers || 'N/A'}</Box>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
            <Stack.Item grow={1}>
              <Section title="Law Selection">
                <Stack vertical fill>
                  <Box textAlign="center" bold color="label" mb={1}>
                    CRIMES
                  </Box>
                  {Object.entries(data.all_crimes).map(([code, category]) => (
                    <Stack.Item key={code}>
                      <Stack fill>
                        {Object.entries(category).map(([key, crime]) => (
                          <Stack.Item grow={1} basis={0} key={key}>
                            <Button
                              fluid
                              textAlign="center"
                              tooltip={crime.description}
                              selected={selectedCrimes[code] === key}
                              onClick={() =>
                                setSelectedCrimes({
                                  ...selectedCrimes,
                                  [code]: selectedCrimes[code] === key ? null : key,
                                })
                              }
                            >
                              {crime.name}
                            </Button>
                          </Stack.Item>
                        ))}
                      </Stack>
                    </Stack.Item>
                  ))}
                  <Divider />
                  <Box textAlign="center" bold color="label" mb={1}>
                    MODIFIERS
                  </Box>
                  {Object.entries(data.all_modifiers).map(([modifierGroup, category]) => (
                    <Stack.Item key={modifierGroup}>
                      <Stack fill>
                        {Object.entries(category).map(([key, modifier]) => (
                          <Stack.Item grow={1} basis={0} key={key}>
                            <Button
                              fluid
                              textAlign="center"
                              tooltip={modifier.description}
                              color={selectedModifiers[modifierGroup] === key ? 'green' : ''}
                              onClick={() =>
                                setSelectedModifiers({
                                  ...selectedModifiers,
                                  [modifierGroup]: selectedModifiers[modifierGroup] === key ? null : key,
                                })
                              }
                            >
                              {modifier.name}
                            </Button>
                          </Stack.Item>
                        ))}
                      </Stack>
                    </Stack.Item>
                  ))}
                </Stack>
              </Section>
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};
