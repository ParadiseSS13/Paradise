import { useBackend } from '../backend';
import { Button, Box, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const VotePanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    remaining,
    vote_type,
    choices,
    user_vote,
    counts,
    show_counts,
   } = data;
  return (
    <Window>
      <Window.Content>
        <Section title={vote_type}>
          <Box mb={1}>
            Time remaining: {remaining / 10}s
          </Box>
          {choices.map(c => (
            <Box key={c}>
              <Button content={(show_counts === 1 ? (c + " (" + (counts[c] || 0) + ")") : c)} onClick={() => act("vote", { "target": c })} selected={c === user_vote} />
            </Box>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
}
