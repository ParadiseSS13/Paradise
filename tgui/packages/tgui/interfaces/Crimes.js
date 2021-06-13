import { useBackend } from '../backend';
import { LabeledList, Button, Section } from '../components';
import { Window } from '../layouts';

const Menor = (props, context) => {
  const { act } = useBackend(context);
  const { color, thing } = props;

  return (
    <Button
      color={color}
      onClick={() => act("menor", {
        ref: thing,
      })}>
      {thing}
    </Button>
  );
};

const Moder = (props, context) => {
  const { act } = useBackend(context);
  const { color, thing } = props;

  return (
    <Button
      color={color}
      onClick={() => act("moderado", {
        ref: thing,
      })}>
      {thing}
    </Button>
  );
};

const Mayor = (props, context) => {
  const { act } = useBackend(context);
  const { color, thing } = props;

  return (
    <Button
      color={color}
      onClick={() => act("mayor", {
        ref: thing,
      })}>
      {thing}
    </Button>
  );
};

export const Crimes = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    menores,
    moderados,
    mayores,
  } = data;

  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title={`CRIMENES MENORES - (${menores.length})`}>
          {menores
            .map(thing => (
              <Menor
                key={thing}
                color="good"
                thing={thing} />
            ))}
        </Section>

        <LabeledList.Item>
          <Button
            icon="address-book"
            content="Detalles de los Crimenes Menores"
            onClick={() => act('menor_detalles')} />
          <LabeledList.Item label="Detalles">
            {data.prisoner_minor_details}
          </LabeledList.Item>
        </LabeledList.Item>

        <Section title={`CRIMENES MODERADOS - (${moderados.length})`}>
          {moderados
            .map(thing => (
              <Moder
                key={thing}
                color="average"
                thing={thing} />
            ))}
        </Section>

        <LabeledList.Item>
          <Button
            icon="address-book"
            content="Detalles de los Crimenes Moderados"
            onClick={() => act('moder_detalles')} />
          <LabeledList.Item label="Detalles">
            {data.prisoner_moderate_details}
          </LabeledList.Item>
        </LabeledList.Item>

        <Section title={`CRIMENES MAYORES - (${mayores.length})`}>
          {mayores
            .map(thing => (
              <Mayor
                key={thing}
                color="bad"
                thing={thing} />
            ))}
        </Section>

        <LabeledList.Item>
          <Button
            icon="address-book"
            content="Detalles de los Crimenes Mayores"
            onClick={() => act('mayor_detalles')} />
          <LabeledList.Item label="Detalles">
            {data.prisoner_major_details}
          </LabeledList.Item>
        </LabeledList.Item>
      </Window.Content>
    </Window>
  );
};
