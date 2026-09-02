import { Box, Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const VotePanel = (props) => {
  const { act, data } = useBackend();
  const { remaining, question, choices, user_vote, counts, show_counts } = data;
  return (
    <Window width={400} height={360}>
      <Window.Content>
        <Section fill scrollable title={question}>
          <Box mb={1.5} ml={0.5}>
            Time remaining: {Math.round(remaining / 10)}s
          </Box>
          {choices.map((choice) => (
            <Box key={choice}>
              <Button
                mb={1}
                fluid
                lineHeight={3}
                multiLine={choice}
                content={choice + (show_counts ? ' (' + (counts[choice] || 0) + ')' : '')}
                onClick={() => act('vote', { 'target': choice })}
                selected={choice === user_vote}
              />
            </Box>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
