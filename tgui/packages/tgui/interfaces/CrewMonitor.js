import { sortBy } from 'common/collections';
import { useBackend } from "../backend";
import { Window } from "../layouts";
import { NanoMap, Box, Table, Tooltip, Icon, Button } from "../components";

export const CrewMonitor = (props, context) => {
  const { act, data } = useBackend(context);
  const crew = sortBy(
    crewmember => crewmember.name,
  )(data.crewmembers || []);
  return (
    <Window>
      <Window.Content>
        {crew.map(crewmember => (
          (crewmember.sensor_type === 3 ? (
            <Box
              name={crewmember.sensor_type === 3 ? "circle" : "none"}
              position="absolute"
              className="NanoMap_Marker"
              top={(((255 - crewmember.y) * 2) + 2) + 'px'}
              left={((crewmember.x * 2) + 2) + 'px'}
              tooltip={crewmember.name}>
              <Icon
                name="circle"
                color={crewmember.dead ? 'red' : 'green'}
                size={0.5}
              />
              <Tooltip content={crewmember.name} />
            </Box>
          ) : (null))
        ))}
        <NanoMap />
        <div className="NanoMap_Content_Offset">
          <Box bold m={2}>
            <Table>
              <Table.Row header>
                <Table.Cell>
                  Name
                </Table.Cell>
                <Table.Cell>
                  Status
                </Table.Cell>
                <Table.Cell>
                  Location
                </Table.Cell>
              </Table.Row>
              {crew.map(crewmember => (
                <Table.Row key={crewmember.name}>
                  <td>
                    {crewmember.name} ({crewmember.assignment})
                  </td>
                  <td>
                    <Box inline
                      color={crewmember.dead ? 'red' : 'green'}>
                      {crewmember.dead ? 'Deceased' : 'Living'}
                    </Box>
                    {crewmember.sensor_type >= 2 ? (
                      <Box inline>
                        {'('}
                        <Box inline
                          color="red">
                          {crewmember.brute}
                        </Box>
                        {'|'}
                        <Box inline
                          color="orange">
                          {crewmember.fire}
                        </Box>
                        {'|'}
                        <Box inline
                          color="green">
                          {crewmember.tox}
                        </Box>
                        {'|'}
                        <Box inline
                          color="blue">
                          {crewmember.oxy}
                        </Box>
                        {')'}
                      </Box>
                    ) : null}
                  </td>
                  <td>
                    {crewmember.sensor_type === 3 ? (
                      data.isAI ? (
                        <Button fluid
                          content={crewmember.area+" ("
                            +crewmember.x+", "+crewmember.y+")"}
                          onClick={() => act('track', {
                            track: crewmember.ref,
                          })} />
                      ) : (
                        crewmember.area+" ("+crewmember.x+", "+crewmember.y+")"
                      )
                    ) : "Not Available"}
                  </td>
                </Table.Row>
              ))}
            </Table>
          </Box>
        </div>
      </Window.Content>
    </Window>
  );
};
