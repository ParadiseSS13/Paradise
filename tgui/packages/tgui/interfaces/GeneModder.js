import { useBackend } from '../backend';
import {
  Button,
  Section,
  Stack,
  Icon,
  Collapsible,
  LabeledList,
} from '../components';
import { ComplexModal } from '../interfaces/common/ComplexModal';
import { Window } from '../layouts';

export const GeneModder = (props, context) => {
  const { data } = useBackend(context);
  const { has_seed } = data;

  return (
    <Window width={500} height={650}>
      <Window.Content>
        <Stack fill vertical>
          <Storage />
          <ComplexModal maxWidth="75%" maxHeight="75%" />
          {has_seed === 0 ? <MissingSeed /> : <Genes />}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Genes = (props, context) => {
  const { act, data } = useBackend(context);
  const { disk } = data;

  return (
    <Section
      title="Genes"
      fill
      scrollable
      buttons={
        <Button
          content="Insert Gene from Disk"
          disabled={!disk || !disk.can_insert || disk.is_core}
          icon="arrow-circle-down"
          onClick={() => act('insert')}
        />
      }
    >
      <CoreGenes />
      <ReagentGenes />
      <TraitGenes />
    </Section>
  );
};

const MissingSeed = (props, context) => {
  return (
    <Section fill height="85%">
      <Stack height="100%">
        <Stack.Item
          bold
          grow="1"
          textAlign="center"
          align="center"
          color="green"
        >
          <Icon name="leaf" size={5} mb="10px" />
          <br />
          The plant DNA manipulator is missing a seed.
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const Storage = (props, context) => {
  const { act, data } = useBackend(context);
  const { has_seed, seed, has_disk, disk } = data;

  let show_seed;
  let show_disk;

  if (has_seed) {
    show_seed = (
      <Stack.Item mb="-6px" mt="-4px">
        <img
          src={`data:image/jpeg;base64,${seed.image}`}
          style={{
            'vertical-align': 'middle',
            width: '32px',
            margin: '-1px',
            'margin-left': '-11px',
          }}
        />
        <Button content={seed.name} onClick={() => act('eject_seed')} />
        <Button
          ml="3px"
          icon="pen"
          tooltip="Name Variant"
          onClick={() => act('variant_name')}
        />
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
            <Button
              ml={3.3}
              content={show_disk}
              onClick={() => act('eject_disk')}
            />
          </Stack.Item>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const CoreGenes = (props, context) => {
  const { act, data } = useBackend(context);
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
          <Stack.Item>
            <Button
              content="Replace"
              disabled={!gene.is_type || !disk.can_insert}
              icon="arrow-circle-down"
              onClick={() => act('replace', { id: gene.id })}
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
          <Stack.Item>
            <Button
              content="Replace All"
              disabled={!disk?.is_bulk_core}
              icon="arrow-circle-down"
              onClick={() => act('bulk_replace_core')}
            />
          </Stack.Item>
        </Stack>
      }
    </Collapsible>
  );
};

const ReagentGenes = (props, context) => {
  const { data } = useBackend(context);
  const { reagent_genes, has_reagent } = data;

  return (
    <OtherGenes
      title="Reagent Genes"
      gene_set={reagent_genes}
      do_we_show={has_reagent}
    />
  );
};

const TraitGenes = (props, context) => {
  const { data } = useBackend(context);
  const { trait_genes, has_trait } = data;

  return (
    <OtherGenes
      title="Trait Genes"
      gene_set={trait_genes}
      do_we_show={has_trait}
    />
  );
};

const OtherGenes = (props, context) => {
  const { title, gene_set, do_we_show } = props;
  const { act, data } = useBackend(context);
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
              <Button
                content="Remove"
                icon="times"
                onClick={() => act('remove', { id: gene.id })}
              />
            </Stack.Item>
          </Stack>
        ))
      ) : (
        <Stack.Item>No Genes Detected</Stack.Item>
      )}
    </Collapsible>
  );
};
