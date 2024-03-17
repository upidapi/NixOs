# this is not a example usecase for "load-modules"
# but instead more like a test to see if it works
load-modules
{
  src = ./sub;
  scope = "test";
}
{
  config = {};
  options = {};
  pkgs = {};
  modulesPath = "";
}
