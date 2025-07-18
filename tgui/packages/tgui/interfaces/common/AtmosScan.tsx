import { filter } from 'common/collections';
import { Box, LabeledList } from 'tgui-core/components';

const getItemColor = (value, min2, min1, max1, max2) => {
  if (value < min2) {
    return 'bad';
  } else if (value < min1) {
    return 'average';
  } else if (value > max1) {
    return 'average';
  } else if (value > max2) {
    return 'bad';
  }
  return 'good';
};

type AirContent = {
  entry: string;
  units: string;
  val: string;
  bad_high: number;
  poor_high: number;
  poor_low: number;
  bad_low: number;
};

type AtmosScanProps = {
  aircontents: AirContent[];
};

export const AtmosScan = (props: AtmosScanProps) => {
  const { aircontents } = props;

  return (
    <Box>
      <LabeledList>
        {filter(aircontents, (i) => i.val !== '0' || i.entry === 'Pressure' || i.entry === 'Temperature').map(
          (item) => (
            <LabeledList.Item
              key={item.entry}
              label={item.entry}
              color={getItemColor(item.val, item.bad_low, item.poor_low, item.poor_high, item.bad_high)}
            >
              {item.val}
              {item.units}
            </LabeledList.Item>
          )
        )}
      </LabeledList>
    </Box>
  );
};
