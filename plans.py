"""
# todo
Make something a bit simular to snowfall lib.

the following is supplied to all imports / modules
m_opts, exports, lib 


# note: only files named default.nix will be supplied with m_opts and exports
the m_opts and exports work like python imports
    a default.nix is the same as __init__.py
    i.e as a file to edit what exist in it's parent folder

    and then normal files (.nix) will act as their own __init__.py

    but for that reason you cant set attrs whose names that exist
    in the same directory

where "m_config" dynamically maps tp options."path_to_module"

    it should be used to define module options
    like mkOpt

    DO NOT SET OPTIONS WITH OPTIONS

"exports" dynamically maps to lib."path_to_module"

    can ony contain functions

and "lib" is just a object to store functions (from "module".export for use
    in other modules

    this can be accessed from any module


example
    # /{project_root}/modules/discord/default.nix
    # or
    # /{project_root}/modules/discord.nix

    {m_opt, exports, ...} : {
        m_opt = {
            enabled = mkOptions bool
        }
        
        exports = {
            mkProfile = {...}: ...
        }
    }
    
    # is the same as 
    
    {options, lib, ...} : {
        options.modules.discord = {
            enabled = mkOptions bool
        }
        
        lib.modules.discord = {
            mkProfile = {...}: ...
        }
    }

# note options."option" = "value" should still be used to set options
    m_opt is only for defining options
"""
