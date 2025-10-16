# nix-jetkvm-builder
Static ARMv7 builder and cross shell for JetKVM

## Example
nix run github:florian-sonnenschein/nix-jetkvm-builder#build -- hello

This will create the package hello for the jetkvm plattform

## Copy Binary to jetKVM
1. Enable Development Mode in the jetKVM Advanced Settings
2. Put in your ssh public key and ssh into the jetKVM: `ssh root@<jetkvm-ip>`
3. Start a simple http server on your host (e.g. `python -m http.simple`)
4. Download the binary using wget on the jetKVM: `wget http://<host-ip>:8000/result/bin/hello`
5. Put executable flag to the bin: `chmod +x hello`
6. Run the binary `./hello`


The "hello" package is just an example. You can build many more packages from nixpkgs. (e.g. git, wireguard-tools, ...)
