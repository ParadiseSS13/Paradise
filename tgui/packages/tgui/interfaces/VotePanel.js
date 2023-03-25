import { useBackend } from '../backend';
import { Button, Box, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const VotePanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    remaining,
    question,
    choices,
    user_vote,
    counts,
    show_counts,
    show_cancel,
  } = data;
  return (
    <Window>
      <Window.Content scrollable>
        <Section title={question}>
          <Box mb={1}>
            Time remaining: {Math.round(remaining / 10)}s
          </Box>
          {choices.map(choice => (
            <Box key={choice}>
              <Button
                content={choice + (show_counts ? " (" + (counts[choice] || 0) + ")" : "")}
                onClick={() => act("vote", { "target": choice })}
                selected={choice === user_vote} />
            </Box>
          ))}
          {!!show_cancel && (
            <Box key={"Cancel"}>
              <Button
                content={"Cancel"}
                onClick={() => act("cancel")} />
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
