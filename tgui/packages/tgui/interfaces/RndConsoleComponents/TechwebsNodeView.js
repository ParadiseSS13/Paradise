import { useBackend } from "../../backend";
import { AnimatedNumber, Box, LabeledList, Section, Flex, Button, Tooltip } from "../../components";

export const TechwebNodeView = (properties, context) => {
  const { data, act } = useBackend(context);
  const {
    researchpoints,
    nodename,
    nodecost,
    nodedesc,
    node_designs,
    node_unlocks,
    node_requirements
  } = data;
  return (
    <Box>
      <Section title={nodename} buttons={
        <Button content="Back" onClick={() => act('TW_back')} />
      }>
        <LabeledList>
          <LabeledList.Item label="Research Points">
            <AnimatedNumber value={researchpoints} />
          </LabeledList.Item>
        </LabeledList>
        <Flex mt={1}>
          <Flex.Item grow={1} width="30%">
            <Box bold mb={1}>
              Required Nodes
            </Box>
            <Box maxHeight={32} overflowY="auto" overflowX="hidden">
              {node_requirements.map(n => (
                <Box mt={1} key={n.id} style={{border: "1px solid #595959", "border-radius" : "5px"}} pt={0.5} pl={0.5} pr={0.5} pb={0.5}>
                  <Button content={n.displayname} fluid onClick={() => act('TW_viewNode', {id: n.id})} selected={n.unlocked} />
                  <Button content={"Research (" + nodecost + " Points)"} fluid onClick={() => act('TW_research', {id: n.id})} />
                  <Box italic>
                    {n.description}
                  </Box>
                </Box>
              ))}
            </Box>
          </Flex.Item>
          <Flex.Item grow={1} width="40%">
            <Box bold mb={1}>
              Selected Node
            </Box>
            <Box maxHeight={32} overflowY="auto" overflowX="hidden">
              <Box mt={1} style={{border: "1px solid #595959", "border-radius" : "5px"}} pt={0.5} pl={0.5} pr={0.5} pb={0.5}>
                <Button content={nodename} fluid />
                <Button content={"Research (" + nodecost + " Points)"} fluid onClick={() => act('TW_research', {id: n.id})} />
                <Box italic>
                  {nodedesc}
                </Box>
                <Box bold mt={1} mb={1}>
                  Designs:
                </Box>
                {node_designs.map(d => (
                  <Box key={d.name}>
                    - {d.name}
                  </Box>
                ))}
              </Box>
            </Box>
          </Flex.Item>
          <Flex.Item grow={1} width="30%">
            <Box bold mb={1}>
              Component Of
            </Box>
            <Box maxHeight={32} overflowY="auto" overflowX="hidden">
              {node_unlocks.map(n => (
                <Box mt={1} key={n.id} style={{border: "1px solid #595959", "border-radius" : "5px"}} pt={0.5} pl={0.5} pr={0.5} pb={0.5}>
                  <Button content={n.displayname} fluid onClick={() => act('TW_viewNode', {id: n.id})}/>
                  <Button content={"Research (" + n.research_cost + " Points)"} fluid disabled />
                  <Box italic>
                    {n.description}
                  </Box>
                </Box>
              ))}
            </Box>
          </Flex.Item>
        </Flex>
      </Section>
    </Box>
  );
};
