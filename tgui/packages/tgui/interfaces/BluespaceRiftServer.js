import { useBackend } from '../backend';
import { LabeledList, Section, ProgressBar, Button, Box, Icon } from '../components';
import { Window } from '../layouts';

const status_table = {
  0: "OFF",
  1: "NO_RIFTS",
  2: "SOME_RIFTS",
  3: "DANGER",
};

export const BluespaceRiftServer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    emagged,
    pointsPerProbe,
    cooldown,
    goals,
    servers,
    scanners,
  } = data;

  const goal = goalData => {
    const {
      riftId,
      riftName,
      targetResearchPoints,
      researchPoints,
      probePoints,
      rewardGiven,
    } = goalData;
    const percentage = Math.floor((researchPoints / targetResearchPoints) * 100);
    const probesLeft = (pointsPerProbe > 0) ? Math.floor(probePoints / pointsPerProbe) : 0;
    const pointsPerProbeMessage = emagged ? ("@?%%!№@" + pointsPerProbe) : pointsPerProbe;
    const enoughProbePoints = probePoints >= pointsPerProbe;
    const displayed_cooldown = cooldown - (cooldown % 5) + ((cooldown % 5) > 0 ? 5 : 0);
    return (
      <Section title="Исследование Разлома">
        <Box
          color="silver"
          bold>
          {riftName}
        </Box>
        <ProgressBar
          color={percentage === 0 ? "bad" : (percentage < 100 ? "average" : "good")}
          value={researchPoints}
          maxValue={targetResearchPoints}
          mt={1} mb={2}>
          {percentage <= 100 ? percentage : 100} %
        </ProgressBar>
        <Box>
          {"Данные для зондирования: "}
          <Box
            color={probePoints ? (enoughProbePoints ? "good" : "average") : "bad"}
            as="span">
            {Math.floor(probePoints)}
          </Box>
          <Button
            icon="atom"
            tooltip={"Для генерации одного зондирующего импульса нужно собрать " + pointsPerProbeMessage + " данных."}
            content={(cooldown > 0) ? ("Подготовка " + displayed_cooldown + " секунд") : ("Зондировать (" + probesLeft + ")")}
            disabled={!enoughProbePoints || (cooldown > 0)}
            onClick={() => act('probe', {
              rift_id: riftId,
            })}
            mx={2}
          />
          <br />
          <Button
            fluid
            textAlign="center"
            content={rewardGiven ? "Результат получен" : "Получить результат исследований"}
            disabled={rewardGiven || (percentage < 100)}
            onClick={() => act('reward', {
              rift_id: riftId,
            })}
            mt={1.4}
          />
        </Box>
      </Section>
    );
  };
  
  const server = serverData => {
    const {
      servName,
      servData,
    } = serverData;
    return (
      <LabeledList.Item label={servName}>
        {servData.length ? (
          servData.map((oneRiftData, index) => (
            <Box key={index}>
              {oneRiftData.riftName} — {Math.floor(oneRiftData.probePoints)} данных.
            </Box>
          ))
        ) : (
          <Box>
            Нет данных
          </Box>
        )}
      </LabeledList.Item>
    );
  };
  
  const scanner = scannerData => {
    const {
      scannerId,
      scannerName,
      scanStatus,
      canSwitch,
      switching,
    } = scannerData;
  
    const scanStatusTxt = status_table[scanStatus];
  
    const getStatusText = () => {
      if (scanStatusTxt === "OFF") {
        return [" ", "silver"];
      } else if (scanStatusTxt === "NO_RIFTS") {
        return ["Нет разломов", "silver"];
      } else if (scanStatusTxt === "SOME_RIFTS") {
        return ["Сканирует", "good"];
      } else if (scanStatusTxt === "DANGER") {
        return ["Опасность! Выключите сканер!", "bad"];
      }
    };
  
    const statusText = getStatusText();
  
    return (
      <LabeledList.Item
        label={scannerName}
        py={0}>
        {switching ? (
          <Icon 
            name="circle-notch"
            color="silver"
            spin
            ml={1.85} mr={1.79} my={0.84}
          />
        ) : (
          canSwitch ? (
            <Button
              icon="power-off"
              color={scanStatusTxt === "OFF" ? "bad" : "good"}
              onClick={() => act('toggle_scanner', {
                scanner_id: scannerId,
              })}
              ml={1} mr={1}
            />
          ) : (
            <Icon 
              name="power-off"
              color={scanStatusTxt === "OFF" ? "bad" : "good"}
              ml={1.85} mr={1.79} my={0.84}
            />
          )
        )}
        {(scanStatusTxt !== "OFF") && (
          <Box
            as="span"
            color={statusText[1]}>
            {statusText[0]}
          </Box>
        )}
      </LabeledList.Item>
    );
  };

  return (
    <Window resizable>
      <Window.Content scrollable>
        {goals && goals.map(goalData => (
          goal(goalData)
        ))}
        <Section title="Сканеры в сети">
          <LabeledList>
            {scanners && scanners.map(scannerData => (
              scanner(scannerData)
            ))}
          </LabeledList>
        </Section>
        <Section title="Серверы в сети">
          <LabeledList>
            {servers && servers.map(serverData => (
              server(serverData)
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
