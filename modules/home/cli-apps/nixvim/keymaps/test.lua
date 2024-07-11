local tt = require("toggleterm")

local function CallLanguage(inp)
    local esc = escape(inp)  -- expand args (eg % -> path-to-cur-buffer) 

    tt.exec_command([[
      PS1="\n>>>";
      clear;
      echo -e ">>> ]] .. esc .. [[ \n"; ]] ..
      esc .. [[;
      echo -e "\nFinished with code: $?"
    ]], 0 --[[send to open term]])
end

CallLanguage("asd")
