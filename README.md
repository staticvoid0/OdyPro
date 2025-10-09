# OdysseyPro Version 3.4.1

                           //OdysseyPro
    Mog Segments Tracker; Odyssey targetinfo; Intuitive auto-targetting addon for Windower 4
    Tracks Mog Segments earned in Odyssey per run, total held and goal and displays it on screen
    with messages and sound effects in response to certain events; Displays enemies' physical and elemental Resistances
	as well as vulnerability to cruel joke. Provides maps for Sheol zones. Credit to Marian Arlt for the resistances 
	and maps. Solves the targetting problems inside Odyssey segfarms with an intuitive autotargetting system.
    More to come!

-- Latest changes v3.3 - v3.4
-- The auto-targeting system 1.0 now prioritizes mobs with the same name, making weapon swaps less frequent and neatly splitting mobs between players.
-- Commands are no longer cap-sensitive. This was unintended behavior and a fix that was neglected.
-- AutoRP feature! Automatically use amplifiers upon entering boss chambers, //op tarp to toggle auto-RP ; while the feature is off the notifications are cleaner now also. I left it on by default with a notice that you are about to amp so it can be stopped and toggled if needed.
-- Introducing the Autoweaponswap system! Inside Odyssey users that are running gearswap will now be able to set weaponmodes for each dmg type with the 
command for that type, once the weaponmode is set for a job, it will remain set for that specific job each time you switch to the job until you save over it
with another. i.e. //op slashing sword  ,  //op piercing shiningone  , //op blunt maxentius . When targeting mobs in the 3 seg zones the AWS system 
will use the resistances and types tables combined with decision making logic to determine if a swap is needed and if so, execute the swap to the designated weaponmode for that damage type.
-- Superwarp commands are now interpreted through OdyPro and relayed to Superwarp; feel free to type //op port instead of //od port :D
-- The Auto-targeting system now swaps off mobs inside sheol a, b and c with invincible or perfect dodge and swap back to them once it wears off.
-- The maps sub-commands have been fixed as well as the resistance box sub-commands; //op map size #  to change the map size.
-- Major updates to the resistances and types files to include all NMs in sheol A and B and their pets and halo mobs.
-- Queue for Odyssey with  //op gaol ; //op sheola ; //op sheolb ; //op sheolc
-- Enter Odyssey after having been queue'ed with //op enter.
-- Numerous bug-fixes.
-- I have provided a missing_families file. This file will come to you blank, if it ever prints anything - please get a copy of this file to me.

-- Latest changes v3.2
-- Autotargetting system now prioritizes NMs, then Agon mobs, then anything else.
-- Autotargetting system now imposes a height limiter of 3 yalms, this will be adjustable potentially in the future if deemed necessary.
-- Auto-RP feature to automatically use a moogle amplifier while in Sheol Gaol vs just getting a reminder. (This has proven particularly useful when doing the 6% without amplifier on and then afking.)
-- Fixed error when targetting Bosses inside Gaol after entering as party leader.
-- Fixed errors from targetting mobs in Sheol B. Sheol A will be handled next. (Adding all targets from B to the resistance tables in progress)
-- Added a congratulations message and sound when achieving Gaol wins.
-- Added commands to enter Sheol A, B and C (i.e. //op sheolb)
-- Bug fixes.

## Known Issues
-- Some of the NM pets from Sheol B could have mispelled names as the way they are written on BGWiki doesn't seem to be correct half the time. Send me your missing_families.txt file if it generates anything. Thank you!

This addon has been tested to work in the following cases:
Odyssey Segfarms, reading target info, tracking Mog Segments, auto pickup of amplifier/moglophone/moglophone II KIs and intelligent targetting system.

This addon has NOT been tested to work in the following cases:
-- There is doubtless debugging still to do.

If you experience an issue, let me know.


## Installation
After downloading, extract to your Windower addons folder. Make sure the folder is called OdysseyPro.  Your file structure should look like this:

    Windower4/addons/OdysseyPro/OdysseyPro.lua

Once the addon is in your Windower addons folder...

    lua load OdysseyPro

## Commands

-- //op togglesound / ts  ( toggles sound effects on and off. (On by default) )

-- //op reset  ( resets your Instance Segments )

-- //op reload or //op r  ( reloads the addon )

-- //op unstuck (resets player state if somehow gets stuck in menu-lock state)

-- //op unstuck2 (if somehow gets stuck in menu-lock state with Veridical Conflux instead of the ??? moogle.)

-- //op toggleautoamp / taa (toggle auto-amp-grabbing feature.)

-- //op toggleautorp / tarp (toggle auto-amp-usage feature inside Gaol.)

-- //op sheola (Queue to enter Sheol A)

-- //op sheolb (Queue to enter Sheol B)

-- //op sheolc (Queue to enter Sheol C)

-- //op gaol (Queue to enter Sheol Gaol)

-- //op enter (Enter Odyssey after having been queue'ed already.)

-- //op amp # (Buys the specified # of amplifier(s) )

-- //op charge (Manually changes your RP charge status to On.)

-- //op uncharge (Manually changes your RP charge status to Off.)

-- //op show ( makes the display visible. )

-- //op hide ( hides the display. )

-- //op mogdisplay / md ( toggles display of all ody moogle data outside of Rabao and Walk Of Echoes. )

-- //op help (displays this list of commands in the log ingame.)

Auto-targetting system commands.
------------------------------------------------------------------------------------------------------------------------------------------------------------ 

-- //op add [target keyword] :  i.e. Crab or Nostos Crab or Nostos (adds keyword to target scanner.)

-- //op target / t: (scans and targets nearest mob specified with the add command)

-- //op autotarget / at: (toggles auto-targetting system.)

-- //op autotargetdistance / atd # : (sets the max yalms for the auto-targetting system.)

-- //op autotargetsystem / ats : (toggles between V.1 and V.2 auto-targetting systems, currently v.2 is a dev. mode. use v.1)

Auto-weapon-swap system commands.
------------------------------------------------------------------------------------------------------------------------------------------------------------ 
-- //op aws : toggles the auto-weapon-swap system

-- //op slashing (weaponmode name): (saves a weaponmode name to slashing specific to the job you are on.)

-- //op piercing (weaponmode name): (saves a weaponmode name to piercing specific to the job you are on.)

-- //op blunt (weaponmode name): (saves a weaponmode name to blunt specific to the job you are on.)


Enemy Resistance and Element settings; Map settings
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- //op toggle [segments/resistances/joke] : (Shows/hides the info)

-- //op map : (Toggle the current floor's map)

-- //op map center : (Repositions the map to the center of the screen)

-- //op map size [size] : (Sets the map to the new [size].)

-- //op map floor [floor] : (Sets the map to reflect [floor].)

Enjoy!

