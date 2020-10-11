import { filter } from 'common/collections';
import { decodeHtmlEntities, toTitleCase } from 'common/string';
import { Fragment } from 'inferno';
import { toFixed } from 'common/math';
import { useBackend, useLocalState } from "../../backend";
import { Button, Grid, LabeledList, NumberInput, Section } from "../../components";

export const pda_signaler = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    code,
    frequency,
    minFrequency,
    maxFrequency,
  } = data;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Frequency">
          <NumberInput
            animate
            step={0.2}
            stepPixelSize={6}
            minValue={minFrequency / 10}
            maxValue={maxFrequency / 10}
            value={frequency / 10}
            format={value => toFixed(value, 1)}
            width="80px"
            onDrag={(e, value) => act('freq', {
              freq: value,
            })} />
        </LabeledList.Item>
        <LabeledList.Item label="Code">
          <NumberInput
            animate
            step={1}
            stepPixelSize={6}
            minValue={1}
            maxValue={100}
            value={code}
            width="80px"
            onDrag={(e, value) => act('code', {
              code: value,
            })} />
        </LabeledList.Item>
      </LabeledList>
      <Button
        mt={1}
        fluid
        icon="arrow-up"
        content="Send Signal"
        textAlign="center"
        onClick={() => act('signal')} />
    </Section>
  );
};
