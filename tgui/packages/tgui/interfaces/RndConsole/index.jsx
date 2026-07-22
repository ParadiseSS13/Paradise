import { useState } from 'react';
import { Box, Button, Divider, DmIcon, Icon, NoticeBox, Section, Stack, Table, Tabs } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { AnalyzerMenu } from './AnalyzerMenu';
import { DataDiskMenu } from './DataDiskMenu';
import { LatheMenu } from './LatheMenu';
import { LinkMenu } from './LinkMenu';
import { SettingsMenu } from './SettingsMenu';

const Tab = Tabs.Tab;

export const MENU = {
  MAIN: 0,
  DISK: 2,
  ANALYZE: 3,
  LATHE: 4,
  IMPRINTER: 5,
  SETTINGS: 6,
};

export const PRINTER_MENU = {
  MAIN: 0,
  SEARCH: 1,
  MATERIALS: 2,
  CHEMICALS: 3,
};

const decideTab = (tab) => {
  switch (tab) {
    case MENU.MAIN:
      return <NewResearchMenu />;
    case MENU.DISK:
      return <DataDiskMenu />;
    case MENU.ANALYZE:
      return <AnalyzerMenu />;
    case MENU.LATHE:
    case MENU.IMPRINTER:
      return <LatheMenu />;
    case MENU.SETTINGS:
      return <SettingsMenu />;
    default:
      return 'UNKNOWN MENU';
  }
};

const ConsoleTab = (props) => {
  const { act, data } = useBackend();
  const { menu: currentMenu } = data;
  const { menu, ...rest } = props;
  return <Tab selected={currentMenu === menu} onClick={() => act('nav', { menu })} {...rest} />;
};

export const RndConsole = (properties) => {
  const { act, data } = useBackend();

  if (!data.linked) {
    return <LinkMenu />;
  }

  const { menu, linked_analyzer, linked_lathe, linked_imprinter, wait_message } = data;

  return (
    <Window width={800} height={550}>
      <Window.Content>
        <Box className="RndConsole">
          <Tabs>
            <ConsoleTab icon="flask" menu={MENU.MAIN}>
              Research
            </ConsoleTab>
            {!!linked_analyzer && (
              <ConsoleTab icon="microscope" menu={MENU.ANALYZE}>
                Analyze
              </ConsoleTab>
            )}
            {!!linked_lathe && (
              <ConsoleTab icon="print" menu={MENU.LATHE}>
                Protolathe
              </ConsoleTab>
            )}
            {!!linked_imprinter && (
              <ConsoleTab icon="memory" menu={MENU.IMPRINTER}>
                Imprinter
              </ConsoleTab>
            )}
            <ConsoleTab icon="floppy-disk" menu={MENU.DISK}>
              Disk
            </ConsoleTab>
            <ConsoleTab icon="cog" menu={MENU.SETTINGS}>
              Settings
            </ConsoleTab>
          </Tabs>
          {decideTab(menu)}
          <WaitNotice />
        </Box>
      </Window.Content>
    </Window>
  );
};

const WaitNotice = (props) => {
  const { data } = useBackend();
  const { wait_message } = data;
  if (!wait_message) {
    return null;
  }

  return (
    <Box className="RndConsole__Overlay">
      <Box className="RndConsole__Overlay__Wrapper">
        <NoticeBox color="black">{wait_message}</NoticeBox>
      </Box>
    </Box>
  );
};


// !! WIP !! Currently doesnt actually display the technodes since the mapping doesnt work.
// This is Cannibalized from the nuclear rod fabricator UI.

// MIXTODO - Finish this off

const NODE_COLORS = {
  RESEARCH: '2px solid rgba(250, 31, 250, 0.4)',
  MEDICAL: '2px solid rgba(31, 243, 250, 0.4)',
  ENGINEERING: '2px solid rgba(250, 181, 31, 0.4)',
  SECURITY: '2px solid rgba(250, 31, 31, 0.4)',
  ILLEGAL: '2px solid rgba(250, 31, 133, 0.4)',
  ALIEN: '2px solid rgba(255, 255, 255, 0.4)',
};

const TABS = {
  RESEARCH: 'research',
  PROTOLATHE: 'protolathe',
  IMPRINTER: 'imprinter',
  DISK: 'disk',
  SETTINGS: 'settings',
};

