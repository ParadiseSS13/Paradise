import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const Wires = (props) => {
  const { act, data } = useBackend();

  const wires = data.wires || [];
  const statuses = data.status || [];
  const dynamicHeight = 56 + wires.length * 23 + (status ? 0 : 15 + statuses.length * 17);

  return (
    <Window width={350} height={dynamicHeight}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section fill scrollable>
              <LabeledList>
                {wires.map((wire) => (
                  <LabeledList.Item
                    key={wire.seen_color}
                    className="candystripe"
                    label={wire.color_name}
                    labelColor={wire.seen_color}
                    color={wire.seen_color}
                    buttons={
                      <>
                        <Button
                          content={wire.cut ? 'Mend' : 'Cut'}
                          onClick={() =>
                            act('cut', {
                              wire: wire.color,
                            })
                          }
                        />
                        <Button
                          content="Pulse"
                          onClick={() =>
                            act('pulse', {
                              wire: wire.color,
                            })
                          }
                        />
                        <Button
                          content={wire.attached ? 'Detach' : 'Attach'}
                          onClick={() =>
                            act('attach', {
                              wire: wire.color,
                            })
                          }
                        />
                      </>
                    }
                  >
                    {!!wire.wire && <i>({wire.wire})</i>}
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Section>
          </Stack.Item>
          {!!statuses.length && (
            <Stack.Item>
              <Section>
                {statuses.map((status) => (
                  <Box key={status} color="lightgray">
                    {status}
                  </Box>
                ))}
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
