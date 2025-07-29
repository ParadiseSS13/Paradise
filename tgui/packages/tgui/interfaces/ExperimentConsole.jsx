import { Button, LabeledList, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const statusInfoMap = new Map([
  [0, { text: 'Conscious', color: 'good' }],
  [1, { text: 'Unconscious', color: 'average' }],
  [2, { text: 'Deceased', color: 'bad' }],
]);

const experimentInfoMap = new Map([
  [0, { label: 'Probe', icon: 'thermometer' }],
  [1, { label: 'Dissect', icon: 'brain' }],
  [2, { label: 'Analyze', icon: 'search' }],
]);

export const ExperimentConsole = (props) => {
  const { act, data } = useBackend();
  const { open, feedback, occupant, occupant_name, occupant_status } = data;

  const renderScannerSection = () => {
    if (!occupant) {
      return <NoticeBox>No specimen detected.</NoticeBox>;
    }

    const getStatusInfo = () => {
      return statusInfoMap.get(occupant_status);
    };

    const statusInfo = getStatusInfo();

    return (
      <LabeledList>
        <LabeledList.Item label="Name">{occupant_name}</LabeledList.Item>
        <LabeledList.Item label="Status" color={statusInfo.color}>
          {statusInfo.text}
        </LabeledList.Item>
        <LabeledList.Item label="Experiments">
          {[0, 1, 2].map((experimentType) => (
            <Button
              key={experimentType}
              icon={experimentInfoMap.get(experimentType).icon}
              content={experimentInfoMap.get(experimentType).label}
              onClick={() => act('experiment', { experiment_type: experimentType })}
            />
          ))}
        </LabeledList.Item>
      </LabeledList>
    );
  };

  const scannerSection = renderScannerSection();

  return (
    <Window theme="abductor" width={350} height={200}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Status">{feedback}</LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Scanner"
          buttons={<Button icon="eject" content="Eject" disabled={!open} onClick={() => act('door')} />}
        >
          {scannerSection}
        </Section>
      </Window.Content>
    </Window>
  );
};
