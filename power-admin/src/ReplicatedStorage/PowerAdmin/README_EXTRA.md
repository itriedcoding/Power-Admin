Advanced modules added:
- `Bans.lua`: DataStore-backed bans with temp/perm support.
- `RolesStore.lua`: Persist per-user role selections.
- `GroupAdapter.lua`: Auto-assign roles based on Roblox group rank thresholds.
- `Targeting.lua`: Centralized targeting parser for players (me, all, others, name:, team:).
- `CommandRegistry.lua`: Server-sourced command metadata powering client autocomplete and help.

New commands:
- `;mute`, `;unmute`: Temporarily or permanently mute chat for targets.
- `;announce`: Broadcast announcement to server.
- `;pm`: Private message a player.
- `;stats`: Show basic server stats.
- `;shutdown`: Kick all players with message.

Client extras:
- Autocomplete dropdown for command names when starting with `;`.

Server internals:
- Roles persisted via `RolesStore` and optionally auto-assigned from `Config.GroupRoles`.

