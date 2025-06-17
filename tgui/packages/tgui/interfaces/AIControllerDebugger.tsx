import { ReactNode } from 'react';
import { Box, Button, Flex, LabeledList, NoticeBox, Section, Stack, Table, Tabs, Tooltip } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { truncate } from 'lodash';

interface AIControllerDebuggerData {
  controller: AIController;
}

interface ObjRef {
  name: string;
  uid: string;
}

interface AIController {
  type: string;
  pawn?: ObjRef;
  idle_behavior: string;
  movement: string;
  movement_target?: MovementTarget;
  current_behaviors: string[];
  planned_behaviors: string[];
  blackboard: BlackboardItem[];
}

interface MovementTarget extends ObjRef {
  source: string;
}

interface BlackboardItem {
  name: string;
  value: string;
  uid?: string;
}

export const CopyableValue = ({ text }) => {
  return (
    <>
      <Button icon="clipboard-list" onClick={() => navigator.clipboard.writeText(text)} />
      <span style={{ fontFamily: 'monospace' }}>{text}</span>
    </>
  );
};

export const ObjectReference = (props: { obj_ref: ObjRef }) => {
  const { act } = useBackend();
  const { obj_ref } = props;
  return (
    <>
      <Button onClick={() => act('vv', { uid: obj_ref.uid })}>VV</Button>
      <Button onClick={() => act('flw', { uid: obj_ref.uid })}>FLW</Button>
      &nbsp;{obj_ref.name}
    </>
  );
};

export const AIControllerDebugger = (props) => {
  const { data, act } = useBackend<AIControllerDebuggerData>();
  const { controller } = data;
  return (
    <Window width={675} height={600}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Section title="Basic Info">
            <Table>
              {controller.pawn && (
                <Table.Row>
                  <Table.Cell>Pawn</Table.Cell>
                  <Table.Cell>
                    <ObjectReference obj_ref={controller.pawn} />
                  </Table.Cell>
                </Table.Row>
              )}
              <Table.Row>
                <Table.Cell>Type</Table.Cell>
                <Table.Cell>
                  <CopyableValue text={controller.type} />
                </Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell>Idle Behavior</Table.Cell>
                <Table.Cell>
                  <CopyableValue text={controller.idle_behavior} />
                </Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell>Movement</Table.Cell>
                <Table.Cell>
                  <CopyableValue text={controller.movement} />
                </Table.Cell>
              </Table.Row>
              {controller.movement_target && (
                <>
                  <Table.Row>
                    <Table.Cell>Movement Target</Table.Cell>
                    <Table.Cell>
                      <ObjectReference obj_ref={controller.movement_target} />
                    </Table.Cell>
                  </Table.Row>
                  <Table.Row>
                    <Table.Cell>Target Source</Table.Cell>
                    <Table.Cell>
                      <CopyableValue text={controller.movement_target.source} />
                    </Table.Cell>
                  </Table.Row>
                </>
              )}
            </Table>
          </Section>
          <Section title="Blackboard">
            <Table className="AIControllerDebugger__Blackboard">
              {controller.blackboard.map((blackboard_item) => (
                <Table.Row>
                  <Table.Cell>
                    {blackboard_item.name.length > 30 ? (
                      <Tooltip content={blackboard_item.name}>
                        <Box>{truncate(blackboard_item.name)}</Box>
                      </Tooltip>
                    ) : (
                      blackboard_item.name
                    )}
                  </Table.Cell>
                  <Table.Cell className="bb_value">
                    {blackboard_item.uid && (
                      <>
                        <Button onClick={() => act('vv', { uid: blackboard_item.uid })}>VV</Button>
                        <Button onClick={() => act('flw', { uid: blackboard_item.uid })}>FLW</Button>
                        &nbsp;
                      </>
                    )}
                    {blackboard_item.value || 'null'}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
          <Section title="Current Behaviors">
            <Table>
              {controller.current_behaviors.map((behavior) => (
                <Table.Row>
                  <Table.Cell>
                    <CopyableValue text={behavior} />
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
          <Section title="Planned Behaviors">
            <Table>
              {controller.planned_behaviors.map((behavior) => (
                <Table.Row>
                  <Table.Cell>
                    <CopyableValue text={behavior} />
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};
