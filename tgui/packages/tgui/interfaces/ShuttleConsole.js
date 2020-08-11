import { useBackend } from '../backend';
import { Button, LabeledList, Box, Fragment, Section } from '../components';
import { Window } from '../layouts';
import { LabeledListItem } from '../components/LabeledList';

export const ShuttleConsole = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable>
      <Window.Content>
        <LabeledList>
          <LabeledList.Item label="Location">
            {data.status ? (
              data.status
            ) : (
              <Box color="red">
                *MISSING*
              </Box>
            )}
          </LabeledList.Item>
          {!!data.shuttle && (// only show this stuff if there's a shuttle
            !!data.docking_ports_len && (
              <LabeledList.Item label={"Send to "}>
                {data.docking_ports.map(port => (
                  <Button
                    icon="chevron-right"
                    key={port.name}
                    content={port.name}
                    onClick={() => act('move', {
                      move: port.id,
                    })} />
                )
                )}
              </LabeledList.Item>
            ) || (// ELSE, if there's no docking ports.
              <Fragment>
                <LabeledListItem label="Status" color="red">
                  Shuttle Locked
                </LabeledListItem>
                {!!data.admin_controlled && (
                  <LabeledListItem label="Authorized Personnel Only">
                    <Button
                      icon="exclamation-circle"
                      content="Request Authorization"
                      disabled={!data.status}
                      onClick={() => act('request')} />
                  </LabeledListItem>
                )}
              </Fragment>
            )
          )}
        </LabeledList>
      </Window.Content>
    </Window>
  );
};
