// REF: https://github.com/bingo084/ags-config/blob/main/widget/Bar/Inhibit.tsx

import { exec, subprocess } from "astal";
import GObject, { property, register } from "astal/gobject";

interface InhibitData {
  who: string;
  uid: number;
  user: string;
  pid: number;
  comm: string;
  what: string;
  why: string;
  mode: "block" | "delay";
}

@register({ GTypeName: "Inhibit" })
export default class Inhibit extends GObject.Object {
  private declare _inhibitData: InhibitData[];

  _getInhibitsData() {
    const rawData = exec("systemd-inhibit --list").trim().split("\n");
    const header = rawData[0];
    const rawInhibits = rawData.slice(1, -2);

    const keys = ["WHO", "UID", "USER", "PID", "COMM", "WHAT", "WHY", "MODE"];
    let i = 0;
    const keyStarts: number[] = [];
    for (const key in keys) {
      while (!header.slice(i).startsWith(key)) {
        i++;
      }

      keyStarts.push(i);
    }

    keyStarts.push(header.length);

    const inhibits: InhibitData[] = [];

    for (const inhibit in rawInhibits) {
      let parts = [];

      for (const i of keyStarts) {
        parts.push(inhibit.slice(keyStarts[i], keyStarts[i + 1]));
      }

      parts = parts.map((x) => x.trim());

      inhibits.push({
        who: parts[0],
        uid: parseInt(parts[1]),
        user: parts[2],
        pid: parseInt(parts[3]),
        comm: parts[4],
        what: parts[5],
        why: parts[6],
        mode: parts[7] as "block" | "delay",
      });
    }

    return inhibits;
  }

  _getInhibitData(what: string) {
    return this._inhibitData.find((d) => d.what == what && d.who == "Ags");
  }

  _inhibit(what: string) {
    subprocess(
      `systemd-inhibit --what=${what} --who="Ags" --why="Manual inhibit ${what}" sleep infinity`,
    );
  }

  _uninhibit(what: string) {
    const pid = this._getInhibitData(what)?.pid;
    if (pid) {
      exec(`kill ${pid}`);
    }
  }

  @property(Boolean)
  get sleepInhibit() {
    return this._getInhibitData("sleep") == undefined ? false : true;
  }
  set sleepInhibit(bool) {
    if (bool == this.sleepInhibit) {
      return
    }

    if (bool) {
      this._inhibit("sleep");
    } else {
      this._uninhibit("sleep");
    }

    this._inhibitData = this._getInhibitsData()
    this.notify("sleep-inhibit")
  }

  @property(Boolean)
  get idleInhibit() {
    return this._getInhibitData("idle") == undefined ? false : true;
  }
  set idleInhibit(bool) {
    if (bool == this.idleInhibit) {
      return
    }

    if (bool) {
      this._inhibit("idle");
    } else {
      this._uninhibit("idle");
    }

    this._inhibitData = this._getInhibitsData()
    this.notify("idle-inhibit")
  }

  constructor() {
    super();
    this._inhibitData = this._getInhibitsData();
  }
}
