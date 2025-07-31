import { Button, LabeledList, Section } from 'tgui-core/components';
import { IdCard } from './types';
import { useBackend } from '../../backend';

type AuthBlockProps = {
  scanned_card?: IdCard;
  modifying_card?: IdCard;
};

export const AuthBlock = (props: AuthBlockProps) => {
  const { act } = useBackend();
  const { scanned_card, modifying_card } = props;

  return (
    <Section title="Authentication">
      <LabeledList>
        <LabeledList.Item label="Login/Logout">
          {scanned_card ? (
            <Button icon="sign-out-alt" selected onClick={() => act('interact_scanned')}>
              {`Log Out: ${scanned_card.name}`}
            </Button>
          ) : (
            <Button icon="id-card" onClick={() => act('interact_scanned')}>
              -----
            </Button>
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Card To Modify">
          {modifying_card ? (
            <Button icon="eject" selected onClick={() => act('interact_modify')}>
              {`Remove Card: ${modifying_card.name}`}
            </Button>
          ) : (
            <Button icon="id-card" onClick={() => act('interact_modify')}>
              -----
            </Button>
          )}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
