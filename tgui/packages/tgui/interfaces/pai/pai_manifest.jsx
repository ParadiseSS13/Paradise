import { useBackend } from '../../backend';
import { CrewManifest } from '../common/CrewManifest';

export const pai_manifest = (props) => {
  const { act, data } = useBackend();

  return <CrewManifest data={data.app_data} />;
};
