import { useBackend } from '../../backend';
import { CrewManifest } from '../common/CrewManifest';

export const pda_manifest = (props) => {
  const { act, data } = useBackend();

  return <CrewManifest />;
};
