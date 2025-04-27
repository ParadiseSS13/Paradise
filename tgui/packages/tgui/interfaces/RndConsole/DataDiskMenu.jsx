import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';

const DISK_TYPE_DESIGN = 'design';
const DISK_TYPE_TECH = 'tech';

const TechSummary = (props) => {
  const { data, act } = useBackend();
  const { disk_data } = data;

  if (!disk_data) {
    return null;
  }

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Name">{disk_data.name}</LabeledList.Item>
        <LabeledList.Item label="Level">{disk_data.level}</LabeledList.Item>
        <LabeledList.Item label="Description">{disk_data.desc}</LabeledList.Item>
      </LabeledList>
      <Box mt="10px">
        <Button content="Upload to Database" icon="arrow-up" onClick={() => act('updt_tech')} />
      </Box>
    </Box>
  );
};

// summarize a design disk contents from d_disk
const LatheSummary = (props) => {
  const { data, act } = useBackend();
  const { disk_data } = data;
  if (!disk_data) {
    return null;
  }

  const { name, lathe_types, materials } = disk_data;

  const lathe_types_str = lathe_types.join(', ');

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Name">{name}</LabeledList.Item>

        {lathe_types_str ? <LabeledList.Item label="Lathe Types">{lathe_types_str}</LabeledList.Item> : null}

        <LabeledList.Item label="Required Materials" />
      </LabeledList>

      {materials.map((mat) => (
        <Box key={mat.name}>
          {'- '}
          <span style={{ textTransform: 'capitalize' }}>{mat.name}</span>
          {' x '}
          {mat.amount}
        </Box>
      ))}

      <Box mt="10px">
        <Button content="Upload to Database" icon="arrow-up" onClick={() => act('updt_design')} />
      </Box>
    </Box>
  );
};

const DiskSection = (props) => {
  const { act, data } = useBackend();
  const { disk_data } = data;
  return (
    <Section
      buttons={
        <>
          <Button.Confirm content="Erase" icon="eraser" disabled={!disk_data} onClick={() => act('erase_disk')} />
          <Button
            content="Eject"
            icon="eject"
            onClick={() => {
              act('eject_disk');
            }}
          />
        </>
      }
      {...props}
    />
  );
};

const CopySubmenu = (props) => {
  const { data, act } = useBackend();
  const { disk_type, to_copy } = data;
  const { title } = props;

  return (
    <DiskSection title={title}>
      <Box overflowY="auto" overflowX="hidden" maxHeight="450px">
        <LabeledList>
          {to_copy
            .sort((a, b) => a.name.localeCompare(b.name))
            .map(({ name, id }) => (
              <LabeledList.Item noColon label={name} key={id}>
                <Button
                  icon="arrow-down"
                  content="Copy to Disk"
                  onClick={() => {
                    if (disk_type === DISK_TYPE_TECH) {
                      act('copy_tech', { id });
                    } else {
                      act('copy_design', { id });
                    }
                  }}
                />
              </LabeledList.Item>
            ))}
        </LabeledList>
      </Box>
    </DiskSection>
  );
};

export const DataDiskMenu = (props) => {
  const { data } = useBackend();
  const { disk_type, disk_data } = data;

  if (!disk_type) {
    return <Section title="Data Disk">No disk loaded.</Section>;
  }

  switch (disk_type) {
    case DISK_TYPE_DESIGN:
      return disk_data ? (
        <DiskSection title="Design Disk">
          <LatheSummary />
        </DiskSection>
      ) : (
        <CopySubmenu title="Design Disk" />
      );
    case DISK_TYPE_TECH:
      if (disk_data) {
        return (
          <DiskSection title="Technology Disk">
            <TechSummary />
          </DiskSection>
        );
      } else {
        return <CopySubmenu title="Technology Disk" />;
      }
    default:
      return <>UNRECOGNIZED DISK TYPE</>;
  }
};
