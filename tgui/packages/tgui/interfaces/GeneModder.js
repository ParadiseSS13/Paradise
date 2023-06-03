import { useBackend, useSharedState } from "../backend";
import {
  Button,
  Section,
  Box,
  Flex,
  Icon,
  Collapsible } from "../components";
import { Window } from "../layouts";

export const GeneModder = (props, context) => {
  const { data } = useBackend(context);
  const { has_seed } = data;

  return (
    <Window>
      <Window.Content display="flex" className="Layout__content--flexColumn">
        <Storage />

        {has_seed === 0 ? (
          <MissingSeed />
        ) : (
          <>
            <CoreGenes/>
            <ReagentGenes/>
            <TraitGenes/>
          </>
        )}
      </Window.Content>
    </Window>
  );
};

const MissingSeed = (props, context) => {
  return (
    <Section flexGrow="1">
      <Flex height="100%">
        <Flex.Item
          bold
          grow="1"
          textAlign="center"
          align="center"
          color="green">
          <Icon
            name="leaf"
            size={5}
            mb="10px"
          /><br />
          The GENE MODDER is missing a SEED, DONT FORGET TO CHANGE THIS, #coding-chat.
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const Storage = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    has_seed, seed,
    has_disk, disk
  } = data;

  return (
    <Section
      title="Storage">
      <Flex>
        <Flex.Item mr="20px" color="silver">
          Plant Sample:
        </Flex.Item>
        {has_seed ? (
          <Flex.Item mr="5px">
            {/* <img
              src={`data:image/jpeg;base64,${seed.image}`}
              style={{
                'vertical-align': 'middle',
                width: '32px',
                margin: '0px',
                'margin-left': '0px',
              }}
            /> */}
          <Button
            content= {seed.name}
            onClick={() => act('eject_seed')}
          />
          {/* <Button
            content = "test"
            icon="pen"
            onClick={() => act('variant_name')}
          /> */}
        </Flex.Item>
        ) : (
        <Flex.Item>
          None
        </Flex.Item> ) }
      </Flex>
      <Flex height="21px" mt="8px"align="center">
        <Flex.Item mr="10px" color="silver">
          Data Disk:
        </Flex.Item>
        {has_disk ? (
          <Flex.Item>
            <Button
              content= {disk.name}
              onClick={() => act('eject_disk')}
            />
          </Flex.Item>
        ) : (
          <Flex.Item>
            None
          </Flex.Item>
        )}
      </Flex>
    </Section>
  );
};

const CoreGenes = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    disk,
    core_genes
  } = data;

  return (
    <Section
      title="Products"
      flexGrow="1">
      <Collapsible
        key= "Core Genes"
        title= "Core Genes"
        open>
        {core_genes.map((gene) => (
          <Flex
            key={gene}
            py="2px"
            className="candystripe"
            align="center">
            <Flex.Item width="40%" ml="2px">
              {gene.name}
            </Flex.Item>
            <Flex.Item textAlign="right" width="30%">
              <Button.Confirm
                content="Extract"
                disabled={!disk.can_extract}
                icon="save"
                onClick={() => act('extract', {id: gene.id})}
              />
            </Flex.Item>
            <Flex.Item textAlign="right" width="30%">
              <Button.Confirm
                content="Replace"
                disabled={!gene.is_type || !disk.can_insert}
                icon="upload"
                onClick={() => act('replace', {id: gene.id})}
              />
            </Flex.Item>
          </Flex>
        ))}
      </Collapsible>
    </Section>
  );
};

const ReagentGenes = (props, context) => {
  const { data } = useBackend(context);
  const { reagent_genes } = data;

  return (
    <OtherGenes
      gene_set = {reagent_genes}
    />
  );
};

const TraitGenes = (props, context) => {
  const { data } = useBackend(context);
  const { trait_genes } = data;

  return (
    <OtherGenes
      gene_set = {trait_genes}
    />
  );
};


const OtherGenes = (props, context) => {
  const {
    gene_set
  } = props;
  const { act, data } = useBackend(context);
  const {
    disk
  } = data;

  return (
    <Section
      title="Products"
      flexGrow="1">
      <Collapsible
        key={gene_set.title}
        title={gene_set.title}
        open>
        {gene_set.items.map((gene) => (
          <Flex
            key={gene}
            py="2px"
            className="candystripe"
            align="center">
            <Flex.Item width="40%" ml="2px">
              {gene.name}
            </Flex.Item>
            <Flex.Item textAlign="right" width="30%">
              <Button.Confirm
                content="Extract"
                disabled={!disk.can_extract}
                icon="save"
                onClick={() => act('extract', {id: gene.id})}
              />
            </Flex.Item>
            <Flex.Item textAlign="right" width="30%">
              <Button.Confirm
                content="Remove"
                icon="times"
                onClick={() => act('remove', {id: gene.id})}
              />
            </Flex.Item>
          </Flex>
        ))}
      </Collapsible>
    </Section>
  );
};
