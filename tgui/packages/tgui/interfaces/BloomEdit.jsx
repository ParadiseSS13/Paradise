import { Box, Button, LabeledList, NumberInput, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const BloomEdit = (props) => {
  const { act, data } = useBackend();

  const {
    glow_brightness_base,
    glow_brightness_power,
    glow_contrast_base,
    glow_contrast_power,
    exposure_brightness_base,
    exposure_brightness_power,
    exposure_contrast_base,
    exposure_contrast_power,
  } = data;

  return (
    <Window title="BloomEdit" width={500} height={500}>
      <Window.Content>
        <Section title="Bloom Edit">
          <LabeledList>
            <LabeledList.Item label="Lamp Brightness Base">
              <Box inline>Base Lamp Brightness</Box>
              <NumberInput
                fluid
                value={glow_brightness_base}
                minValue={-10}
                maxValue={10}
                step={0.01}
                width="20px"
                onChange={(value) =>
                  act('glow_brightness_base', {
                    value: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Lamp Brightness Power">
              <Box inline>Lamp Brightness * Light Power</Box>
              <NumberInput
                fluid
                value={glow_brightness_power}
                minValue={-10}
                maxValue={10}
                step={0.01}
                width="20px"
                onChange={(value) =>
                  act('glow_brightness_power', {
                    value: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Lamp Contrast Base">
              <Box inline>Base Lamp Contrast</Box>
              <NumberInput
                fluid
                value={glow_contrast_base}
                minValue={-10}
                maxValue={10}
                step={0.01}
                width="20px"
                onChange={(value) =>
                  act('glow_contrast_base', {
                    value: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Lamp Contrast Power">
              <Box inline>Lamp Contrast * Light Power</Box>
              <NumberInput
                fluid
                value={glow_contrast_power}
                minValue={-10}
                maxValue={10}
                step={0.01}
                width="20px"
                onChange={(value) =>
                  act('glow_contrast_power', {
                    value: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Exposure Brightness Base">
              <Box inline>Base Exposure Brightness</Box>
              <NumberInput
                fluid
                value={exposure_brightness_base}
                minValue={-10}
                maxValue={10}
                step={0.01}
                width="20px"
                onChange={(value) =>
                  act('exposure_brightness_base', {
                    value: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Exposure Brightness Power">
              <Box inline>Exposure Brightness * Light Power</Box>
              <NumberInput
                fluid
                value={exposure_brightness_power}
                minValue={-10}
                maxValue={10}
                step={0.01}
                width="20px"
                onChange={(value) =>
                  act('exposure_brightness_power', {
                    value: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Exposure Contrast Base">
              <Box inline>Base Exposure Contrast</Box>
              <NumberInput
                fluid
                value={exposure_contrast_base}
                minValue={-10}
                maxValue={10}
                step={0.01}
                width="20px"
                onChange={(value) =>
                  act('exposure_contrast_base', {
                    value: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Exposure Contrast Power">
              <Box inline>Exposure Contrast * Light Power</Box>
              <NumberInput
                fluid
                value={exposure_contrast_power}
                minValue={-10}
                maxValue={10}
                step={0.01}
                width="20px"
                onChange={(value) =>
                  act('exposure_contrast_power', {
                    value: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item>
              <Button content="Reload Lamps with New Parameters" onClick={() => act('update_lamps')} />
              <Button content="Reset to Default" onClick={() => act('default')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
