
import { Box, Button, Flex, Section, Stack, Tabs } from '../components';
import { BooleanLike } from 'common/react';
import { DmIcon } from '../components';
import { useBackend } from '../backend';
import { Window } from '../layouts';


const hereticRed = {
  color: '#e03c3c',
};

const hereticBlue = {
  fontWeight: 'bold',
  color: '#2185d0',
};

const hereticPurple = {
  fontWeight: 'bold',
  color: '#bd54e0',
};

const hereticGreen = {
  fontWeight: 'bold',
  color: '#20b142',
};

const hereticYellow = {
  fontWeight: 'bold',
  color: 'yellow',
};

type IconParams = {
  icon: string;
  state: string;
  frame: number;
  dir: number;
  moving: BooleanLike;
};

type Knowledge = {
  path: string;
  icon_params: IconParams;
  name: string;
  desc: string;
  gainFlavor: string;
  cost: number;
  bgr: string;
  disabled: BooleanLike;
  finished: BooleanLike;
  ascension: BooleanLike;
};

type KnowledgeInfo = {
  knowledge_tiers: KnowledgeTier[];
};

type KnowledgeTier = {
  nodes: Knowledge[];
};

type Info = {
  charges: number;
  total_sacrifices: number;
  ascended: BooleanLike;
};




const KnowledgeTree = (props, context) => {
  const { data, act } = useBackend<KnowledgeInfo>(context);
  const { knowledge_tiers } = data;

  return (
    <Section title="Research Tree" fill scrollable>
      <Box textAlign="center" fontSize="32px">
        <span style={hereticYellow}>DAWN</span>
      </Box>
      <Stack vertical>
        {knowledge_tiers.length === 0
          ? 'None!'
          : knowledge_tiers.map((tier, i) => (
              <Stack.Item key={i}>
                <Flex
                  justify="center"
                  align="center"
                  backgroundColor="transparent"
                  wrap="wrap"
                >
                  {tier.nodes.map((node) => (
                    <Flex.Item key={node.name}>
                      <Button
                        color="transparent"
                        tooltip={`${node.name}:
                          ${node.desc}`}
                        onClick={
                          node.disabled || node.finished
                            ? undefined
                            : () => act('research', { path: node.path })
                        }
                        width={node.ascension ? '192px' : '64px'}
                        height={node.ascension ? '192px' : '64px'}
                        m="8px"
                        style={{
                          borderRadius: '50%',
                        }}
                      >
                        <DmIcon
                          icon="icons/ui_icons/antags/heretic/knowledge.dmi"
                          icon_state={
                            node.disabled
                              ? 'node_locked'
                              : node.finished
                                ? 'node_finished'
                                : node.bgr
                          }
                          height={node.ascension ? '192px' : '64px'}
                          width={node.ascension ? '192px' : '64px'}
                          top="0px"
                          left="0px"
                          position="absolute"
                        />
                        <DmIcon
                          icon={node.icon_params.icon}
                          icon_state={node.icon_params.state}
                          frame={node.icon_params.frame}
                          direction={node.icon_params.dir}
                          movement={node.icon_params.moving}
                          height={node.ascension ? '152px' : '64px'}
                          width={node.ascension ? '152px' : '64px'}
                          top={node.ascension ? '20px' : '0px'}
                          left={node.ascension ? '20px' : '0px'}
                          position="absolute"
                        />
                        <Box
                          position="absolute"
                          top="0px"
                          left="0px"
                          backgroundColor="black"
                          textColor="white"
                          bold
                        >
                          {!node.finished &&
                            (node.cost > 0 ? node.cost : 'FREE')}
                        </Box>
                      </Button>
                      {!!node.ascension && (
                        <Box textAlign="center" fontSize="32px">
                          <span style={hereticPurple}>DUSK</span>
                        </Box>
                      )}
                    </Flex.Item>
                  ))}
                </Flex>
                <hr />
              </Stack.Item>
            ))}
      </Stack>
    </Section>
  );
};

const ResearchInfo = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { charges } = data;

  return (
    <Stack vertical fill>
      <Stack.Item fontSize="20px" textAlign="center">
        You have <b>{charges || 0}</b>&nbsp;
        <span style={hereticBlue}>
          knowledge point{charges !== 1 ? 's' : ''}
        </span>{' '}
        to spend.
      </Stack.Item>
      <Stack.Item grow>
        <KnowledgeTree />
      </Stack.Item>
    </Stack>
  );
};


