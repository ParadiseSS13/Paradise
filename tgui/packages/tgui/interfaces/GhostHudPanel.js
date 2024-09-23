import { useBackend } from '../backend';
import { Button, Section, Flex, Divider } from '../components';
import { Window } from '../layouts';

export const GhostHudPanel = (props, context) => {
  const { data } = useBackend(context);
  const { security, medical, diagnostic, radioactivity, ahud } = data;
  return (
    <Window width={250} height={207} theme="nologo">
      <Window.Content>
        <Section>
          <HudEntry label="Medical" type="medical" is_active={medical} />
          <HudEntry label="Security" type="security" is_active={security} />
          <HudEntry label="Diagnostic" type="diagnostic" is_active={diagnostic} />
          <Divider />
          <HudEntry
            label="Radioactivity"
            type="radioactivity"
            is_active={radioactivity}
            act_on={'rads_on'}
            act_off={'rads_off'}
          />
          <Divider />
          <HudEntry label="Antag HUD" is_active={ahud} act_on={'ahud_on'} act_off={'ahud_off'} />
        </Section>
      </Window.Content>
    </Window>
  );
};

const HudEntry = (props, context) => {
  const { act } = useBackend(context);
  const { label, type = null, is_active, act_on = 'hud_on', act_off = 'hud_off' } = props;
  return (
    <Flex pt={0.3} color="label">
      <Flex.Item pl={0.5} align="center" width="80%">
        {label}
      </Flex.Item>
      <Flex.Item>
        <Button
          mr={0.6}
          content={is_active ? 'On' : 'Off'}
          icon={is_active ? 'toggle-on' : 'toggle-off'}
          selected={is_active}
          onClick={() => act(is_active ? act_off : act_on, { hud_type: type })}
        />
      </Flex.Item>
    </Flex>
  );
};
