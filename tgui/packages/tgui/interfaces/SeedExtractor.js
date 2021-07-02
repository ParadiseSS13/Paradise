import { createSearch } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Section, Button, NumberInput, Input, Divider, Flex, NoticeBox, Icon } from '../components';
import { Window } from '../layouts';

const localeStrings ={
  'title': 'Seeds',

  'plantName': 'Plant',
  'lifespan': 'Lifespan',
  'endurance': 'Endurance',
  'maturation': 'Maturation',
  'production': 'Production',
  'yield': 'Yield',
  'potency': 'Potency',

  'searchTooltip': 'Search..',
  'sortByTooltip': 'Sort by',

  'dispOneTooltip': 'Dispense one',
  'dispAllTooltip': 'Dispense all',

  'inStock': 'in stock',

  'noContents': 'No seeds loaded.',
  'emptySearchResult': 'No items matching your criteria was found!',
};

const sortTypes = {
  'plantName': (a, b) => (a.display_name!==b.display_name ? (a.display_name>b.display_name? 1 : -1) : 0),
  'lifespan': (a, b) => a.life - b.life,
  'endurance': (a, b) => a.endr - b.endr,
  'maturation': (a, b) => a.matr - b.matr,
  'production': (a, b) => a.prod - b.prod,
  'yield': (a, b) => a.yld - b.yld,
  'potency': (a, b) => a.potn - b.potn,
};

export const SeedExtractor = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    total,
    capacity,
    contents,
  } = data;

  return (
    <Window>
      <Window.Content className="Layout__content--flexColumn">
        <Section title={localeStrings["title"]} buttons={(<SeedVaultSearch />)} m={0} p={0}>
          <SeedVaultHeader seedsTotal={total} seedsCapacity={capacity} />
        </Section>
        {!contents
          ? <NoticeBox m={0}> {localeStrings["noContents"]} </NoticeBox>
          : <div class="Divider Divider__noMargin" />}
        <Section flexGrow={1} stretchContents mt={0}>
          {!!contents && (<SeedVaultContents />)}
        </Section>
      </Window.Content>
    </Window>
  );
};

const SeedVaultHeaderField = (props, context) => {
  const {
    name,
    alpha,
  } = props;

  const [
    _sortOrder,
    setSortOrder,
  ] = useLocalState(context, 'sort', { "field": "plantName", "desc": false });

  return (
    <Button fluid iconRight
      icon={_sortOrder.field!==name ? "" : (_sortOrder.desc ? (!alpha ? "sort-amount-down" : "sort-alpha-down") : (!alpha ? "sort-amount-up" : "sort-alpha-up"))}
      color="transparent"
      textColor="white"
      content={localeStrings[name]}
      tooltip={localeStrings["sortByTooltip"]+" "+name.toLowerCase()}
      tooltipPosition="bottom"
      onClick={() => { (_sortOrder.field!==props.name ? setSortOrder({ "field": name, "desc": false }) : setSortOrder({ "field": name, "desc": !_sortOrder.desc })); }}
    />
  );
};

const SeedVaultSearch = (props, context) => {
  const [
    _searchText,
    setSearchText,
  ] = useLocalState(context, 'search', '');
  return (
    <Box mb="0.5rem" width="50vw" style={{ display: 'block' }}>
      <Flex width="100%">
        <Flex.Item mx={1} align="center"><Icon name="filter" /></Flex.Item>
        <Flex.Item grow="1" mr="0.5rem">
          <Input
            placeholder={localeStrings["searchTooltip"]}
            width="100%"
            onInput={(_e, value) => setSearchText(value)}
          />
        </Flex.Item>
      </Flex>
    </Box>
  );
};

const SeedVaultHeader = (props, context) => {
  const {
    seedsTotal,
    seedsCapacity,
  } = props;

  return (
    <Flex direction="row" textAlign="center" bold align="baseline" mt={0}>
      <Flex.Item basis={"15vw"}>
        <SeedVaultHeaderField name="plantName" alpha />
      </Flex.Item>
      <Flex.Item basis={"65vw"}>
        <Flex direction="row">
          <Flex.Item basis={0} grow={1} shrink={1}>
            <SeedVaultHeaderField name="lifespan" />
          </Flex.Item>
          <Flex.Item basis={0} grow={1} shrink={1}>
            <SeedVaultHeaderField name="endurance" />
          </Flex.Item>
          <Flex.Item basis={0} grow={1} shrink={1}>
            <SeedVaultHeaderField name="maturation" />
          </Flex.Item>
          <Flex.Item basis={0} grow={1} shrink={1}>
            <SeedVaultHeaderField name="production" />
          </Flex.Item>
          <Flex.Item basis={0} grow={1} shrink={1}>
            <SeedVaultHeaderField name="yield" />
          </Flex.Item>
          <Flex.Item basis={0} grow={1} shrink={1}>
            <SeedVaultHeaderField name="potency" />
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item basis={0} grow={1} shrink={1} color="average">
        {seedsTotal}/{seedsCapacity}
      </Flex.Item>
    </Flex>
  );
};

