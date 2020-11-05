import { Fragment } from 'inferno';
import { useBackend } from "../backend";
import { Box, Button, Flex, LabeledList, ProgressBar, Section } from "../components";
import { Window } from "../layouts";

const dispenseAmounts = [1, 5, 10, 20, 30, 50];
const removeAmounts = [1, 5, 10];

export const HandheldChemDispenser = (props, context) => {
  return (
    <Window resizable>
      <Window.Content className="Layout__content--flexColumn">
        <HandheldChemDispenserSettings />
        <HandheldChemDispenserChemicals />
      </Window.Content>
    </Window>
  );
};

const HandheldChemDispenserSettings = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    amount,
    energy,
    maxEnergy,
    mode,
  } = data;
  return (
    <Section title="Settings" flex="content">
      <LabeledList>
        <LabeledList.Item label="Energy">
          <ProgressBar
            value={energy}
            minValue={0}
            maxValue={maxEnergy}
            ranges={{
              good: [maxEnergy * 0.5, Infinity],
              average: [maxEnergy * 0.25, maxEnergy * 0.5],
              bad: [-Infinity, maxEnergy * 0.25],
            }}>
            {energy} / {maxEnergy} Units
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Amount" verticalAlign="middle">
          <Flex direction="row" spacing="1">
            {dispenseAmounts.map((a, i) => (
              <Flex.Item key={i} grow="1" width="14%" display="inline-block">
                <Button
                  icon="cog"
                  selected={amount === a}
                  content={a}
                  m="0"
                  width="100%"
                  onClick={() => act('amount', {
                    amount: a,
                  })}
                />
              </Flex.Item>
            ))}
          </Flex>
        </LabeledList.Item>
        <LabeledList.Item label="Mode" verticalAlign="middle">
          <Flex direction="row" justify="space-between">
            <Button
              icon="cog"
              selected={mode === "dispense"}
              content="Dispense"
              m="0"
              width="32%"
              onClick={() => act('mode', {
                mode: "dispense",
              })}
            />
            <Button
              icon="cog"
              selected={mode === "remove"}
              content="Remove"
              m="0"
              width="32%"
              onClick={() => act('mode', {
                mode: "remove",
              })}
            />
            <Button
              icon="cog"
              selected={mode === "isolate"}
              content="Isolate"
              m="0"
              width="32%"
              onClick={() => act('mode', {
                mode: "isolate",
              })}
            />
          </Flex>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const HandheldChemDispenserChemicals = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    chemicals = [],
    current_reagent,
  } = data;
  const flexFillers = [];
  for (let i = 0; i < (chemicals.length + 1) % 3; i++) {
    flexFillers.push(true);
  }
  return (
    <Section
      title={data.glass ? 'Drink Selector' : 'Chemical Selector'}
      flexGrow="1">
      <Flex
        direction="row"
        wrap="wrap"
        height="100%"
        spacingPrecise="2"
        align="flex-start"
        alignContent="flex-start">
        {chemicals.map((c, i) => (
          <Flex.Item
            key={i}
            grow="1"
            basis="25%"
            height="20px"
            width="30%"
            display="inline-block">
            <Button
              icon="arrow-circle-down"
              overflow="hidden"
              textOverflow="ellipsis"
              selected={current_reagent === c.id}
              width="100%"
              height="100%"
              align="flex-start"
              content={c.title}
              onClick={() => act('dispense', {
                reagent: c.id,
              })}
            />
          </Flex.Item>
        ))}
        {flexFillers.map((_, i) => (
          <Flex.Item key={i} grow="1" basis="25%" height="20px" />
        ))}
      </Flex>
    </Section>
  );
};
