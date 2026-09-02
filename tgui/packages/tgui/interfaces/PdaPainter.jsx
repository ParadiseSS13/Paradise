import { Button, Icon, Section, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const PdaPainter = (props) => {
  const { data } = useBackend();
  const { has_pda } = data;
  return (
    <Window width={510} height={505}>
      <Window.Content>{!has_pda ? <PdaInsert /> : <PdaMenu />}</Window.Content>
    </Window>
  );
};

const PdaInsert = (props) => {
  const { act } = useBackend();
  return (
    <Section fill>
      <Stack fill>
        <Stack.Item bold grow textAlign="center" align="center" color="silver">
          <Icon name="download" size={5} mb="10px" />
          <br />
          <Button width="160px" textAlign="center" content="Insert PDA" onClick={() => act('insert_pda')} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const PdaMenu = (props) => {
  const { act, data } = useBackend();
  const { pda_colors } = data;
  return (
    <Stack fill>
      <Stack.Item>
        <PdaImage />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          <Table className="PdaPainter__list">
            {Object.keys(pda_colors).map((sprite_name) => (
              <Table.Row key={sprite_name} onClick={() => act('choose_pda', { selectedPda: sprite_name })}>
                <Table.Cell collapsing>
                  <img
                    src={`data:image/png;base64,${pda_colors[sprite_name][0]}`}
                    style={{
                      verticalAlign: 'middle',
                      width: '32px',
                      margin: '0px',
                      imageRendering: 'pixelated',
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

const PdaImage = (props) => {
  const { act, data } = useBackend();
  const { current_appearance, preview_appearance } = data;
  return (
    <Stack.Item>
      <Section title="Current PDA">
        <img
          src={`data:image/jpeg;base64,${current_appearance}`}
          style={{
            verticalAlign: 'middle',
            width: '160px',
            margin: '0px',
            imageRendering: 'pixelated',
          }}
        />
        <Button fluid textAlign="center" icon="eject" content="Eject" color="green" onClick={() => act('eject_pda')} />
        <Button fluid textAlign="center" icon="paint-roller" content="Paint PDA" onClick={() => act('paint_pda')} />
      </Section>
      <Section title="Preview">
        <img
          src={`data:image/jpeg;base64,${preview_appearance}`}
          style={{
            verticalAlign: 'middle',
            width: '160px',
            margin: '0px',
            imageRendering: 'pixelated',
          }}
        />
      </Section>
    </Stack.Item>
  );
};
