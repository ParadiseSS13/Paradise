import { useBackend } from '../backend';
import { Button, LabeledList, Box, Section } from '../components';
import { Window } from '../layouts';
import { LabeledListItem } from '../components/LabeledList';

export const ShuttleConsole = (props, context) => {
  const { act, data } = useBackend(context);
  // get stuff
  return (
    <Window>
      <Window.Content>
        <LabeledList>
          <LabeledList.Item label="Location">
            {data.status ? (
              data.status
            ) : (
              <Box bold lineHeight={2} color="red">
                *MISSING*
              </Box>
            )}
          </LabeledList.Item>
        </LabeledList>
        {!!data.shuttle && (// only show this stuff if there's a shuttle
          <>
            {!!data.docking_ports_len && (
              // I am not sure if I am nesting this stuff right...
              <>
                {data.docking_ports.map(port => (
                  <Button key={port.name} // IDK man
                    content={"Send to " + port.name}
                    // TODO: should button have icon?
                    disabled={!data.status}
                    // I am not sure if there's any conditions
                    // where this should be locked
                    onClick={() => act('move', {
                      move: port.id,
                    })} />
                )
                )}
                {/* Apparently I need to comment like this sometimes??
                Also end of the button at /> up there.*/}
              </>
            ) || (// ELSE, if there's no docking ports.
              <>
                <LabeledList>
                  <LabeledListItem label="Status" color="red">
                    Shuttle Locked
                  </LabeledListItem>
                </LabeledList>
                {!!data.admin_controlled && (
                  <LabeledListItem label="Authorized Personnel Only">
                    <Button
                      content="Request Authorization"
                      // TODO: should button have icon?
                      disabled={!data.status}// I am not sure if there's
                      // any conditions this should be locked
                      onClick={() => act('request')} />
                  </LabeledListItem>
                )}
              </>
            )}
            {/* end of the docking_ports_len if/else block
             there is an (as far as I can tell) unreachable
             piece of code in the original tmpl since
             docking_request doesn't seem to be ever set
             so it's probably not needed?*/}
          </>
        )}
      </Window.Content>
    </Window>
  );
};
