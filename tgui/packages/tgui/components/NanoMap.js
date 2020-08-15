import { Box, Icon, Tooltip } from '.';
import { useBackend } from "../backend";

export const NanoMap = (props, context) => {
  const { config } = useBackend(context);
  const { onClick } = props;
  return (
    <Box className="NanoMap__container">
      <Box
        as="img"
        src={config.map+"_nanomap_z1.png"}
        style={{
          width: '512px',
          height: '512px',
        }}
        onClick={onClick} />
    </Box>
  );
};

const NanoMapMarker = props => {
  const {
    x,
    y,
    icon,
    tooltip,
    color,
  } = props;
  return (
    <Box
      position="absolute"
      className="NanoMap__marker"
      top={(((255 - y) * 2) + 2) + 'px'}
      left={((x * 2) + 2) + 'px'}>
      <Icon
        name={icon}
        color={color}
        size={0.5}
      />
      <Tooltip content={tooltip} />
    </Box>
  );
};

NanoMap.Marker = NanoMapMarker;
