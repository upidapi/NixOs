let
  path = /home/upidapi/.mozilla/firefox/upidapi/extensions.json;
  file_data = ''{"helllo": "hi"}''; #  builtins.readFile path;
  data = builtins.fromJSON file_data;
in
  builtins.toJSON data
