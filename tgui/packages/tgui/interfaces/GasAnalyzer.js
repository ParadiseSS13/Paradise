import { useBackend } from '../backend';
import { GasmixParser } from '../../common/GasmixParser';
import { Button, Flex, LabeledList, Section, Box } from '../components';
import { Window } from '../layouts';

export const GasAnalyzerContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { gasmixes, autoUpdating } = data;
  return (
    <Section
      title={gasmixes[0].name}
      key={gasmixes[0]}
      buttons={
        <Button
          icon={autoUpdating ? 'unlock' : 'lock'}
          onClick={() => act('autoscantoggle')}
          tooltip={
            autoUpdating ? 'Auto-Update Enabled' : 'Auto-Update Disabled'
          }
          fluid
          textAlign="center"
          selected={autoUpdating}
        />
      }>
      <GasmixParser />
    </Section>
  );
};

export const GasAnalyzerHistory = (props, context) => {
  const { act, data } = useBackend(context);
  const { historyGasmixes, historyViewMode, historyIndex } = data;
  return (
    <Section
      fill
      title="Scan History"
      buttons={
        <Button
          icon={'trash'}
          tooltip="Clear History"
          onClick={() => act('clearhistory')}
          textAlign="center"
          disabled={historyGasmixes.length === 0}
        />
      }>
      <LabeledList.Item label="Mode">
        <Flex inline width="50%">
          <Flex.Item>
            <Button
              content={'kPa'}
              onClick={() => act('modekpa')}
              textAlign="center"
              selected={historyViewMode === 'kpa'}
            />
          </Flex.Item>
          <Flex.Item>
            <Button
              content={'mol'}
              onClick={() => act('modemol')}
              textAlign="center"
              selected={historyViewMode === 'mol'}
            />
          </Flex.Item>
        </Flex>
      </LabeledList.Item>
      <LabeledList>
        {historyGasmixes.map((historyGasmix, index) => (
          <Box key={historyGasmix[0]}>
            <Button
              content={
                index + 1
                + '. '
                + (historyViewMode === 'mol'
                  ? historyGasmix[0].total_moles.toFixed(2)
                  : historyGasmix[0].pressure.toFixed(2))
              }
              onClick={() => act('input', { target: index + 1 })}
              textAlign="left"
              selected={index + 1 === historyIndex}
              fluid
            />
          </Box>
        ))}
      </LabeledList>
    </Section>
  );
};

export const GasAnalyzer = (props, context) => {
  const styleLeftDiv = {
    float: 'left',
    width: '67%',
  };
  const styleRightDiv = {
    float: 'right',
    width: '33%',
  };
  return (
    <Window>
      <Window.Content scrollable>
        {/* Left Column */}
        <div style={styleLeftDiv}>
          <Section grow>
            <GasAnalyzerContent />
          </Section>
        </div>
        {/* Right Column */}
        <div style={styleRightDiv}>
          <Section width={'160px'}>
            <GasAnalyzerHistory />
          </Section>
        </div>
      </Window.Content>
    </Window>
  );
};
