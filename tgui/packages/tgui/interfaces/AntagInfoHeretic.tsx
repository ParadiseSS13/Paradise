import { useState } from 'react';
import { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Box, Button, DmIcon, Flex, Section, Tabs } from 'tgui-core/components';
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
  can_change_objective: BooleanLike;
};

const IntroductionSection = () => {
  const { data } = useBackend<Info>();
  const { ascended, can_change_objective } = data;

  return (
    <Flex direction="column" height="100%">
      <Section title="You are the Heretic!" fontSize="14px">
        <Flex direction="column" gap={1}>
          <FlavorSection />
          <Box my={1}>
            <hr />
          </Box>
          <GuideSection />
          <Box my={1}>
            <hr />
          </Box>
          <InformationSection />
        </Flex>
      </Section>
    </Flex>
  );
};

const FlavorSection = () => {
  return (
    <Flex.Item>
      <Box textAlign="center" fontSize="14px">
        <i>
          Another day at a meaningless job. You feel a&nbsp;
          <span style={hereticBlue}>shimmer</span>
          &nbsp;around you, as a realization of something&nbsp;
          <span style={hereticRed}>strange</span>
          &nbsp;in the air unfolds. You look inwards and discover something that will change your life.
        </i>
        <Box mt={1}>
          <b>
            The <span style={hereticPurple}>Gates of Mansus</span>
            &nbsp;open up to your mind.
          </b>
        </Box>
      </Box>
    </Flex.Item>
  );
};

const GuideSection = () => {
  return (
    <Flex.Item>
      <Flex direction="column" gap={1} fontSize="12px">
        <Box>
          - Find reality smashing&nbsp;
          <span style={hereticPurple}>influences</span>
          &nbsp;around the station invisible to the normal eye and&nbsp;
          <b>click</b> on them to harvest them for&nbsp;
          <span style={hereticBlue}>knowledge points</span>. Tapping them makes them visible to all after a short time.
        </Box>
        <Box>
          - Use your&nbsp;
          <span style={hereticRed}>Living Heart action</span>
          &nbsp;to track down&nbsp;
          <span style={hereticRed}>sacrifice targets</span>, but be careful: Pulsing it will produce a heartbeat sound
          that nearby people may hear. This action is tied to your <b>heart</b> - if you lose it, you must complete a
          ritual to regain it.
        </Box>
        <Box>
          - Draw a&nbsp;
          <span style={hereticGreen}>transmutation rune</span> by using a drawing tool (a pen or crayon) on the floor
          while having&nbsp;
          <span style={hereticGreen}>Mansus Grasp</span>
          &nbsp;active in your other hand. This rune allows you to complete rituals and sacrifices.
        </Box>
        <Box>
          - Follow your <span style={hereticRed}>Living Heart</span> to find your targets. Bring them back to a&nbsp;
          <span style={hereticGreen}>transmutation rune</span> in critical or worse condition to&nbsp;
          <span style={hereticRed}>sacrifice</span> them for&nbsp;
          <span style={hereticBlue}>knowledge points</span>. The Mansus <b>ONLY</b> accepts targets pointed to by
          the&nbsp;
          <span style={hereticRed}>Living Heart</span>.
        </Box>
        <Box>
          - Make yourself a <span style={hereticYellow}>focus</span> to be able to cast various advanced spells to
          assist you in acquiring harder and harder sacrifices.
        </Box>
        <Box>
          - Accomplish all of your objectives to be able to learn the <span style={hereticYellow}>final ritual</span>.
          Complete the ritual to become all powerful!
          <span style={hereticRed}> You can only do this ritual with&nbsp; hijack or if a cult tries to summon</span>.
        </Box>
      </Flex>
    </Flex.Item>
  );
};

const InformationSection = () => {
  const { data } = useBackend<Info>();
  const { charges, total_sacrifices, ascended } = data;
  return (
    <Flex.Item>
      <Flex direction="column" gap={1}>
        {!!ascended && (
          <Flex align="center" gap={1}>
            <Box>You have</Box>
            <Box fontSize="24px" color="yellow" inline>
              ASCENDED!
            </Box>
          </Flex>
        )}
        <Box>
          You have <b>{charges || 0}</b>&nbsp;
          <span style={hereticBlue}>knowledge point{charges !== 1 ? 's' : ''}</span>.
        </Box>
        <Box>
          You have made a total of&nbsp;
          <b>{total_sacrifices || 0}</b>&nbsp;
          <span style={hereticRed}>sacrifices</span>.
        </Box>
      </Flex>
    </Flex.Item>
  );
};

const KnowledgeTree = () => {
  const { data, act } = useBackend<KnowledgeInfo>();
  const { knowledge_tiers } = data;

  return (
    <Section title="Research Tree" fill scrollable>
      <Box textAlign="center" fontSize="32px">
        <span style={hereticYellow}>DAWN</span>
      </Box>
      <Flex direction="column">
        {knowledge_tiers.length === 0
          ? 'None!'
          : knowledge_tiers.map((tier, i) => (
              <Flex.Item key={i}>
                <Flex justify="center" align="center" backgroundColor="transparent" wrap="wrap">
                  {tier.nodes.map((node) => (
                    <Flex.Item key={node.name}>
                      <Button
                        color="transparent"
                        tooltip={`${node.name}:
                          ${node.desc}`}
                        onClick={
                          node.disabled || node.finished ? undefined : () => act('research', { path: node.path })
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
                          icon_state={node.disabled ? 'node_locked' : node.finished ? 'node_finished' : node.bgr}
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
                        <Box position="absolute" top="0px" left="0px" backgroundColor="black" textColor="white" bold>
                          {!node.finished && (node.cost > 0 ? node.cost : 'FREE')}
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
              </Flex.Item>
            ))}
      </Flex>
    </Section>
  );
};

const ResearchInfo = () => {
  const { data } = useBackend<Info>();
  const { charges } = data;

  return (
    <Flex direction="column" height="100%">
      <Box textAlign="center" fontSize="20px" mb={1}>
        You have <b>{charges || 0}</b>&nbsp;
        <span style={hereticBlue}>knowledge point{charges !== 1 ? 's' : ''}</span> to spend.
      </Box>
      <Flex.Item grow>
        <KnowledgeTree />
      </Flex.Item>
    </Flex>
  );
};

export const AntagInfoHeretic = () => {
  const { data } = useBackend<Info>();
  const { ascended } = data;
  const [currentTab, setTab] = useState(0);

  return (
    <Window width={675} height={635}>
      <Window.Content
        style={{
          backgroundImage: 'none',
          background: ascended
            ? 'radial-gradient(circle, rgba(24,9,9,1) 54%, rgba(31,10,10,1) 60%, rgba(46,11,11,1) 80%, rgba(47,14,14,1) 100%);'
            : 'radial-gradient(circle, rgba(9,9,24,1) 54%, rgba(10,10,31,1) 60%, rgba(21,11,46,1) 80%, rgba(24,14,47,1) 100%);',
        }}
      >
        <Flex direction="column" height="100%">
          <Flex.Item>
            <Tabs fluid>
              <Tabs.Tab icon="info" selected={currentTab === 0} onClick={() => setTab(0)}>
                Information
              </Tabs.Tab>
              <Tabs.Tab
                icon={currentTab === 1 ? 'book-open' : 'book'}
                selected={currentTab === 1}
                onClick={() => setTab(1)}
              >
                Research
              </Tabs.Tab>
            </Tabs>
          </Flex.Item>
          <Flex.Item grow>{currentTab === 0 ? <IntroductionSection /> : <ResearchInfo />}</Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
