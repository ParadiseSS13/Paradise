import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const Wires = (props, context) => {
  const { act, data } = useBackend(context);

  const wires = data.wires || [];
  const statuses = data.status || [];

  return (
    <Window resizable width={350} height={100 + wires.length * 30}>
      <Window.Content>
        <Section>
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
        {!!statuses.length && (
          <Section>
            {statuses.map((status) => (
              <Box key={status} color="lightgray" mt={0.1}>
                {status}
              </Box>
            ))}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
