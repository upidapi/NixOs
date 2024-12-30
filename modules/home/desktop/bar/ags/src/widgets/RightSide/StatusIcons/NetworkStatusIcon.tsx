import Network from "gi://AstalNetwork";
import { Variable, bind } from "astal";
import { StatusIcon } from "./StatusIcon";

export default function NetworkStatusIcon() {
  const network = Network.get_default();

  // pp(network);
  return (
    <StatusIcon
      icon={Variable.derive(
        [
          bind(network, "primary"),

          bind(network, "wifi"),
          bind(network, "wired"),
        ],
        (primary, wifi, wired) => {
          return {
            // should not occur
            [Network.Primary.UNKNOWN]: "network-wireless-offline-symbolic",
            [Network.Primary.WIFI]: wifi == null ? "error" : wifi.iconName,
            [Network.Primary.WIRED]: wired.iconName,
          }[primary];
        },
      )()}
    />
  );
}
