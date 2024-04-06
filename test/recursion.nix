{lib}: rec {
  inp = {
    data = "data";
    sub = {
      a = {
        a_data = "a";
      };
      b = {
        b_data = "b";
      };
      c = {
        c_data = "c";
      };
    };
  };

  out =
    [inp]
    ++ (
      builtins.attrValues (
        builtins.mapAttrs (_: d: d)
        inp.sub
      )
    );
}
