import { useState } from 'react';
import {
  Box,
  Button,
  Flex,
  Icon,
  Image,
  Input,
  ProgressBar,
  Section,
  Table,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  categories: string[];
  achievements: Achievement[];
  highscores: Highscore[];
  progresses: Progress[];
  user_key: string;
};

type Achievement = {
  name: string;
  desc: string;
  category: string;
  value: number;
  score: BooleanLike;
  achieve_info: string;
  achieve_tooltip: string;
};

type Highscore = {
  name: string;
  scores: Score[];
};

type Score = {
  ckey: string;
  value: number;
};

type Progress = {
  name: string;
  value_text: string;
  percent: number;
  entries: ProgEntry[];
};

type ProgEntry = {
  name: string;
  icon: string;
  height: number;
  width: number;
};

export const Achievements = (_props) => {
  const { data } = useBackend<Data>();
  const { categories } = data;
  const [selectedCategory, setSelectedCategory] = useState(categories[0]);
  return (
    <Window title="Achievements" width={540} height={680}>
      <Window.Content scrollable>
        <Tabs>
          {categories.map((category) => (
            <Tabs.Tab
              key={category}
              selected={selectedCategory === category}
              onClick={() => setSelectedCategory(category)}
            >
              {category}
            </Tabs.Tab>
          ))}
          <Tabs.Tab selected={selectedCategory === 'High Scores'} onClick={() => setSelectedCategory('High Scores')}>
            Leaderboard
          </Tabs.Tab>
          <Tabs.Tab selected={selectedCategory === 'Progress'} onClick={() => setSelectedCategory('Progress')}>
            Progress
          </Tabs.Tab>
        </Tabs>
        {(selectedCategory === 'High Scores' && <HighScoreTable />) ||
          (selectedCategory === 'Progress' && <ProgressTable />) || <AchievementTable category={selectedCategory} />}
      </Window.Content>
    </Window>
  );
};

const AchievementTable = (props) => {
  const { data } = useBackend<Data>();
  const { achievements } = data;
  const { category } = props;
  const [searchText, setSearchText] = useState('');
  const [selectedName, setSelectedName] = useState<string | null>(null);
  const filteredAchievements = achievements.filter((achievement) => {
    if (achievement.category !== category) {
      return false;
    }
    const search = searchText.trim().toLowerCase();
    return (
      !search || achievement.name.toLowerCase().includes(search) || achievement.desc.toLowerCase().includes(search)
    );
  });
  const selectedAchievement = filteredAchievements.find((achievement) => achievement.name === selectedName);
  const earnedCount = filteredAchievements.filter((achievement) =>
    achievement.score ? achievement.value > 0 : !!achievement.value
  ).length;

  if (filteredAchievements.length === 0) {
    return (
      <Flex direction="column" height="100%">
        <Section title={`${category} Archive`}>
          <Input fluid value={searchText} placeholder="Search achievements" onChange={setSearchText} />
        </Section>
        <Section fill>
          <Box color="label" textAlign="center" mt={3}>
            No achievements match this search.
          </Box>
        </Section>
      </Flex>
    );
  }

  return (
    <Flex direction="column" height="100%" minHeight={0}>
      <Section title={`${category} Archive`} mb={1}>
        <Flex align="center" justify="space-between" mb={1}>
          <Box color="label">Collection progress</Box>
          <Box bold>
            {earnedCount} / {filteredAchievements.length} earned
          </Box>
        </Flex>
        <ProgressBar
          ranges={{
            good: [0, 1],
          }}
          value={earnedCount / filteredAchievements.length}
        />
        <Input fluid mt={1} value={searchText} placeholder="Search achievements" onChange={setSearchText} />
      </Section>
      <Section
        title={selectedAchievement ? 'Award Details' : `List of Achievements (${filteredAchievements.length})`}
        fill
        scrollable={!selectedAchievement}
        buttons={
          selectedAchievement && (
            <Button icon="arrow-left" content="All achievements" onClick={() => setSelectedName(null)} />
          )
        }
      >
        {selectedAchievement ? (
          <>
            <Box fontSize="18px" bold mb={1}>
              {selectedAchievement.name}
            </Box>
            <Box color="label" mb={2}>
              {selectedAchievement.desc}
            </Box>
            <Box
              color={
                (selectedAchievement.score ? selectedAchievement.value > 0 : !!selectedAchievement.value)
                  ? 'good'
                  : 'bad'
              }
              bold
            >
              {(selectedAchievement.score && selectedAchievement.value > 0) ||
              (!selectedAchievement.score && !!selectedAchievement.value)
                ? 'Earned'
                : 'Not earned'}
            </Box>
            {!!selectedAchievement.achieve_info && <Box mt={2}>{selectedAchievement.achieve_info}</Box>}
            {!!selectedAchievement.achieve_tooltip && (
              <Tooltip position="bottom" content={selectedAchievement.achieve_tooltip}>
                <Box mt={1} color="label" fontSize={0.9}>
                  Unlock rarity
                </Box>
              </Tooltip>
            )}
          </>
        ) : (
          filteredAchievements.map((achievement) => {
            const earned = achievement.score ? achievement.value > 0 : !!achievement.value;
            return (
              <Button
                key={achievement.name}
                fluid
                textAlign="left"
                mb={0.5}
                onClick={() => setSelectedName(achievement.name)}
              >
                <Flex justify="space-between" align="center" minWidth={0}>
                  <Box overflow="hidden" style={{ whiteSpace: 'nowrap', textOverflow: 'ellipsis' }}>
                    {achievement.name}
                  </Box>
                  <Box color={earned ? 'good' : 'label'} ml={1}>
                    {earned ? 'Earned' : 'Locked'}
                  </Box>
                </Flex>
              </Button>
            );
          })
        )}
      </Section>
    </Flex>
  );
};

