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
            <Fragment>
              {!!data.docking_ports_len && (
              // I am not sure if I am nesting this stuff right...
                <Fragment>
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
                  {/* Apparently I need to comment like this sometimes??
                Also end of the button at /> up there.*/}
                </Fragment>
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
              )}
              {/* end of the docking_ports_len if/else block
             there is an (as far as I can tell) unreachable
             piece of code in the original tmpl since
             docking_request doesn't seem to be ever set
             so it's probably not needed?*/}
            </Fragment>
          )}
        </LabeledList>
      </Window.Content>
    </Window>
  );
};
