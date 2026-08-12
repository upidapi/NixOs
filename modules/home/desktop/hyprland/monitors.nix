{
  osConfig,
  lib,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;

    extraLuaFiles."monitors.lua" = let
      monitorCfg = osConfig.modules.nixos.hardware.monitors;
      monitorList = builtins.attrValues monitorCfg.monitors;

      luaData = lib.generators.toLua {} {
        monitors = monitorList;
        primaryMonitor = monitorCfg.primaryMonitor;
      };
    in
      #lua
      ''
        local config = ${luaData}

        for _, m in ipairs(config.monitors) do
          if m.enabled then
            local resolution = m.width .. "x" .. m.height .. "@" .. m.refreshRate
            local position = m.x .. "x" .. m.y

            hl.monitor({
              output = m.name,
              mode = resolution,
              position = position,
              scale = m.scale
            })

            -- assign each monitor the correct workspace (this breaks switching
            -- with focusworkspaceoncurrentmonitor)
            --[[
            hl.workspace_rule({
              workspace = tostring(m.workspace),
              monitor = m.name,
              default = true
            })
            --]]

          hl.on("hyprland.start", function () 
            -- move each workspace to their correct default workspace
            hl.exec_cmd("hyprctl dispatch focusmonitor " .. m.name)
            hl.exec_cmd("hyprctl dispatch focusworkspaceoncurrentmonitor " .. m.workspace)
          end)

          else
            hl.monitor({
              output = m.name,
              disabled = true
            })
          end
        end


        hl.on("hyprland.start", function () 
          -- move cursor to primary workspace
          if config.primaryMonitor then
            hl.exec_cmd("hyprctl dispatch focusmonitor " .. config.primaryMonitor)
          end
        end)
      '';
  };
}
