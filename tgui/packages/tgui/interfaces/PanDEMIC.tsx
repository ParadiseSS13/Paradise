import { ReactNode } from 'react';
import {
  Button,
  Dimmer,
  Dropdown,
  Flex,
  Icon,
  LabeledList,
  Modal,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface BaseStats {
  resistance: number;
  stealth: number;
  stageSpeed: number;
  transmissibility: number;
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
  possibleCures?: string;
  transmissionRoute?: string;
  symptoms: PathogenSymptom[];
  baseStats: BaseStats;
  isAdvanced: BooleanLike;
  RequiredCures: string;
  Stabilized: BooleanLike;
  StrainTracker: string;
}

interface Contribution {
  factor: string;
  amount: number;
  maxAmount: number;
}
interface PanDEMICData {
  synthesisCooldown: BooleanLike;
  beakerLoaded: BooleanLike;
  beakerContainsBlood: BooleanLike;
  beakerContainsVirus: BooleanLike;
  selectedStrainIndex: number;
  strains: PathogenStrain[];
  resistances: string[];
  analysisDuration: number;
  analysisTime: number;
  canAnalyze: boolean;
  analyzing: boolean;
  reporting: boolean;
  analysisDifficulty: number;
  analysisContributions: Contribution[];
  totalContribution: number;
  symptom_names: string[];
  predictions: string[];
}

export const PanDEMIC = (props) => {
  const { data } = useBackend<PanDEMICData>();
  const { reporting, analyzing, beakerLoaded, beakerContainsBlood, beakerContainsVirus, resistances = [] } = data;
  let emptyPlaceholder;
  if (!beakerLoaded) {
    emptyPlaceholder = <>No container loaded.</>;
  } else if (!beakerContainsBlood) {
    emptyPlaceholder = <>No blood sample found in the loaded container.</>;
  } else if (beakerContainsBlood && !beakerContainsVirus) {
    emptyPlaceholder = <>No disease detected in provided blood sample.</>;
  }

  return (
    <Window width={700} height={640}>
      <Window.Content>
        <Stack fill vertical>
          <AnalysisDimmer operating={analyzing || reporting} name="PanD.E.M.I.C" />
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

const AnalysisDimmer = (props) => {
  const { operating } = props;
  const { act, data } = useBackend<PanDEMICData>();
  const { analyzing, analysisTime, analysisDuration, analysisDifficulty, totalContribution, analysisContributions } =
    data;
  const analysisReport = (
    <>
      <LabeledList.Item label="Analysis Difficulty">{Math.ceil(analysisDifficulty)}</LabeledList.Item>

      {analysisContributions.map((contribution, i) => (
        <LabeledList.Item key={i} label={contribution.factor}>
          {Math.floor(contribution.amount)}
        </LabeledList.Item>
      ))}
      <LabeledList.Item label="Total">{Math.floor(totalContribution)}</LabeledList.Item>
      <LabeledList.Item label="Analysis Result">
        {analysisDifficulty - totalContribution < 0 ? 'Disease Analyzed Successfully' : 'Analysis Failed'}
      </LabeledList.Item>
    </>
  );
  if (operating) {
    if (analyzing) {
      return (
        <Dimmer>
          <Flex mb="30px">
            <Flex.Item bold color="silver" textAlign="center">
              <Icon name="spinner" spin size={4} mb="15px" />
              <br />
              Analyzing {Math.floor(100 - (100 * analysisTime) / analysisDuration)}%
            </Flex.Item>
          </Flex>
        </Dimmer>
      );
    }
    return (
      <Modal backgroundColor="rgba(0, 0, 0, 1)">
        <Section title="Analysis Results" backgroundColor="rgba(0, 0, 0, 1)" bold>
          <Stack vertical>
            <LabeledList>{analysisReport}</LabeledList>
            <Button textAlign="center" onClick={() => act('close_report')}>
              Close
            </Button>
          </Stack>
        </Section>
      </Modal>
    );
  }
};

const CommonCultureActions = (props) => {
  const { act, data } = useBackend<PanDEMICData>();
  const { beakerLoaded } = data;
  return (
    <>
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

const StrainInformation = (props: { strain: PathogenStrain; strainIndex: number }) => {
  const { act, data } = useBackend<PanDEMICData>();
  const { analysisDifficulty, analysisContributions, beakerContainsVirus, analyzing, canAnalyze } = data;
  const {
    commonName,
    description,
    strainID,
    sample_stage,
    known,
    diseaseAgent,
    bloodDNA,
    bloodType,
    possibleCures,
    transmissionRoute,
    isAdvanced,
    RequiredCures,
    Stabilized,
    StrainTracker,
  } = props.strain;

  const bloodInformation = (
    <>
      <LabeledList.Item label="Blood DNA">
        {!bloodDNA ? 'Undetectable' : <span style={{ fontFamily: "'Courier New', monospace" }}>{bloodDNA}</span>}
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

  const analysisInformation = (
    <>
      <LabeledList.Item label="Analysis Difficulty">{Math.ceil(analysisDifficulty)}</LabeledList.Item>
      {analysisContributions.map((contribution, i) => (
        <LabeledList.Item key={i} label={contribution.factor}>
          <ProgressBar
            maxValue={Math.min(contribution.maxAmount, analysisDifficulty)}
            minValue={0}
            value={contribution.amount}
            ranges={{
              good: [Math.min(contribution.maxAmount, analysisDifficulty) * 0.66, Infinity],
              average: [
                Math.min(contribution.maxAmount, analysisDifficulty) * 0.33,
                Math.min(contribution.maxAmount, analysisDifficulty) * 0.66,
              ],
              bad: [-Infinity, Math.min(contribution.maxAmount, analysisDifficulty) * 0.33],
            }}
          >
            {contribution.amount}
          </ProgressBar>
        </LabeledList.Item>
      ))}
    </>
  );

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
          style={{ marginLeft: 'auto' }}
        />
      );
    } else {
      nameButtons = (
        <Button
          icon="pen"
          content={
            commonName !== undefined && commonName !== null && commonName !== 'Unknown'
              ? 'Rename Disease'
              : 'Name Disease'
          }
          disabled={!known}
          onClick={() => act('name_strain', { strain_index: props.strainIndex })}
          style={{ marginLeft: 'auto' }}
        />
      );
    }
    let analyzeButton;
    let removeDataButton;
    if (isAdvanced) {
      analyzeButton = (
        <Button
          content="Analyze"
          disabled={!canAnalyze || analyzing}
          onClick={() => act('analyze_strain', { strain_index: props.strainIndex })}
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
      <Stack vertical>
        <Stack align="left">
          {nameButtons}
          {analyzeButton}
          {removeDataButton}
        </Stack>
        <LabeledList>
          <LabeledList.Item label="Common Name" className="common-name-label">
            {commonName ?? 'Unknown'}
          </LabeledList.Item>
          {description && <LabeledList.Item label="Description">{description}</LabeledList.Item>}
          <LabeledList.Item label="Strain ID">{strainID}</LabeledList.Item>
          {canAnalyze ? analysisInformation : ''}
          <LabeledList.Item label="Sample Stage">{sample_stage}</LabeledList.Item>
          <LabeledList.Item label="Disease Agent">{diseaseAgent}</LabeledList.Item>
          {bloodInformation}
          <LabeledList.Item label="Spread Vector">{transmissionRoute ?? 'None'}</LabeledList.Item>
          <LabeledList.Item label="Possible Cures">{possibleCures ?? 'None'}</LabeledList.Item>
          <LabeledList.Item label="Required Cures">{RequiredCures ?? 'None'}</LabeledList.Item>
          {isAdvanced ? <LabeledList.Item label="Stabilized">{Stabilized === 1 ? 'Yes' : 'No'}</LabeledList.Item> : ''}
          {isAdvanced ? (
            <LabeledList.Item label="Tracked Strain">
              {StrainTracker && StrainTracker !== '' ? StrainTracker : 'None'}
            </LabeledList.Item>
          ) : (
            ''
          )}
        </LabeledList>
      </Stack>
    );
  }
};

const StrainInformationSection = (props: {
  strain: PathogenStrain;
  strainIndex: number;
  sectionTitle?: string;
  sectionButtons?: ReactNode;
}) => {
  const { act, data } = useBackend<PanDEMICData>();
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

const CultureInformationSection = (props) => {
  const { act, data } = useBackend<PanDEMICData>();
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
      </Section>
    </Stack.Item>
  );
};

const sum = (values: number[]) => {
  return values.reduce((r, value) => r + value, 0);
};

const StrainSymptomsSection = (props: { className?: string; strain: PathogenStrain }) => {
  const { act, data } = useBackend<PanDEMICData>();
  const { predictions, symptom_names, analyzing, analysisDuration } = data;
  const { baseStats, symptoms, known } = props.strain;
  return (
    <Flex.Item grow>
      <Section title="Infection Symptoms" fill className={props.className}>
        <Table className="symptoms-table">
          <Table.Row>
            <Table.Cell>Name</Table.Cell>
            <Table.Cell>Stealth</Table.Cell>
            <Table.Cell>Resistance</Table.Cell>
            <Table.Cell>Stage Speed</Table.Cell>
            <Table.Cell>Transmissibility</Table.Cell>
          </Table.Row>
          {symptoms.map((symptom, index) => (
            <Table.Row key={index}>
              {known || !(symptom.name === 'UNKNOWN') ? (
                <Table.Cell>{symptom.name}</Table.Cell>
              ) : (
                <Dropdown
                  options={symptom_names.sort((a, b) => a.localeCompare(b))}
                  width="180px"
                  selected={predictions[index]}
                  disabled={analyzing || analysisDuration === -2}
                  onSelected={(val) => act('set_prediction', { pred_index: index + 1, pred_value: val })}
                />
              )}
              <Table.Cell>{symptom.stealth}</Table.Cell>
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
            <Table.Cell bold>Total</Table.Cell>
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

const ResistancesSection = (props) => {
  const { act, data } = useBackend<PanDEMICData>();
  const { synthesisCooldown, beakerContainsVirus, resistances } = data;
  return (
    <Stack.Item>
      <Section title="Antibodies" fill>
        <Stack wrap>
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
