import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, Section, AnimatedNumber, Box } from '../components';
import { Window } from '../layouts';

export const HealthSensor = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    on,
    user_health,
    minHealth,
    maxHealth,
    alarm_health
  } = data;

  return (
    <Window>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Scanning">
              <Button
                icon='power-off'
                content={on ? 'On' : 'Off'}
                color={on ? null : 'red'}
                selected={on}
                onClick={() => act('scan_toggle')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Health activation">
              <NumberInput
                animate
                step={2}
                stepPixelSize={6}
                minValue={minHealth}
                maxValue={maxHealth}
                value={alarm_health}
                format={(value) => toFixed(value, 1)}
                width="80px"
                onDrag={(e, value) =>
                  act('alarm_health', {
                    alarm_health: value,
                  })
                }
              />
            </LabeledList.Item>
            {user_health !== null && (
              <LabeledList.Item label="User health">
                <Box color={Health2Color(user_health)}
                  bold={user_health >= 100}>
                  <AnimatedNumber value={user_health}/>
                </Box>
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
}

const Health2Color = (health) => {
  if (health > 50) {
    return 'green';
  }
  if (health > 0) {
    return 'orange';
  }
  return 'red';
};
