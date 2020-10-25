import { useBackend } from "../backend";
import { Slider, Button, Section, NumberInput, LabeledList, Flex } from "../components";
import { Window } from "../layouts";

export const ConveyorSwitch = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    slowFactor,
    oneWay,
    position,
  } = data;

  return (
    <Window>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Lever position">
              { (position > 0)
                ? "forward"
                : (position < 0)
                  ? "reverse"
                  : "neutral"}
            </LabeledList.Item>
            <LabeledList.Item label="Allow reverse">
              <Button.Checkbox
                // content="allow reverse"
                checked={!oneWay}
                onClick={() => act('toggleOneWay')}
              />
            </LabeledList.Item>

            <LabeledList.Item label="Slowdown factor">
              <Flex>
                <Flex.Item mx="1px"> <Button icon="angle-double-left" onClick={() => act('slowFactor', { value: slowFactor-5 })} /> </Flex.Item>
                <Flex.Item mx="1px"> <Button icon="angle-left" onClick={() => act('slowFactor', { value: slowFactor-1 })} /> </Flex.Item>
                <Flex.Item>
                  <Slider
                    width="100px"
                    mx="1px"
                    value={slowFactor}
                    fillValue={slowFactor}
                    minValue={1}
                    maxValue={50}
                    step={1}
                    format={value => value+"x"}
                    onChange={(e, value) => act('slowFactor', { value: value })} />
                </Flex.Item>
                <Flex.Item mx="1px"> <Button icon="angle-right" onClick={() => act('slowFactor', { value: slowFactor+1 })} /> </Flex.Item>
                <Flex.Item mx="1px"> <Button icon="angle-double-right" onClick={() => act('slowFactor', { value: slowFactor+5 })} /> </Flex.Item>
              </Flex>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
