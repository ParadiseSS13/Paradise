
import { useBackend, useLocalState } from '../backend';
import { Box, Flex, Section } from '../components';
import { Window } from '../layouts';
import BreakerIMG from '../assets/BreakerOn.png';

export const BreakerBox = (props, context) => {
  const { act, data } = useBackend(context);
  const { breaker_list } = data;
  return (
    <Window resizable>
      <Window.Content scrollable className="BreakerBox-window-interior">
        <Section className="BreakerBox-window-interior">
          <Box className="WirePanel-wires-container">
            {breaker_list.map((breaker) => {
              return (
                <SkeuomorphWire
                  key={breaker}
                  apc_id={breaker.apc_UID}
                  name={breaker.name}
                  toggled={breaker.toggled}
                  value={breaker.wire_color}
                />
              );
            })}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};

const SkeuomorphWire = (props, context) => {
  const { act, data } = useBackend(context);
  const { name, apc_id, value, cut, index } = props;
  return (
    <Box style={{ "background-color": "orange" }}>
      <Flex fill className="WirePanel-wires-wire" >
        <Flex.Item grow className="WirePanel-wires-name">
          <Box className="WirePanel-wires-label">{name}</Box>
        </Flex.Item>

        <Flex.Item className="">
          <img src={BreakerIMG}
            className="breakerOn"
            onClick={() => act('flip_breaker', { "breaker_uid" : apc_id})}/>
          { /* wirePanel-wires-buttons #TODO add buttons for screwdriver, sabotage, and lock break
                <Button
                className="WirePanel-wires-generic-button"
                icon="route"
                color="green"
                content={"Mend"}
                onClick={() => act("actwire", { wire: index + 1, action: WirePanelActions.WIRE_ACT_MEND })}
                {...rest}
              />
              */
          }
        </Flex.Item>
      </Flex>
    </Box>
  );
};
