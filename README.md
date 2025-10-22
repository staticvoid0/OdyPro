# 🧭 OdyPro v3.4.2

### Mog Segment Tracker, Odyssey Target Info, and Intuitive Auto-Targeting Addon for Windower 4

> Handles Moglophone & Amplifier pickup, offers optional auto-amp use inside Gaol, displays RP charge status, and includes powerful auto-targeting and auto-weapon-swap systems.  
> Also shows target resistances and available maps for Sheol A, B, and C.

---

## ✨ Features

- Automatic Moglophone & Amplifier pickup  
- Optional **Auto-RP** (auto amplifier usage inside Gaol)  
- **Auto-targeting system** with mob-name prioritization and invincible/perfect-dodge awareness  
- **Auto-weapon-swap (AWS)** that hooks into Gearswap  
- Displays target resistances, mob types, and zone maps  
- Odyssey queueing and entry commands  
- Fully compatible with Superwarp commands  
- Numerous bug fixes and QoL improvements  

---

## 🧾 Changelog

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

