import { Variable } from "astal";
import DataContainer from "../DataContainer";

const date = Variable("").poll(
  1000,
  `bash -c "LC_ALL=en_GB.utf8 date +'%Y-%m-%d %a %H:%M:%S'"`,
);
export default function Time() {
  return (
    <DataContainer>
      <label label={date()} />
    </DataContainer>
  );
}
