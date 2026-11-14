# Silent friendly-fire notifications v4.1 ? 2026-11-13

User wants Zeus remote-controlled kills to stop revealing friendly-fire attribution to players. Presentation-only change, no damage, kill attribution, punishment, respawn or revive changes. No tests/config validation/game launch, per standing user instruction.

New client postInit initSilentFriendlyFire installs one guarded HandleChatMessage handler. Blocks engine system-channel messages with friendly fire/friendly-fire text or friendly-kill/fire/teamkill string IDs. Leaves player-written messages and unrelated system/death messages alone. English fallback text is covered; unknown localized engine string IDs may require further identification. Also wraps the existing native A3A_fnc_customHint at runtime to drop only headings equal to localized STR_A3A_punishment_ff_notification. All other hints call the captured native function. No per-unit EH added, no duplicate initialization. Installed on all client/JIP machines using addon postInit. Every player must update/restart to suppress their local display.

API reference: https://community.bistudio.com/wiki/Arma_3:_Mission_Event_Handlers (HandleChatMessage returns true to suppress feed). Native Antistasi friendly-fire heading confirmed from local extracted punishment functions. No claim of in-game acceptance.

Files: new functions/Compatibility/fn_initSilentFriendlyFire.sqf; config.cpp registration/version; mod.cpp version; notes/HANDOFF. Built with FileBank only.
