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
          robust pair of claws that attack rapidly, drain a targets blood, and
          heal you.
        </p>
        <p>
          <b>Blood Barrier</b>: Unlocked at 250 blood, allows you to select two
          turfs and create a wall between them.
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
          <b>Predator senses</b>: Unlocked at 600 blood, allows you to sniff out
          anyone within the same sector as you.
        </p>
        <p>
          <b>Blood eruption</b>: Unlocked at 800 blood, allows you to manipulate
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
          <b>Shadow anchor</b>: Unlocked at 250 blood, casting it will create an
          anchor at the cast location after a short delay. If you then cast the
          ability again, you are teleported back to the anchor. If you do not
          cast again within 2 minutes, you will do a fake recall, causing a
          clone to appear at the anchor and making yourself invisible. It will
          not teleport you between Z levels.
        </p>
        <p>
          <b>Shadow snare</b>: Unlocked at 250 blood, allows you to summon a
          trap that when crossed blinds and ensnares the victim. This trap is
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
        <b>Shadow boxing</b>: Unlocked at 800 blood, sends out shadow clones
        towards a target, damaging them while you remain in range.
        <p>
          <b>Full power</b>
          <Divider />
          <b>Eternal darkness</b>: When toggled, you consume yourself in unholy
          darkness, only the strongest of lights will be able to see through it.
          Inside the radius, nearby creatures will freeze and energy projectiles
          will deal less damage.
        </p>
        <p>In addition, you also gain permanent X-ray vision.</p>
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
          <b>Seismic stomp</b>: Unlocked at 250 blood, allows you to stomp the
          ground to send out a shockwave, knocking people back.
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
          bump into a door that you do not have access to, it will force it
          open. In addition, you cannot be pushed or pulled while it is active.
        </p>
        <p>
          <b>Demonic grasp</b>: Unlocked at 800 blood, allows you to send out a
          demonic hand to snare someone. If you are on disarm/grab intent you
          will push/pull the target, respectively.
        </p>
        <p>
          <b>Charge</b>: Unlocked at 800 blood, you gain the ability to charge
          at a target. Destroying and knocking back pretty much anything you
          collide with.
        </p>
        <p>
          <b>Full Power</b>
          <Divider />
          <b>Desecrated Duel</b>: Leap towards a visible enemy, creating an
          arena upon landing, infusing you with increased regeneration, and
          granting you resistance to internal damages.
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
          <b>Thrall cap</b>: You can only thrall a max of 1 person at a time.
          This can be increased at 400 blood, 600 blood and at full power to a
          max of 4 thralls.
        </p>
        <p>
          <b>Thrall commune</b>: Unlocked at 150 blood, Allows you to talk to
          your thralls, your thralls can talk back in the same way.
        </p>
        <p>
          <b>Subspace swap</b>: Unlocked at 250 blood, allows you to swap
          positions with a target.
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
          <b>Rally thralls</b>: Unlocked at 600 blood, removes all
          incapacitating effects from nearby thralls.
        </p>
        <p>
          <b>Blood bond</b>: Unlocked at 800 blood, when cast, all nearby
          thralls become linked to you. If anyone in the network takes damage,
          it is shared equally between everyone in the network. If a thrall goes
          out of range, they will be removed from the network.
        </p>
        <p>
          <b>Full Power</b>
          <Divider />
          <b>Mass Hysteria</b>: Casts a powerful illusion that blinds and then
          makes everyone nearby perceive others as random animals.
        </p>
        <Button content="Dantalion" onClick={() => act('dantalion')} />
      </Section>
    </Flex.Item>
  );
};
