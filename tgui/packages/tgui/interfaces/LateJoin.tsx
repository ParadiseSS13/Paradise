import { Color } from 'common/color';
import { Box, Button, Section, Stack, StyleableSection } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type RoundDuration = {
  hours: number;
  mins: number;
};

type SecurityLevel = {
  name: string;
  color: string;
};

type Job = {
  title: string;
  total_slots: number;
  active_players: number;
  prioritized: BooleanLike;
  is_command: BooleanLike;
  unavailable_to_player: number;
  unavailability_text?: string;
};

type Department = {
  jobs: Job[];
  color: string;
};

type Data = {
  round_duration: RoundDuration;
  security_level: SecurityLevel;
  shuttle_status?: string;
  prioritized_jobs?: string;
  categorized_jobs: Department[];
};

export const DepartmentTable = (props: { title: string; dept: Department }) => {
  const { act } = useBackend();
  const { title, dept } = props;
  return (
    <Box minWidth="30%" >
      <StyleableSection
        title={title}
        style={{
          backgroundColor: dept.color,
          marginBottom: '0.4em',
          breakInside: 'avoid-column',
        }}
        titleStyle={{
          'border-bottom-color': Color.fromHex(dept.color).lighten(50).toString(),
          textAlign: 'center',
        }}
        textStyle={{
          color: "#dddddd",
          fontSize: '1.2rem',
        }}

      >
        <Stack vertical>
          {dept.jobs.map((job) => {
            return (
              <Stack.Item key={job.title}>
                <Button
                  fluid
                  style={{
                    // Try not to think too hard about this one.
                    backgroundColor: job.unavailable_to_player
                      ? '#949494' // Grey background
                      : Color.fromHex(dept.color).lighten(20).toString(),
                    color: job.unavailable_to_player
                      ? '#414141' // Dark grey font
                      : '#dddddd',
                    fontSize: '1.0rem',
                    cursor: job.unavailable_to_player ? 'initial' : 'pointer',
                    border: job.prioritized ? '1px solid #16fc0f' : 'default',
                  }}
                  onClick={() => { !job.unavailable_to_player && act('latejoin_role', { job: job.title }); }}
                  tooltipPosition='top'
                  tooltip={job.unavailable_to_player && job.unavailability_text}
                ><Stack>
                  <Stack.Item grow>{job.is_command ? (<b>{job.title}</b>) : job.title}</Stack.Item>
                  <Stack.Item>{job.active_players} / {job.total_slots < 0 ? '∞' : job.total_slots}</Stack.Item>
                 </Stack>
                </Button>
              </Stack.Item>
            );
          })}
        </Stack>
      </StyleableSection>
    </Box>
  );
};

export const LateJoin = () => {
  const { data } = useBackend<Data>();
  const { round_duration, security_level, shuttle_status, prioritized_jobs, categorized_jobs } = data;

  return (
    <Window width={800} height={740}>
      <Window.Content>
        <Section fill scrollable>
          <Stack vertical>
            <Stack.Item>
              <Stack>
                <Stack.Item grow>Round Duration: {round_duration.hours}h {round_duration.mins}m</Stack.Item>
                <Stack.Item>
                The station alert level is:{' '}
                <Box inline color={security_level.color} fontWeight="bold">
                  {security_level.name.toUpperCase()}
                </Box>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              {shuttle_status && <Box>{shuttle_status}</Box>}
              {prioritized_jobs && <Box>The station has flagged these jobs as high priority: {prioritized_jobs}</Box>}
            </Stack.Item>
            <Stack.Item>
              {Object.keys(categorized_jobs).length > 0 ? (
                <Box style={{ columns: '20em' }}>
                  {Object.entries(categorized_jobs).map(([title, department], i) => (
                    <DepartmentTable key={title} title={title} dept={department} />
                  ))}
                </Box>
              ) : (
                <Box>
                  There are no job slots free currently. Wait a few minutes, then try again. Or, try observing the
                  round.
                </Box>
              )}
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
