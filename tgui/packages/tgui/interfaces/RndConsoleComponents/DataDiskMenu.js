import { useBackend } from "../../backend";
import { Button, LabeledList, Section, Box } from "../../components";
import { RndNavButton, RndRoute } from "./index";
import { SUBMENU } from "../RndConsole";

const DISK_TYPE_DESIGN = 'design';
const DISK_TYPE_TECH = 'tech';

const TechSummary = (properties, context) => {
  const { data, act } = useBackend(context);
  const { disk_data } = data;

  if (!disk_data) { return null; }

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Name">{disk_data.name}</LabeledList.Item>
        <LabeledList.Item label="Level">{disk_data.level}</LabeledList.Item>
        <LabeledList.Item label="Description">{disk_data.desc}</LabeledList.Item>
      </LabeledList>
      <Box mt="10px">
        <Button content="Upload to Database" icon="arrow-up" onClick={() => act('updt_tech')} />
        <Button content="Clear Disk" icon="trash" onClick={() => act('clear_tech')} />
        <EjectDisk />
      </Box>
    </Box>
  );
};

// summarize a design disk contents from d_disk
const LatheSummary = (properties, context) => {
  const { data, act } = useBackend(context);
  const { disk_data } = data;
  if (!disk_data) { return null; }

  const { name, lathe_types, materials } = disk_data;

  const lathe_types_str = lathe_types.join(', ');

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Name">
          {name}
        </LabeledList.Item>

        {lathe_types_str ? (
          <LabeledList.Item label="Lathe Types">
            {lathe_types_str}
          </LabeledList.Item>
        ) : null}

        <LabeledList.Item label="Required Materials" />
      </LabeledList>

      {materials.map(mat => (
        <Box key={mat.name}>
          {"- "}
          <span style={{ 'text-transform': 'capitalize' }}>{mat.name}</span>
          {" x "}
          {mat.amount}
        </Box>
      ))}

      <Box mt="10px">
        <Button content="Upload to Database" icon="arrow-up" onClick={() => act('updt_design')} />
        <Button content="Clear Disk" icon="trash" onClick={() => act('clear_design')} />
        <EjectDisk />
      </Box>
    </Box>
  );
};

const EmptyDisk = (properties, context) => {
  const { data } = useBackend(context);
  const { disk_type } = data;
  return (
    <Box>
      <Box>This disk is empty.</Box>
      <Box mt="10px">
        <RndNavButton
          submenu={SUBMENU.DISK_COPY}
          icon="arrow-down"
          content={disk_type === DISK_TYPE_TECH
            ? 'Load Tech to Disk'
            : 'Load Design to Disk'} />
        <EjectDisk />
      </Box>
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
        const action = disk_type === DISK_TYPE_TECH ? 'eject_tech' : 'eject_design';
        act(action);
      }} />
  );
};

const ContentsSubmenu = (properties, context) => {
  const { data: { disk_data, disk_type } } = useBackend(context);

  const body = () => {
    if (!disk_data) {
      return <EmptyDisk />;
    }
    switch (disk_type) {
      case DISK_TYPE_DESIGN:
        return <LatheSummary />;
      case DISK_TYPE_TECH:
        return <TechSummary />;
      default:
        return null;
    }
  };

  return (
    <Section title="Data Disk Contents">
      {body()}
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
      <RndRoute submenu={SUBMENU.MAIN} render={() => <ContentsSubmenu />} />
      <RndRoute submenu={SUBMENU.DISK_COPY} render={() => <CopySubmenu />} />
    </>
  );
};
