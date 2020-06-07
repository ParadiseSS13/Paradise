import { Box } from '.';
import { useBackend } from "../backend";

export const NanoMap = (props, context) => {
  const { config } = useBackend(context);
  const { onClick } = props;
  return (
    <div class="NanoMap_Container">
      <Box
        as="img"
        src={config.map+"_nanomap_z1.png"}
        style={{
          width: '512px',
          height: '512px',
        }}
        onClick={onClick} />
    </div>
  );
};
