import { Component, Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Tooltip, Flex, LabeledList, Modal, Section, ProgressBar, Dropdown, NoticeBox } from '../components';
import { LabeledListItem } from '../components/LabeledList';
import { Window } from '../layouts';

export const SpiderOS = (properties, context) => {
  const { act, data } = useBackend((context));
  let body;
  if (data.suit_tgui_state === 0) {
    body = (
      <Flex
        direction="row"
        spacing={1}>
        <Flex
          direction="column"
          width="60%">
          <Flex.Item
            backgroundColor="rgba(0, 0, 0, 0)">
            <ActionBuyPanel />
          </Flex.Item>
          <Flex.Item
            mt={2.2}
            backgroundColor="rgba(0, 0, 0, 0)">
            <ShuttleConsole />
          </Flex.Item>
        </Flex>

        <Flex.Item
          width="40%"
          height="190px"
          grow={1}
          backgroundColor="rgba(0, 0, 0, 0)">
          <Helpers />
          <StylesPreview />
          <SuitTuning />
        </Flex.Item>

      </Flex>
    );
  }
  else if (data.suit_tgui_state === 1) {
    body = (
      <Flex
        width="100%"
        height="100%"
        direction="column"
        shrink={1}
        spacing={1}>
        <Flex.Item backgroundColor="rgba(0, 0, 0, 0.8)" height="100%">
          <FakeLoadBar />
          <FakeTerminal
            allMessages={data.current_load_text}
            finishedTimeout={3000}
            current_initialisation_phase={data.current_initialisation_phase}
            end_terminal={data.end_terminal}
            onFinished={() => act('set_UI_state', { suit_tgui_state: 0 })}
          />
        </Flex.Item>
      </Flex>
    );
  }
  return (
    <Window theme="spider_clan">
      <Window.Content>
        <Flex
          direction="row"
          spacing={1}>
          {body}
        </Flex>
      </Window.Content>
    </Window>
  );
};

const StylesPreview = (properties, context) => {
  const { data } = useBackend((properties, context));
  const {
    allStylesPreview,
    style_preview_icon_state,
  } = data;
  return (
    <Section title="Персонализация костюма"
      style={{ "text-align": "center" }}
      buttons={<Button
        content="?"
        tooltip={"Настройка внешнего вида вашего костюма!\
        Наши технологии позволяют вам подстроить костюм под себя, \
        при этом не теряя оборонительных качеств. \
        Потому что удобство при ношении костюма, жизненно важно для настоящего убийцы."}
        tooltipPosition="bottom-left" />}>
      <Flex
        direction="column"
        grow={1}
        alignContent="center">
        <NoticeBox className="NoticeBox_blue"
          success={0}
          danger={0}
          align="center">
          <Section
            style={{ "background": "rgba(4, 74, 27, 0.75)" }}
            mr={10}
            ml={10}>
            <img
              height="128px"
              width="128px"
              src={`data:image/jpeg;base64,${allStylesPreview[style_preview_icon_state]}`}
              style={{
                "margin-left": "0px",
                "-ms-interpolation-mode": "nearest-neighbor",
              }} />
          </Section>
        </NoticeBox>
      </Flex>
    </Section>
  );
};


