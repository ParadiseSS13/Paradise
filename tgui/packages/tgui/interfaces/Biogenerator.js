import { useBackend, useSharedState } from "../backend";
import {
  Button,
  Section,
  Box,
  Flex,
  Icon,
  Collapsible,
  NumberInput,
  ProgressBar,
  Dimmer} from "../components";
import { Window } from "../layouts";

export const Biogenerator = (props, context) => {
  const { data } = useBackend(context);
  const { container } = data;

  return (
    <Window>
      <Window.Content display="flex" className="Layout__content--flexColumn">
        {!container ? (
          <MissingContainer />
        ) : (
          <>
          <Processing />
          <Storage />
          <Controls />
          <Products />
          </>
        )}
      </Window.Content>
    </Window>
  );
};

const MissingContainer = (props, context) => {
  return (
    <Section flexGrow="1">
      <Flex height="100%">
        <Flex.Item
          grow="1"
          textAlign="center"
          align="center"
          color="silver">
          <Icon
            name="flask"
            size="5"
            mb={3}
          /><br />
          The biogenerator is missing a container.
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const Processing = (props, context) => {
  const { data } = useBackend(context);
  const { processing } = data;

  if (processing) {
    return (
      <Dimmer>
        <Flex>
          <Flex.Item
            bold
            textColor="silver"
            textAlign="center"
            mb={2}>
            <Icon
              name="spinner"
              spin={1}
              size={4}
              mb={4}
            /><br />
            The biogenerator is processing...
          </Flex.Item>
        </Flex>
      </Dimmer>
    );
  }
};

const Storage = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    biomass,
    container_curr_reagents,
    container_max_reagents
  } = data;

  return (
    <Section
      title="Storage">
      <Flex>
        <Flex.Item mr="20px" color="silver">
          Biomass:
        </Flex.Item>
        <Flex.Item mr="5px">
          {biomass}
        </Flex.Item>
        <Icon
          name="leaf"
          size={1.2}
          color="#3d8c40"
        />
      </Flex>
      <Flex mt="8px">
        <Flex.Item mr="10px" color="silver">
          Container:
        </Flex.Item>
          <ProgressBar
            value={container_curr_reagents}
            maxValue={container_max_reagents}>
            <Box textAlign="center">
              {container_curr_reagents + ' / ' + container_max_reagents + ' units'}
            </Box>
          </ProgressBar>
      </Flex>
    </Section>
  );
};

const Controls = (props, context) => {
  const { act, data } = useBackend(context);
  const { has_plants } = data;

  return (
    <Section title="Controls">
      <Flex>
        <Flex.Item width="30%" mr="3px">
          <Button
            fluid
            textAlign="center"
            icon="power-off"
            disabled={!has_plants}
            tooltip={has_plants ? "" : "There are no plants in the biogenerator."}
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
            tooltip={has_plants ? "" : "There are no stored plants to eject."}
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
  const {
    biomass,
    product_list,
    efficiency,
  } = data;

  let [vendAmount, setVendAmount] = useSharedState(context, 'vendAmount', 1);

  let content = Object.entries(product_list).map((kv, _i) => {
    let category_items = Object.entries(kv[1]).map((kv2) => {
      return kv2[1];
    })

    return (
      <Collapsible
        key={kv[0]}
        title={kv[0]}
        open>
        {category_items.map((item) => (
          <Flex
            key={item}
            py="2px"
            className="candystripe"
            align="center">
            <Flex.Item width="50%" ml={0.5}>
              {item.name}
            </Flex.Item>
            <Flex.Item textAlign="right" width="20%">
              {(item.cost / efficiency) * vendAmount}
              <Icon
                ml="5px"
                name="leaf"
                size={1.2}
                color="#3d8c40"
              />
            </Flex.Item>
            <Flex.Item textAlign="right" width="40%">
              <Button
                content="Vend"
                disabled={biomass < (item.cost / efficiency) * vendAmount}
                icon="arrow-circle-down"
                onClick={() => act('create', {
                  id: item.id,
                  amount: vendAmount,
                })}
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
        <Box inline mr="5px" color="silver">Amount to vend:</Box>
        <NumberInput
          animated
          value={vendAmount}
          width="32px"
          minValue={1}
          maxValue={10}
          stepPixelSize={7}
          onChange={(e, value) =>
            setVendAmount(value)
          }
        />
        </>
      }>
      {content}
    </Section>
  );
};
