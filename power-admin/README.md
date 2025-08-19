## Power Admin (Roblox)

An advanced, production-grade admin system for Roblox games. Built with Luau. Secure-by-default, fully modular, and extensible.

### Highlights
- Role-based access control with weighted roles and per-command permissions
- Persistent bans (permanent and temporary), session grants, and revocations
- Command chaining (`;`) and macros, aliases, argument parsing & targeting (`me`, `all`, `others`, `team:Red`, `name:Alice`)
- Robust server-side validation, rate limiting, and audit logging (memory + DataStore)
- Optional webhook export (Discord-compatible) via `HttpService`
- Real-time panel UI: Console, Players, Logs, and Settings with autocomplete and history
- Scheduler for temporary punishments and timed tasks
- Safe networking: no trust in client, server-only authority
- Staff tooling: warnings, notes, mute/unmute, announcements, private messages
- Whitelist + server lock, group-rank auto roles, and persisted roles

### Folder Structure
```
power-admin/
  └─ src/
      ├─ ReplicatedStorage/
      │   └─ PowerAdmin/
      │       ├─ Init.lua
      │       ├─ Config.lua
      │       ├─ Permissions.lua
      │       ├─ RateLimiter.lua
      │       ├─ AuditLog.lua
      │       ├─ Networking.lua
      │       ├─ Scheduler.lua
      │       ├─ Utils.lua
      │       ├─ Commands.lua
      │       ├─ Bans.lua
      │       ├─ RolesStore.lua
      │       ├─ GroupAdapter.lua
      │       ├─ Targeting.lua
      │       ├─ CommandRegistry.lua
      │       ├─ Warnings.lua
      │       ├─ Notes.lua
      │       ├─ Whitelist.lua
      │       ├─ ServerState.lua
      │       └─ README_EXTRA.md
      ├─ ServerScriptService/
      │   └─ PowerAdmin.server.lua
      └─ StarterPlayerScripts/
          ├─ PowerAdmin.client.lua
          └─ AutoComplete.lua
```

### Installation
1. Download this folder as a zip from your environment or repo and extract it.
2. In Roblox Studio:
   - Place the contents of `src/ReplicatedStorage/PowerAdmin` into `ReplicatedStorage` under a folder named exactly `PowerAdmin`.
   - Place `src/ServerScriptService/PowerAdmin.server.lua` into `ServerScriptService`.
   - Place `src/StarterPlayerScripts/PowerAdmin.client.lua` into `StarterPlayer > StarterPlayerScripts`.
3. In Studio Game Settings:
   - Enable `API Services` (for DataStore) if you want persistence.
   - Enable `Allow HTTP Requests` if you plan to use webhooks.
4. Configure owners/roles in `ReplicatedStorage/PowerAdmin/Config.lua`.
5. Press Play. Type `/` to focus the console, or use the panel button in the top-left.

### Configuration
Edit `Config.lua`:
- `Owners`: UserIds that always have highest permissions.
- `Roles`: Define named roles, weights, and permissions.
- `DefaultRole`: The fallback role for new players.
- `FeatureFlags`: Toggle optional behaviors (webhooks, strict targeting, etc.).
- `Webhook`: Discord webhook URL (optional). Leave empty to disable.
- `GroupRoles`: Optional group rank-to-role mapping.

### Core Commands
- `;help [command?]`: Shows help or details for a command.
- `;cmds`: Lists commands you can run.
- `;grant <playerTarget> <role>` / `;revoke <playerTarget>`
- `;kick <playerTarget> <reason?>`
- `;ban <playerTarget> <reason?>` / `;unban <userId>`
- `;tban <playerTarget> <duration> <reason?>` (e.g., `15m`, `2h`, `1d`)
- `;logs [playerTarget?] [limit?]`: Shows recent audit entries
- `;tp <playerTarget> <toTarget>` / `;bring <playerTarget>`
- `;freeze <playerTarget>` / `;thaw <playerTarget>`
- `;speed <playerTarget> <number>`
- `;health <playerTarget> <number>`
- `;macro <name> <command;command;...>` then `;macro-run <name> [args...]`
- `;alias <name> <command>`

### Advanced Commands
- `;mute <player> [duration]` / `;unmute <player>`
- `;warn <player> [reason]`, `;warns <player>`, `;unwarn <player>`
- `;note <player> <text>`, `;notes <player>`
- `;announce <message>`
- `;pm <player> <message>`
- `;stats`
- `;wlist <add|remove|list> [userId]`
- `;lock`, `;unlock`

You can chain commands with `;`, for example: `;freeze me;tp me name:Alice`.

### Security Notes
- The client has zero authority. All permission checks and state changes happen on the server.
- Commands are rate-limited per user.
- Every action is audited with actor, target(s), arguments, and outcome.

### Packaging as a Model (Optional)
If you prefer a single importable model:
1. In Studio, create a folder `PowerAdmin` in `ReplicatedStorage` and paste the module files.
2. Insert the server and client scripts into their services.
3. Select the items and use `File > Publish Selection to Roblox` or `Save to Roblox` to create a model.

### License
MIT. Attribution appreciated but not required.

