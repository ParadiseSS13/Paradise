import { useBackend } from '../backend';
import { Button, LabeledList, Section, Table, Dropdown, Flex } from '../components';
import { Window } from '../layouts';

export const FloorPainter = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    availableStyles,
    selectedStyle,
    selectedDir,
    directionsPreview,
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Floor painter">
          <LabeledList>
            <LabeledList.Item label="style">
              <Flex>
                <Button
                  content="<-"
                  onClick={() => act("cycle_style", { offset: -1 })}
                />
                <Dropdown
                  options={availableStyles}
                  selected={selectedStyle}
                  // forceUpdate={stuff=>{this.selected = stuff}}
                  width="150px"
                  height="20px"
                  onSelected={val => act("select_style", { style: val })}
                  // ref={(dropdown) =>alert(dropdown)}
                />
                <Button
                  content="->"
                  onClick={() => act("cycle_style", { offset: 1 })}
                />
              </Flex>
            </LabeledList.Item>
            <LabeledList.Item label="direction">
              <Table style={{ display: "inline" }}>
                {["north", "", "south"].map(latitude => (
                  <Table.Row key={latitude}>
                    {[latitude + "west", latitude, latitude + "east"].map(
                      dir => (
                        <Table.Cell key={dir}>
                          {dir === "" || (
                            <img
                              src={`data:image/jpeg;base64,${directionsPreview[dir]}`}
                              style={{
                                "border-style":
                                  (dir === selectedDir && "solid") || "none",
                                "border-width": "2px",
                                "border-color": "orange",
                                padding: (dir === selectedDir && "2px") || "4px",
                              }}
                              onClick={() => act("select_direction", { direction: dir })}
                            />
                          )}
                        </Table.Cell>
                      )
                    )}
                  </Table.Row>
                ))}
              </Table>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
