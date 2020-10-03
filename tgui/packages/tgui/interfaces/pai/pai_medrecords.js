import { useBackend } from "../../backend";
import { SimpleMedRecords } from "../common/SimpleMedRecords";

export const pai_medrecords = (props, context) => {
  const { data } = useBackend(context);
  return <SimpleMedRecords data={data.app_data} />;
};