const ProgressTable = () => {
  const { data } = useBackend<Data>();
  const { progresses } = data;
  const [progressIndex, setProgressIndex] = useState(0);
  if (!progresses || progresses.length === 0) {
    return null;
  }
  const progress: Progress = progresses[progressIndex];
  return (
    <Flex>
      <Flex.Item>
        <Tabs vertical>
          {progresses.map((progress, i) => (
            <Tabs.Tab key={progress.name} selected={progressIndex === i} onClick={() => setProgressIndex(i)}>
              {progress.name}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Flex.Item>
      <Flex.Item grow={1} basis={0}>
        <ProgressBar
          ranges={{
            gold: [0.97, Infinity],
            good: [-Infinity, 0.97],
          }}
          value={progress.percent}
        >
          <Box fontSize="15px" bold>
            {progress.percent >= 0.97 && <Icon name="crown" color="yellow" mr={2} />}
            {progress.value_text}
            {progress.percent >= 0.98 && <Icon name="crown" color="yellow" mr={2} />}
          </Box>
        </ProgressBar>
        <Table>
          {progress.entries.map((entry, i) => (
            <Table.Row key={entry.name} className="candystripe">
              <Table.Cell width="128px">
                <Image
                  src={`data:image/jpeg;base64,${entry.icon}`}
                  height={`${entry.height}px`}
                  width={`${entry.width}px`}
                />
              </Table.Cell>
              <Table.Cell>
                <Box fontSize="16px" bold>
                  {entry.name}
                </Box>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Flex.Item>
    </Flex>
  );
};

const HighScoreTable = () => {
  const { data } = useBackend<Data>();
  const { highscores, user_key } = data;
  const [highScoreIndex, setHighScoreIndex] = useState(0);
  if (!highscores || highscores.length === 0) {
    return null;
  }
  const highscore: Highscore = highscores[highScoreIndex];
  return (
    <Flex>
      <Flex.Item>
        <Tabs vertical>
          {highscores.map((highscore, i) => (
            <Tabs.Tab key={highscore.name} selected={highScoreIndex === i} onClick={() => setHighScoreIndex(i)}>
              {highscore.name}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Flex.Item>
      <Flex.Item grow={1} basis={0}>
        <Table>
          <Table.Row header>
            <Table.Cell textAlign="center">Position</Table.Cell>
            <Table.Cell textAlign="center">Ckey</Table.Cell>
            <Table.Cell textAlign="center">Results</Table.Cell>
          </Table.Row>
          {highscore.scores.map((score, i) => (
            <Table.Row key={score.ckey} className="candystripe" m={2}>
              <Table.Cell color="label" textAlign="center">
                {i + 1}
              </Table.Cell>
              <Table.Cell color={score.ckey === user_key && 'green'} textAlign="center">
                {i === 0 && <Icon name="crown" color="yellow" mr={2} />}
                {score.ckey}
                {i === 0 && <Icon name="crown" color="yellow" ml={2} />}
              </Table.Cell>
              <Table.Cell textAlign="center">{score.value}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Flex.Item>
    </Flex>
  );
};
