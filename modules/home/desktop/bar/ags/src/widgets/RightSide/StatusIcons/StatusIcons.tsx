import DataContainer from "../../DataContainer";
import AirplainStatusIcon from "./AirplaneStatusIcon";
import AudioStatusIcons from "./AudioStatusIcons";
import NetworkStatusIcon from "./NetworkStatusIcon";

export default function StatusIcons() {
  return (
    <DataContainer>
      <AudioStatusIcons />
      <AirplainStatusIcon />
      <NetworkStatusIcon />
    </DataContainer>
  );
}
