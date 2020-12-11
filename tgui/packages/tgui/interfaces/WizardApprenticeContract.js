import { useBackend } from '../backend';
import { Button, Box, LabeledList, Section, Divider, Fragment } from '../components';
import { Window } from '../layouts';

export const WizardApprenticeContract = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    used,
  } = data;
  let body;
  if (used) {
    body = (
      <Box bold color="bad">
        You have already summoned your apprentice.
      </Box>);
  } else {
    body = (
      <Fragment>
        <Section title="Contract of Apprenticeship">
          Using this contract, you may summon an apprentice to aid you on your mission.
          <p>If you are unable to establish contact with your apprentice, you can feed the contract back to the spellbook to refund your points.</p>
        </Section>
        <Section title="Which school of magic is your apprentice studying?">
          <LabeledList>
            <LabeledList.Item label="Destruction">
              Your apprentice is skilled in offensive magic. They know Magic Missile and Fireball.<br />
              <Button
                content="Select"
                onClick={() => act('destruction')} />
            </LabeledList.Item>
            <Divider />
            <LabeledList.Item label="Bluespace Manipulation">
              Your apprentice is able to defy physics, melting through solid objects and travelling great distances in the blink of an eye. They know Teleport and Ethereal Jaunt.<br />
              <Button
                content="Select"
                onClick={() => act('bluespace')} />
            </LabeledList.Item>
            <Divider />
            <LabeledList.Item label="Healing">
              Your apprentice is training to cast spells that will aid your survival. They know Forcewall and Charge and come with a Staff of Healing.<br />
              <Button
                content="Select"
                onClick={() => act('healing')} />
            </LabeledList.Item>
            <Divider />
            <LabeledList.Item label="Robeless">
              Your apprentice is training to cast spells without their robes. They know Knock and Mindswap.<br />
              <Button
                content="Select"
                onClick={() => act('robeless')} />
            </LabeledList.Item>
            <Divider />
          </LabeledList>
        </Section>
      </Fragment>
    );
  }
  return (
    <Window resizable>
      <Window.Content scrollable>
        {body}
      </Window.Content>
    </Window>
  );
};
