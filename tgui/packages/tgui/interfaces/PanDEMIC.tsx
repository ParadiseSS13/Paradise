import { BooleanLike } from '../../common/react';
import { InfernoNode } from 'inferno';
import { useBackend } from '../backend';
import { Button, Dropdown, Flex, LabeledList, NoticeBox, Section, Stack, Table, Tabs } from '../components';
import { Window } from '../layouts';
import { Operating } from '../interfaces/common/Operating';

interface BaseStats {
  stealth: number;
  resistance: number;
  stageSpeed: number;
  transmissibility: number;
  severity: number;
}
interface PathogenSymptom {
  name: string;
  stealth: number;
  resistance: number;
  stageSpeed: number;
  transmissibility: number;
  guess: string;
}

interface PathogenStrain {
  commonName?: string;
  description?: string;
  strainID?: string;
  strainFullID?: string;
  diseaseID?: string;
  sample_stage?: number;
  known?: BooleanLike;
  bloodDNA?: string;
  bloodType?: string;
  diseaseAgent: string;
  possibleTreatments?: string;
  transmissionRoute?: string;
  symptoms?: PathogenSymptom[];
  baseStats?: BaseStats;
  isAdvanced: BooleanLike;
}

interface PanDEMICData {
  synthesisCooldown: BooleanLike;
  beakerLoaded: BooleanLike;
  beakerContainsBlood: BooleanLike;
  beakerContainsVirus: BooleanLike;
  calibrating: BooleanLike;
  canCalibrate: BooleanLike;
  selectedStrainIndex: number;
  strains?: PathogenStrain[];
  resistances?: string[];
  analysisTimeDelta: number;
  analysisTime: number;
  accumulatedError: number;
  analyzing: BooleanLike;
  sympton_names: string[];
}

