import { useBackend } from '../backend';
import { Button, Flex, Section, Divider } from '../components';
import { Window } from '../layouts';

export const SpecMenu = (props, context) => {
  return (
    <Window resizable theme="nologo">
      <Window.Content>
        <Flex justify="space-around">
          <HemoMenu />
          <Divider vertical={1} />
          <UmbrMenu />
          <Divider vertical={1} />
          <GarMenu />
          <Divider vertical={1} />
          <DantMenu />
        </Flex>
      </Window.Content>
    </Window>
  );
};

const HemoMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { subclasses } = data;
  return (
    <Flex.Item grow={1} basis="25%">
      <Section title="Hemomancer">
        <h3>
          Focuses on blood magic and the manipulation of blood around you.
        </h3>
        <p>
          <b>Vampiric claws</b>: Unlocked at 150 blood, allows you to summon a
          robust pair of claws that attack rapidly and drain a targets blood.
        </p>
        <p>
          <b>Blood tendrils</b>: Unlocked at 250 blood, allows you to slow
          everyone in a targeted 3x3 area after a short delay.
        </p>
        <p>
          <b>Sanguine pool</b>: Unlocked at 400 blood, allows you to travel at
          high speeds for a short duration. Doing this leaves behind blood
          splatters. You can move through anything but walls and space when
          doing this.
        </p>
        <p>
          <b>Blood eruption</b>: Unlocked at 600 blood, allows you to manipulate
          all nearby blood splatters, in 4 tiles around you, into spikes that
          impale anyone stood ontop of them.
        </p>
        <p>
          <b>Full power</b>
          <Divider />
          <b>The blood bringers rite</b>: When toggled you will rapidly drain
          the blood of everyone who is nearby and use it to heal yourself
          slightly and remove any incapacitating effects rapidly.
        </p>
        <Button content="Hemomancer" onClick={() => act('hemomancer')} />
      </Section>
    </Flex.Item>
  );
};

const UmbrMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { subclasses } = data;
  return (
    <Flex.Item grow={1} basis="25%">
      <Section title="Umbrae">
        <h3>Focuses on darkness, stealth ambushing and mobility.</h3>
        <p>
          <b>Cloak of darkness</b>: Unlocked at 150 blood, when toggled, allows
          you to become nearly invisible and move rapidly when in dark regions.
          While active, burn damage is more effective against you.
        </p>
        <p>
          <b>Shadow snare</b>: Unlocked at 250 blood, allows you to summon a
          trap that when crossed blinds and ensares the victim. This trap is
          hard to see, but withers in the light.
        </p>
        <p>
          <b>Dark passage</b>: Unlocked at 400 blood, allows you to target a
          turf on screen, you will then teleport to that turf.
        </p>
        <p>
          <b>Extinguish</b>: Unlocked at 600 blood, allows you to snuff out
          nearby electronic light sources and glowshrooms.
        </p>
        <p>
          <b>Full power</b>
          <Divider />
          <b>Eternal darkness</b>: When toggled, you consume yourself in unholy
          darkness, only the strongest of lights will be able to see through it.
          It will also cause nearby creatures to freeze.
        </p>
        <p>In addition, you also gain permament X-ray vision.</p>
        <Button content="Umbrae" onClick={() => act('umbrae')} />
      </Section>
    </Flex.Item>
  );
};

const GarMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { subclasses } = data;
  return (
    <Flex.Item grow={1} basis="25%">
      <Section title="Gargantua">
        <h3>Focuses on tenacity and melee damage.</h3>
        <p>
          <b>Rejuvenate</b>: Will heal you at an increased rate based on how
          much damage you have taken.
        </p>
        <p>
          <b>Blood swell</b>: Unlocked at 150 blood, increases your resistance
          to physical damage, stuns and stamina for 30 seconds. While it is
          active you cannot fire guns.
        </p>
        <p>
          <b>Blood rush</b>: Unlocked at 250 blood, gives you a short speed
          boost when cast.
        </p>
        <p>
          <b>Blood swell II</b>: Unlocked at 400 blood, increases all melee
          damage by 10.
        </p>
        <p>
          <b>Overwhelming force</b>: Unlocked at 600 blood, when toggled, if you
          bump into a door that you dont have access to, it will force it open.
          In addition, you cannot be pushed or pulled while it is active.
        </p>
        <p>
          <b>Full Power</b>
          <Divider />
          <b>Charge</b>: You gain the ability to charge at a target. Destroying
          and knocking back pretty much anything you collide with.
        </p>
        <Button content="Gargantua" onClick={() => act('gargantua')} />
      </Section>
    </Flex.Item>
  );
};

const DantMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { subclasses } = data;
  return (
    <Flex.Item grow={1} basis="25%">
      <Section title="Dantalion">
        <h3>Focuses on thralling and illusions.</h3>
        <p>
          <b>Enthrall</b>: Unlocked at 150 blood, Thralls your target to your
          will, requires you to stand still. Does not work on mindshielded or
          already enthralled/mindslaved people.
        </p>
        <p>
          <b>Thrall Cap</b>: You can only thrall a max of 1 person at a time.
          This can be increased at 400 blood, 600 blood and at full power to a
          max of 4 thralls.
        </p>
        <p>
          <b>Thrall commune</b>: Unlocked at 150 blood, Allows you to talk to
          your thralls, your thralls can talk back in the same way.
        </p>
        <p>
          <b>Pacify</b>: Unlocked at 250 blood, allows you to pacify a target,
          preventing them from causing harm for 40 seconds.
        </p>
        <p>
          <b>Decoy</b>: Unlocked at 400 blood, briefly turn invisible and send
          out an illusion to fool everyone nearby.
        </p>
        <p>
          <b>Rally Thralls</b>: All nearby thralls get all incapacitating
          effects removed from them.
        </p>
        <p>
          <b>Full Power</b>
          <Divider />
          <b>Mass Hysteria</b>: Casts a powerful illusion that, blinds then make
          everyone nearby percieve others to looks like random animals.
        </p>
        <Button content="Dantalion" onClick={() => act('dantalion')} />
      </Section>
    </Flex.Item>
  );
};
