import { useBackend } from '../backend';
import { Box, Button, Flex, LabeledList, Section, Table, NoticeBox } from '../components';
import { Window } from '../layouts';

export const NinjaMindScan = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable theme="spider_clan">
      <Window.Content className="Layout__content--flexColumn">
        <MindScanMenu />
      </Window.Content>
    </Window>
  );
};

const MindScanMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    occupantIcon,
    occupant_name,
    occupant_health,
    scanned_occupants,
  } = data;
  let block_buttons = occupant_name === "none" ? 1 : 0;

  return (
    <Flex
      direction="column"
      shrink={1}
      alignContent="left">
      <Section title={"Пациент"}
        backgroundColor="rgba(0, 0, 0, 0.4)"
        buttons={<Button
          content="?"
          tooltip={"Отображение внешнего вида и состояния пациента в устройстве."}
          tooltipPosition="bottom-left" />}>
        <Flex
          direction="row"
          shrink={1}
          alignContent="left">
          <Flex.Item
            shrink={1}
            alignContent="left">
            <NoticeBox className="NoticeBox_blue"
              success={0}
              danger={0}
              width="90px"
              align="left">

              <Section
                style={{ "background": "rgba(4, 74, 27, 0.75)" }}
                align="left">
                <img
                  height="128px"
                  width="128px"
                  src={`data:image/jpeg;base64,${occupantIcon}`}
                  style={{
                    "margin-left": "-28px",
                    "-ms-interpolation-mode": "nearest-neighbor",
                  }} />
              </Section>
            </NoticeBox>
          </Flex.Item>
          <Flex.Item
            grow={1}
            alignContent="right">
            <NoticeBox className="NoticeBox_green"
              success={0}
              danger={0}
              align="left">

              <LabeledList>
                <LabeledList.Item label="Имя">
                  {occupant_name}
                </LabeledList.Item>
                <LabeledList.Item label="Здоровье">
                  {occupant_health}
                </LabeledList.Item>
              </LabeledList>

            </NoticeBox>
            <NoticeBox className="NoticeBox_red"
              mt={2.5}
              success={0}
              danger={0}
              align="center">
              <Button
                className={block_buttons === 0 ? "" : "Button_disabled"}
                content="Начать сканирование"
                width="250px"
                textAlign="center"
                disabled={block_buttons}
                tooltip={"Сканирует пациента и пытается добыть из его разума необходимую клану информацию."}
                tooltipPosition="bottom-left"
                onClick={() => act('scan_occupant')} />

              <Button
                className={block_buttons === 0 ? "" : "Button_disabled"}
                content="Открыть устройство"
                width="250px"
                textAlign="center"
                disabled={block_buttons}
                tooltip={"Открывает устройство, выпуская пациента из капсулы"}
                tooltipPosition="bottom-left"
                onClick={() => act('go_out')} />

              <Button
                className={block_buttons === 0 ? "" : "Button_disabled"}
                content="Телепортация пациента"
                width="250px"
                textAlign="center"
                disabled={block_buttons}
                tooltip={"Телепортирует пациента обратно на обьект с которого он был похищен. Рекомендуем как следует его запугать перед этим, чтобы он не разболтал о вас."}
                tooltipPosition="bottom-left"
                onClick={() => act('teleport_out')} />
            </NoticeBox>
          </Flex.Item>
        </Flex>
      </Section >
      <Section
        title={"Список уже просканированных вами людей"}
        align="center"
        backgroundColor="rgba(0, 0, 0, 0.4)">
        <Box maxHeight={15} overflowY="auto" overflowX="hidden">
          <Table m="0.5rem" >
            {scanned_occupants.map(r => (
              <Table.Row key={r.scanned_occupant}>
                <Table.Cell>
                  <Box>
                    {r.scanned_occupant}
                  </Box>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Box>
      </Section>
    </Flex >
  );
};
