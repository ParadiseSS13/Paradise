import { useBackend } from '../backend';
import { Button, Box, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const WizardApprenticeContract = (props, context) => {
  const { act, data } = useBackend(context);
  const { used } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Contract of Apprenticeship">
          Using this contract, you may summon an apprentice to aid you on your
          mission.
          <p>
            If you are unable to establish contact with your apprentice, you can
            feed the contract back to the spellbook to refund your points.
          </p>
          {used ? (
            <Box bold color="red">
              You&apos;ve already summoned an apprentice or you are in process
              of summoning one.
            </Box>
          ) : (
            ''
          )}
        </Section>
        <Section title="Which school of magic is your apprentice studying?">
          <LabeledList>
            <LabeledList.Item label="Fire">
              Your apprentice is skilled in offensive magic. They know Fireball
              and Ethereal Jaunt.
              <br />
              <Button
                content="Select"
                disabled={used}
                onClick={() => act('fire')}
              />
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Earth">
              Your apprentice is learning how to manipulate matter. They know
              Flesh to Stone and Ethereal Jaunt.
              <br />
              <Button
                content="Select"
                disabled={used}
                onClick={() => act('earth')}
              />
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Bluespace">
              Your apprentice is able to defy physics, learning how to move
              through bluespace. They know Blink and Ethereal Jaunt.
              <br />
              <Button
                content="Select"
                disabled={used}
                onClick={() => act('bluespace')}
              />
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Honk">
              Your apprentice is here to spread the Honkmother's blessings. They
              know Banana Touch, Instant Summons, Ethereal jaunt, and comes
              equipped with a Staff of Slipping. While under your tutelage, they
              have been 'blessed' with clown shoes that are impossible to
              remove.
              <br />
              <Button
                content="Select"
                disabled={used}
                onClick={() => act('honk')}
              />
            </LabeledList.Item>
            <LabeledList.Divider />
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
