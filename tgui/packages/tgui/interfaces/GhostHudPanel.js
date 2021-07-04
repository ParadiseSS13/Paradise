import { useBackend } from "../backend";
import { Button, Section, Flex } from "../components";
import { Window } from "../layouts";

export const GhostHudPanel = (props, context) => {
  const { data } = useBackend(context);
  const {
    security,
    medical,
    diagnostic,
    ahud,
  } = data;
  return (
    <Window resizable theme="nologo">
      <Window.Content display="flex" className="Layout__content--flexColumn">
        <Section >
          <HudEntry label="Medical" type="medical" is_active={medical} />
          <HudEntry label="Security" type="security" is_active={security} />
          <HudEntry label="Diagnostic" type="diagnostic" is_active={diagnostic} />
          <HudEntry label="Antag HUD" is_active={ahud} act_on={"ahud_on"} act_off={"ahud_off"} />
        </Section>
      </Window.Content>
    </Window>
  );
};

const HudEntry = (props, context) => {
  const { act } = useBackend(context);
  const {
    label,
    type = null,
    is_active,
    act_on = 'hud_on',
    act_off = 'hud_off',
  } = props;
  return (
    <Flex my={0.5} color="label">
      <Flex.Item align="center" width="57.6%">
        {label}
      </Flex.Item>
      <Flex.Item>
        <Button
          mr={0.6}
          content="On"
          icon="toggle-on"
          selected={is_active}
          onClick={() => act(act_on, { hud_type: type })}
        />
        <Button
          content="Off"
          icon="toggle-off"
          selected={!is_active}
          onClick={() => act(act_off, { hud_type: type })}
        />
      </Flex.Item>
    </Flex>
  );
};