export const NewResearchMenu = (props) => {
  const { data, act } = useBackend(props);

  const [selectedNode, setSelectedNode] = useState(null);
  const [hoveredNode, setHoveredNode] = useState(null);
  const [selectedCategory, setSelectedCategory] = useState(null);
  const [hoveredCategory, setHoveredCategory] = useState(null);
  const [selectedDesign, setSelectedDesign] = useState(null);
  const [hoveredDesign, setHoveredDesign] = useState(null);
  const [activeTab, setActiveTab] = useState(TABS.RESEARCH);

  const { visible_nodes, known_nodes, protolathe_data, imprinter_data } = data;

  return (
    <Window width={850} height={600}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab icon="flask" selected={activeTab === TABS.RESEARCH} onClick={() => setActiveTab(TABS.RESEARCH)}>
                Research
              </Tabs.Tab>
              <Tabs.Tab icon="print" selected={activeTab === TABS.PROTOLATHE} onClick={() => setActiveTab(TABS.PROTOLATHE)}>
                Protolathe
              </Tabs.Tab>
              <Tabs.Tab icon="memory" selected={activeTab === TABS.IMPRINTER} onClick={() => setActiveTab(TABS.IMPRINTER)}>
                Imprinter
              </Tabs.Tab>
              <Tabs.Tab icon="floppy-disk" selected={activeTab === TABS.DISK} onClick={() => setActiveTab(TABS.DISK)}>
                Disk
              </Tabs.Tab>
              <Tabs.Tab icon="cog" selected={activeTab === TABS.SETTINGS} onClick={() => setActiveTab(TABS.SETTINGS)}>
                Settings
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>

          <Stack.Item grow>
            {activeTab === TABS.RESEARCH && (
              <Stack fill stretch>
                <Stack vertical height="200%" width="50%">
                  <Stack.Item height="100%">
                    <Section title={`Discoverable Technology`} fill scrollable>
                      <Box mt={1}>
                        {(() => {
                          const list = data[visible_nodes] || [];
                          if (list.length === 0) {
                            return (
                              <Box color="average" p={1}>
                                No Technology to Discover.
                              </Box>
                            );
                          }

                          return visible_nodes.map((node, i) => (
                            <Box
                              key={i}
                              p={1}
                              mb={0.5}
                              style={{
                                cursor: 'pointer',
                                backgroundColor:
                                  selectedNode?.type_path === node.type_path
                                    ? 'rgba(80, 140, 255, 0.25)'
                                    : hoveredNode?.type_path === node.type_path
                                    ? 'rgba(255,255,255,0.08)'
                                    : 'rgba(167, 78, 226, 0.03)',
                                border: '2px solid rgba(250, 31, 250, 0.4)',
                              }}
                              onClick={() => setSelectedNode(node)}
                              onMouseEnter={() => setHoveredNode(node)}
                              onMouseLeave={() => setHoveredNode(null)}
                            >
                              <Box bold>{node.name}</Box>
                              <Box fontSize="0.85em" color="label">
                                {node.desc}
                              </Box>
                            </Box>
                          ));
                        })()}
                      </Box>
                    </Section>
                  </Stack.Item>
                  <Stack.Item height="100%">
                    <Section title={`Known Technology`} fill scrollable>
                      <Box mt={1}>
                        {(() => {
                          const list = data[known_nodes] || [];
                          if (list.length === 0) {
                            return (
                              <Box color="average" p={1}>
                                No Technology Known.
                              </Box>
                            );
                          }
                          return list.map((node) => (
                            <Box
                              key={node.id}
                              p={1}
                              mb={0.5}
                              style={{
                                cursor: 'pointer',
                                backgroundColor:
                                  selectedNode?.type_path === node.type_path
                                    ? 'rgba(80, 140, 255, 0.25)'
                                    : hoveredNode?.type_path === node.type_path
                                      ? 'rgba(255,255,255,0.08)'
                                      : 'rgba(255,255,255,0.03)',
                                border: '2px solid rgba(250, 31, 250, 0.4)',
                              }}
                              onClick={() => setSelectedNode(node)}
                              onMouseEnter={() => setHoveredNode(node)}
                              onMouseLeave={() => setHoveredNode(null)}
                            >
                              <Box bold>{name}</Box>
                              <Box fontSize="0.85em" color="label">
                                {desc}
                              </Box>
                            </Box>
                          ));
                        })()}
                      </Box>
                    </Section>
                  </Stack.Item>
                </Stack>
                <Divider />
                <Stack.Item grow height="200%" vertical width="50%">
                  <Section title="Node Information" fill vertical>
                    {!selectedNode && <NoticeBox>Please select a node.</NoticeBox>}

                    {selectedNode && (
                      <Stack vertical fill>
                        <Section title={selectedNode.name}>
                          <Table>
                            <Table.Row>
                              <Table.Cell bold> Field: </Table.Cell>
                              <Table.Cell> {selectedNode.type} </Table.Cell>
                            </Table.Row>
                            <Table.Row>
                              <Table.Cell bold> Cost: </Table.Cell>
                              {selectedNode.cost.map(({ type, amount }) => (
                                <Table.Cell key={type}>
                                  - {amount} {type} points.
                                </Table.Cell>
                              ))}
                            </Table.Row>
                            <Table.Row>
                              <Table.Cell bold> Prerequisites: </Table.Cell>
                              {selectedNode.prereqs.map(({ prereq_name, prereq_id, prereq_is_unlocked, prereq_is_hidden }) => (
                                <Table.Cell key={prereq_id} color={prereq_is_unlocked ? 'white' : 'bad'}>
                                  - {prereq_is_hidden ? { prereq_name } : 'Unknown'}
                                </Table.Cell>
                              ))}
                            </Table.Row>
                          <Divider />
                            <Table.Row>
                              <Table.Cell bold> Unlocks: </Table.Cell>
                            </Table.Row>
                            {selectedNode.unlocks.map(({ unlock_id, unlock_name, unlock_icon, unlock_icon_state }) => (
                              <Table.Row key={unlock_id}>
                                <Table.Cell>
                                  - {unlock_name}
                                </Table.Cell>
                                <Table.Cell>
                                  <DmIcon
                                    verticalAlign="middle"
                                    icon={unlock_icon}
                                    icon_state={unlock_icon_state}
                                    fallback={<Icon p={0.66} name={'spinner'} size={2} spin />}
                                  />
                                </Table.Cell>
                              </Table.Row>
                            ))}
                          </Table>
                        </Section>

                        <Divider />

                        <Button
                          disabled={selectedNode.known}
                          icon="magnifying-glass"
                          content={`Research Technology`}
                          color="good"
                          onClick={() => act('unlock_node', { type_path: selectedNode.type_path })}
                        />
                      </Stack>
                    )}
                  </Section>
                </Stack.Item>
              </Stack>
            )}
          </Stack.Item>

          <Stack.Item grow>
            {activeTab === TABS.PROTOLATHE && (
              <Stack fill stretch>
                <Stack.Item width="50%">
                  <Section title={`Protolathe`} fill>
                    <Box mt={1}>
                      {(() => {
                        const list = data[protolathe_data] || [];

                        if (list.length === 0) {
                          return (
                            <Box color="average" p={1}>
                              No designs to print.
                            </Box>
                          );
                        }

                        return list.map((design_cat) => (
                          <Box
                            key={design_cat.name}
                            p={1}
                            mb={0.5}
                            style={{
                              cursor: 'pointer',
                              backgroundColor:
                                selectedCategory?.name === category.name
                                  ? 'rgba(80, 140, 255, 0.25)'
                                  : hoveredCategory?.name === category.name
                                    ? 'rgba(255,255,255,0.08)'
                                    : 'rgba(255,255,255,0.03)',
                              border: '1px solid rgba(255,255,255,0.08)',
                            }}
                            onClick={() => setSelectedCategory(category)}
                            onMouseEnter={() => setHoveredCategory(category)}
                            onMouseLeave={() => setHoveredCategory(null)}
                          >
                            <Box bold>{category.name}</Box>
                          </Box>
                        ));
                      })()}
                    </Box>
                  </Section>
                </Stack.Item>

                <Stack.Item grow>
                  <Section title="Designs" fill scrollable>
                    {!selectedCategory && <NoticeBox>Please select a category.</NoticeBox>}

                    {selectedCategory && (
                      <Stack vertical fill>
                        <Section title={selectedCategory.name}>
                          <Table>
                            {selectedCategory.designs.map(({
                              design_id,
                              design_name,
                              design_cost,
                              design_icon,
                              design_icon_state,
                              design_can_build,
                             }) => (
                              <Table.Row key={design_id}>
                                <Table.Cell>
                                  <Button
                                    content='Print'
                                    onClick={() => act(action, { id, amount: 1 })}
                                  />
                                </Table.Cell>
                                <Table.Cell>
                                  {design_can_build >= 1 ? <Button content="x" onClick={() => act('custom_build', { id })} /> : null}
                                </Table.Cell>
                                <Table.Cell>
                                  {design_can_build >= 5 ? <Button content="x5" onClick={() => act('build', { id, amount: 5 })} /> : null}
                                </Table.Cell>
                                <Table.Cell>
                                  {design_can_build >= 10 ? <Button content="x10" onClick={() => act('build', { id, amount: 10 })} /> : null}
                                </Table.Cell>
                                <Table.Cell bold>
                                  {design_name}
                                  <DmIcon
                                    verticalAlign="middle"
                                    icon={design_icon}
                                    icon_state={design_icon_state}
                                    fallback={<Icon p={0.66} name={'spinner'} size={2} spin />}
                                  />
                                </Table.Cell>
                                {design_cost.map(({ material_name, material_amount, has_enough }) => (
                                  <Table.Cell
                                    key={material_name}
                                    color={design_cost.has_enough ? 'white' : 'bad'}>
                                    | {material_amount} {material_name}
                                  </Table.Cell>
                                ))}
                              </Table.Row>
                            ))}
                          </Table>
                        </Section>

                        <Divider />

                        <Table>
                          <Table.Row>
                            materials go here
                          </Table.Row>
                        </Table>
                      </Stack>
                    )}
                  </Section>
                </Stack.Item>
              </Stack>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
