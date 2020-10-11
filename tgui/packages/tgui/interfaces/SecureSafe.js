import { Box, Button, Divider, Flex, Section } from "../components";
import { Window } from "../layouts";
import { useBackend } from "../backend";

const buttons = [[1, 2, 3], [4, 5, 6], [7, 8, 9], ['R', 0, 'E']];

export const SecureSafe = (properties, context) => {
  const { data, act } = useBackend(context);

  const {
    l_set,
    l_code_len,
    emagged,
    locked,
    code,
    error,
  } = data;

  const onButtonClick = val => {
    switch (val) {
      case 'R':
        act('reset');
        break;
      case 'E':
        act('enter');
        break;
      default:
        act('addCode', { number: val });
        break;
    }
  };

  let codeChars = (code || '').split('');
  let codeBoxes = [];

  for (let i = 0; i < l_code_len; i++) {
    codeBoxes.push(
      <Flex
        className="SecureSafe__CodeBox"
        alignItems="center"
        justifyContent="center"
        flexGrow={1}
        key={i}>
        {locked ? codeChars[i] || '_' : '*'}
      </Flex>
    );
  }

  let message = null;

  if (emagged) {
    message = 'LOCKING SYSTEM ERROR - 1701';
  } else if (error) {
    message = error;
  } else if (!l_set) {
    message = 'ENTER NEW PASSCODE';
  }


  return (
    <Window>
      <Window.Content>
        <Section>

          <Flex flexDirection="row" alignItems="center" justifyContent="space-between">
            <Box color={l_set ? 'red' : 'grey'}>
              CODE SET
            </Box>
            <Box color={locked && l_set ? 'red' : 'grey'}>
              LOCKED
            </Box>

            <Box color={locked ? 'grey' : 'green'}>
              UNLOCKED
            </Box>

          </Flex>

        </Section>

        <Section className="SecureSafe__Message">
          {message}
        </Section>

        <Section>

          <Flex align="center" justify="space-between">
            {codeBoxes}
          </Flex>

          <Box className="SecureSafe__ButtonGrid">
            {buttons.map((row, i) => (
              <Box className="SecureSafe__ButtonGridRow" key={i}>
                {row.map((val, j) => (
                  <Button
                    content={val}
                    key={i}
                    className={`SecureSafe__Button SecureSafe__Button--${val}`}
                    onClick={() => onButtonClick(val)}
                  />
                ))}
              </Box>
            ))}
          </Box>

        </Section>

      </Window.Content>

    </Window>
  );
};