const SeedVaultContents = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    contents,
  } = data;

  const [
    searchText,
    _setSearchText,
  ] = useLocalState(context, 'search', '');

  const [
    sortOrder,
    _setSortOrder,
  ] = useLocalState(context, 'sort', { "field": "plantName", "desc": false });

  const nameSearch = createSearch(searchText, pile => pile.display_name + pile.strain_text);

  let piles = contents.filter(nameSearch).sort(sortTypes[sortOrder.field]);

  if (sortOrder.desc) {
    piles = piles.reverse();
  }

  let no_results = (piles.length === 0);

  return (
    <Flex.Item grow={1} >
      {!!no_results && (
        <Box color="average"> {localeStrings["emptySearchResult"]} </Box>
      )}
      {!no_results && (
        <Box className="SeedExtractor__Contents">
          {piles.map(item => (
            <SeedVaultContentsRow
              key={item.vend}
              displayName={item.display_name}
              descriptionText={item.strain_text}
              lifespanVal={item.life}
              enduranceVal={item.endr}
              maturationVal={item.life}
              productionVal={item.prod}
              yieldVal={item.yld}
              potencyVal={item.potn}
              vendIdx={item.vend}
              pileStock={item.quantity} />
          ))}
        </Box>
      )}
    </Flex.Item>
  );

};

const SeedVaultContentsRow = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    key,
    displayName,
    descriptionText,
    lifespanVal,
    enduranceVal,
    maturationVal,
    productionVal,
    yieldVal,
    potencyVal,
    vendIdx,
    pileStock,
  } = props;
  return (
    <Fragment>
      <Flex direction="row" textAlign="center" className="SeedExtractor__contents--row">
        <Flex.Item basis={"15vw"} textAlign="left" bold>
          <Box m={1}>
            {displayName}
          </Box>
        </Flex.Item>
        <Flex.Item basis={"65vw"} py={1}>
          <table style={{ "width": "100%", "border": "0" }}>
            <tr>
              <td>
                <Flex direction="row" textAlign="center">
                  <Flex.Item basis={0} grow={1} shrink={1}>
                    {lifespanVal}
                  </Flex.Item>
                  <Flex.Item basis={0} grow={1} shrink={1}>
                    {enduranceVal}
                  </Flex.Item>
                  <Flex.Item basis={0} grow={1} shrink={1}>
                    {maturationVal}
                  </Flex.Item>
                  <Flex.Item basis={0} grow={1} shrink={1}>
                    {productionVal}
                  </Flex.Item>
                  <Flex.Item basis={0} grow={1} shrink={1}>
                    {yieldVal}
                  </Flex.Item>
                  <Flex.Item basis={0} grow={1} shrink={1}>
                    {potencyVal}
                  </Flex.Item>
                </Flex>
              </td>
            </tr>
            <tr>
              <td style={{ "font-size": "90%", "padding-top": "0.5em" }} >
                {descriptionText}
              </td>
            </tr>
          </table>
        </Flex.Item>
        <Flex.Item basis={0} grow={1} shrink={1} py={1}>
          <Flex direction="column">
            <Flex.Item color="good">
              {pileStock} {localeStrings["inStock"]}
            </Flex.Item>
            <Flex.Item minHeight="25px" pt={1}>
              <Button
                icon="arrow-down"
                content="1"
                tooltip="Dispense one"
                tooltipPosition="bottom-left"
                onClick={() => act('vend',
                  { index: vendIdx, amount: 1 })} />
              <NumberInput
                width="40px"
                minValue={0}
                value={0}
                maxValue={pileStock}
                step={1}
                stepPixelSize={3}
                onChange={(e, value) => act('vend',
                  { index: vendIdx, amount: value })} />
              <Button
                icon="arrow-down"
                content="All"
                tooltip="Dispense all"
                tooltipPosition="bottom-left"
                onClick={() => act('vend',
                  { index: vendIdx, amount: pileStock })} />
            </Flex.Item>
          </Flex>
        </Flex.Item>
      </Flex>
      <Divider />
    </Fragment>
  );
};
