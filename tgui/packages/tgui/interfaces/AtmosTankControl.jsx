import { Button, LabeledList, NumberInput, ProgressBar, Section } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { getGasColor, getGasLabel } from '../constants';
import { Window } from '../layouts';

export const AtmosTankControl = (props) => {
  const { act, data } = useBackend();

  let sensors_list = data.sensors || {};

  return (
    <Window width={400} height={435}>
      <Window.Content scrollable>
        {Object.keys(sensors_list).map((s) => (
          <Section key={s} title={s}>
            <LabeledList>
              {Object.keys(sensors_list[s]).indexOf('pressure') > -1 ? (
                <LabeledList.Item label="Pressure">{sensors_list[s]['pressure']} kpa</LabeledList.Item>
              ) : (
                ''
              )}
              {Object.keys(sensors_list[s]).indexOf('temperature') > -1 ? (
                <LabeledList.Item label="Temperature">{sensors_list[s]['temperature']} K</LabeledList.Item>
              ) : (
                ''
              )}

              {['o2', 'n2', 'plasma', 'co2', 'n2o'].map((g) =>
                Object.keys(sensors_list[s]).indexOf(g) > -1 ? (
                  <LabeledList.Item key={getGasLabel(g)} label={getGasLabel(g)}>
                    <ProgressBar color={getGasColor(g)} value={sensors_list[s][g]} minValue={0} maxValue={100}>
                      {toFixed(sensors_list[s][g], 2) + '%'}
                    </ProgressBar>
                  </LabeledList.Item>
                ) : (
                  ''
                )
              )}
            </LabeledList>
          </Section>
        ))}
        <Section title="Inlets">
          {data.inlets && Object.keys(data.inlets).length > 0
            ? data.inlets.map((inlet) => (
                <Section title={inlet.name} key={inlet}>
                  <LabeledList>
                    <LabeledList.Item label="Power">
                      <Button
                        icon={inlet.on ? 'power-off' : 'power-off'}
                        content={inlet.on ? 'On' : 'Off'}
                        color={inlet.on ? null : 'red'}
                        selected={inlet.on}
                        onClick={() => act('toggle_inlet_active', { dev: inlet.uid })}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Rate">
                      <NumberInput
                        animated
                        unit={'L/s'}
                        width={6.1}
                        lineHeight={1.5}
                        step={1}
                        minValue={0}
                        maxValue={50}
                        value={inlet.rate}
                        onChange={(value) =>
                          act('set_inlet_volume_rate', {
                            dev: inlet.uid,
                            val: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              ))
            : ''}
        </Section>
        <Section title="Outlets">
          {data.vent_outlets && Object.keys(data.vent_outlets).length > 0
            ? data.vent_outlets.map((outlet) => (
                <Section title={'Outlet: ' + outlet.name} key={outlet}>
                  <LabeledList>
                    <LabeledList.Item label="Status">
                      <Button
                        icon={outlet.on ? 'power-off' : 'power-off'}
                        content={outlet.on ? 'On' : 'Off'}
                        color={outlet.on ? null : 'red'}
                        selected={outlet.on}
                        onClick={() => act('toggle_outlet_active', { dev: outlet.uid })}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Pressure Checks">
                      <Button
                        content="External"
                        selected={outlet.checks === 1}
                        onClick={() => act('set_outlet_reference', { dev: outlet.uid, val: 1 })}
                      />
                      <Button
                        content="Internal"
                        selected={outlet.checks === 2}
                        onClick={() => act('set_outlet_reference', { dev: outlet.uid, val: 2 })}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Rate">
                      <NumberInput
                        animated
                        unit={'kPa'}
                        width={6.1}
                        lineHeight={1.5}
                        step={10}
                        minValue={0}
                        maxValue={5066}
                        value={outlet.rate}
                        onChange={(value) =>
                          act('set_outlet_pressure', {
                            dev: outlet.uid,
                            val: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              ))
            : ''}
          {data.scrubber_outlets && Object.keys(data.scrubber_outlets).length > 0 ? <TankControlScrubbersView /> : ''}
        </Section>
      </Window.Content>
    </Window>
  );
};

const TankControlScrubbersView = (props) => {
  const { act, data } = useBackend();
  return data.scrubber_outlets.map((s) => (
    <Section title={'Outlet: ' + s.name} key={s.name}>
      <LabeledList>
        <LabeledList.Item label="Status">
          <Button
            content={s.power ? 'On' : 'Off'}
            selected={s.power}
            icon="power-off"
            onClick={() =>
              act('command', {
                cmd: 'power',
                id_tag: s.id_tag,
              })
            }
          />
          <Button
            content={s.scrubbing ? 'Scrubbing' : 'Siphoning'}
            icon={s.scrubbing ? 'filter' : 'sign-in-alt'}
            onClick={() =>
              act('command', {
                cmd: 'scrubbing',
                id_tag: s.id_tag,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Range">
          <Button
            content={s.widenet ? 'Extended' : 'Normal'}
            selected={s.widenet}
            icon="expand-arrows-alt"
            onClick={() =>
              act('command', {
                cmd: 'widenet',
                id_tag: s.id_tag,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Filtering">
          <Button
            content="Carbon Dioxide"
            selected={s.filter_co2}
            onClick={() =>
              act('command', {
                cmd: 'co2_scrub',
                id_tag: s.id_tag,
              })
            }
          />
          <Button
            content="Plasma"
            selected={s.filter_toxins}
            onClick={() =>
              act('command', {
                cmd: 'tox_scrub',
                id_tag: s.id_tag,
              })
            }
          />
          <Button
            content="Nitrous Oxide"
            selected={s.filter_n2o}
            onClick={() =>
              act('command', {
                cmd: 'n2o_scrub',
                id_tag: s.id_tag,
              })
            }
          />
          <Button
            content="Oxygen"
            selected={s.filter_o2}
            onClick={() =>
              act('command', {
                cmd: 'o2_scrub',
                id_tag: s.id_tag,
              })
            }
          />
          <Button
            content="Nitrogen"
            selected={s.filter_n2}
            onClick={() =>
              act('command', {
                cmd: 'n2_scrub',
                id_tag: s.id_tag,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  ));
};
