import { useBackend } from '../backend';
import { Button, Flex, Section, Tooltip, ProgressBar, NoticeBox } from '../components';
import { FlexItem } from '../components/Flex';
import { Window } from '../layouts';

export const NinjaBloodScan = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable theme="spider_clan">
      <Window.Content className="Layout__content--flexColumn">
        <BloodScanMenu />
        <FakeLoadBar />
      </Window.Content>
    </Window>
  );
};

const BloodScanMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    vialIcons,
    noVialIcon,
    bloodOwnerNames,
    bloodOwnerSpecies,
    bloodOwnerTypes,
    blockButtons,
    scanStates,
  } = data;
  let rowStyles = { blue: "Button_blue", green: "Button_green", red: "Button_red", disabled: "Button_disabled" };
  const noticeBoxStyles = ["NoticeBox_red", "NoticeBox", "NoticeBox_blue"];
  const flexColumns = [1, 2, 3];
  return (
    <Flex
      direction="column"
      shrink={1}
      alignContent="center">
      <Section title={"Образцы"}
        backgroundColor="rgba(0, 0, 0, 0.4)"
        buttons={<Button
          content="?"
          tooltip={"Добавьте три образца крови. \
          Машина настроена на работу с кровью существ и условиями которые поставил вам клан. \
          Реагенты им не соответствующие не примутся или сканирование не будет успешным"}
          tooltipPosition="bottom-left" />}>
        <Flex
          direction="row"
          shrink={1}
          alignContent="center">
          {flexColumns.map((x, i) => (
            <FlexItem
              direction="column"
              width="33.3%"
              ml={i ? 2 : 0}
              key={i}>
              <Section title={bloodOwnerNames[i] ? "Кровь" : "Нет реагента"}
                style={{ "text-align": "left", "background": "rgba(53, 94, 163, 0.5)" }} />
              <NoticeBox className={noticeBoxStyles[scanStates[i]]} success={0} danger={0} align="center">
                <Button
                  className={!blockButtons ? rowStyles.blue : rowStyles.disabled}
                  height="100%"
                  width="100%"
                  disabled={blockButtons}
                  onClick={() => act("vial_out", { button_num: i + 1 })}>
                  <img
                    height="128px"
                    width="128px"
                    src={`data:image/jpeg;base64,${vialIcons[i] || noVialIcon}`}
                    style={{
                      "margin-left": "3px",
                      "-ms-interpolation-mode": "nearest-neighbor",
                    }} />
                  <Tooltip
                    title={bloodOwnerNames[i] || " - "}
                    content={`Раса: ${bloodOwnerSpecies[i] || " - "}` + "\n" + `Тип крови: ${bloodOwnerTypes[i] || " - "}`}
                    position="bottom" />
                </Button>
              </NoticeBox>
            </FlexItem>)
          )}

        </Flex>
        <NoticeBox className="NoticeBox_red"
          success={0}
          danger={0}
          align="center">
          <Button
            className={blockButtons === 0 ? "" : "Button_disabled"}
            content="Начать сканирование"
            width="250px"
            textAlign="center"
            disabled={blockButtons}
            tooltip={"Сканирует кровь и пересылает полученную информацию клану."}
            tooltipPosition="bottom"
            onClick={() => act('scan_blood')} />
        </NoticeBox>
      </Section>
    </Flex >
  );
};

const FakeLoadBar = (properties, context) => {
  const { data } = useBackend((properties, context));
  const {
    progressBar,
  } = data;
  return (
    <Section
      stretchContents>
      <ProgressBar
        color="green"
        value={progressBar}
        minValue={0}
        maxValue={100}>
        <center>
          <NoticeBox
            className={"NoticeBox_green"}
            mt={1}>
            {progressBar ? `Загрузка ${progressBar + "%"}` : `Режим ожидания`}
          </NoticeBox>
        </center>
      </ProgressBar>
    </Section >
  );
};
