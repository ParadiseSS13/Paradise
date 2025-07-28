import { Button, LabeledList, ProgressBar, Section, Slider, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BotStatus } from './common/BotStatus';

export const BotMed = (props) => {
  const { act, data } = useBackend();
  const {
    locked,
    noaccess,
    maintpanel,
    on,
    autopatrol,
    canhack,
    emagged,
    remote_disabled,
    painame,
    shut_up,
    declare_crit,
    stationary_mode,
    heal_threshold,
    injection_amount,
    use_beaker,
    treat_virus,
    reagent_glass,
  } = data;
  return (
    <Window width={500} height={500}>
      <Window.Content>
        <Stack fill vertical>
          <BotStatus />
          <Section title="Communication Settings">
            <Button.Checkbox
              fluid
              content="Speaker"
              checked={!shut_up}
              disabled={noaccess}
              onClick={() => act('toggle_speaker')}
            />
            <Button.Checkbox
              fluid
              content="Critical Patient Alerts"
              checked={declare_crit}
              disabled={noaccess}
              onClick={() => act('toggle_critical_alerts')}
            />
          </Section>
          <Section fill title="Treatment Settings">
            <LabeledList>
              <LabeledList.Item label="Healing Threshold">
                <Slider
                  value={heal_threshold.value}
                  minValue={heal_threshold.min}
                  maxValue={heal_threshold.max}
                  step={5}
                  disabled={noaccess}
                  onChange={(e, value) =>
                    act('set_heal_threshold', {
                      target: value,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Injection Level">
                <Slider
                  value={injection_amount.value}
                  minValue={injection_amount.min}
                  maxValue={injection_amount.max}
                  step={5}
                  format={(value) => `${value}u`}
                  disabled={noaccess}
                  onChange={(e, value) =>
                    act('set_injection_amount', {
                      target: value,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Reagent Source">
                <Button
                  content={use_beaker ? 'Beaker' : 'Internal Synthesizer'}
                  icon={use_beaker ? 'flask' : 'cogs'}
                  disabled={noaccess}
                  onClick={() => act('toggle_use_beaker')}
                />
              </LabeledList.Item>
              {reagent_glass && (
                <LabeledList.Item label="Beaker">
                  <Stack inline width="100%">
                    <Stack.Item grow={1}>
                      <ProgressBar value={reagent_glass.amount} minValue={0} maxValue={reagent_glass.max_amount}>
                        {reagent_glass.amount} / {reagent_glass.max_amount}
                      </ProgressBar>
                    </Stack.Item>
                    <Stack.Item ml={1}>
                      <Button content="Eject" disabled={noaccess} onClick={() => act('eject_reagent_glass')} />
                    </Stack.Item>
                  </Stack>
                </LabeledList.Item>
              )}
            </LabeledList>
            <Button.Checkbox
              mt={1}
              fluid
              content={'Treat Viral Infections'}
              checked={treat_virus}
              disabled={noaccess}
              onClick={() => act('toggle_treat_viral')}
            />
            <Button.Checkbox
              fluid
              content={'Stationary Mode'}
              checked={stationary_mode}
              disabled={noaccess}
              onClick={() => act('toggle_stationary_mode')}
            />
          </Section>
          {painame && (
            <Section title="pAI">
              <Button fluid icon="eject" content={painame} disabled={noaccess} onClick={() => act('ejectpai')} />
            </Section>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
