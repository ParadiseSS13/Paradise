// !! WIP !! Currently doesnt actually display the technodes since the mapping doesnt work.
// This is Cannibalized from the nuclear rod fabricator UI.

import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  DmIcon,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';

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

type ResearchNode = {
  name: string;
  desc: string;
  id: string;
  node_type: string;
  type_path: string;
  known: BooleanLike;
  cost: NodeCost[];
  unlocks: Unlock[];
  prereqs: Prereq[];
};

type NodeCost = {
  cost_type: string;
  amount: number;
};

type Unlock = {
  unlock_id: string;
  unlock_name: string;
  unlock_desc: string;
  unlock_icon: string;
  unlock_icon_state: string;
};

type ResearchMenuData = {
  visible_nodes: ResearchNode[];
  known_nodes: ResearchNode[];
  research_points: Record<string, number>;
};

type Prereq = {
  prereq_name: string;
  prereq_id: string;
  prereq_is_unlocked: BooleanLike;
  prereq_is_hidden: BooleanLike;
};

export const NewResearchMenu = () => {
  const { data, act } = useBackend<ResearchMenuData>();

  const [selectedNode, setSelectedNode] = useState<ResearchNode | null>(null);
  const [hoveredNode, setHoveredNode] = useState<ResearchNode | null>(null);

  const { visible_nodes, known_nodes, research_points } = data;

  return (
    <Stack vertical fill scrollable>
      <Stack.Item>
        <Section title="Available Points">
            {Object.entries(research_points).map(([name, points]) => (
              <Box key={name} inline mr={2} fontSize="120%">
                {name}: <code>{points}</code>
              </Box>
            ))}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Stack height="200px" fill>
          <Stack.Item width="50%">
            <Section title={`Discoverable Technology`} scrollable fill>
              <Box>
                {visible_nodes.length === 0 ? (
                  <Box color="average">No Technology to Discover.</Box>
                ) : (
                  visible_nodes.map((node, i) => (
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
                      onClick={() => (selectedNode === node ? setSelectedNode(null) : setSelectedNode(node))}
                      onMouseOver={() => setHoveredNode(node)}
                      onMouseLeave={() => setHoveredNode(null)}
                    >
                      <Box bold>{node.name}</Box>
                      <Box fontSize="0.85em" color="label">
                        {node.desc}
                      </Box>
                    </Box>
                  ))
                )}
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item width="50%">
            <Section title={`Known Technology`} scrollable fill>
              <Box mt={1}>
                {known_nodes.length === 0 ? (
                  <Box color="average" p={1}>
                    No Technology Known.
                  </Box>
                ) : (
                  known_nodes.map((node) => (
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
                      onClick={() => (selectedNode === node ? setSelectedNode(null) : setSelectedNode(node))}
                      onMouseOver={() => setHoveredNode(node)}
                      onMouseLeave={() => setHoveredNode(null)}
                    >
                      <Box bold>{node.name}</Box>
                      <Box fontSize="0.85em" color="label">
                        {node.desc}
                      </Box>
                    </Box>
                  ))
                )}
              </Box>
            </Section>
          </Stack.Item>
        </Stack>
        <Divider />
        <Stack height="200px" scrollable fill>
          <Stack.Item width="100%">
            <Section
              title="Node Information"
              scrollable fill
              buttons={
                selectedNode &&
                !selectedNode.known && (
                  <Button
                    disabled={selectedNode.known}
                    icon="magnifying-glass"
                    color="good"
                    onClick={() => act('unlock_node', { type_path: selectedNode.type_path })}
                  >
                    Research Technology
                  </Button>
                )
              }
            >
              {!selectedNode && <NoticeBox>Please select a node.</NoticeBox>}

              {selectedNode && (
                <Stack vertical fill>
                  <Stack.Item>
                    <Section title={selectedNode.name} scrollable>
                      <Stack fill scrollable>
                        <Stack.Item width="50%">
                          <LabeledList>
                            <LabeledList.Item label="Field">{selectedNode.node_type}</LabeledList.Item>
                            <LabeledList.Item label="Cost">
                              {selectedNode.cost.length === 0
                                ? 'Nothing'
                                : selectedNode.cost.map(({ cost_type, amount }) => (
                                    <>
                                      - {amount} {cost_type} points.
                                      <br />
                                    </>
                                  ))}
                            </LabeledList.Item>
                            <LabeledList.Item label="Prerequisites">
                              {selectedNode.prereqs.length === 0
                                ? 'None'
                                : selectedNode.prereqs.map(
                                    ({ prereq_name, prereq_id, prereq_is_unlocked, prereq_is_hidden }) => (
                                      <Table.Cell key={prereq_id} color={prereq_is_unlocked ? 'white' : 'bad'}>
                                        - {prereq_is_hidden ? `${prereq_name}` : 'Unknown'}
                                      </Table.Cell>
                                    )
                                  )}
                            </LabeledList.Item>
                          </LabeledList>
                        </Stack.Item>
                        <Stack.Item>
                          <LabeledList>
                            <LabeledList.Item label="Unlocks">
                              {selectedNode.unlocks.length === 0
                                ? 'Nothing'
                                : selectedNode.unlocks.map(
                                    ({ unlock_id, unlock_name, unlock_icon, unlock_icon_state }) => (
                                      <Box key={unlock_id} inline>
                                        <DmIcon
                                          verticalAlign="middle"
                                          icon={unlock_icon}
                                          icon_state={unlock_icon_state}
                                          fallback={<Icon p={0.66} name={'spinner'} size={2} spin />}
                                        />
                                        {unlock_name}
                                        <br />
                                      </Box>
                                    )
                                  )}
                            </LabeledList.Item>
                          </LabeledList>
                        </Stack.Item>
                      </Stack>
                    </Section>
                  </Stack.Item>
                </Stack>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
