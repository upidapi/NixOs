import { Widget } from "astal/gtk3";

export default function DataContainer({
    child,
    children,
    className = "",
    visible = true,
}: Widget.BoxProps) {
    return (
        <box
            spacing={5}
            className={"container " + className}
            homogeneous={false}
            visible={visible}
        >
            {child}
            {children}
        </box>
    );
}
