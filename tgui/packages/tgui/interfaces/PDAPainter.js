import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { Button, LabeledList, Flex, Box, Section, Table } from '../components';

export const PDAPainter = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    statusLabel,
    pdaTypes,
    hasPDA,
    pdaIcon,
    pdaOwnerName,
    pdaJobName,
  } = data;

  return (
    <Window>
      <Window.Content>
        <Flex
          spacing={1}
          direction="row"
          height="100%" flex="1">
          <Flex.Item
            width={24}
            shrink={0}>
            <Section title="Общее"
              buttons={
                <Button fluid
                  icon={hasPDA ? 'eject' : 'exclamation-triangle'}
                  selected={hasPDA}
                  content={hasPDA ? 'Извлечь' : '-----'}
                  tooltip={hasPDA ? "Извлечь PDA" : "Вставить PDA"}
                  tooltipPosition="left"
                  onClick={() => act(hasPDA ? 'eject_pda' : 'insert_pda')} />
              }>
              <LabeledList>
                <LabeledList.Item label="Имя">
                  {pdaOwnerName ? pdaOwnerName : 'Н/Д'}
                </LabeledList.Item>
                <LabeledList.Item label="Должность">
                  {pdaJobName ? pdaJobName : 'Н/Д'}
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section>
              <Flex height="100%"
                direction="column" flex="1">
                <Flex.Item>
                  <Box
                    textAlign="center">
                    <Box as="img"
                      height="160px" // Set image size here.
                      src={hasPDA ? `data:image/png;base64,${pdaIcon}`: ""}
                      style={{
                        '-ms-interpolation-mode': 'nearest-neighbor',
                      }}
                      align="middle" />
                  </Box>
                  <LabeledList m="5px">
                    <LabeledList.Item label="Статус">
                      {statusLabel}
                    </LabeledList.Item>
                  </LabeledList>

                  <Button.Confirm m="5px"
                    fluid
                    disabled={!hasPDA}
                    content="Стереть PDA"
                    confirmContent="Подтвердить?"
                    textAlign="left"
                    color="red"
                    tooltip={"Cбросить телефон на заводские настройки"}
                    tooltipPosition="top"
                    onClick={() => act("erase_pda")}
                  />
                </Flex.Item>
              </Flex>
            </Section>
          </Flex.Item>
          <Flex.Item
            width={27}>
            <Flex direction="column" height="100%" flex="1">
              <Section title="Цвет PDA" flexGrow="1">
                <Table>
                  {Object.keys(pdaTypes).map(key => (
                    <PDAColorRow
                      key={key}
                      selectedPda={key}
                      selectedPdaImage={pdaTypes[key][0]} />
                  ))}

                  {/* Logic explanation for dummies.
                    PDApainter.dm:
                      data["pdaTypes"] = colorlist << all pda colors here
                      colorlist is a list(list()):
                        example: colorlist[initial(P.icon_state)] = list(iconImage, initial(P.desc))

                        to get data:
                          colorlist[pda-clown] - yields a list that has image and description.
                          colorlist[pda-clown][1] - to get image
                          colorlist[pda-clown][2] - to get description

                    [!] in DM an array starts from 1

                      then it goes as:
                        var/data = list()
                        data["pdaTypes"] = colorlist

                    in PDAPainter.js
                      pdaTypes[key]
                      pdaTypes[pda-clown] - yields a list that has image and description.
                      pdaTypes[pda-clown][0] - to get image
                      pdaTypes[pda-clown][1] - to get description

                      [!] in JS an array start from 0
                  */}
                </Table>
              </Section>
            </Flex>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

export const PDAColorRow = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    hasPDA,
  } = data;

  const {
    selectedPda,
    selectedPdaImage,
  } = props;

  return (
    <Table.Row>
      <Table.Cell collapsing>
        <img
          src={`data:image/png;base64,${selectedPdaImage}`}
          style={{
            'vertical-align': 'middle',
            width: '32px',
            margin: '0px',
            'margin-left': '0px',
          }} />
      </Table.Cell>
      <Table.Cell bold>
        <Button.Confirm
          fluid
          disabled={!hasPDA}
          icon={selectedPdaImage}
          content={selectedPda}
          confirmContent="Покрасить?"
          textAlign="left"
          onClick={() => act("choose_pda", {
            selectedPda: selectedPda,
            selectedPdaImage: selectedPdaImage,
          })} />
      </Table.Cell>
    </Table.Row>
  );
};

