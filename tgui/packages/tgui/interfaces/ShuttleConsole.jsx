import { Button, Fragment, LabeledList, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const ShuttleConsole = (props) => {
  const { act, data } = useBackend();
  return (
    <Window width={500} height={350}>
      <Window.Content scrollable>
        {data.shuttles.map((s) => (
          <Section key={s.shuttle_id} title={s.shuttle_name}>
            <LabeledList>
              <LabeledList.Item label="Location">
                {s.status ? s.status : <NoticeBox color="red">Shuttle Missing</NoticeBox>}
              </LabeledList.Item>
              {!!s.shuttle && // only show this stuff if there's a shuttle
                ((!!s.docking_ports_len && (
                  <LabeledList.Item label={'Send to '}>
                    {s.docking_ports.map((port) => (
                      <Button
                        icon="chevron-right"
                        key={port.name}
                        content={port.name}
                        onClick={() =>
                          act('move', {
                            shuttle: s.shuttle_id,
                            move: port.id,
                          })
                        }
                      />
                    ))}
                  </LabeledList.Item>
                )) || ( // ELSE, if there's no docking ports.
                  <>
                    <LabeledList.Item label="Status" color="red">
                      <NoticeBox color="red">Shuttle Locked</NoticeBox>
                    </LabeledList.Item>
                    {!!s.admin_controlled && (
                      <LabeledList.Item label="Authorization">
                        <Button
                          icon="exclamation-circle"
                          content="Request Authorization"
                          disabled={!s.status}
                          onClick={() => act('request', {
                            shuttle: s.shuttle_id,
                          })}
                        />
                      </LabeledList.Item>
                    )}
                  </>
                ))}
            </LabeledList>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
