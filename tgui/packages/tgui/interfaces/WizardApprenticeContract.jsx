import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const WizardApprenticeContract = (props) => {
  const { act, data } = useBackend();
  const { used } = data;
  return (
    <Window width={500} height={555}>
      <Window.Content scrollable>
        <Section title="Contract of Apprenticeship">
          Using this contract, you may summon an apprentice to aid you on your mission.
          <p>
            If you are unable to establish contact with your apprentice, you can feed the contract back to the spellbook
            to refund your points.
          </p>
          {used ? (
            <Box bold color="red">
              You&apos;ve already summoned an apprentice or you are in process of summoning one.
            </Box>
          ) : (
            ''
          )}
        </Section>
        <Section title="Which school of magic is your apprentice studying?">
          <LabeledList>
            <LabeledList.Item label="Fire">
              Your apprentice is skilled in bending fire. <br />
              They know Fireball, Sacred Flame, and Ethereal Jaunt.
              <br />
              <Button content="Select" disabled={used} onClick={() => act('fire')} />
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Translocation">
              Your apprentice is able to defy physics, learning how to move through bluespace. <br />
              They know Teleport, Blink and Ethereal Jaunt.
              <br />
              <Button content="Select" disabled={used} onClick={() => act('translocation')} />
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Restoration">
              Your apprentice is dedicated to supporting your magical prowess.
              <br />
              They come equipped with a Staff of Healing, have the unique ability to teleport back to you, and know
              Charge and Knock.
              <br />
              <Button content="Select" disabled={used} onClick={() => act('restoration')} />
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Stealth">
              Your apprentice is learning the art of infiltrating mundane facilities. <br />
              They know Mindswap, Knock, Homing Toolbox, and Disguise Self, all of which can be cast without robes. They
              also join you in a Maintenance Dweller disguise, complete with Gloves of Shock Immunity and a Belt of
              Tools.
              <br />
              <Button content="Select" disabled={used} onClick={() => act('stealth')} />
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Honk">
              Your apprentice is here to spread the Honkmother&apos;s blessings.
              <br />
              They know Banana Touch, Instant Summons, Ethereal Jaunt, and come equipped with a Staff of Slipping.{' '}
              <br />
              While under your tutelage, they have been &apos;blessed&apos; with clown shoes that are impossible to
              remove.
              <br />
              <Button content="Select" disabled={used} onClick={() => act('honk')} />
            </LabeledList.Item>
            <LabeledList.Divider />
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
