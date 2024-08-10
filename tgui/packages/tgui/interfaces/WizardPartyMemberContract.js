import { useBackend } from '../backend';
import { Button, Box, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const WizardPartyMemberContract = (props, context) => {
  const { act, data } = useBackend(context);
  const { used } = data;
  return (
    <Window width={500} height={555}>
      <Window.Content scrollable>
        <Section title="Summon Party Member">
          Using this contract, you may summon an additional member to your party.
          <p>
            If you are unable to summon a member, you can feed the contract back to the spellbook to refund your point.
          </p>
          {used ? (
            <Box bold color="red">
              You&apos;ve already summoned an ally or you are in process of summoning one.
            </Box>
          ) : (
            ''
          )}
        </Section>
        <Section title="Which class are you looking to summon?">
          <LabeledList>
            <LabeledList.Item label="Cleric">
              You will summon a Cleric. <br />
              They are equipped with an armored labcoat, a telescopic baton, a variety of medical supplies and a surgery
              tools implant.
              <br />
              <Button content="Select" disabled={used} onClick={() => act('Cleric')} />
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Barbarian">
              You will summon a Barbarian. <br />
              They are equipped with fully fireproof armor, a fire axe, a whetstone, and a short range fire spray.
              <br />
              <Button content="Select" disabled={used} onClick={() => act('Barbarian')} />
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Fighter">
              You will summon a Fighter.
              <br />
              They are equipped with a reinforced riot suit, a riot shotgun, spare non-lethal ammo, a disabler, a
              stunbaton and a variety of security gear.
              <br />
              <Button content="Select" disabled={used} onClick={() => act('Fighter')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
