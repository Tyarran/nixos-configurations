# AGENTS.md - NixOS Configuration Guidelines

## Build/Lint/Test Commands

### Build Commands (Flake-based)
- `nixos-rebuild build --flake .#nova`: Build nova (x86_64-linux) configuration
- `nixos-rebuild build --flake .#orion`: Build orion (aarch64-linux) configuration
- `nixos-rebuild switch --flake .#<host>`: Build and apply configuration to current system
- `nixos-rebuild test --flake .#<host>`: Test configuration temporarily without modifying bootloader

### Lint/Format Commands
- `nixfmt .`: Format all Nix files (REQUIRED before committing)
- `statix check .`: Run static analysis on Nix files
- `deadnix .`: Find unused code in Nix expressions

## Code Style Guidelines

### File Structure (Modular Pattern)
- Each host has its own directory: `nova/`, `orion/`
- Configuration split into modules: `configuration.nix`, `users.nix`, `locale.nix`, `keyboard.nix`
- Services in dedicated `services/` subdirectory with `default.nix` importing all service modules
- Hardware configuration kept separate: `hardware-configuration.nix` (auto-generated, do not manually edit)

### Nix Language Conventions
- Use `nixfmt` for formatting (2-space indentation, NO tabs)
- Relative imports: `./hardware-configuration.nix`, `./services`
- Module pattern: `{ config, pkgs, ... }: { ... }`
- Descriptive names: `power-management.nix` not `pm.nix`

### Security (agenix)
- NEVER commit plaintext secrets
- Use agenix for password management: `age.secrets.<name>.file`
- Secrets stored in `secrets/` directory as `.age` files
- Public keys defined in `secrets.nix`

### Adding New Modules
1. Create module file in appropriate `services/` directory
2. Add to `services/default.nix` imports list
3. Run `nixfmt .` before committing
4. Test with `nixos-rebuild build --flake .#<host>`</content>
<parameter name="filePath">/home/romain/Projects/nixos-configurations/AGENTS.md