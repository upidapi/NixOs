# todo
Make something a bit simular to snowfall lib.
    
Each module is supplied with "mod_options"
    
    # The mod_options dynamically resolves to the path of the module

    namespace = p_conf
    project_root = "./."
    mod_path = "the path of module a"  
    mod_confs.a.b.c => "options".{namespace}.{mod_path}.a.b.c
    
    @example
    project_root = "/"

    # /{project_root}/modules/discord
    {mod_options, ...} : {
        mod_options.enabled = true
    }
:
    => (is the same as)

    {options, ...} : {
        options.p_conf.modules.discord = true
    }

The reason for this is to force proper file organisation


should mod_options be a function?


since nix doesn't have getAtte overload we have to predefine our category's


    groups = {a = [z, y, z],  b = 


no_op = {x, ...}: x
# no_op_set = x: map ((y: ))
struct =  {
    modules = no_op;
    options = 
}

we supply the function mod_path: 
    
    # The mod_options dynamically resolves to the path of the module

    namespace = p_conf
    project_root = "./."
    mod_path = "the path of module a"  
    mod_confs.a.b.c => "options".{namespace}.{mod_path}.a.b.c
    
    @example
    project_root = "/"

    # /{project_root}/modules/discord
    {namespace, ...} : {
        namespace {enabled = true}
    }

    namespace.options = {enabled = true}

    => (is the same as)

    {options, ...} : {
        options.p_conf.modules.discord = true
    }

what namespaces should we have?
    
    
    mod_options  # maby m_opt
    lib


    
