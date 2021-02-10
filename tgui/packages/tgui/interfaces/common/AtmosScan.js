import { filter } from 'common/collections';
import { useBackend } from "../../backend";
import { Box, LabeledList } from "../../components";

const getItemColor = (value, min2, min1, max1, max2) => {
  if (value < min2) {
    return "bad";
  } else if (value < min1) {
    return "average";
  } else if (value > max1) {
    return "average";
  } else if (value > max2) {
    return "bad";
  }
  return "good";
};

export const AtmosScan = (props, context) => {
  const {
    aircontents,
  } = props.data;

  return (
    <Box>
      <LabeledList>
        {filter(
          i => (i.val !== "0")
            || i.entry === "Pressure"
            || i.entry === "Temperature"
        )(aircontents)
          .map(item => (
            <LabeledList.Item
              key={item.entry}
              label={item.entry}
              color={getItemColor(item.val,
                item.bad_low,
                item.poor_low,
                item.poor_high,
                item.bad_high)}>
              {item.val}{item.units}
            </LabeledList.Item>
          ))}
      </LabeledList>
    </Box>
  );
};