const SuitTuning = (properties, context) => {
  const { act, data } = useBackend((properties, context));
  const {
    designs,
    design_choice,
    scarf_design_choice,
    colors,
    color_choice,
    genders,
    preferred_clothes_gender,
    suit_state,
    preferred_scarf_over_hood,
    show_charge_UI,
    has_martial_art,
    show_concentration_UI,
  } = data;
  let dynamicButtonText;
  if (suit_state === 0) {
    dynamicButtonText = "Активировать костюм";
  }
  else {
    dynamicButtonText = "Деактивировать костюм";
  }

  let dynamicButtonText_scarf;
  if (preferred_scarf_over_hood === 0) {
    dynamicButtonText_scarf = "Капюшон";
  }
  else {
    dynamicButtonText_scarf = "Шарф";
  }

  let if_scarf;
  if (preferred_scarf_over_hood === 1) {
    if_scarf = (<LabeledList.Item
      label={"Стиль шарфа"}
      content={
        <Dropdown
          options={designs}
          selected={scarf_design_choice}
          onSelected={val => act("set_scarf_design", { scarf_design_choice: val }
          )} />
      } />);
  } else {
    if_scarf = null;
  }

  let if_concentration;
  if (has_martial_art) {
    if_concentration = (<LabeledList.Item
      label={"Концентрация"}
      content={
        <Box>
          <Button
            selected={show_concentration_UI}
            width="78px"
            textAlign="left"
            content={show_concentration_UI ? "Показать" : "Скрыть"}
            onClick={() => act("toggle_ui_concentration")} />
          <Button
            textAlign="center"
            content="?"
            tooltip={"Включение или отключение интерфейса показывающего сконцентрированы ли вы для применения боевого исскуства."}
            tooltipPosition="top-left" />
        </Box>
      } />);
  } else {
    if_concentration = null;
  }

  return (
    <Flex
      direction="row"
      grow={1}
      alignContent="center"
      ml={0.5}>
      <Flex.Item
        grow={1}
        width="100%">
        <NoticeBox success={0} danger={0} align="center">
          <LabeledList>
            <LabeledList.Item label="Стиль">
              <Dropdown
                options={designs}
                selected={design_choice}
                onSelected={val => act("set_design", { design_choice: val })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Цвет">
              <Dropdown
                options={colors}
                selected={color_choice}
                onSelected={val => act("set_color", { color_choice: val })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Женский/Мужской">
              <Dropdown
                options={genders}
                selected={preferred_clothes_gender}
                onSelected={val => act("set_gender", { preferred_clothes_gender: val })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Шарф/Капюшон">
              <Button
                className={suit_state === 0 ? "" : "Button_disabled"}
                width="78px"
                selected={preferred_scarf_over_hood}
                disabled={suit_state}
                textAlign="left"
                content={dynamicButtonText_scarf}
                onClick={() => act("toggle_scarf")} />
              <Button
                textAlign="center"
                content="?"
                tooltip={"С настройкой \"Шарф\" ваш капюшон больше не будет прикрывать волосы.\
                            Но это не значит, что ваша голова не защищена! \
                            Адаптивные нано-волокна костюма всё ещё реагируют на потенциальные угрозы прикрывая вашу голову! \
                            Уточнение: нановолокна так же будут прикрывать вашу голову и от других головных уборов \
                            с целью уменьшения помех в их работе."}
                tooltipPosition="top-left" />
            </LabeledList.Item>
            {if_scarf}
            <LabeledList.Item label="Заряд костюма">
              <Button selected={show_charge_UI}
                width="78px"
                textAlign="left"
                content={show_charge_UI ? "Показать" : "Скрыть"}
                onClick={() => act("toggle_ui_charge")}
              />
              <Button textAlign="center"
                content="?"
                tooltip={"Включение или отключение интерфейса показывающего заряд вашего костюма."}
                tooltipPosition="top-left" />
            </LabeledList.Item>
            {if_concentration}
          </LabeledList>
        </NoticeBox>
        <NoticeBox className={"NoticeBox_" + color_choice} success={0} danger={0} mt={-1.2} align="center">
          <Button
            width="80%"
            icon="power-off"
            mt={0.5}
            textAlign="center"
            content={dynamicButtonText}
            tooltip={"Позволяет вам включить костюм и получить доступ к применению всех функций в нём заложенных. \
              \nУчтите, что вы не сможете приобрести любые модули, когда костюм будет активирован. \
              \nТак же включённый костюм пассивно потребляет заряд для поддержания работы всех функций и модулей.\
              \nАктивированный костюм нельзя снять обычным способом, пока он не будет деактивирован.\
              \nВключение ровно как и выключение костюма занимает много времени. Подумайте дважды прежде, чем выключать его на территории врага!"}
            tooltipPosition="top-left"
            onClick={() => act("initialise_suit")} />
        </NoticeBox>
      </Flex.Item>
    </Flex>
  );
};

const Helpers = (properties, context) => {
  const { data } = useBackend((properties, context));
  const {
    allActionsPreview,
  } = data;
  return (
    <Section title="Советы и подсказки"
      style={{ "text-align": "center" }}
      buttons={<Button
        content="?"
        tooltip={"Молодым убийцам часто не легко освоится в полевых условиях, даже после интенсивных тренировок. \
        \nЭтот раздел призван помочь вам советами по определённым часто возникающим вопросам касательно возможных миссий которые вам выдадут\
        или рассказать о малоизвестной информации которую вы можете обернуть в свою пользу."}
        tooltipPosition="bottom-left" />}>
      <Flex
        direction="column"
        grow={1}
        alignContent="center">
        <Flex.Item direction="row">
          <Button
            className="Button_green"
            height="48px"
            width="48px">
            <img
              height="48px"
              width="48px"
              src={`data:image/jpeg;base64,${allActionsPreview["ninja_teleport"]}`}
              style={{
                "margin-left": "-6px",
                "-ms-interpolation-mode": "nearest-neighbor",
              }} />
            <Tooltip
              title={"Телепортация и шаттл"}
              content={"В вашем Додзё есть личные устройства для телепортации на обьект вашей миссии. \
              Точка назначения случайная, но приоритет идёт на технические тоннели станции или малопосещаемые места. \
              \nЭто отличный способ быстро приступить к выполнению задания. \
              \nПользуясь встроенным контроллером шаттла, вы всегда сможете призвать его к себе и вернуться назад. \
              \nТак же в случае если вы решите полететь на шаттле, напоминаем вам, что во избежание вашего обнаружения или кражи шаттла и попадания на вашу базу посторонних лиц, \
              отличной практикой будет отозвать его."}
              position="bottom-left" />
          </Button>
          <Button
            className="Button_green"
            height="48px"
            width="48px">
            <img
              height="48px"
              width="48px"
              src={`data:image/jpeg;base64,${allActionsPreview["headset_green"]}`}
              style={{
                "margin-left": "-6px",
                "-ms-interpolation-mode": "nearest-neighbor",
              }} />
            <Tooltip
              title={"Ваш наушник"}
              content={"В отличии от стандартных наушников большинства корпораций, наш вариант создан специально для помощи в вашем внедрении. \
              В него встроен специальный канал для общения с вашим боргом или другими членами клана.\
              \nК тому же он способен просканировать любые другие наушники и скопировать доступные для прослушки и/или разговора каналы их ключей.\
              Благодаря этому вы можете постепенно накапливать необходимые вам местные каналы связи для получения любой информации.\
              \nТак же ваш наушник автомати- чески улавливает и переводит бинарные сигналы генерируемые синтетиками при общении друг с другом. \
              К тому же позволяя вам самим общаться с ними."}
              position="bottom-left" />
          </Button>
          <Button
            className="Button_green"
            height="48px"
            width="48px">
            <img
              height="48px"
              width="48px"
              src={`data:image/jpeg;base64,${allActionsPreview["ninja_sleeper"]}`}
              style={{
                "margin-left": "-6px",
                "-ms-interpolation-mode": "nearest-neighbor",
              }} />
            <Tooltip
              title={"Похищение экипажа"}
              content={"Порой клану нужны сведения которыми могут обладать люди работающие на обьекте вашей миссии. \
              В такой ситуации вам становится доступно особое устройство для сканирования чужого разума. \
              Даже если вам не удастся найти обладающего всей информацией человека, можно будет собрать информацию по крупицам продолжая похищать людей.\
              \nДля того, чтобы успешно похи- тить людей. У вас на шаттле есть скафандры, а на базе запас на- ручников, кислорода и балло- нов. \
              \nТак же напоминаем, что ваши перчатки способны направлять в людей электрический импульс, эффективно станя их на короткое время. "}
              position="bottom-left" />
          </Button>
          <Button
            className="Button_green"
            height="48px"
            width="48px">
            <img
              height="48px"
              width="48px"
              src={`data:image/jpeg;base64,${allActionsPreview["ai_face"]}`}
              style={{
                "margin-left": "-6px",
                "-ms-interpolation-mode": "nearest-neighbor",
              }} />
            <Tooltip
              title={"Саботаж ИИ"}
              content={"Иногда у нас заказывают сабо- таж Искусственного интеллекта на обьектах операции. Это про- цесс сложный и требующий от нас основательной подготовки. \
              \nПредпочитаемый кланом метод это создание уязвимости прямо в загрузочной для законов позволяющей вывести ИИ из строя. \
              В результате такого метода мы можем легко перегрузить ИИ абсурдными законами, но это ограничивает нас в том плане, что для взлома в итоге подходят только консоли в самой загрузочной.\
              Так же взлом задача нелёгкая - системы защиты есть везде. А процесс занимает время. Не удивляйтесь если ИИ будет противодейст- вовать вашим попыткам его сломать."}
              position="bottom-left" />
          </Button>
          <Button
            className="Button_green"
            height="48px"
            width="48px">
            <img
              height="48px"
              width="48px"
              src={`data:image/jpeg;base64,${allActionsPreview["ninja_borg"]}`}
              style={{
                "margin-left": "-6px",
                "-ms-interpolation-mode": "nearest-neighbor",
              }} />
            <Tooltip
              title={"Саботаж роботов"}
              content={"Иногда оценивая ваши шансы на выполнение миссии для их увеличения на обьектах, \
              что используют роботов для своих целей, мы даём вам особый \"Улучшающий\" их прибор, встроенный в ваши перчатки. \
              \nПри взломе киборга таким прибором(Взлом занимает время) вы получите лояльного клану и вам лично \
              слугу способ- ного на оказание помощи как в саботаже станции так и в вашем лечении. \
              \nТак же робот будет оснащён личной катаной, устройством маскировки, пинпоинтером указывающим ему на вас и генератором электрических сюрикенов. \
              Помните, что катана робота не способна обеспечить его блюспейс транслокацию!"}
              position="bottom-left" />
          </Button>
        </Flex.Item>
        <Flex.Item direction="row">
          <Button
            className="Button_green"
            height="48px"
            width="48px">
            <img
              height="48px"
              width="48px"
              src={`data:image/jpeg;base64,${allActionsPreview["server"]}`}
              style={{
                "margin-left": "-6px",
                "-ms-interpolation-mode": "nearest-neighbor",
              }} />
            <Tooltip
              title={"Саботаж исследований"}
              content={"На научных обьектах всегда есть своя команда учёных и мно- жество данных которые прихо- дится где то хранить. \
              В качестве такого обьекта обычно высту- пают сервера. А как известно корпорации вечно грызутся за знания. Что нам на руку. \
              \nМы разработали специальный вирус который будет записан на ваши перчатки перед миссией такого рода. \
              Вам нужно будет лишь загрузить его напрямую на их научный сервер и все их исследования будут утеряны. \
              \nНо загрузка вируса требует времени, и системы защиты многих обьектов не дремлют. \
              Скорее всего о вашей попытке взлома будет оповещён местный ИИ. Будьте готовы к этому."}
              position="bottom-left" />
          </Button>
          <Button
            className="Button_green"
            height="48px"
            width="48px">
            <img
              height="48px"
              width="48px"
              src={`data:image/jpeg;base64,${allActionsPreview["buckler"]}`}
              style={{
                "margin-left": "-6px",
                "-ms-interpolation-mode": "nearest-neighbor",
              }} />
            <Tooltip
              title={"Защита цели"}
              content={"Иногда богатые шишки платят за услуги защиты определённого человека. Если вам досталась такая цель помните следующее:\
              \n * Защищаемый обязан дожить до конца смены! \
              \n * Скорее всего защищаемый не знает о вашей задаче. И лучше всего чтобы он и дальше не знал! \
              \n * Не важно кто или что охотится на вашего подзащитного, но для обьекта где проходит миссия вы всегда нежеланное лицо. \
              Не раскрывайте себя без нужды, чтобы упростить себе же работу и на вас самих не вели охоту! \
              \nТак же мы напоминаем, что клан не одобряет варварские методы \"Защиты\" цели. Нет вы не можете посадить защищаемого в клетку и следить за ним там! \
              Не портите нашу репутацию в глазах наших клиентов!"}
              position="bottom-left" />
          </Button>
          <Button
            className="Button_green"
            height="48px"
            width="48px">
            <img
              height="48px"
              width="48px"
              src={`data:image/jpeg;base64,${allActionsPreview["cash"]}`}
              style={{
                "margin-left": "-6px",
                "-ms-interpolation-mode": "nearest-neighbor",
              }} />
            <Tooltip
              title={"Кража денег"}
              content={"Как бы это не было тривиально. Иногда клан нуждается в день- гах. Или даже возможно вы задолжали нам. \
              В таком случае мы скорее всего дадим вам задачу достать для нас эти деньги на следующей вашей миссии. \
              \nДля вас эта задача не трудная, но времязатратная. Помните, что вы натренированы в искусстве незаметных карманных краж. \
              Вы можете это использовать для кражи чужих карт и обналичи- вания их счетов. Либо можете метить выше и ограбить хранилища или счета самого обьекта вашей миссии.\
              Самое главное. Достаньте эти деньги!"}
              position="bottom-left" />
          </Button>
          <Button
            className="Button_green"
            height="48px"
            width="48px">
            <img
              height="48px"
              width="48px"
              src={`data:image/jpeg;base64,${allActionsPreview["handcuff"]}`}
              style={{
                "margin-left": "-6px",
                "-ms-interpolation-mode": "nearest-neighbor",
              }} />
            <Tooltip
              title={"Подставить человека"}
              content={"В некоторых ситуациях чужой позор для клиентов гораздо интереснее чем смерть. \
              В таких случаях вам прийдётся проявить креативность и добиться того, чтобы вашу жертву по законным основаниям упекли за решётку \
              Самое главное чтобы в криминальной истории цели остался след. \
              Но в то же время просто прийти и вписать цели срок в консоли - не рабочий метод. Цель легко оправдают в суде, что не устроит клиента.\
              \n У вас достаточно инструментов, чтобы совершить преступление под личиной цели. \
              Главное постарайтесь обойтись без слиш- ком больших последствий. Лишняя дыра в обшивке станции или трупы - увеличивают шансы провала вашего плана."}
              position="bottom-left" />
          </Button>
          <Button
            className="Button_green"
            height="48px"
            width="48px">
            <img
              height="48px"
              width="48px"
              src={`data:image/jpeg;base64,${allActionsPreview["spider_charge"]}`}
              style={{
                "margin-left": "-6px",
                "-ms-interpolation-mode": "nearest-neighbor",
              }} />
            <Tooltip
              title={"Подрыв отдела"}
              content={"Старые добрые бомбы. Эффек- тивные орудия уничтожения всего живого и неживого в большом радиусе. \
              Когда клиенты просят подорвать обьект, они часто не знают насколько дорого стоит такая операция. Но редко готовы сдаться.\
              Как раз поэтому многие согласны на подрыв одной области или отдела. \
              \nБудьте готовы к тому, что после взрыва на вас будет вестись охота. \
              \n Наши бомбы специально изготовлены с ограничителями. Никто кроме вас не сможет их подорвать \
              и даже вы сможете активировать их лишь в зоне заказанной клиентом. Советуем сразу бежать подальше после установки. Хотя это и так должно быть для вас очевидно."}
              position="bottom-left" />
          </Button>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const ActionBuyPanel = (properties, context) => {
  const { act, data } = useBackend((properties, context));
  const {
    allActionsPreview,
    blocked_TGUI_rows,
  } = data;

  let rowStyles = [{ blue: "Button_blue", green: "Button_green", red: "Button_red", disabled: "Button_disabled" }];

  return (
    <Section title="Модули костюма" style={{ "text-align": "center" }}
      buttons={<Button
        content="?"
        tooltip={"Устанавливаемые улучшения для вашего костюма!\
        Делятся на 3 разных подхода для выполнения вашей миссии.\
        Из-за больших требований по поддержанию работоспособности костюма,\
        приобретение любого модуля, блокирует приобретение модулей одного уровня из соседних столбцов"}
        tooltipPosition="bottom" />}>
      <Flex
        direction="row"
        alignContent="center"
        ml={1.5}>

        <Flex.Item
          width="33%"
          shrink={1}>
          <Section title="Призрак"
            buttons={<Button
              content="?"
              tooltip={"Скрывайтесь среди врагов, нападайте из тени и будьте незримой угрозой, всё для того чтобы о вас и вашей миссии никто не узнал! Будьте незаметны как призрак!"}
              tooltipPosition="bottom" />}
            style={{ "text-align": "center", "background": "rgba(53, 94, 163, 0.8)" }} />
          <NoticeBox className="NoticeBox_blue" success={0} danger={0} align="center">

            <Button
              className={!blocked_TGUI_rows[0] ? rowStyles[0].blue : rowStyles[0].disabled}
              height="64px"
              width="100%"
              disabled={blocked_TGUI_rows[0]}
              onClick={() => act("give_ability", { style: "smoke", row: "1" })}>
              <img
                height="64px"
                width="64px"
                src={`data:image/jpeg;base64,${allActionsPreview["smoke"]}`}
                style={{
                  "margin-left": "-6px",
                  "-ms-interpolation-mode": "nearest-neighbor",
                }} />
              <Tooltip
                title={"ДЫМОВАЯ ЗАВЕСА"}
                content={"Вы создаёте большое облако дыма чтобы запутать своих врагов.\
                \nЭта способность отлично сочетается с вашим визором в режиме термального сканера.\
                \nА так же автоматически применяется многими другими модулями если вы того пожелаете.\
                \nСтоимость активации: 1000 ед. энергии.\
                \nСтоимость автоматической активации: 250 ед. энергии.\
                \nПерезарядка: 3 секунды."}
                position="bottom-right" />
            </Button>

            <Button
              className={!blocked_TGUI_rows[1] ? rowStyles[0].blue : rowStyles[0].disabled}
              height="64px"
              width="100%"
              disabled={blocked_TGUI_rows[1]}
              onClick={() => act("give_ability", { style: "ninja_cloak", row: "2" })}>
              <img
                height="64px"
                width="64px"
                src={`data:image/jpeg;base64,${allActionsPreview["ninja_cloak"]}`}
                style={{
                  "margin-left": "-6px",
                  "-ms-interpolation-mode": "nearest-neighbor",
                }} />
              <Tooltip
                title={"НЕВИДИМОСТЬ"}
                content={"Вы формируете вокруг себя маскировочное поле скрыва- ющее вас из виду и приглуша- ющее ваши шаги.\
                \nПоле довольно хрупкое и может разлететься от любого резкого действия или удара.\
                \nАктивация поля занимает 2 секунды. Хоть поле и скрывает вас полностью, настоящий убийца должен быть хладнокровен.\
                \nНе стоит недооценивать внимательность других людей.\
                \nАктивная невидимость слабо увеличивает пассивный расход энергии.\
                \nПерезарядка: 15 секунд."}
                position="bottom-right" />
            </Button>
            <Button
              className={!blocked_TGUI_rows[2] ? rowStyles[0].blue : rowStyles[0].disabled}
              height="64px"
              width="100%"
              disabled={blocked_TGUI_rows[2]}
              onClick={() => act("give_ability", { style: "ninja_clones", row: "3" })}>
              <img
                height="64px"
                width="64px"
                src={`data:image/jpeg;base64,${allActionsPreview["ninja_clones"]}`}
                style={{
                  "margin-left": "-6px",
                  "-ms-interpolation-mode": "nearest-neighbor",
                }} />
              <Tooltip
                title={"ЭНЕРГЕТИЧЕСКИЕ КЛОНЫ"}
                content={"Создаёт двух клонов готовых помочь в битве и дезориенти- ровать противника\
                \nТак же в процессе смещает вас и ваших клонов в случайном направлении в радиусе пары метров.\
                \nПользуйтесь осторожно. Случайное смещение может запереть вас за 4-мя стенами. Будьте к этому готовы.\
                \nКлоны существуют примерно 20 секунд. Клоны имеют шанс размножится атакуя противников.\
                \nСтоимость активации: 4000 ед. энергии.\
                \nПерезарядка: 8 секунд."}
                position="right" />
            </Button>
            <Button
              className={!blocked_TGUI_rows[3] ? rowStyles[0].blue : rowStyles[0].disabled}
              height="64px"
              width="100%"
              disabled={blocked_TGUI_rows[3]}
              onClick={() => act("give_ability", { style: "chameleon", row: "4" })}>
              <img
                height="64px"
                width="64px"
                src={`data:image/jpeg;base64,${allActionsPreview["chameleon"]}`}
                style={{
                  "margin-left": "-6px",
                  "-ms-interpolation-mode": "nearest-neighbor",
                }} />
              <Tooltip
                title={"ХАМЕЛЕОН"}
                content={"Вы формируете вокруг себя голографическое поле искажающее визуальное и слуховое восприятие других существ.\
                \nВас будут видеть и слышать как человека которого вы просканируете специальным устройством.\
                \nЭто даёт вам огромный простор по внедрению и имитации любого члена экипажа.\
                \nПоле довольно хрупкое и может разлететься от любого резкого действия или удара.\
                \nАктивация поля занимает 2 секунды. \
                \nАктивный хамелеон слабо увеличивает пассивный расход энергии.\
                \nПерезарядка: Отсутствует."}
                position="right" />
            </Button>
            <Button
              className={!blocked_TGUI_rows[4] ? rowStyles[0].blue : rowStyles[0].disabled}
              height="64px"
              width="100%"
              disabled={blocked_TGUI_rows[4]}
              onClick={() => act("give_ability", { style: "ninja_spirit_form", row: "5" })}>
              <img
                height="64px"
                width="64px"
                src={`data:image/jpeg;base64,${allActionsPreview["ninja_spirit_form"]}`}
                style={{
                  "margin-left": "-6px",
                  "-ms-interpolation-mode": "nearest-neighbor",
                }} />
              <Tooltip
                title={"ФОРМА ДУХА"}
                content={"Вы воздействуете на стабильность собственного тела посредством этой эксперементальной технологии.\
                \nДелая ваше тело нестабильным эта способность дарует вам возможность проходить сквозь стены.\
                \nЭта эксперементальная технология не сделает вас неуязвимым для пуль и лезвий!\
                \nНо позволит вам снять с себя наручники, болы и даже вылезти из гроба или ящика, окажись вы там заперты...\
                \nАктивация способности мгновенна. \
                \nАктивная форма духа значительно увеличивает пассивный расход энергии! Потребление одинаково большое вне зависимости от объёма батареи.\
                \nПерезарядка: 25 секунд."}
                position="right" />
            </Button>
          </NoticeBox>
        </Flex.Item>
        <Flex.Item
          width="33%"
          shrink={1}>
          <Section title="Змей"
            buttons={<Button
              content="?"
              tooltip={"Удивляйте! Трюки, ловушки, щиты. Покажите им, что такое бой с настоящим убийцей. Извивайтесь и изворачивайтесь находя выход из любой ситуации. Враги всего лишь грызуны, чьё логово навестил змей!"}
              tooltipPosition="bottom" />}
            style={{ "text-align": "center", "background": "rgba(0, 174, 208, 0.15)" }} />
          <NoticeBox success={0} danger={0} align="center">
            <Button
              className={!blocked_TGUI_rows[0] ? rowStyles[0].green : rowStyles[0].disabled}
              height="64px"
              width="100%"
              disabled={blocked_TGUI_rows[0]}
              onClick={() => act("give_ability", { style: "kunai", row: "1" })}>
              <img
                height="64px"
                width="64px"
                src={`data:image/jpeg;base64,${allActionsPreview["kunai"]}`}
                style={{
                  "margin-left": "-6px",
                  "-ms-interpolation-mode": "nearest-neighbor",
                }} />
              <Tooltip
                title={"ВСТРОЕННОЕ ДЖОХЬЁ"}
                content={"Так же известно как Шэнбяо или просто Кинжал на цепи.\
                \nИнтегрированное в костюм устройство запуска позволит вам поймать и притянуть к себе жертву за доли секунды.\
                \nОружие не очень годится для долгих боёв, но отлично подходит для вытягивания одной жертвы - на расстояние удара!\
                \nГлавное не промахиваться при стрельбе.\
                \nСтоимость выстрела: 500 ед. энергии.\
                \nПерезарядка: 5 секунд."}
                position="bottom-right" />
            </Button>
            <Button
              className={!blocked_TGUI_rows[1] ? rowStyles[0].green : rowStyles[0].disabled}
              height="64px"
              width="100%"
              disabled={blocked_TGUI_rows[1]}

              onClick={() => act("give_ability", { style: "chem_injector", row: "2" })}>
              <img
                height="64px"
                width="64px"
                src={`data:image/jpeg;base64,${allActionsPreview["chem_injector"]}`}
                style={{
                  "margin-left": "-6px",
                  "-ms-interpolation-mode": "nearest-neighbor",
                }} />
              <Tooltip
                title={"ИСЦЕЛЯЮЩИЙ КОКТЕЙЛЬ"}
                content={"Вводит в вас эксперементальную лечебную смесь. Способную залечить даже сломанные кости и оторванные конечности.\
                \nПрепарат вызывает пространст-\
                \nвенно-временные парадоксы и очень медленно выводится из организма!\
                \nПри передозировке они становятся слишком опасны для пользователя. Не вводите больше 30 ед. препарата в ваш организм! \
                \nВместо траты энергии имеет 3 заряда. Их можно восстановить вручную с помощью цельных кусков блюспейс кристаллов помещённых в костюм."}
                position="bottom-right" />
            </Button>
            <Button
              className={!blocked_TGUI_rows[2] ? rowStyles[0].green : rowStyles[0].disabled}
              height="64px"
              width="100%"
              disabled={blocked_TGUI_rows[2]}

              onClick={() => act("give_ability", { style: "emergency_blink", row: "3" })}>
              <img
                height="64px"
                width="64px"
                src={`data:image/jpeg;base64,${allActionsPreview["emergency_blink"]}`}
                style={{
                  "margin-left": "-6px",
                  "-ms-interpolation-mode": "nearest-neighbor",
                }} />
              <Tooltip
                title={"ЭКСТРЕННАЯ ТЕЛЕПОРТАЦИЯ"}
                content={"При использовании мгновенно телепортирует пользователя в случайную зону в радиусе около двух десятков метров.\
                \nДля активации используются мозговые импульсы пользователя. Поэтому опытные воины клана, могут использовать её даже во сне.\
                \nСтоимость активации: 1500 ед. энергии.\
                \nПерезарядка: 3 секунды."}
                position="right" />
            </Button>
            <Button
              className={!blocked_TGUI_rows[3] ? rowStyles[0].green : rowStyles[0].disabled}
              height="64px"
              width="100%"
              disabled={blocked_TGUI_rows[3]}

              onClick={() => act("give_ability", { style: "caltrop", row: "4" })}>
              <img
                height="64px"
                width="64px"
                src={`data:image/jpeg;base64,${allActionsPreview["caltrop"]}`}
                style={{
                  "margin-left": "-6px",
                  "-ms-interpolation-mode": "nearest-neighbor",
                }} />
              <Tooltip
                title={"ЭЛЕКТРО-ЧЕСНОК"}
                content={"Чаще их называют просто калтропы, из-за запутывающих ассоциаций с более съестным чесноком.\
                \nПри использовании раскидывает позади вас сделанные из спрессованной энергии ловушки.\
                \nЛовушки существуют примерно 10 секунд. Так же они пропадают - если на них наступить.\
                \nБоль от случайного шага на них настигнет даже роботизирован- ные конечности.\
                \nВы не защищены от них. Не наступайте на свои же ловушки!\
                \nСтоимость активации: 1500 ед. энергии.\
                \nПерезарядка: 1 секунда."}
                position="right" />
            </Button>
            <Button
              className={!blocked_TGUI_rows[4] ? rowStyles[0].green : rowStyles[0].disabled}
              height="64px"
              width="100%"
              disabled={blocked_TGUI_rows[4]}

              onClick={() => act("give_ability", { style: "cloning", row: "5" })}>
              <img
                height="64px"
                width="64px"
                src={`data:image/jpeg;base64,${allActionsPreview["cloning"]}`}
                style={{
                  "margin-left": "-6px",
                  "-ms-interpolation-mode": "nearest-neighbor",
                }} />
              <Tooltip
                title={"ВТОРОЙ ШАНС"}
                content={"В прошлом многие убийцы проваливая свои миссии совершали самоубийства или оказывались в лапах врага.\
                \nСейчас же есть довольно дорогая альтернатива. Мощное устройство способное достать вас практически с того света.\
                \nЭта машина позволит вам получить второй шанс, телепортировав вас к себе и излечив любые травмы.\
                \nМы слышали про сомнения завязанные на идее, что это просто устройство для клонирования членов клана. Но уверяем вас, это не так.\
                \nК сожалению из-за больших затрат на лечение и телепортацию. Устройство спасёт вас лишь один раз.\
                \nУстройство активируется автоматически, когда вы будете при смерти."}
                position="right" />
            </Button>
          </NoticeBox>
        </Flex.Item>
        <Flex.Item
          width="33%"
          shrink={1}>
          <Section title="Сталь"
            buttons={<Button
              content="?"
              tooltip={"Ярость не доступная обычным людям. Сила, скорость и орудия выше их понимания. Разите их как хищник что разит свою добычу. Покажите им холодный вкус стали!"}
              tooltipPosition="bottom" />}
            style={{ "text-align": "center", "background": "rgba(80, 20, 20, 1)" }} />
          <NoticeBox className="NoticeBox_red" success={0} danger={0} align="center">
            <Button
              className={!blocked_TGUI_rows[0] ? rowStyles[0].red : rowStyles[0].disabled}
              height="64px"
              width="100%"
              disabled={blocked_TGUI_rows[0]}

              onClick={() => act("give_ability", { style: "shuriken", row: "1" })}>
              <img
                height="64px"
                width="64px"
                src={`data:image/jpeg;base64,${allActionsPreview["shuriken"]}`}
                style={{
                  "margin-left": "-6px",
                  "-ms-interpolation-mode": "nearest-neighbor",
                }} />
              <Tooltip
                title={"ЭНЕРГЕТИЧЕСКИЕ СЮРИКЕНЫ"}
                content={"Активирует пусковое устройство скрытое в перчатках костюма.\
                \nУстройство выпускает по три сюрикена, сделанных из сжатой энергии, очередью.\
                \nСюрикены постепенно изнуряют врагов и наносят слабый ожоговый урон.\
                \nТак же они пролетают через стекло, как и обычные лазерные снаряды.\
                \nСтоимость выстрела: 300 ед. энергии."}
                position="bottom-right" />
            </Button>
            <Button
              className={!blocked_TGUI_rows[1] ? rowStyles[0].red : rowStyles[0].disabled}
              height="64px"
              width="100%"
              disabled={blocked_TGUI_rows[1]}

              onClick={() => act("give_ability", { style: "adrenal", row: "2" })}>
              <img
                height="64px"
                width="64px"
                src={`data:image/jpeg;base64,${allActionsPreview["adrenal"]}`}
                style={{
                  "margin-left": "-6px",
                  "-ms-interpolation-mode": "nearest-neighbor",
                }} />
              <Tooltip
                title={"ВСПЛЕСК АДРЕНАЛИНА"}
                content={"Мгновенно вводит в вас мощную эксперементальную сыворотку ускоряющую вас в бою и помогающую быстрее оклематься от оглушающих эффектов.\
                \nКостюм производит сыворотку с использованием урана. Что к сожалению даёт неприятный негативный эффект, в виде накопления радия в организме пользователя.\
                \nВместо траты энергии может быть использовано лишь один раз, пока не будет перезаряжено вручную с помощью цельных кусков урана помещённых в костюм."}
                position="bottom-right" />
            </Button>
            <Button
              className={!blocked_TGUI_rows[2] ? rowStyles[0].red : rowStyles[0].disabled}
              height="64px"
              width="100%"
              disabled={blocked_TGUI_rows[2]}

              onClick={() => act("give_ability", { style: "emp", row: "3" })}>
              <img
                height="64px"
                width="64px"
                src={`data:image/jpeg;base64,${allActionsPreview["emp"]}`}
                style={{
                  "margin-left": "-6px",
                  "-ms-interpolation-mode": "nearest-neighbor",
                }} />
              <Tooltip
                title={"ЭЛЕКТРОМАГНИТНЫЙ ВЗРЫВ"}
                content={"Электромагнитные волны выключают, подрывают или иначе повреждают - киборгов, дронов, КПБ, энергетическое оружие, портативные Светошумовые устройства, устройства связи и т.д.\
                \nЭтот взрыв может как помочь вам в бою, так и невероятно навредить. Внимательно осматривайте местность перед применением.\
                \nНе забывайте о защищающем от света режиме вашего визора. Он может помочь не ослепнуть, при подрыве подобных устройств.\
                \nВзрыв - прерывает пассивные эффекты наложенные на вас. Например невидимость.\
                \nСтоимость активации: 5000 ед. энергии.\
                \nПерезарядка: 4 секунды."}
                position="right" />
            </Button>
            <Button
              className={!blocked_TGUI_rows[3] ? rowStyles[0].red : rowStyles[0].disabled}
              height="64px"
              width="100%"
              disabled={blocked_TGUI_rows[3]}

              onClick={() => act("give_ability", { style: "energynet", row: "4" })}>
              <img
                height="64px"
                width="64px"
                src={`data:image/jpeg;base64,${allActionsPreview["energynet"]}`}
                style={{
                  "margin-left": "-6px",
                  "-ms-interpolation-mode": "nearest-neighbor",
                }} />
              <Tooltip
                title={"ЭНЕРГЕТИЧЕСКАЯ СЕТЬ"}
                content={"Мгновенно ловит выбранную вами цель в обездвиживающую ловушку.\
                \nИз ловушки легко выбраться просто сломав её любым предметом.\
                \nОтлично подходит для временной нейтрализации одного врага.\
                \nК тому же в неё можно поймать агрессивных животных или надоедливых охранных ботов.\
                \nУчитывайте, что сеть не мешает жертве отстреливаться от вас.\
                \nТак же сеть легко покинуть другим путём, например телепортацией.\
                \nАктивация сети - прерывает пассивные эффекты наложенные на вас. Например невидимость.\
                \nСтоимость активации: 4000 ед. энергии."}
                position="right" />
            </Button>
            <Button
              className={!blocked_TGUI_rows[4] ? rowStyles[0].red : rowStyles[0].disabled}
              height="64px"
              width="100%"
              disabled={blocked_TGUI_rows[4]}

              onClick={() => act("give_ability", { style: "spider_red", row: "5" })}>
              <img
                height="64px"
                width="64px"
                src={`data:image/jpeg;base64,${allActionsPreview["spider_red"]}`}
                style={{
                  "margin-left": "-6px",
                  "-ms-interpolation-mode": "nearest-neighbor",
                }} />
              <Tooltip
                title={"БОЕВОЕ ИСКУССТВО \nПОЛЗУЧЕЙ ВДОВЫ"}
                content={"Боевое искусство ниндзя сосредоточенное на накоплении концентрации для использования приёмов.\
                \nВ учение входят следующие приёмы:\
                \nВыворачивание руки - заставляет жертву выронить своё оружие.\
                \nУдар ладонью - откидывает жертву на несколько метров от вас, лишая равновесия.\
                \nПеререзание шеи - мгновенно обезглавливает лежачую жертву катаной во вспомогательной руке.\
                \nЭнергетическое торнадо - раскидывает врагов вокруг вас и создаёт облако дыма при наличии активного дымового устройства и энергии.\
                \nТак же вы обучаетесь с определённым шансом отражать сняряды врагов обратно."}
                position="right" />
            </Button>
          </NoticeBox>
        </Flex.Item>
      </Flex>
    </Section >
  );
};


export const ShuttleConsole = (properties, context) => {
  const { act, data } = useBackend((properties, context));
  return (
    <Section title="Управление шаттлом" style={{ "text-align": "center" }}
      buttons={<Button
        content="?"
        tooltip={"Панель для удалённого управление вашим личным шаттлом. \
        Так же показывает вашу текущую позицию и позицию самого шаттла!"}
        tooltipPosition="right" />}>
      <Flex ml={2}>
        <LabeledList>
          <LabeledList.Item label="Позиция">
            {data.status ? (
              data.status
            ) : (
              <NoticeBox color="red">
                Shuttle Missing
              </NoticeBox>
            )}
          </LabeledList.Item>
          <LabeledList.Item label="Ваша позиция">
            {data.player_pos}
          </LabeledList.Item>
          {!!data.shuttle && (// only show this stuff if there's a shuttle
            !!data.docking_ports_len && (
              <LabeledList.Item label={"Отправить шаттл"}>
                {data.docking_ports.map(port => (
                  <Button
                    icon="chevron-right"
                    key={port.name}
                    content={port.name}
                    onClick={() => act('move', {
                      move: port.id,
                    })} />
                )
                )}
              </LabeledList.Item>
            ) || (// ELSE, if there's no docking ports.
              <Fragment>
                <LabeledListItem label="Status" color="red">
                  <NoticeBox color="red">
                    Shuttle Locked
                  </NoticeBox>
                </LabeledListItem>
                {!!data.admin_controlled && (
                  <LabeledListItem label="Авторизация">
                    <Button
                      icon="exclamation-circle"
                      content="Запросить авторизацию"
                      disabled={!data.status}
                      onClick={() => act('request')} />
                  </LabeledListItem>
                )}
              </Fragment>
            )
          )}
        </LabeledList>
      </Flex>
    </Section>
  );
};

const FakeLoadBar = (properties, context) => {
  const { data } = useBackend((properties, context));
  const {
    randomPercent,
    allActionsPreview,
    color_choice,
  } = data;
  return (
    <Section
      stretchContents>
      <ProgressBar
        color={color_choice}
        value={randomPercent}
        minValue={0}
        maxValue={100}>
        <center>
          <NoticeBox
            className={"NoticeBox_" + color_choice}
            mt={1}>
            <img
              height="64px"
              width="64px"
              src={`data:image/jpeg;base64,${allActionsPreview["spider_" + color_choice]}`}
              style={{
                "margin-left": "-6px",
                "-ms-interpolation-mode": "nearest-neighbor",
              }} />
            <br />
            Loading {randomPercent + "%"}
          </NoticeBox>

        </center>
      </ProgressBar>
    </Section >
  );
};

class FakeTerminal extends Component {
  constructor(props) {
    super(props);
    this.timer = null;
    this.state = {
      lastText: "text do be there",
      currentDisplay: [],
    };
  }

  tick() {
    const { props, state } = this;
    if (props.allMessages !== state.lastText && !props.end_terminal) {
      const { currentDisplay } = state;
      currentDisplay.push(props.allMessages);
      state.lastText = props.allMessages;
    } else if (props.end_terminal) {
      clearTimeout(this.timer);
      setTimeout(props.onFinished, props.finishedTimeout);
    }
  }

  componentDidMount() {
    const {
      linesPerSecond = 2.5,
    } = this.props;
    this.timer = setInterval(() => this.tick(), 1000 / linesPerSecond);
  }

  componentWillUnmount() {
    clearTimeout(this.timer);
  }

  render() {
    return (
      <Box m={1}>
        {this.state.currentDisplay.map(value => (
          <Fragment key={value}>
            {value}
            <br />
          </Fragment>
        ))}
      </Box>
    );
  }
}
