import { useBackend } from '../backend';
import { Box, Button, Section, Icon, Dimmer, Flex } from '../components';
import { Window } from '../layouts';

const status_table = {
  0: "OFF",
  1: "NO_RIFTS",
  2: "SOME_RIFTS",
  3: "DANGER",
};

export const BluespaceRiftScanner = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    scanStatus,
    noServers,
    switching,
  } = data;
  const status = status_table[scanStatus];

  const getStatusText = () => {
    if (status === "OFF") {
      return [" ", "silver"];
    } else if (status === "NO_RIFTS") {
      return ["Нет разломов в радиусе сканирования.", "silver"];
    } else if (status === "SOME_RIFTS") {
      if (noServers) {
        return ["Сервер не найден. Передача данных приостановлена.", "average"];
      } else {
        return ["Сканирование проходит успешно.", "good"];
      }
    } else if (status === "DANGER") {
      return ["Опасность! Выключите сканер!", "bad"];
    }
  };

  const statusText = getStatusText();

  const inactiveIconOpacity = 0.11;

  const powerIconColor = status === "OFF" ? ["grey", inactiveIconOpacity] : ["good", 1];
  const scanIconColor = status === "SOME_RIFTS" ? [(noServers ? "average" : "good"), 1] : ["grey", inactiveIconOpacity];
  const dangerIconColor = status === "DANGER" ? ["bad", 1] : ["grey", inactiveIconOpacity];

  return (
    <Window resizable>
      <Window.Content>
        {switching ? (
          <Dimmer
            backgroundColor="black"
            opacity={0.85}>
            <Flex>
              <Flex.Item
                bold
                textAlign="center"
                mb={2}>
                <Icon
                  name="circle-notch"
                  size={2}
                  mb={4}
                  spin
                /><br />
                {status === "OFF" ? "Сканер включается..." : "Сканер выключается..."}
              </Flex.Item>
            </Flex>
          </Dimmer>
        ) : (
          <>
            <Section 
              title="Статус"
              pb={1}>
              <Icon
                name="power-off"
                size={2}
                color={powerIconColor[0]}
                opacity={powerIconColor[1]}
                mx={0.7} mt={0.1}
              />
              <Icon
                name="satellite-dish"
                size={2}
                color={scanIconColor[0]}
                opacity={scanIconColor[1]}
                mx={0.7} mt={0.1}
              />
              <Icon
                name="exclamation-triangle"
                size={2}
                color={dangerIconColor[0]}
                opacity={dangerIconColor[1]}
                mx={0.7} mt={0.1}
              />
              <Box
                fontSize="1.3rem"
                color="silver"
                italic={status !== "OFF"}
                mt={1.7} mb={1} ml={0.7}>
                {status === "OFF" ? "Сканер выключен" : "Сканирование..."}
              </Box>
              {(status !== "OFF") && (
                <Box color={statusText[1]}>
                  <Icon
                    name="info"
                    opacity={0.9}
                    ml={1.1} mr={1.4}
                  />
                  {statusText[0]}
                </Box>
              )}
            </Section>
            <Section>
              <Button
                fluid
                icon="power-off"
                textAlign="center"
                content={status === "OFF" ? "Включить" : "Выключить"}
                onClick={() => act('toggle')}
              />
            </Section>
          </>
        )}
      </Window.Content>
    </Window>
  );
};
