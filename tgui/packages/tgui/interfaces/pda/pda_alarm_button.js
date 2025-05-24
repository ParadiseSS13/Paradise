import { capitalize } from 'common/string';
import { useBackend } from '../../backend';
import { Button, Icon, Stack, Section, Box } from '../../components';

export const pda_alarm_button = (props, context) => {
  const { act, data } = useBackend(context);
  const { is_home, last_response } = data;

  if (!is_home) {
    return (
      <AlarmAlert
        title={last_response.title}
        text={last_response.text}
        success={last_response.success}
        acts={last_response.acts}
      />
    );
  }

  return (
    <Section textAlign="center">
      <Box>
        Данная тревожная кнопка предназначена для <b>экстренного вызова</b>. Ее использование приведет к уведомлению
        сотрудников службы безопасности о вашем примерном местонахождении.
      </Box>
      <Section>
        <Button color="red" onClick={() => act('submit')}>
          <Stack vertical={false} align="center">
            <Stack.Item>
              <Icon name="exclamation-triangle" size={2} my={1} mx={0} />
            </Stack.Item>
            <Stack.Item grow>
              <Box fontSize={2} bold>
                SECURITY
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Icon name="exclamation-triangle" size={2} my={1} mx={0} />
            </Stack.Item>
          </Stack>
        </Button>
      </Section>
    </Section>
  );
};

const AlarmAlert = (props, context) => {
  const { act } = useBackend(context);
  const { title, text, success, acts } = props;

  return (
    <Section>
      <Box bold>
        <Icon name={success ? 'check-circle' : 'times-circle'} color={success ? 'green' : 'red'} mr={1} />
        {title}
      </Box>
      <Box>{text}</Box>
      <Section>
        <Stack align="center">
          {acts.map((action, i) => (
            <Stack.Item key={i} grow>
              <Button width="100%" textAlign="center" onClick={() => act(action)}>
                {capitalize(action)}
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      </Section>
    </Section>
  );
};
