import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Icon,
  Input,
  LabeledList,
  Modal,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Countdown } from '../components';
import { Window } from '../layouts';

// __DEFINES/construction.dm, L73
const MINERAL_MATERIAL_AMOUNT = 2000;

const iconNameOverrides = {
  bananium: 'clown',
  tranquillite: 'mime',
};

export const ExosuitFabricator = (properties) => {
  const { act, data } = useBackend();
  const { building, linked } = data;
  const [showLevelsModal, setShowLevelsModal] = useState(false);

  if (!linked) {
    return <LinkMenu />;
  }

  return (
    <Window width={950} height={625}>
      <Window.Content className="Exofab">
        <LevelsModal showLevelsModal={showLevelsModal} setShowLevelsModal={setShowLevelsModal} />
        <Stack fill>
          <Stack.Item grow>
            <Stack fill vertical>
              <Stack.Item grow>
                <Designs setShowLevelsModal={setShowLevelsModal} />
              </Stack.Item>
              {building && (
                <Stack.Item>
                  <Building />
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
          <Stack.Item width="30%">
            <Stack fill vertical>
              <Stack.Item grow>
                <Materials />
              </Stack.Item>
              <Stack.Item grow>
                <Queue />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Materials = (properties) => {
  const { act, data } = useBackend();
  const { materials, capacity } = data;
  const totalMats = Object.values(materials).reduce((a, b) => a + b, 0);
  return (
    <Section
      fill
      scrollable
      title="Materials"
      className="Exofab__materials"
      buttons={
        <Box color="label" mt="0.25rem">
          {((totalMats / capacity) * 100).toPrecision(3)}% full
        </Box>
      }
    >
      {[
        'metal',
        'glass',
        'silver',
        'gold',
        'uranium',
        'titanium',
        'plasma',
        'diamond',
        'bluespace',
        'bananium',
        'tranquillite',
        'plastic',
      ].map((name) => (
        <MaterialCount
          mt={-2}
          key={name}
          id={name}
          bold={name === 'metal' || name === 'glass'}
          onClick={() =>
            act('withdraw', {
              id: name,
            })
          }
        />
      ))}
    </Section>
  );
};

const Designs = (properties) => {
  const { act, data } = useBackend();
  const { curCategory, categories, designs, syncing } = data;
  const [searchText, setSearchText] = useState('');
  const searcher = createSearch(searchText, (design) => {
    return design.name;
  });
  const filteredDesigns = designs.filter(searcher);
  const { setShowLevelsModal } = properties;
  return (
    <Section
      fill
      scrollable
      className="Exofab__designs"
      title={
        <Stack fill fontSize={1} align="center">
          <Stack.Item>
            <Dropdown
              width={19}
              selected={curCategory}
              options={categories}
              onSelected={(cat) =>
                act('category', {
                  cat: cat,
                })
              }
            />
          </Stack.Item>
          <Stack.Item grow />
          <Stack.Item>
            <Button icon="plus" content="Queue all" onClick={() => act('queueall')} />
          </Stack.Item>
          <Stack.Item>
            <Button icon="info" content="Show current tech levels" onClick={() => setShowLevelsModal(true)} />
          </Stack.Item>
          <Stack.Item>
            <Button icon="unlink" color="red" tooltip="Disconnect from R&D network" onClick={() => act('unlink')} />
          </Stack.Item>
        </Stack>
      }
    >
      <Input mb="0.5rem" width="100%" placeholder="Search by name..." onChange={(value) => setSearchText(value)} />
      {filteredDesigns.map((design) => (
        <Design key={design.id} design={design} />
      ))}
      {filteredDesigns.length === 0 && <Box color="label">No designs found.</Box>}
    </Section>
  );
};

function Building() {
  const { act, data } = useBackend();
  const { building, buildStart, buildEnd } = data;

  return (
    <Section className="Exofab__building" stretchContents>
      <Countdown progressBar timeStart={buildStart} timeEnd={buildEnd} format={(v, f) => f.substr(3)}>
        <Stack fill>
          <Stack.Item grow>
            <Icon spin name="cog" /> Building
          </Stack.Item>
          <Stack.Item>{building}</Stack.Item>
        </Stack>
      </Countdown>
    </Section>
  );
}

const Queue = (properties) => {
  const { act, data } = useBackend();
  const { queue, processingQueue } = data;
  const queueDeficit = Object.entries(data.queueDeficit).filter((a) => a[1] < 0);
  const queueTime = queue.reduce((a, b) => a + b.time, 0);
  return (
    <Section
      fill
      scrollable
      className="Exofab__queue"
      title="Queue"
      buttons={
        <Box>
          <Button
            selected={processingQueue}
            icon={processingQueue ? 'toggle-on' : 'toggle-off'}
            content="Process"
            onClick={() => act('process')}
          />
          <Button disabled={queue.length === 0} icon="eraser" content="Clear" onClick={() => act('unqueueall')} />
        </Box>
      }
    >
      <Stack fill vertical>
        {queue.length === 0 ? (
          <Box color="label">The queue is empty.</Box>
        ) : (
          <>
            <Stack.Item className="Exofab__queue--queue" grow overflow="auto">
              {queue.map((line, index) => (
                <Box key={index} color={line.notEnough && 'bad'}>
                  {index + 1}. {line.name}
                  {index > 0 && (
                    <Button
                      icon="arrow-up"
                      onClick={() =>
                        act('queueswap', {
                          from: index + 1,
                          to: index,
                        })
                      }
                    />
                  )}
                  {index < queue.length - 1 && (
                    <Button
                      icon="arrow-down"
                      onClick={() =>
                        act('queueswap', {
                          from: index + 1,
                          to: index + 2,
                        })
                      }
                    />
                  )}
                  <Button
                    icon="times"
                    color="red"
                    onClick={() =>
                      act('unqueue', {
                        index: index + 1,
                      })
                    }
                  />
                </Box>
              ))}
            </Stack.Item>
            {queueTime > 0 && (
              <Stack.Item className="Exofab__queue--time">
                <Divider />
                Processing time:
                <Icon name="clock" mx="0.5rem" />
                <Box inline bold>
                  {new Date((queueTime / 10) * 1000).toISOString().substr(14, 5)}
                </Box>
              </Stack.Item>
            )}
            {Object.keys(queueDeficit).length > 0 && (
              <Stack.Item className="Exofab__queue--deficit" shrink="0">
                <Divider />
                Lacking materials to complete:
                {queueDeficit.map((kv) => (
                  <Box key={kv[0]}>
                    <MaterialCount id={kv[0]} amount={-kv[1]} lineDisplay />
                  </Box>
                ))}
              </Stack.Item>
            )}
          </>
        )}
      </Stack>
    </Section>
  );
};

const MaterialCount = (properties) => {
  const { act, data } = useBackend();
  const { id, amount, lineDisplay, onClick, ...rest } = properties;
  const storedAmount = data.materials[id] || 0;
  const curAmount = amount || storedAmount;
  if (curAmount <= 0 && !(id === 'metal' || id === 'glass')) {
    return;
  }
  const insufficient = amount && amount > storedAmount;
  return (
    <Stack align="center" className={classes(['Exofab__material', lineDisplay && 'Exofab__material--line'])} {...rest}>
      {!lineDisplay ? (
        <>
          <Stack.Item basis="content">
            <Button width="85%" color="transparent" onClick={onClick}>
              <Box mt={1} className={classes(['materials32x32', id])} />
            </Button>
          </Stack.Item>
          <Stack.Item grow="1">
            <Box className="Exofab__material--name">{id}</Box>
            <Box className="Exofab__material--amount">
              {curAmount.toLocaleString('en-US')} cm³ ({Math.round((curAmount / MINERAL_MATERIAL_AMOUNT) * 10) / 10}{' '}
              sheets)
            </Box>
          </Stack.Item>
        </>
      ) : (
        <>
          <Stack.Item className={classes(['materials32x32', id])} />
          <Stack.Item className="Exofab__material--amount" color={insufficient && 'bad'} ml={0} mr={1}>
            {curAmount.toLocaleString('en-US')}
          </Stack.Item>
        </>
      )}
    </Stack>
  );
};

const Design = (properties) => {
  const { act, data } = useBackend();
  const design = properties.design;
  return (
    <Box className="Exofab__design">
      <Button
        disabled={design.notEnough || data.building}
        icon="cog"
        content={design.name}
        onClick={() =>
          act('build', {
            id: design.id,
          })
        }
      />
      <Button
        icon="plus-circle"
        onClick={() =>
          act('queue', {
            id: design.id,
          })
        }
      />
      <Box className="Exofab__design--cost">
        {Object.entries(design.cost).map((kv) => (
          <Box key={kv[0]}>
            <MaterialCount id={kv[0]} amount={kv[1]} lineDisplay />
          </Box>
        ))}
      </Box>
      <Stack className="Exofab__design--time">
        <Stack.Item>
          <Icon name="clock" />
          {design.time > 0 ? <>{design.time / 10} seconds</> : 'Instant'}
        </Stack.Item>
      </Stack>
    </Box>
  );
};

const LinkMenu = (properties) => {
  const { act, data } = useBackend();

  const { controllers } = data;

  return (
    <Window>
      <Window.Content>
        <Section title="Setup Linkage">
          <Table m="0.5rem">
            <Table.Row header>
              <Table.Cell>Network Address</Table.Cell>
              <Table.Cell>Network ID</Table.Cell>
              <Table.Cell>Link</Table.Cell>
            </Table.Row>
            {controllers.map((c) => (
              <Table.Row key={c.addr}>
                <Table.Cell>{c.addr}</Table.Cell>
                <Table.Cell>{c.net_id}</Table.Cell>
                <Table.Cell>
                  <Button
                    content="Link"
                    icon="link"
                    onClick={() =>
                      act('linktonetworkcontroller', {
                        target_controller: c.addr,
                      })
                    }
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};

const LevelsModal = (properties) => {
  const { act, data } = useBackend();
  const { tech_levels } = data;

  const { showLevelsModal, setShowLevelsModal } = properties;

  if (showLevelsModal) {
    return (
      <Modal maxWidth="75%" width={window.innerWidth + 'px'} maxHeight={window.innerHeight * 0.75 + 'px'} mx="auto">
        <Section
          title="Current tech levels"
          buttons={
            <Button
              content="Close"
              onClick={() => {
                setShowLevelsModal(false);
              }}
            />
          }
        >
          <LabeledList>
            {tech_levels.map(({ name, level }) => (
              <LabeledList.Item label={name} key={name}>
                {level}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Modal>
    );
  } else {
    return null;
  }
};
