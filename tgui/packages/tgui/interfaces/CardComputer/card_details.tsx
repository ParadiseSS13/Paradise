import { Box, Button, LabeledList, Section } from 'tgui-core/components';
import { CardSkin, IdCard } from './types';
import { useBackend } from '../../backend';
import { BooleanLike } from 'tgui-core/react';

type CardInformationProps = {
  card?: IdCard;
};

export const CardInformation = (props: CardInformationProps) => {
  const { act } = useBackend();
  const { card } = props;
  return (
    <>
      <LabeledList.Item label="Registered Name">
        <Button
          icon={!card || card.registered_name === 'Unknown' ? 'exclamation-triangle' : 'pencil-alt'}
          selected={!!card}
          onClick={() => act('reg')}
        >
          {card?.registered_name}
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label="Account Number">
        <Button
          icon={card?.account_number ? 'pencil-alt' : 'exclamation-triangle'}
          selected={!!card?.account_number}
          onClick={() => act('set_card_account_number')}
        >
          {card?.account_number ? card?.account_number : 'None'}
        </Button>
      </LabeledList.Item>
    </>
  );
};

type CardSkinsProps = {
  card?: IdCard;
  card_skins: CardSkin[];
  all_centcom_skins: CardSkin[] | BooleanLike;
  is_centcom: BooleanLike;
};

export const CardSkins = (props: CardSkinsProps) => {
  const { act } = useBackend();
  const { card_skins, card, is_centcom, all_centcom_skins } = props;
  return (
    <Section title="Card Skins">
      {card_skins.map((v) => (
        <Button
          selected={card?.current_skin === v.skin}
          key={v.skin}
          onClick={() => act('set_card_skin', { skin_target: v.skin })}
        >
          {v.display_name}
        </Button>
      ))}
      {!!is_centcom && (
        <Box>
          {Array.isArray(all_centcom_skins) &&
            all_centcom_skins.map((v) => (
              <Button
                selected={card?.current_skin === v.skin}
                key={v.skin}
                color="purple"
                onClick={() => act('set_card_skin', { skin_target: v.skin })}
              >
                {v.display_name}
              </Button>
            ))}
        </Box>
      )}
    </Section>
  );
};
