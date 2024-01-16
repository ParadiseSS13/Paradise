import { useBackend, useSharedState } from '../backend';
import {
  Button,
  Section,
  Box,
  Flex,
  Icon,
  Collapsible,
  NumberInput,
  ProgressBar,
} from '../components';
import { Window } from '../layouts';
import { Operating } from '../interfaces/common/Operating';

export const Biogenerator = (props, context) => {
  const { data, config } = useBackend(context);
  const { container, processing } = data;
  const { title } = config;
  return (
    <Window>
      <Window.Content display="flex" className="Layout__content--flexColumn">
        <Operating operating={processing} name={title} />
        <Storage />
        <Controls />
        {!container ? <MissingContainer /> : <Products />}
      </Window.Content>
    </Window>
  );
};

const MissingContainer = (props, context) => {
  return (
    <Section flexGrow="1">
      <Flex height="100%">
        <Flex.Item
          bold
          grow="1"
          textAlign="center"
          align="center"
          color="silver"
        >
          <Icon name="flask" size={5} mb="10px" />
          <br />
          The biogenerator is missing a container.
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const Storage = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    biomass,
    container,
    container_curr_reagents,
    container_max_reagents,
  } = data;

  return (
    <Section title="Storage">
      <Flex>
        <Flex.Item mr="20px" color="silver">
          Biomass:
        </Flex.Item>
        <Flex.Item mr="5px">{biomass}</Flex.Item>
        <Icon name="leaf" size={1.2} color="#3d8c40" />
      </Flex>
      <Flex height="21px" mt="8px" align="center">
        <Flex.Item mr="10px" color="silver">
          Container:
        </Flex.Item>
        {container ? (
          <ProgressBar
            value={container_curr_reagents}
            maxValue={container_max_reagents}
          >
            <Box textAlign="center">
              {container_curr_reagents +
                ' / ' +
                container_max_reagents +
                ' units'}
            </Box>
          </ProgressBar>
        ) : (
          <Flex.Item>None</Flex.Item>
        )}
      </Flex>
    </Section>
  );
};

const Controls = (props, context) => {
  const { act, data } = useBackend(context);
  const { has_plants, container } = data;

  return (
    <Section title="Controls">
      <Flex>
        <Flex.Item width="30%" mr="3px">
          <Button
            fluid
            textAlign="center"
            icon="power-off"
            disabled={!has_plants}
            tooltip={
              has_plants ? '' : 'There are no plants in the biogenerator.'
            }
            tooltipPosition="top-right"
            content="Activate"
            onClick={() => act('activate')}
          />
        </Flex.Item>
        <Flex.Item width="40%" mr="3px">
          <Button
            fluid
            textAlign="center"
            icon="flask"
            disabled={!container}
            tooltip={
              container ? '' : 'The biogenerator does not have a container.'
            }
            tooltipPosition="top"
            content="Detach Container"
            onClick={() => act('detach_container')}
          />
        </Flex.Item>
        <Flex.Item width="30%">
          <Button
            fluid
            textAlign="center"
            icon="eject"
            disabled={!has_plants}
            tooltip={has_plants ? '' : 'There are no stored plants to eject.'}
            tooltipPosition="top-left"
            content="Eject Plants"
            onClick={() => act('eject_plants')}
          />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const Products = (props, context) => {
  const { act, data } = useBackend(context);
  const { biomass, product_list } = data;

  let [vendAmount, setVendAmount] = useSharedState(context, 'vendAmount', 1);

  let content = Object.entries(product_list).map((kv, _i) => {
    let category_items = Object.entries(kv[1]).map((kv2) => {
      return kv2[1];
    });

    return (
      <Collapsible key={kv[0]} title={kv[0]} open>
        {category_items.map((item) => (
          <Flex key={item} py="2px" className="candystripe" align="center">
            <Flex.Item width="50%" ml="2px">
              {item.name}
            </Flex.Item>
            <Flex.Item textAlign="right" width="20%">
              {item.cost * vendAmount}
              <Icon ml="5px" name="leaf" size={1.2} color="#3d8c40" />
            </Flex.Item>
            <Flex.Item textAlign="right" width="40%">
              <Button
                content="Vend"
                disabled={biomass < item.cost * vendAmount}
                icon="arrow-circle-down"
                onClick={() =>
                  act('create', {
                    id: item.id,
                    amount: vendAmount,
                  })
                }
              />
            </Flex.Item>
          </Flex>
        ))}
      </Collapsible>
    );
  });

  return (
    <Section
      title="Products"
      flexGrow="1"
      buttons={
        <>
          <Box inline mr="5px" color="silver">
            Amount to vend:
          </Box>
          <NumberInput
            animated
            value={vendAmount}
            width="32px"
            minValue={1}
            maxValue={10}
            stepPixelSize={7}
            onChange={(e, value) => setVendAmount(value)}
          />
        </>
      }
    >
      {content}
    </Section>
  );
};
