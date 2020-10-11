import { useBackend } from "../backend";
import { Button, Flex, LabeledList, Section, Box, Icon } from '../components';
import { Window } from "../layouts";

const TEMPS = {
  scalding: { label: 'Scalding', color: '#FF0000', icon: 'fa fa-arrow-circle-up', requireEmag: true },
  warm: { label: 'Warm', color: '#990000', icon: 'fa fa-arrow-circle-up' },
  normal: { label: 'Normal', color: null, icon: 'fa fa-arrow-circle-right' },
  cool: { label: 'Cool', color: '#009999', icon: 'fa fa-arrow-circle-down' },
  frigid: { label: 'Frigid', color: '#00CCCC', icon: 'fa fa-arrow-circle-down', requireEmag: true },
};

const TempButton = (properties, context) => {
  const { tempKey, ...buttonProps } = properties;
  const temp = TEMPS[tempKey];
  if (!temp) {
    return null;
  }
  const { data, act } = useBackend(context);
  const { currentTemp } = data;
  const { label, icon } = temp;
  const selected = tempKey === currentTemp;
  const setTemp = () => {
    act('setTemp', { temp: tempKey });
  };
  return (
    <Button selected={selected} onClick={setTemp} {...buttonProps}>
      <Icon name={icon} />
      {label}
    </Button>
  );
};

export const PoolController = (properties, context) => {
  const { data } = useBackend(context);
  const { emagged, currentTemp } = data;
  const { label: currentLabel, color: currentColor } = TEMPS[currentTemp] || TEMPS.normal;

  const visibleTempKeys = [];
  for (const [tempKey, { requireEmag }] of Object.entries(TEMPS)) {
    if (!requireEmag || requireEmag && emagged) {
      visibleTempKeys.push(tempKey);
    }
  }

  return (
    <Window>
      <Window.Content>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="Current Temperature">
              <Box color={currentColor}>
                {currentLabel}
              </Box>
            </LabeledList.Item>

            <LabeledList.Item label="Safety Status">
              {emagged ? (
                <Box color="red">
                  WARNING: OVERRIDDEN
                </Box>
              ) : (
                <Box color="good">
                  Nominal
                </Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="Temperature Selection">
          <Flex className="PoolController__Buttons" direction="column" align="flex-start">
            {visibleTempKeys.map(tempKey => (
              <TempButton key={tempKey} tempKey={tempKey} />
            ))}
          </Flex>
        </Section>

      </Window.Content>
    </Window>
  );
};
