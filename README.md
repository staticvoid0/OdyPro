# 🧭 OdyPro v3.4.3

### Everything Odyssey addon for Windower 4

[Download OdyPro](https://github.com/staticvoid0/OdyPro/releases/download/3.4.3main/OdyPro.zip)

- Handles Moglophone & Amplifier pickup automatically.
- Offers optional auto-amp use inside Gaol boss chambers.
- Displays total mog segments, amount per instance and record for a single instance.
- Displays Moglophone, Moglophone II and amplifier possession.
- Displays RP charge status.
- Tracks and displays moglophone timer, with a pickup alarm.
- Includes powerful auto-targeting and auto-weapon-swap systems, the AWS system hooks into gearswap. 
- Shows target resistances and available maps for Sheol A, B, and C.
- Fully compatible with Superwarp. Interprets and relays the commands. (//op port works just like //od port )
- Odyssey queueing and entry commands

**Auto-targeting system**  
has NM → Agon → same-name-mob prioritization and invincible/perfect-dodge detection and omission.

**Auto-weapon-swap (AWS)**  
hooks into Gearswap with Easy 1.2.3 setup.


## 🧾 Changelog

### **v3.4.1 → v3.4.3**
- Added auto moglophone timer setting. You no longer need to have had OdyPro loaded when picking up moglophone for the timer to be set.
Please note auto-setting of the timer when standing near the Odyssey ??? in rabao will only be 100% accurate if it is within the last hour as the server does not send the exact minute remaining until < `60 minutes`.
- All sounds have been rebalanced and are all now subject to the togglesound config setting which is saved to your settings file. ( //op ts )
I hesitated to subject certain sounds to this setting since it is common to toggle sound off and never remember there are even sounds which can be very helpful since you can only look at one thing at a time, 
especially for multiboxers.
- Added a sound when toggling any of the toggle features off or on.
- Added a visual indicator for the state of the auto-targeting-system. If it is on 'OdyPro' will be displayed orange, if it is off 'OdyPro' will be displayed similar color as the background.

### **v3.3 → v3.4**
- Auto-targeting system now prioritizes mobs with the same name — smoother splits between players.  
- Commands are no longer case-sensitive.  
- Added **Auto-RP**: automatically use amplifiers in boss chambers. Toggle with `//op tarp`.  
- Introduced the **Auto-Weapon-Swap (AWS)** system:
  - Define per-job weaponmodes for slashing/piercing/blunt types.  
  - Example:
    ```text
    //op slashing sword  
    //op piercing shiningone  
    //op blunt maxentius
    ```
  - AWS intelligently selects the proper weaponmode for each damage type.
- Superwarp commands can now be relayed via OdyPro. (`//op port` works!)  
- Auto-targeting now avoids mobs using Invincible or Perfect Dodge, returning when effects wear off.  
- Fixed sub-commands for maps and resistances (`//op map size #` now works).  
- Expanded resistance/type data for all Sheol A & B NMs, pets, and halo mobs.  
- Added queueing commands: `//op gaol`, `//op sheola`, `//op sheolb`, `//op sheolc` and `//op enter`.  
- Added `missing_families` file — if it prints anything, send it to the dev.

### **v3.2**
- Auto-targeting priorities: NMs → Agon mobs → everything else.  
- Added height limit (3 yalms) to target scanning.  
- Optional Auto-RP for amplifier use in Sheol Gaol.  
- Fixed Gaol boss targeting errors.  
- Fixed targeting errors in Sheol B.  
- Added victory message & sound for Gaol wins.  
- Added Sheol A/B/C entry commands (`//op sheolb`, etc).  
- General bug fixes.

---

## Very well tested. No egregious stuff, just mega QoL - so play with confidence.

If you encounter an issue, please let me know.

---

## ⚙️ Installation

1. Extract to your Windower `addons` folder.  
   Folder structure should look like:
   Windower4/addons/OdyPro/OdyPro.lua 
   If installing new version, ensure it is a single
   OdyPro folder after extracting and just paste the 
   OdyPro folder into your addons folder and
   say yes to replace all files already present.
   This will maintain your xml config files.
   
2. Load the addon..
   lua load odypro
   



💬 Commands
| Command                                       | Action                                    |
| --------------------------------------------- | ----------------------------------------- |
| `//op togglesound` / `//op ts`                | Toggle sound effects (on by default).     |
| `//op reset`                                  | Reset your instance segment tracker.      |
| `//op reload` / `//op r`                      | Reload the addon.                         |
| `//op unstuck`                                | Reset player if stuck in menu-lock state. |
| `//op unstuck2`                               | Use if stuck at Veridical Conflux menu.   |
| `//op toggleautoamp` / `//op taa`             | Toggle auto-amp-grabbing.                 |
| `//op toggleautorp` / `//op tarp`             | Toggle auto-amp usage inside Gaol.        |
| `//op sheola` / `//op sheolb` / `//op sheolc` | Queue for Odyssey A / B / C.              |
| `//op gaol`                                   | Queue for Sheol Gaol.                     |
| `//op enter`                                  | Enter Odyssey after queueing.             |
| `//op amp #`                                  | Purchase `#` of amplifiers.               |
| `//op charge`                                 | Manually set RP charge to *On*.           |
| `//op uncharge`                               | Manually set RP charge to *Off*.          |
| `//op pickup`                                 | Manually start moglophone timer.          |
| `//op timerreset`                             | Manually set moglophone timer to *0:00*   |
| `//op show` / `//op hide`                     | Show or hide display UI.                  |
| `//op mogdisplay` / `//op md`                 | Toggle display of Ody moogle data.        |
| `//op help`                                   | Display in-game command help list.        |


🧠 Auto-Targeting System
| Command                                        | Action                                                          |
| ---------------------------------------------- | --------------------------------------------------------------- |
| `//op add [keyword]`                           | Add keyword to target scanner (e.g. `//op add Nostos Crab`).    |
| `//op target` / `//op t`                       | Scan & target nearest matching mob.                             |
| `//op autotarget` / `//op at`                  | Toggle auto-targeting system.                                   |
| `//op autotargetdistance [#]` / `//op atd [#]` | Set max scan distance (in yalms).                               |
| `//op autotargetsystem` / `//op ats`           | Toggle between V1 and V2 auto-targeting logic (V1 recommended). |


⚔️ Auto-Weapon-Swap System
| Command                | Action                               |
| ---------------------- | ------------------------------------ |
| `//op aws`             | Toggle the Auto-Weapon-Swap system.  |
| `//op slashing [mode]` | Save weaponmode for slashing damage. |
| `//op piercing [mode]` | Save weaponmode for piercing damage. |
| `//op blunt [mode]`    | Save weaponmode for blunt damage.    |


🗺️ Map & Resistance Settings
| Command                                   | Action                         |
| ----------------------------------------- | ------------------------------ |
| `//op toggle [segments/resistances/joke]` | Toggle corresponding info box. |
| `//op map`                                | Toggle the current floor map.  |
| `//op map center`                         | Center map on screen.          |
| `//op map size [#]`                       | Adjust map size.               |
| `//op map floor [#]`                      | Switch displayed floor.        |


OdyPro aims to make Odyssey runs smooth, efficient, and smart — with automation that enhances, not replaces, your gameplay.
🎉 Enjoy!

