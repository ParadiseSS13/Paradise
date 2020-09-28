import { useBackend, useLocalState } from "../backend";
import { Box, Button, Flex, Icon, Input, LabeledList, Section, Table, Tabs } from '../components';
import { Window } from "../layouts";

const TEMPS = {
  scalding: { label: 'Scalding', color: '#FF0000', icon: 'fa fa-arrow-circle-up', requireEmag: true },
  warm: { label: 'Warm', color: '#990000', icon: 'fa fa-arrow-circle-up' },
  normal: { label: 'Normal', color: null, icon: 'fa fa-arrow-circle-right' },
  cool: { label: 'Cool', color: '#009999', icon: 'fa fa-arrow-circle-down' },
  frigid: { label: 'Frigid', color: '#00CCCC', icon: 'fa fa-arrow-circle-down', requireEmag: true },
};

const TempButton = (properties, context) => {
  const { tempKey } = properties;
  const temp = TEMPS[tempKey];
  if (!temp) {
    return null;
  }
  const { data, act } = useBackend(context);
  const { currentTemp } = data;
  const { label, icon } = temp;
  const selected = tempKey === currentTemp;
  const setTemp = () => {
    act('setTemp', { temp: tempKey });
  };
  return (
    <div style={{ margin: '0 0 4px 0' }}>
      <Button selected={selected} onClick={setTemp} >
        <i className={icon} />
        {label}
      </Button>
    </div>
  );
};

export const PoolController = (properties, context) => {
  const { data, act } = useBackend(context);
  const { emagged, currentTemp } = data;
  const { label: currentLabel, color: currentColor } = TEMPS[currentTemp] || TEMPS.normal;

  return (
    <Window>
      <Window.Content>

        <LabeledList>
          <LabeledList.Item labelColor="yellow" labelClassName="text-bold" label="Current Temperature">
            <span style={{ color: currentColor }}>
              {currentLabel}
            </span>
          </LabeledList.Item>

          <LabeledList.Item labelColor="yellow" label="Saftey Status">
            {emagged ? (
              <span className="text-bold" style={{ color: 'red' }}>
                WARNING: OVERRIDDEN
              </span>
            ) : (
              <span style={{ color: 'green' }}>
                Nominal
              </span>
            )}
          </LabeledList.Item>
        </LabeledList>

        <div className="text-bold" style={{ margin: '8px 0 5px 0' }}>
          Temperature Selection:
        </div>

        <div>
          {Object.keys(TEMPS).map(tempKey => {
            const temp = TEMPS[tempKey];
            const { requireEmag } = temp;
            if (requireEmag && !emagged) {
              return null;
            }
            return (
              <TempButton key={tempKey} tempKey={tempKey} />
            );
          })}
        </div>

      </Window.Content>
    </Window>
  );
};
