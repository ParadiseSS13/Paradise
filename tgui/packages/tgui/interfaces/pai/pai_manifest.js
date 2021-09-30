import { useBackend } from "../../backend";
import { CrewManifest } from "../common/CrewManifest";

export const pai_manifest = (props, context) => {
  const { act, data } = useBackend(context);

  return <CrewManifest data={data.app_data} />;
};
