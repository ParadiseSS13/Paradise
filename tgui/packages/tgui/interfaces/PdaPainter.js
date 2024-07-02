import { useBackend } from '../backend';
import { Button, Icon, Section, Table, Stack } from '../components';
import { Window } from '../layouts';

export const PdaPainter = (props, context) => {
  const { data } = useBackend(context);
  const { has_pda } = data;
  return (
    <Window width={510} height={505}>
      <Window.Content>{!has_pda ? <PdaInsert /> : <PdaMenu />}</Window.Content>
    </Window>
  );
};

const PdaInsert = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Section fill>
      <Stack fill>
        <Stack.Item bold grow textAlign="center" align="center" color="silver">
          <Icon name="download" size={5} mb="10px" />
          <br />
          <Button
            width="160px"
            textAlign="center"
            content="Insert PDA"
            onClick={() => act('insert_pda')}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const PdaMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { pda_colors } = data;
  return (
    <Stack fill horizontal>
      <Stack.Item>
        <PdaImage />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          <Table className="PdaPainter__list">
            {Object.keys(pda_colors).map((sprite_name) => (
              <Table.Row
                key={sprite_name}
                onClick={() => act('choose_pda', { selectedPda: sprite_name })}
              >
                <Table.Cell collapsing>
                  <img
                    src={`data:image/png;base64,${pda_colors[sprite_name][0]}`}
                    style={{
                      'vertical-align': 'middle',
                      width: '32px',
                      margin: '0px',
                      'margin-left': '0px',
                      '-ms-interpolation-mode': 'nearest-neighbor', // TODO: Remove with 516
                      'image-rendering': 'pixelated',
                    }}
                  />
                </Table.Cell>
                <Table.Cell>{sprite_name}</Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const PdaImage = (props, context) => {
  const { act, data } = useBackend(context);
  const { current_appearance, preview_appearance } = data;
  return (
    <Stack.Item>
      <Section title="Current PDA">
        <img
          src={`data:image/jpeg;base64,${current_appearance}`}
          style={{
            'vertical-align': 'middle',
            width: '160px',
            margin: '0px',
            'margin-left': '0px',
            '-ms-interpolation-mode': 'nearest-neighbor', // TODO: Remove with 516
            'image-rendering': 'pixelated',
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
            '-ms-interpolation-mode': 'nearest-neighbor', // TODO: Remove with 516
            'image-rendering': 'pixelated',
          }}
        />
      </Section>
    </Stack.Item>
  );
};
