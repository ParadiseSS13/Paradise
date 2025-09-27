import { Box, Button, LabeledList, Section } from 'tgui-core/components';
import { useBackend } from '../../backend';
import { CardSkin, IdCard, JobNames } from './types';
import { BooleanLike } from 'tgui-core/react';
import { COLORS } from '../../constants';
import { CardInformation, CardSkins } from './card_details';

const dept_colors = COLORS.department;

type JobTransferButtonsProps = {
  dept_name: string;
  dept_color?: string;
  job_names: string[];
  job_colors: { string: string };
  default_job_color?: string;
  card?: IdCard;
};

const JobTransferButtons = (props: JobTransferButtonsProps) => {
  const { act } = useBackend();
  const { job_colors, dept_name, job_names, dept_color, default_job_color = '', card } = props;
  return (
    <LabeledList.Item label={dept_name} labelColor={dept_color}>
      {job_names.map((job_name) => (
        <Button
          selected={card?.rank === job_name}
          key={job_name}
          color={job_colors[job_name] ? job_colors[job_name] : default_job_color}
          onClick={() => act('assign', { assign_target: job_name })}
        >
          {job_name}
        </Button>
      ))}
    </LabeledList.Item>
  );
};

type JobTransferProps = {
  target_dept: number;
  card?: IdCard;
  can_terminate: BooleanLike;
  is_centcom: BooleanLike;
  jobs: JobNames;
  jobs_dept?: string[];
  job_colors: { string: string };
  card_skins: CardSkin[];
  all_centcom_skins: CardSkin[] | BooleanLike;
};

export const CardComputerJobTransfer = (props: JobTransferProps) => {
  const { act } = useBackend();
  const {
    card_skins,
    target_dept,
    card,
    can_terminate,
    is_centcom,
    jobs,
    jobs_dept = [],
    job_colors,
    all_centcom_skins,
  } = props;

  const depts = jobs && [
    { name: 'Special', jobs: jobs.top },
    { name: 'Engineering', color: dept_colors.engineering, jobs: jobs.engineering },
    { name: 'Medical', color: dept_colors.medical, jobs: jobs.medical },
    { name: 'Science', color: dept_colors.science, jobs: jobs.science },
    { name: 'Security', color: dept_colors.security, jobs: jobs.security },
    { name: 'Service', color: dept_colors.service, jobs: jobs.service },
    { name: 'Supply', color: dept_colors.supply, jobs: jobs.supply },
    { name: 'Retirement', jobs: jobs.assistant },
  ];

  return (
    <>
      <Section title="Card Information">
        {!target_dept && <CardInformation card={card} />}
        <LabeledList.Item label="Latest Transfer">{card?.lastlog || '---'}</LabeledList.Item>
      </Section>
      <Section title={target_dept ? 'Department Job Transfer' : 'Job Transfer'}>
        <LabeledList>
          {target_dept ? (
            <JobTransferButtons dept_name="Department" job_colors={job_colors} job_names={jobs_dept} card={card} />
          ) : (
            <>
              {depts.map((dept) => (
                <JobTransferButtons
                  dept_name={dept.name}
                  dept_color={dept.color}
                  job_names={dept.jobs}
                  job_colors={job_colors}
                  card={card}
                />
              ))}
            </>
          )}
          {!!is_centcom && (
            <JobTransferButtons
              dept_name="Centcom"
              dept_color={dept_colors.centcom}
              job_colors={job_colors}
              job_names={jobs.centcom}
              default_job_color="purple"
              card={card}
            />
          )}
          <LabeledList.Item label="Demotion">
            <Button
              disabled={card?.assignment === 'Demoted' || card?.assignment === 'Terminated'}
              key="Demoted"
              tooltip="Assistant access, 'demoted' title."
              color="red"
              icon="times"
              onClick={() => act('demote')}
            >
              Demoted
            </Button>
          </LabeledList.Item>
          {!!can_terminate && (
            <LabeledList.Item label="Non-Crew">
              <Button
                disabled={card?.assignment === 'Terminated'}
                key="Terminate"
                tooltip="Zero access. Not crew."
                color="red"
                icon="eraser"
                onClick={() => act('terminate')}
              >
                Terminated
              </Button>
            </LabeledList.Item>
          )}
        </LabeledList>
      </Section>
      {!target_dept && (
        <CardSkins card={card} card_skins={card_skins} is_centcom={is_centcom} all_centcom_skins={all_centcom_skins} />
      )}
    </>
  );
};
