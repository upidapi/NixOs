import DataContainer from "../../DataContainer";
import AirplainMode from "./AirplaneMode";
import AudioSource from "./AudioSouce";
import NetworkStatus from "./NetworkStatus";

export default function StatusIcons() {
  return (
    <DataContainer>
      <AudioSource />
      <AirplainMode />
      <NetworkStatus />
    </DataContainer>
  );
}
