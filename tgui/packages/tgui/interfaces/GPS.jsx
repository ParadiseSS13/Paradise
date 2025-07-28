import { useState } from 'react';
import { Box, Button, Icon, Input, LabeledList, Section, Stack, Table } from 'tgui-core/components';
import { rad2deg } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const vectorText = (vector) => (vector ? '(' + vector.join(', ') + ')' : 'ERROR');

const distanceToPoint = (from, to) => {
  if (!from || !to) {
    return;
  }

  // Different Z-level
  if (from[2] !== to[2]) {
    return null;
  }

  const angle = Math.atan2(to[1] - from[1], to[0] - from[0]);
  const dist = Math.sqrt(Math.pow(to[1] - from[1], 2) + Math.pow(to[0] - from[0], 2));
  return { angle: rad2deg(angle), distance: dist };
};

export const GPS = (properties) => {
  const { data } = useBackend();
  const { emped, active, area, position, saved } = data;
  return (
    <Window width={400} height={600}>
      <Window.Content>
        <Stack fill vertical>
          {emped ? (
            <Stack.Item grow basis="0">
              <TurnedOff emp />
            </Stack.Item>
          ) : (
            <>
              <Stack.Item>
                <Settings />
              </Stack.Item>
              {active ? (
                <>
                  <Stack.Item>
                    <Position area={area} position={position} />
                  </Stack.Item>
                  {saved && (
                    <Stack.Item>
                      <Position title="Saved Position" position={saved} />
                    </Stack.Item>
                  )}
                  <Stack.Item grow basis="0">
                    <Signals height="100%" />
                  </Stack.Item>
                </>
              ) : (
                <TurnedOff />
              )}
            </>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const TurnedOff = ({ emp }) => {
  return (
    <Section fill>
      <Box width="100%" height="100%" color="label" textAlign="center">
        <Stack fill>
          <Stack.Item grow align="center" color="label">
            <Icon name={emp ? 'ban' : 'power-off'} mb="0.5rem" size="5" />
            <br />
            {emp ? 'ERROR: Device temporarily lost signal.' : 'Device is disabled.'}
          </Stack.Item>
        </Stack>
      </Box>
    </Section>
  );
};

const Settings = (properties) => {
  const { act, data } = useBackend();
  const { active, tag, same_z } = data;
  const [newTag, setNewTag] = useState(tag);
  return (
    <Section
      title="Settings"
      buttons={
        <Button
          selected={active}
          icon={active ? 'toggle-on' : 'toggle-off'}
          content={active ? 'On' : 'Off'}
          onClick={() => act('toggle')}
        />
      }
    >
      <LabeledList>
        <LabeledList.Item label="Tag">
          <Input
            width="5rem"
            value={tag}
            onEnter={() => act('tag', { newtag: newTag })}
            onChange={(value) => setNewTag(value)}
          />
          <Button
            disabled={tag === newTag}
            width="20px"
            mb="0"
            ml="0.25rem"
            onClick={() => act('tag', { newtag: newTag })}
          >
            <Icon name="pen" />
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Range">
          <Button
            selected={!same_z}
            icon={same_z ? 'compress' : 'expand'}
            content={same_z ? 'Local Sector' : 'Global'}
            onClick={() => act('same_z')}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const Position = ({ title, area, position }) => {
  return (
    <Section title={title || 'Position'}>
      <Box fontSize="1.5rem">
        {area && (
          <>
            {area}
            <br />
          </>
        )}
        {vectorText(position)}
      </Box>
    </Section>
  );
};

const Signals = (properties) => {
  const { data } = useBackend();
  const { position, signals } = data;
  return (
    <Section fill scrollable title="Signals" {...properties}>
      <Table>
        {signals
          .map((signal) => ({
            ...signal,
            ...distanceToPoint(position, signal.position),
          }))
          .map((signal, i) => (
            <Table.Row key={i} backgroundColor={i % 2 === 0 && 'rgba(255, 255, 255, 0.05)'}>
              <Table.Cell width="30%" verticalAlign="middle" color="label" p="0.25rem" bold>
                {signal.tag}
              </Table.Cell>
              <Table.Cell verticalAlign="middle" color="grey">
                {signal.area}
              </Table.Cell>
              <Table.Cell verticalAlign="middle" collapsing>
                {signal.distance !== undefined && (
                  <Box opacity={Math.max(1 - Math.min(signal.distance, 100) / 100, 0.5)}>
                    <Icon name={signal.distance > 0 ? 'arrow-right' : 'circle'} rotation={-signal.angle} />
                    &nbsp;
                    {Math.floor(signal.distance) + 'm'}
                  </Box>
                )}
                {signal.due !== undefined && (
                  <Box>
                    <Icon name={'arrow-up'} rotation={signal.due} />
                    &nbsp;--
                  </Box>
                )}
              </Table.Cell>
              <Table.Cell verticalAlign="middle" pr="0.25rem" collapsing>
                {vectorText(signal.position)}
              </Table.Cell>
            </Table.Row>
          ))}
      </Table>
    </Section>
  );
};
