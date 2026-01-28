import { useState } from 'react';
import { Box, Button, Divider, Dropdown, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { spaceLaw } from './common/SpaceLaw';

export const BrigTimer = (props) => {
  const { act, data } = useBackend();
  const [selectedCrimes, setSelectedCrimes] = useState(
    Object.fromEntries(Object.keys(spaceLaw.codes).map((code) => [code, null]))
  );

  const [selectedModifiers, setSelectedModifiers] = useState(
    Object.fromEntries(Object.keys(spaceLaw.modifiers).map((modifier) => [modifier, null]))
  );

  const formattedCrimes = Object.entries(selectedCrimes)
    .filter(([_, value]) => value !== null)
    .map(([code, crime]) => spaceLaw.codes[code][crime].name)
    .join(', ');

  const formattedModifiers = Object.entries(selectedModifiers)
    .filter(([_, value]) => value !== null)
    .map(([modifierGroup, modifier]) => spaceLaw.modifiers[modifierGroup][modifier].name)
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
    .map(([code, crime]) => spaceLaw.codes[code][crime].severity)
    .map((testingseverity) => spaceLaw.severities[testingseverity])
    .reduce((acc, val) => ({ minTime: acc.minTime + val.minTime, maxTime: acc.maxTime + val.maxTime }), {
      minTime: 0,
      maxTime: 0,
    });

  const baseModifiers = Object.entries(selectedModifiers)
    .filter(([_, value]) => value !== null)
    .map(([modifierGroup, modifier]) => spaceLaw.modifiers[modifierGroup][modifier]);

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

  const formatSuggestedTimer = ({ suggestedMin, suggestedMax }) => {
    if (suggestedMin === 60 && suggestedMax === 60) return 'Permanent Confinement';
    if (suggestedMax === 60) return `${suggestedMin} Minutes to Permanent Confinement`;
    if (suggestedMin === suggestedMax && suggestedMin !== 0) return `${suggestedMin} Minutes`;
    if (suggestedMin && suggestedMax) return `${suggestedMin} to ${suggestedMax} Minutes`;
    return 'Select Crimes for Suggestion';
  };

  const formattedSuggestedTimer = formatSuggestedTimer(suggestedTime);

  data.nameText = data.occupant;
  if (data.timing) {
    if (data.prisoner_hasrec) {
      data.nameText = <Box color="green">{data.occupant}</Box>;
    } else {
      data.nameText = <Box color="red">{data.occupant}</Box>;
    }
  }

  let nameIcon = 'pencil-alt';
  if (data.prisoner_name) {
    if (!data.prisoner_hasrec) {
      nameIcon = 'exclamation-triangle';
    }
  }

  let nameOptions = [];
  let i = 0;
  for (i = 0; i < data.spns.length; i++) {
    nameOptions.push(data.spns[i]);
  }

  return (
    <Window width={560} height={data.timing ? 270 : 710}>
      <Window.Content scrollable>
        {data.timing ? (
          <Stack fill>
            <Section title="Cell Information" grow>
              <LabeledList>
                <LabeledList.Item label="Cell ID">{data.cell_id}</LabeledList.Item>
                <LabeledList.Item label="Occupant">{data.nameText}</LabeledList.Item>
                <LabeledList.Item label="Crimes">{data.crimes}</LabeledList.Item>
                <LabeledList.Item label="Brigged By">{data.brigged_by}</LabeledList.Item>
                <LabeledList.Item label="Time Brigged For">{data.time_set}</LabeledList.Item>
                <LabeledList.Item label="Time Left">{data.time_left}</LabeledList.Item>
                <LabeledList.Item label="Actions">
                  <Button icon="lightbulb-o" content="Flash" disabled={!data.isAllowed} onClick={() => act('flash')} />
                  <Button
                    icon="plus"
                    content="Add 10 Minutes"
                    disabled={!data.timing || !data.isAllowed}
                    onClick={() => act('add_time')}
                  />
                  <Button
                    icon="sync"
                    content="Reset Timer"
                    disabled={!data.timing || !data.isAllowed}
                    onClick={() => act('restart_timer')}
                  />
                  <Button
                    icon="eject"
                    content="Release Prisoner"
                    disabled={!data.timing || !data.isAllowed}
                    onClick={() => act('stop')}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack>
        ) : (
          <Stack vertical fill>
            <Stack.Item>
              <Section title="New Prisoner">
                <Stack horizontal>
                  <Stack.Item>
                    <LabeledList>
                      <LabeledList.Item label="Prisoner Name">
                        <Button
                          icon={nameIcon}
                          ellipsis
                          maxWidth="190px"
                          content={data.prisoner_name ? data.prisoner_name : '-----'}
                          disabled={!data.isAllowed}
                          onClick={() => act('prisoner_name')}
                        />
                        {!!data.spns.length && (
                          <Box mt="0.3rem">
                            <Dropdown
                              disabled={!data.isAllowed || !data.spns.length}
                              options={data.spns}
                              width="150px"
                              onSelected={(value) =>
                                act('prisoner_name', {
                                  prisoner_name: value,
                                })
                              }
                            />
                          </Box>
                        )}
                      </LabeledList.Item>
                      <LabeledList.Item label="Prisoner Notes">
                        <Button
                          icon="pencil-alt"
                          ellipsis
                          maxWidth="190px"
                          wrap
                          content={data.prisoner_notes ? data.prisoner_notes : '-----'}
                          disabled={!data.isAllowed}
                          onClick={() => act('prisoner_notes')}
                        />
                      </LabeledList.Item>
                      <LabeledList.Item label="Suggested Timer">{formattedSuggestedTimer}</LabeledList.Item>
                      <LabeledList.Item label="Prisoner Time">
                        <Button
                          icon="pencil-alt"
                          content={data.prisoner_time ? data.prisoner_time : '-----'}
                          disabled={!data.isAllowed}
                          onClick={() => act('prisoner_time')}
                        />
                      </LabeledList.Item>
                      <LabeledList.Item label="Start">
                        <Button
                          icon="gavel"
                          content="Start Sentence"
                          disabled={!data.prisoner_name || !crimeSummary || !data.prisoner_time || !data.isAllowed}
                          onClick={() => act('start', { final_crimes: crimeSummary })}
                        />
                      </LabeledList.Item>
                      <LabeledList.Item />
                    </LabeledList>
                  </Stack.Item>
                  <Stack.Item grow>
                    <Box bold>Crimes:</Box>
                    <Box>{formattedCrimes}</Box>
                    <Divider grow />
                    <Box bold>Modifiers:</Box>
                    <Box>{formattedModifiers ? formattedModifiers : 'N/A'}</Box>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
            <Stack.Item grow>
              <Section title="Quick Timer">
                <Stack vertical>
                  <Stack.Item align="center">
                    <Box bold>Crimes</Box>
                  </Stack.Item>
                  {Object.entries(spaceLaw.codes).map(([code, category]) => (
                    <Stack.Item key={code}>
                      <Stack>
                        {Object.entries(category).map(([key, crime]) => (
                          <Stack.Item key={key}>
                            <Button
                              tooltip={crime.description}
                              onClick={() => {
                                setSelectedCrimes(
                                  selectedCrimes[code] === key
                                    ? { ...selectedCrimes, [code]: null }
                                    : { ...selectedCrimes, [code]: key }
                                );
                              }}
                              selected={selectedCrimes[code] === key}
                            >
                              {crime.name}
                            </Button>
                          </Stack.Item>
                        ))}
                      </Stack>
                    </Stack.Item>
                  ))}
                  <Divider />
                  <Stack.Item align="center">
                    <Box bold>Modifiers</Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Box>
                      <Stack vertical>
                        {Object.entries(spaceLaw.modifiers).map(([modifierGroup, category]) => (
                          <Stack.Item key={modifierGroup}>
                            <Stack>
                              {Object.entries(category).map(([key, modifier]) => (
                                <Stack.Item key={key}>
                                  <Button
                                    tooltip={modifier.description}
                                    onClick={() => {
                                      setSelectedModifiers(
                                        selectedModifiers[modifierGroup] === key
                                          ? { ...selectedModifiers, [modifierGroup]: null }
                                          : { ...selectedModifiers, [modifierGroup]: key }
                                      );
                                    }}
                                    color={selectedModifiers[modifierGroup] === key ? 'green' : ''}
                                  >
                                    {modifier.name}
                                  </Button>
                                </Stack.Item>
                              ))}
                            </Stack>
                          </Stack.Item>
                        ))}
                      </Stack>
                    </Box>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};
