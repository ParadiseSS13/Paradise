import { Button, Collapsible, Icon, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ComplexModal } from './common/ComplexModal';

export const GeneModder = (props) => {
  const { data } = useBackend();
  const { has_seed } = data;

  return (
    <Window width={950} height={650}>
      <div className="GeneModder__left">
        <Window.Content>
          <Disks scrollable />
        </Window.Content>
      </div>
      <div className="GeneModder__right">
        <Window.Content>
          <Stack fill vertical scrollable>
            <Storage />
            <ComplexModal maxWidth="75%" maxHeight="75%" />
            {has_seed === 0 ? <MissingSeed /> : <Genes />}
          </Stack>
        </Window.Content>
      </div>
    </Window>
  );
};

const Genes = (props) => {
  const { act, data } = useBackend();
  const { disk } = data;

  return (
    <Section title="Genes" fill scrollable>
      <CoreGenes />
      <ReagentGenes />
      <TraitGenes />
    </Section>
  );
};

const MissingSeed = (props) => {
  return (
    <Section fill height="85%">
      <Stack height="100%">
        <Stack.Item bold grow="1" textAlign="center" align="center" color="green">
          <Icon name="leaf" size={5} mb="10px" />
          <br />
          The plant DNA manipulator is missing a seed.
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const Storage = (props) => {
  const { act, data } = useBackend();
  const { has_seed, seed, has_disk, disk } = data;

  let show_seed;
  let show_disk;

  if (has_seed) {
    show_seed = (
      <Stack.Item mb="-6px" mt="-4px">
        <img
          src={`data:image/jpeg;base64,${seed.image}`}
          style={{
            verticalAlign: 'middle',
            width: '32px',
            margin: '-1px',
            marginLeft: '-11px',
          }}
        />
        <Button content={seed.name} onClick={() => act('eject_seed')} />
        <Button ml="3px" icon="pen" tooltip="Name Variant" onClick={() => act('variant_name')} />
      </Stack.Item>
    );
  } else {
    show_seed = (
      <Stack.Item>
        <Button ml={3.3} content="None" onClick={() => act('eject_seed')} />
      </Stack.Item>
    );
  }

  if (has_disk) {
    show_disk = disk.name;
  } else {
    show_disk = 'None';
  }

  return (
    <Section title="Storage">
      <LabeledList>
        <LabeledList.Item label="Plant Sample">{show_seed}</LabeledList.Item>
        <LabeledList.Item label="Data Disk">
          <Stack.Item>
            <Button ml={3.3} content={show_disk} tooltip="Select Empty Disk" onClick={() => act('select_empty_disk')} />
          </Stack.Item>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const CoreGenes = (props) => {
  const { act, data } = useBackend();
  const { disk, core_genes } = data;

  return (
    <Collapsible key="Core Genes" title="Core Genes" open>
      {core_genes.map((gene) => (
        <Stack key={gene} py="2px" className="candystripe">
          <Stack.Item width="100%" ml="2px">
            {gene.name}
          </Stack.Item>
          <Stack.Item>
            <Button
              content="Extract"
              disabled={!disk?.can_extract}
              icon="save"
              onClick={() => act('extract', { id: gene.id })}
            />
          </Stack.Item>
        </Stack>
      ))}{' '}
      {
        <Stack>
          <Stack.Item>
            <Button
              content="Extract All"
              disabled={!disk?.can_extract}
              icon="save"
              onClick={() => act('bulk_extract_core')}
            />
          </Stack.Item>
        </Stack>
      }
    </Collapsible>
  );
};

const ReagentGenes = (props) => {
  const { data } = useBackend();
  const { reagent_genes, has_reagent } = data;

  return <OtherGenes title="Reagent Genes" gene_set={reagent_genes} do_we_show={has_reagent} />;
};

const TraitGenes = (props) => {
  const { data } = useBackend();
  const { trait_genes, has_trait } = data;

  return <OtherGenes title="Trait Genes" gene_set={trait_genes} do_we_show={has_trait} />;
};

const OtherGenes = (props) => {
  const { title, gene_set, do_we_show } = props;
  const { act, data } = useBackend();
  const { disk } = data;

  return (
    <Collapsible key={title} title={title} open>
      {do_we_show ? (
        gene_set.map((gene) => (
          <Stack key={gene} py="2px" className="candystripe">
            <Stack.Item width="100%" ml="2px">
              {gene.name}
            </Stack.Item>
            <Stack.Item>
              <Button
                content="Extract"
                disabled={!disk?.can_extract}
                icon="save"
                onClick={() => act('extract', { id: gene.id })}
              />
            </Stack.Item>
            <Stack.Item>
              <Button content="Remove" icon="times" onClick={() => act('remove', { id: gene.id })} />
            </Stack.Item>
          </Stack>
        ))
      ) : (
        <Stack.Item>No Genes Detected</Stack.Item>
      )}
    </Collapsible>
  );
};

const Disks = (props) => {
  const { title, gene_set, do_we_show } = props;
  const { act, data } = useBackend();
  const { has_seed, empty_disks, stat_disks, trait_disks, reagent_disks } = data;

  return (
    <Section title="Disks">
      <br />
      Empty Disks: {empty_disks}
      <br />
      <br />
      <Button
        width={12}
        icon="arrow-down"
        tooltip="Eject an Empty disk"
        content="Eject Empty Disk"
        onClick={() => act('eject_empty_disk')}
      />
      <Stack fill vertical>
        <Section title="Stats">
          <Stack fill vertical scrollable>
            {stat_disks
              .slice()
              .sort((a, b) => a.display_name.localeCompare(b.display_name))
              .map((item) => {
                return (
                  <Stack key={item} mr={2}>
                    <Stack.Item width="49%">{item.display_name}</Stack.Item>
                    <Stack.Item width={25}>
                      {item.stat === 'All' ? (
                        <Button
                          content="Replace All"
                          tooltip="Write disk stats to seed"
                          disabled={!item?.ready || !has_seed}
                          icon="arrow-circle-down"
                          onClick={() => act('bulk_replace_core', { index: item.index })}
                        />
                      ) : (
                        <Button
                          width={6}
                          icon="arrow-circle-down"
                          tooltip="Write disk stat to seed"
                          disabled={!item || !has_seed}
                          content="Replace"
                          onClick={() =>
                            act('replace', {
                              index: item.index,
                              stat: item.stat,
                            })
                          }
                        />
                      )}
                      <Button
                        width={6}
                        icon="arrow-right"
                        content="Select"
                        tooltip="Choose as target for extracted genes"
                        tooltipPosition="bottom-start"
                        onClick={() =>
                          act('select', {
                            index: item.index,
                          })
                        }
                      />
                      <Button
                        width={5}
                        icon="arrow-down"
                        content="Eject"
                        tooltip="Eject Disk"
                        tooltipPosition="bottom-start"
                        onClick={() =>
                          act('eject_disk', {
                            index: item.index,
                          })
                        }
                      />
                      <Button
                        width={2}
                        icon={item.read_only ? 'lock' : 'lock-open'}
                        content=""
                        tool_tip="Set/unset Read Only"
                        onClick={() =>
                          act('set_read_only', {
                            index: item.index,
                            read_only: item.read_only,
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                );
              })}

            <Button />
          </Stack>
        </Section>
        <Section title="Traits">
          <Stack fill vertical scrollable>
            {trait_disks
              .slice()
              .sort((a, b) => a.display_name.localeCompare(b.display_name))
              .map((item) => {
                return (
                  <Stack key={item} mr={2}>
                    <Stack.Item width="49%">{item.display_name}</Stack.Item>
                    <Stack.Item width={25}>
                      <Button
                        width={6}
                        icon="arrow-circle-down"
                        disabled={!item || !item.can_insert}
                        tooltip="Add disk trait to seed"
                        content="Insert"
                        onClick={() =>
                          act('insert', {
                            index: item.index,
                          })
                        }
                      />
                      <Button
                        width={6}
                        icon="arrow-right"
                        content="Select"
                        tooltip="Choose as target for extracted genes"
                        tooltipPosition="bottom-start"
                        onClick={() =>
                          act('select', {
                            index: item.index,
                          })
                        }
                      />
                      <Button
                        width={5}
                        icon="arrow-down"
                        content="Eject"
                        tooltip="Eject Disk"
                        tooltipPosition="bottom-start"
                        onClick={() =>
                          act('eject_disk', {
                            index: item.index,
                          })
                        }
                      />
                      <Button
                        width={2}
                        icon={item.read_only ? 'lock' : 'lock-open'}
                        content=""
                        tool_tip="Set/unset Read Only"
                        onClick={() =>
                          act('set_read_only', {
                            index: item.index,
                            read_only: item.read_only,
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                );
              })}

            <Button />
          </Stack>
        </Section>
        <Section title="Reagents">
          <Stack fill vertical scrollable>
            {reagent_disks
              .slice()
              .sort((a, b) => a.display_name.localeCompare(b.display_name))
              .map((item) => {
                return (
                  <Stack key={item} mr={2}>
                    <Stack.Item width="49%">{item.display_name}</Stack.Item>
                    <Stack.Item width={25}>
                      <Button
                        width={6}
                        icon="arrow-circle-down"
                        disabled={!item || !item.can_insert}
                        tooltip="Add disk reagent to seed"
                        content="Insert"
                        onClick={() =>
                          act('insert', {
                            index: item.index,
                          })
                        }
                      />
                      <Button
                        width={6}
                        icon="arrow-right"
                        content="Select"
                        tooltip="Choose as target for extracted genes"
                        tooltipPosition="bottom-start"
                        onClick={() =>
                          act('select', {
                            index: item.index,
                          })
                        }
                      />
                      <Button
                        width={5}
                        icon="arrow-down"
                        content="Eject"
                        tooltip="Eject Disk"
                        tooltipPosition="bottom-start"
                        onClick={() =>
                          act('eject_disk', {
                            index: item.index,
                          })
                        }
                      />
                      <Button
                        width={2}
                        icon={item.read_only ? 'lock' : 'lock-open'}
                        content=""
                        tool_tip="Set/unset Read Only"
                        onClick={() =>
                          act('set_read_only', {
                            index: item.index,
                            read_only: item.read_only,
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                );
              })}

            <Button />
          </Stack>
        </Section>
      </Stack>
    </Section>
  );
};
