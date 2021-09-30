import { useBackend } from "../../backend";
import { CrewManifest } from "../common/CrewManifest";

export const pda_manifest = (props, context) => {
  const { act, data } = useBackend(context);

  return <CrewManifest />;
};
