: "
load the secrets/infra.yaml 
decrypt with admin key (+ passphrase?)

get the host/\${host name} key (and possibly the admin key)
    generate the age key(s) from those 
    place the file in /persist/sops-nix-key.txt
    fix perms 

------done by nix-sops------
this file will be used to decrypt everythin for the host 
    incluiding user secrets 

user secrets will be used to create the home envs    
"

