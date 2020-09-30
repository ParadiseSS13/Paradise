import { useBackend } from "../../backend";
import { Button, LabeledList, Section, Box } from "../../components";
import { RndNavButton, RndRoute } from "./index";

const TechSummary = (properties, context) => {
  const { data, act } = useBackend(context);
  const { disk_data } = data;

  if (!disk_data) { return null; }

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Name" labelColor="white">{disk_data.name}</LabeledList.Item>
        <LabeledList.Item label="Level" labelColor="white">{disk_data.level}</LabeledList.Item>
        <LabeledList.Item label="Description" labelColor="white">{disk_data.desc}</LabeledList.Item>
      </LabeledList>
      <Button content="Upload to Database" icon="arrow-up" onClick={() => act('updt_tech')} />
      <Button content="Clear Disk" icon="trash" onClick={() => act('clear_tech')} />
      <EjectDisk />
    </Box>
  );
};

const LatheSummary = (properties, context) => {
  const { data, act } = useBackend(context);
  const { disk_data } = data;
  if (!disk_data) { return null; }

  const {
    name, lathe_types, materials,
  } = disk_data;

  const lathe_types_str = (lathe_types || []).join(', ');

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Name" labelColor="white">
          {name}
        </LabeledList.Item>

        {lathe_types_str ? (
          <LabeledList.Item label="Lathe Types" labelColor="white">
            {lathe_types_str}
          </LabeledList.Item>
        ) : null}

        <LabeledList.Item label="Required Materials" labelColor="white" />
      </LabeledList>

      {materials.map(mat => (
        <Box key={mat.name}>
          {"- "}
          <span style={{ 'text-transform': 'capitalize' }}>{mat.name}</span>
          {" x "}
          {mat.amount}
        </Box>
      ))}

      <Button content="Upload to Database" icon="arrow-up" onClick={() => act('updt_design')} />
      <Button content="Clear Disk" icon="trash" onClick={() => act('clear_design')} />
      <EjectDisk />
    </Box>
  );
};

const EmptyDisk = (properties, context) => {
  const { data } = useBackend(context);
  const { disk_type } = data;
  return (
    <Box>
      <Box>This disk is empty.</Box>
      <RndNavButton
        submenu={1}
        icon="arrow-down"
        content={disk_type === 1
          ? 'Load Tech to Disk'
          : 'Load Design to Disk'} />
      <EjectDisk />
    </Box>
  );
};

const EjectDisk = (properties, context) => {
  const { data, act } = useBackend(context);
  const { disk_type } = data;

  if (!disk_type) { return null; }

  return (
    <Button content="Eject Disk" icon="eject"
      onClick={() => {
        const action = disk_type === 1 ? 'eject_tech' : 'eject_design';
        act(action);
      }} />
  );
};

const ContentsSubmenu = (properties, context) => {
  const { data } = useBackend(context);

  const { disk_data, disk_type } = data;

  return (
    <Section title="Data Disk Contents">
      {disk_data
        ? (disk_type === 1 ? <TechSummary /> : <LatheSummary />)
        : <EmptyDisk />}
    </Section>
  );
};

const CopySubmenu = (properties, context) => {
  const { data, act } = useBackend(context);
  const { disk_type, to_copy } = data;

  return (
    <Section>
      <Box overflowY="auto" overflowX="hidden" maxHeight="450px">
        <LabeledList>
          {to_copy
            .sort((a, b) => a.name.localeCompare(b.name))
            .map(({ name, id }) => (
              <LabeledList.Item noColon labelColor="yellow" label={name} key={id}>
                <Button
                  icon="arrow-down"
                  content="Copy to Disk"
                  onClick={() => {
                    if (disk_type === 1) {
                      act('copy_tech', { id });
                    } else {
                      act('copy_design', { id });
                    }
                  }} />
              </LabeledList.Item>
            ))}
        </LabeledList>
      </Box>
    </Section>
  );
};


export const DataDiskMenu = (properties, context) => {
  const { data } = useBackend(context);
  const { disk_type } = data;

  if (!disk_type) {
    return null; // can't access menu without a disk
  }

  return (
    <>
      <RndRoute submenu={0} render={() => <ContentsSubmenu />} />
      <RndRoute submenu={1} render={() => <CopySubmenu />} />
    </>
  );
};
