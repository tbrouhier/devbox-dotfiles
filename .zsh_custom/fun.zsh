function presources () {
    puppetresources -p . -o "$1" --hiera ./tests/hiera.yaml --pdbfile tests/facts.yaml "${@:2}"
}

function nixsearch () {
    nix-env -qaPf '<nixpkgs>' -A $1
}
