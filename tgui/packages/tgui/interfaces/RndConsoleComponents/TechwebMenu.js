import { useBackend } from "../../backend";
import { AnimatedNumber, Box, LabeledList, Section, Flex, Button, Tooltip } from "../../components";

export const TechwebMenu = (properties, context) => {
  const { data, act } = useBackend(context);
  const {
    researchpoints,
    researched,
    available,
    unavailable
  } = data;
  return (
    <Box>
      <Section title="Techwebs Tree">
        <LabeledList>
          <LabeledList.Item label="Research Points">
            <AnimatedNumber value={researchpoints} />
          </LabeledList.Item>
        </LabeledList>
        <Flex mt={1}>
          <Flex.Item grow={1}>
            <Box bold mb={1}>
              Researched Nodes
            </Box>
            <Box maxHeight={32} overflowY="auto" overflowX="hidden">
              {researched.map(n => (
                <Box mt={1} key={n.id} style={{border: "1px solid #595959", "border-radius" : "5px"}} pt={0.5} pl={0.5} pr={0.5} pb={0.5}>
                  <Button content={n.displayname} fluid onClick={() => act('TW_viewNode', {id: n.id})}/>
                  <Box italic>
                    {n.description}
                  </Box>
                </Box>
              ))}
            </Box>
          </Flex.Item>
          <Flex.Item grow={1}>
            <Box bold mb={1}>
              Available Nodes
            </Box>
            <Box maxHeight={32} overflowY="auto" overflowX="hidden">
              {available.map(n => (
                <Box mt={1} key={n.id} style={{border: "1px solid #595959", "border-radius" : "5px"}} pt={0.5} pl={0.5} pr={0.5} pb={0.5}>
                  <Button content={n.displayname} fluid />
                  <Button content={"Research (" + n.research_cost + " Points)"} fluid onClick={() => act('TW_research', {id: n.id})}/>
                  <Box italic>
                    {n.description}
                  </Box>

                </Box>
              ))}
            </Box>
          </Flex.Item>
          <Flex.Item grow={1}>
            <Box bold mb={1}>
              Unavailable Nodes
            </Box>
            <Box maxHeight={32} overflowY="auto" overflowX="hidden">
              {unavailable.map(n => (
                <Box mt={1} key={n.id} style={{border: "1px solid #595959", "border-radius" : "5px"}} pt={0.5} pl={0.5} pr={0.5} pb={0.5}>
                  <Button content={n.displayname} fluid />
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
