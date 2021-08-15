import { useBackend } from '../backend';
import { Button, Box, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const WizardApprenticeContract = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    used,
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Contract of Apprenticeship">
          Using this contract, you may summon an apprentice to aid you on your mission.
          <p>If you are unable to establish contact with your apprentice, you can feed the contract back to the spellbook to refund your points.</p>
          {used ? <Box bold color="red">You&apos;ve already summoned an apprentice or you are in process of summoning one.</Box> : ""}
        </Section>
        <Section title="Which school of magic is your apprentice studying?">
          <LabeledList>
            <LabeledList.Item label="Destruction">
              Your apprentice is skilled in offensive magic. They know Magic Missile and Fireball.<br />
              <Button
                content="Select"
                disabled={used}
                onClick={() => act('destruction')} />
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Bluespace Manipulation">
              Your apprentice is able to defy physics, melting through solid objects and travelling great distances in the blink of an eye. They know Teleport and Ethereal Jaunt.<br />
              <Button
                content="Select"
                disabled={used}
                onClick={() => act('bluespace')} />
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Healing">
              Your apprentice is training to cast spells that will aid your survival. They know Forcewall and Charge and come with a Staff of Healing.<br />
              <Button
                content="Select"
                disabled={used}
                onClick={() => act('healing')} />
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Robeless">
              Your apprentice is training to cast spells without their robes. They know Knock and Mindswap.<br />
              <Button
                content="Select"
                disabled={used}
                onClick={() => act('robeless')} />
            </LabeledList.Item>
            <LabeledList.Divider />
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