export const PanDEMIC = (props, context) => {
  const { data } = useBackend<PanDEMICData>(context);
  const { beakerLoaded, beakerContainsBlood, beakerContainsVirus, calibrating, resistances = [] } = data;

  let emptyPlaceholder;
  if (!beakerLoaded) {
    emptyPlaceholder = <>No container loaded.</>;
  } else if (!beakerContainsBlood) {
    emptyPlaceholder = <>No blood sample found in the loaded container.</>;
  } else if (beakerContainsBlood && !beakerContainsVirus) {
    emptyPlaceholder = <>No disease detected in provided blood sample.</>;
  }

  return (
    <Window width={700} height={510}>
      <Window.Content>
        <Stack fill vertical>
          <Operating operating={calibrating} name="PanD.E.M.I.C" />
          {emptyPlaceholder && !beakerContainsVirus ? (
            <Section title="Container Information" buttons={<CommonCultureActions fill vertical />}>
              <NoticeBox>{emptyPlaceholder}</NoticeBox>
            </Section>
          ) : (
            <CultureInformationSection />
          )}
          {resistances?.length > 0 && <ResistancesSection align="bottom" />}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const CommonCultureActions = (props, context) => {
  const { act, data } = useBackend<PanDEMICData>(context);
  const { beakerLoaded, canCalibrate } = data;
  return (
    <>
      <Button icon="disk" content="Calibrate" disabled={!canCalibrate} onClick={() => act('calibrate')} />
      <Button icon="eject" content="Eject" disabled={!beakerLoaded} onClick={() => act('eject_beaker')} />
      <Button.Confirm
        icon="trash-alt"
        confirmIcon="eraser"
        content="Destroy"
        confirmContent="Destroy"
        disabled={!beakerLoaded}
        onClick={() => act('destroy_eject_beaker')}
      />
    </>
  );
};

const StrainInformation = (props: { strain: PathogenStrain; strainIndex: number }, context) => {
  const { act, data } = useBackend<PanDEMICData>(context);
  const { beakerContainsVirus, analysisTime, analysisTimeDelta, accumulatedError, analyzing } = data;
  const {
    commonName,
    description,
    strainID,
    sample_stage,
    known,
    diseaseAgent,
    bloodDNA,
    bloodType,
    possibleTreatments,
    transmissionRoute,
    isAdvanced,
  } = props.strain;

  const bloodInformation = (
    <>
      <LabeledList.Item label="Blood DNA">
        {!bloodDNA ? 'Undetectable' : <span style={{ 'font-family': "'Courier New', monospace" }}>{bloodDNA}</span>}
      </LabeledList.Item>
      <LabeledList.Item label="Blood Type">
        {
          <div
            // blood type can sometimes contain a span
            // eslint-disable-next-line react/no-danger
            dangerouslySetInnerHTML={{ __html: bloodType ?? 'Undetectable' }}
          />
        }
      </LabeledList.Item>
    </>
  );

  if (!beakerContainsVirus) {
    return <LabeledList>{bloodInformation}</LabeledList>;
  }

  let nameButtons;
  if (isAdvanced) {
    if (commonName !== undefined && commonName !== null && commonName !== 'Unknown') {
      nameButtons = (
        <Button
          icon="print"
          content="Print Release Forms"
          disabled={!known}
          onClick={() =>
            act('print_release_forms', {
              strain_index: props.strainIndex,
            })
          }
          style={{ 'margin-left': 'auto' }}
        />
      );
    } else {
      nameButtons = (
        <Button
          icon="pen"
          content="Name Disease"
          disabled={!known}
          onClick={() => act('name_strain', { strain_index: props.strainIndex })}
          style={{ 'margin-left': 'auto' }}
        />
      );
    }
  }
  let analyzeButton;
  let removeDataButton;
  if (isAdvanced) {
    analyzeButton = (
      <Button
        content="Analyze"
        disabled={analysisTimeDelta < 0 || analyzing}
        onClick={() => act('analyze_strain', { strain_id: props.strain.diseaseID, symptoms: props.strain.symptoms })}
      />
    );
    removeDataButton = (
      <Button.Confirm
        icon={'trash-alt'}
        confirmIcon="eraser"
        content="Delete Data"
        confirmContent="Delete Data"
        disabled={!props.strain.known}
        onClick={() => act('remove_from_database', { strain_id: props.strain.strainFullID })}
      />
    );
  }

  return (
    <LabeledList>
      <LabeledList.Item label="Common Name" className="common-name-label">
        <Stack horizontal align="center">
          {commonName ?? 'Unknown'}
          {nameButtons}
          {analyzeButton}
          {removeDataButton}
        </Stack>
      </LabeledList.Item>
      {
        <LabeledList.Item label="Analysis Time">
          {analyzing
            ? (analysisTime < 6000 ? '0' : '') +
              Math.floor(analysisTime / 600) +
              ':' +
              (Math.floor((analysisTime / 10) % 60) < 10 ? '0' : '') +
              Math.floor((analysisTime / 10) % 60)
            : analysisTimeDelta >= 0
              ? (analysisTimeDelta < 6000 ? '0' : '') +
                Math.floor(analysisTimeDelta / 600) +
                ':' +
                (Math.floor((analysisTimeDelta / 10) % 60) < 10 ? '0' : '') +
                Math.floor((analysisTimeDelta / 10) % 60)
              : analysisTimeDelta === -1
                ? 'Strain Data Is Present In Database'
                : 'Multiple Strains Detected. Analysis Impossible'}
        </LabeledList.Item>
      }
      <LabeledList.Item label="Time From Accumulated Error">
        {(accumulatedError < 6000 ? '0' : '') +
          Math.floor(accumulatedError / 600) +
          ':' +
          (Math.floor((accumulatedError / 10) % 60) < 10 ? '0' : '') +
          Math.floor((accumulatedError / 10) % 60)}
      </LabeledList.Item>

      {description && <LabeledList.Item label="Description">{description}</LabeledList.Item>}
      <LabeledList.Item label="Strain ID">{strainID}</LabeledList.Item>
      <LabeledList.Item label="Sample Stage">{sample_stage}</LabeledList.Item>
      <LabeledList.Item label="Disease Agent">{diseaseAgent}</LabeledList.Item>
      {bloodInformation}
      <LabeledList.Item label="Spread Vector">{transmissionRoute ?? 'None'}</LabeledList.Item>
      <LabeledList.Item label="Possible Cures">{possibleTreatments ?? 'None'}</LabeledList.Item>
    </LabeledList>
  );
};

const StrainInformationSection = (
  props: {
    strain: PathogenStrain;
    strainIndex: number;
    sectionTitle?: string;
    sectionButtons?: InfernoNode | InfernoNode[];
  },
  context
) => {
  const { act, data } = useBackend<PanDEMICData>(context);
  let synthesisCooldown = !!data.synthesisCooldown;
  const appliedSectionButtons = (
    <>
      <Button
        icon={synthesisCooldown ? 'spinner' : 'clone'}
        iconSpin={synthesisCooldown}
        content="Clone"
        disabled={synthesisCooldown}
        onClick={() => act('clone_strain', { strain_index: props.strainIndex })}
      />
      {props.sectionButtons}
    </>
  );

  return (
    <Flex.Item>
      <Section title={props.sectionTitle ?? 'Strain Information'} buttons={appliedSectionButtons}>
        <StrainInformation strain={props.strain} strainIndex={props.strainIndex} />
      </Section>
    </Flex.Item>
  );
};

const CultureInformationSection = (props, context) => {
  const { act, data } = useBackend<PanDEMICData>(context);
  const { selectedStrainIndex, strains } = data;
  const selectedStrain = strains[selectedStrainIndex - 1];

  if (strains.length === 0) {
    return (
      <Section title="Container Information" buttons={<CommonCultureActions />}>
        <NoticeBox>No disease detected in provided blood sample.</NoticeBox>
      </Section>
    );
  }

  if (strains.length === 1) {
    return (
      <>
        <StrainInformationSection strain={strains[0]} strainIndex={1} sectionButtons={<CommonCultureActions />} />
        {strains[0].symptoms?.length > 0 && <StrainSymptomsSection strain={strains[0]} />}
      </>
    );
  }

  const sectionButtons = <CommonCultureActions />;

  return (
    <Stack.Item grow>
      <Section title="Culture Information" fill buttons={sectionButtons}>
        <Flex direction="column" style={{ 'height': '100%' }}>
          <Flex.Item>
            <Tabs>
              {strains.map((strain, i) => (
                <Tabs.Tab
                  key={i}
                  icon="virus"
                  selected={selectedStrainIndex - 1 === i}
                  onClick={() => act('switch_strain', { strain_index: i + 1 })}
                >
                  {strain.commonName ?? 'Unknown'}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Flex.Item>
          <StrainInformationSection strain={selectedStrain} strainIndex={selectedStrainIndex} />
          {selectedStrain.symptoms?.length > 0 && (
            <StrainSymptomsSection className="remove-section-bottom-padding" strain={selectedStrain} />
          )}
        </Flex>
      </Section>
    </Stack.Item>
  );
};

const sum = (values: number[]) => {
  return values.reduce((r, value) => r + value, 0);
};

const StrainSymptomsSection = (props: { className?: string; strain: PathogenStrain }, context) => {
  const { act, data } = useBackend<PanDEMICData>(context);
  const { sympton_names, analyzing, analysisTimeDelta } = data;
  const { baseStats, symptoms, known } = props.strain;

  return (
    <Flex.Item grow>
      <Section title="Infection Symptoms" fill className={props.className}>
        <Table className="symptoms-table">
          <Table.Row>
            <Table.Cell>Name</Table.Cell>
            <Table.Cell>{known ? 'Stealth' : 'Predicted Symptoms'}</Table.Cell>
            <Table.Cell>Resistance</Table.Cell>
            <Table.Cell>Stage Speed</Table.Cell>
            <Table.Cell>Transmissibility</Table.Cell>
          </Table.Row>
          {symptoms.map((symptom, index) => (
            <Table.Row key={index}>
              <Table.Cell>{known ? symptom.name : 'UNKNOWN'}</Table.Cell>
              {known ? (
                <Table.Cell>{symptom.stealth}</Table.Cell>
              ) : (
                <Dropdown
                  options={sympton_names}
                  width="180px"
                  selected={'No Prediction'}
                  disabled={analyzing || analysisTimeDelta === -2}
                  onSelected={(val) => (symptom.guess = val)}
                />
              )}
              <Table.Cell>{symptom.resistance}</Table.Cell>
              <Table.Cell>{symptom.stageSpeed}</Table.Cell>
              <Table.Cell>{symptom.transmissibility}</Table.Cell>
            </Table.Row>
          ))}

          <Table.Row className="table-spacer" />
          <Table.Row>
            <Table.Cell>{'Base Stats'}</Table.Cell>
            <Table.Cell>{known ? baseStats.stealth : 'UNKNOWN'}</Table.Cell>
            <Table.Cell>{known ? baseStats.resistance : 'UNKNOWN'}</Table.Cell>
            <Table.Cell>{known ? baseStats.stageSpeed : 'UNKNOWN'}</Table.Cell>
            <Table.Cell>{known ? baseStats.transmissibility : 'UNKNOWN'}</Table.Cell>
          </Table.Row>

          <Table.Row>
            <Table.Cell style={{ 'font-weight': 'bold' }}>Total</Table.Cell>
            <Table.Cell>{known ? sum(symptoms.map((s) => s.stealth)) + baseStats.stealth : 'UNKNOWN'}</Table.Cell>
            <Table.Cell>{known ? sum(symptoms.map((s) => s.resistance)) + baseStats.resistance : 'UNKNOWN'}</Table.Cell>
            <Table.Cell>{known ? sum(symptoms.map((s) => s.stageSpeed)) + baseStats.stageSpeed : 'UNKNOWN'}</Table.Cell>
            <Table.Cell>
              {known ? sum(symptoms.map((s) => s.transmissibility)) + baseStats.transmissibility : 'UNKNOWN'}
            </Table.Cell>
          </Table.Row>
        </Table>
      </Section>
    </Flex.Item>
  );
};

const VaccineSynthesisIcons = ['flask', 'vial', 'eye-dropper'];

const ResistancesSection = (props, context) => {
  const { act, data } = useBackend<PanDEMICData>(context);
  const { synthesisCooldown, beakerContainsVirus, resistances } = data;
  return (
    <Stack.Item>
      <Section title="Antibodies" fill>
        <Stack horizontal wrap>
          {resistances.map((r, i) => (
            <Stack.Item key={i}>
              <Button
                icon={VaccineSynthesisIcons[i % VaccineSynthesisIcons.length]}
                disabled={!!synthesisCooldown}
                onClick={() => act('clone_vaccine', { resistance_index: i + 1 })}
                mr="0.5em"
              />
              {r}
            </Stack.Item>
          ))}
        </Stack>
      </Section>
    </Stack.Item>
  );
};
