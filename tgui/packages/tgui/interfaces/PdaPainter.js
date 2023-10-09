import { useBackend } from '../backend';
import { Button, Flex, Icon, Section, Table } from '../components';
import { Window } from '../layouts';

export const PdaPainter = (props, context) => {
  const { data } = useBackend(context);
  const { has_pda } = data;
  return (
    <Window>
      <Window.Content>{!has_pda ? <PdaInsert /> : <PdaMenu />}</Window.Content>
    </Window>
  );
};

const PdaInsert = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Section height="100%" stretchContents>
      <Flex height="100%" align="center" justify="center">
        <Flex.Item
          bold
          grow="1"
          textAlign="center"
          align="center"
          color="silver"
        >
          <Icon name="download" size={5} mb="10px" />
          <br />
          <Button
            width="160px"
            textAlign="center"
            content="Insert PDA"
            onClick={() => act('insert_pda')}
          />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const PdaMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { pda_colors } = data;
  return (
    <Flex height="100%">
      <Flex.Item width="180px" mr="3px">
        <PdaImage />
      </Flex.Item>
      <Flex.Item width="65%" mr="3px">
        <Flex direction="column" height="100%" flex="1">
          <Section height="100%" flexGrow="1">
            <Table className="PdaPainter__list">
              {Object.keys(pda_colors).map((sprite_name) => (
                <Table.Row
                  key={sprite_name}
                  onClick={() =>
                    act('choose_pda', { selectedPda: sprite_name })
                  }
                >
                  <Table.Cell collapsing>
                    <img
                      src={`data:image/png;base64,${pda_colors[sprite_name][0]}`}
                      style={{
                        'vertical-align': 'middle',
                        width: '32px',
                        margin: '0px',
                        'margin-left': '0px',
                        '-ms-interpolation-mode': 'nearest-neighbor',
                      }}
                    />
                  </Table.Cell>
                  <Table.Cell>{sprite_name}</Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        </Flex>
      </Flex.Item>
    </Flex>
  );
};

const PdaImage = (props, context) => {
  const { act, data } = useBackend(context);
  const { current_appearance, preview_appearance } = data;
  return (
    <Flex.Item>
      <Section title="Current PDA">
        <img
          src={`data:image/jpeg;base64,${current_appearance}`}
          style={{
            'vertical-align': 'middle',
            width: '160px',
            margin: '0px',
            'margin-left': '0px',
            '-ms-interpolation-mode': 'nearest-neighbor',
          }}
        />
        <Button
          fluid
          textAlign="center"
          icon="eject"
          content="Eject"
          color="green"
          onClick={() => act('eject_pda')}
        />
        <Button
          fluid
          textAlign="center"
          icon="paint-roller"
          content="Paint PDA"
          onClick={() => act('paint_pda')}
        />
      </Section>
      <Section title="Preview">
        <img
          src={`data:image/jpeg;base64,${preview_appearance}`}
          style={{
            'vertical-align': 'middle',
            width: '160px',
            margin: '0px',
            'margin-left': '0px',
            '-ms-interpolation-mode': 'nearest-neighbor',
          }}
        />
      </Section>
    </Flex.Item>
  );
};
