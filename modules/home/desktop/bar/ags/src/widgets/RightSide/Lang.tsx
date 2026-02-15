import { Variable } from "astal";
import DataContainer from "../DataContainer";

const data = Variable("").poll(
    100,
    "hyprctl devices -j"
);

export default function Time() {
    return (
        <DataContainer>
            <label label={
                data().as(x => {
                    if (x === "")
                        return ""

                    return JSON.parse(x)
                        .keyboards.find(k => k.main)
                        .active_keymap
                        .slice(0, 2)
                })

            } />
        </DataContainer>
    );
}
