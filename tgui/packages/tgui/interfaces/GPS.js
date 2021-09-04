import { rad2deg } from 'common/math';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Icon, Input, LabeledList, Section, Table } from '../components';
import { Window } from '../layouts';

const vectorText = vector => vector ? "(" + vector.join(", ") + ")" : "ERROR";

const distanceToPoint = (from, to, upgr) => {
  if (!from || !to) {
    return;
  }

  // Different Z-level or not UP
  if (from[2] !== to[2] || upgr !== 1) {
    return null;
  }

  const angle = Math.atan2(to[1] - from[1], to[0] - from[0]);
  const dist = Math.sqrt(Math.pow(to[1] - from[1], 2) + Math.pow(to[0] - from[0], 2));
  return { angle: rad2deg(angle), distance: dist };
};

export const GPS = (properties, context) => {
  const { data } = useBackend(context);
  const {
    emped,
    active,
    area,
    position,
    saved,
  } = data;
  return (
    <Window>
      <Window.Content>
        <Flex direction="column" height="100%">
          {emped ? (
            <Flex.Item grow="1" basis="0">
              <TurnedOff emp />
            </Flex.Item>
          ) : (
            <Fragment>
              <Flex.Item>
                <Settings />
              </Flex.Item>
              {active ? (
                <Fragment>
                  <Flex.Item mt="0.5rem">
                    <Position area={area} position={position} />
                  </Flex.Item>
                  {saved && (
                    <Flex.Item mt="0.5rem">
                      <Position title="Saved Position" position={saved} />
                    </Flex.Item>
                  )}
                  <Flex.Item mt="0.5rem" grow="1" basis="0">
                    <Signals height="100%" />
                  </Flex.Item>
                </Fragment>
              ) : (
                <TurnedOff />
              )}
            </Fragment>
          )}
        </Flex>
      </Window.Content>
    </Window>
  );
};

const TurnedOff = ({ emp }, context) => {
  return (
    <Section
      mt="0.5rem"
      width="100%"
      height="100%"
      stretchContents>
      <Box
        width="100%"
        height="100%"
        color="label"
        textAlign="center">
        <Flex height="100%">
          <Flex.Item grow="1" align="center" color="label">
            <Icon
              name={emp ? "ban": "power-off"}
              mb="0.5rem"
              size="5"
            /><br />
            {emp
              ? "ERROR: Device temporarily lost signal."
              : "Device is disabled."}
          </Flex.Item>
        </Flex>
      </Box>
    </Section>
  );
};

const Settings = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    active,
    tag,
    same_z,
  } = data;
  const [newTag, setNewTag] = useLocalState(context, "newTag", tag);
  return (
    <Section
      title="Settings"
      buttons={
        <Button
          selected={active}
          icon={active ? "toggle-on" : "toggle-off"}
          content={active ? "On" : "Off"}
          onClick={() => act('toggle')}
        />
      }>
      <LabeledList>
        <LabeledList.Item label="Tag">
          <Input
            width="5rem"
            value={tag}
            onEnter={() => act('tag', { newtag: newTag })}
            onInput={(e, value) => setNewTag(value)}
          />
          <Button
            disabled={tag === newTag}
            width="20px"
            mb="0"
            ml="0.25rem"
            onClick={() => act('tag', { newtag: newTag })}>
            <Icon name="pen" />
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Range">
          <Button
            selected={!same_z}
            icon={same_z ? "compress" : "expand"}
            content={same_z ? "Local Sector" : "Global"}
            onClick={() => act('same_z')}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const Position = ({ title, area, position }, context) => {
  return (
    <Section title={title || "Position"}>
      <Box fontSize="1.5rem">
        {area && (
          <Fragment>
            {area}
            <br />
          </Fragment>
        )}
        {vectorText(position)}
      </Box>
    </Section>
  );
};

const Signals = (properties, context) => {
  const { data } = useBackend(context);
  const {
    position,
    signals,
    upgraded,
  } = data;
  return (
    <Section
      title="Signals"
      overflow="auto"
      {...properties}>
      <Table>
        {signals
          .map(signal => ({
            ...signal,
            ...distanceToPoint(position, signal.position, upgraded),
          }))
          .map((signal, i) => (
            <Table.Row
              key={i}
              backgroundColor={(i % 2 === 0) && "rgba(255, 255, 255, 0.05)"}>
              <Table.Cell
                width="30%"
                verticalAlign="middle"
                color="label"
                p="0.25rem"
                bold>
                {signal.tag}
              </Table.Cell>
              <Table.Cell
                verticalAlign="middle"
                color="grey">
                {signal.area}
              </Table.Cell>
              <Table.Cell
                verticalAlign="middle"
                collapsing>
                {signal.distance !== undefined && (
                  <Box opacity={Math.max(1 - Math.min(signal.distance, 100) / 100, 0.5)}>
                    <Icon
                      name={signal.distance > 0 ? "arrow-right" : "circle"}
                      rotation={-signal.angle}
                    />&nbsp;
                    {Math.floor(signal.distance) + "m"}
                  </Box>
                )}
              </Table.Cell>
              <Table.Cell
                verticalAlign="middle"
                pr="0.25rem"
                collapsing>
                {vectorText(signal.position)}
              </Table.Cell>
            </Table.Row>
          ))}
      </Table>
    </Section>
  );
};
