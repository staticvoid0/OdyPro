--[[ 
Copyright © 2025, Staticvoid
Credit to Marian Arlt for Resistances and maps.
All rights reserved.
Redistribution and use in source and binary forms, without
modification, is permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of OdyPro nor the
      names of its author may be used to endorse or promote products
      derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Staticvoid BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
 --[[
    Mog Segments Tracker; Odyssey targetinfo; Intuitive auto-targetting; Moglophone display / Timer display and alarm addon; Auto-moglophone & moglophone(II) / 3 Amplifier auto pickup addon for Windower 4
    Tracks Mog Segments earned in Odyssey per run, total held - total displays in alternate color if below a minimum threshold - displays it all on screen
    with messages and sound effects in response to certain events; Displays enemies' physical and elemental Resistances
	as well as vulnerability to cruel joke. Provides maps for Sheol zones. Credit to Marian Arlt for the resistances 
	and maps. Solves the targetting problems inside Odyssey segfarms with an intuitive autotargetting system.
	Now swaps off of and ignores targets with invincible or perfect dodge until it wears.
	Now targets the same mob name until there are no more within distance limit or target is swapped manually.
	Introduced the autoweaponswap system to match physical damage types of the targets autotargeted.
	I give this to you now, the community of the game that I have loved so much for so many years.
	*Future development - Chest opening / Izzat display.
	The code in this program was not written to be asthetically pleasing or for other developers to easily read and interpret the code for collaboration on the project. That said I will continue to develop it and reduce cost.
    More to come!
]] 

_addon.name = 'OdyPro'
_addon.author = 'Staticvoid'
_addon.version = '3.4.1'
_addon.commands = {'op', 'odypro'}

require('tables')
require('chat')
require('logger')
require('functions')
require('strings')
images = require('images')
packets = require('packets')
files = require('files')
config = require('config')
res = require('resources')
resistances = require('resistances')
types = require('types')
local texts = require('texts')

----------------------------------------------------------------------------------------
local addon_path = windower.addon_path
local player_name = windower.ffxi.get_info().logged_in and windower.ffxi.get_player().name
local current_character = nil
local screen_w = windower.get_windower_settings().ui_x_res
local screen_h = windower.get_windower_settings().ui_y_res
local sound_paths = {
    odyproload = addon_path .. 'data/waves/load.wav',
    outstanding = addon_path .. 'data/waves/30.wav',
    a_minor = addon_path .. 'data/waves/a_minor.wav',
	prelude = addon_path .. 'data/waves/prelude.wav',
	pickup = addon_path .. 'data/waves/pickup.wav',
	swap = addon_path .. 'data/waves/swap.wav',
	swapnrun = addon_path .. 'data/waves/swapnrun.wav',
	amplifier = addon_path .. 'data/waves/amplifier.wav',
	blank = addon_path .. 'data/waves/blank.wav',
	charged = addon_path .. 'data/waves/charged.wav',
	alert = addon_path .. 'data/waves/alert.wav',
	win = addon_path .. 'data/waves/win.wav',
	piercing = addon_path .. 'data/waves/piercing.wav',
	slashing = addon_path .. 'data/waves/slashing.wav',
	blunt = addon_path .. 'data/waves/blunt.wav',
}
local settings = config.load('data/settings_' .. player_name .. '.xml', {
    pos = {
        x = screen_w / 5,
        y = screen_h / 10000
    },
    bg = {
        alpha = 150,
        red = 0,
        green = 50,
        blue = 0
    },
    text = {
        size = 10,
        font = 'Comic Sans MS',
        red = 255,
        green = 255,
        blue = 255,
        alpha = 255,
        stroke = {
            alpha = 255,
            red = 15,
            green = 15,
            blue = 15,
            width = 2,
            padding = 1
        }
    },
    res_box = {
        pos = {
            x = windower.get_windower_settings().ui_x_res / 4,
            y = windower.get_windower_settings().ui_y_res / 2
        },
        bg = {
            alpha = 0
        },
        text = {
            size = 11,
            font = 'Comic Sans MS',
            stroke = {
                width = 2,
                alpha = 150
            }
        },
        padding = 10,
        flags = {
            bold = true
        },
        show = true,
        joke = true
    },
    map = {
        pos = {
            x = windower.get_windower_settings().ui_x_res / 2 - 256,
            y = windower.get_windower_settings().ui_y_res / 2 - 256
        },
        size = {
            width = 512,
            height = 512
        },
        texture = {
            fit = false,
            path = ''
        }
    },
	padding = 1,
	MogSegments_record = 0,
	ats_max_distance = 15,
	moglophone_start_time = 0,
    targets = L {'agon','nostos'},
    sets = {},
	toggle_sound = true,
	toggle_auto_amp = true,
	toggle_auto_rp = true,
	toggle_auto_weapon_swap = false,
	active_charge = false,
	ats_mode = 1,
    auto_ody_targetting = true,
    job_weapon_sets = {
    WAR = {slashing = 'sword',piercing = 'polearm',blunt = 'club',},MNK = {slashing = nil,piercing = nil,blunt = nil,},
    WHM = {slashing = nil,piercing = nil,blunt = nil,},BLM = {slashing = nil,piercing = nil,blunt = nil,},
    RDM = {slashing = nil,piercing = nil,blunt = nil,},THF = {slashing = nil,piercing = nil,blunt = nil,},
    PLD = {slashing = nil,piercing = nil,blunt = nil,},DRK = {slashing = nil,piercing = nil,blunt = nil,},
    BST = {slashing = nil,piercing = nil,blunt = nil,},BRD = {slashing = nil,piercing = nil,blunt = nil,},
    RNG = {slashing = nil,piercing = nil,blunt = nil,},SAM = {slashing = nil,piercing = nil,blunt = nil,},
    NIN = {slashing = nil,piercing = nil,blunt = nil,},DRG = {slashing = nil,piercing = nil,blunt = nil,},
    SMN = {slashing = nil,piercing = nil,blunt = nil,},BLU = {slashing = nil,piercing = nil,blunt = nil,},
    COR = {slashing = nil,piercing = nil,blunt = nil,},PUP = {slashing = nil,piercing = nil,blunt = nil,},
    DNC = {slashing = nil,piercing = nil,blunt = nil,},SCH = {slashing = nil,piercing = nil,blunt = nil,},
    GEO = {slashing = nil,piercing = nil,blunt = nil,},RUN = {slashing = nil,piercing = nil,blunt = nil,},
},
})

local display = texts.new('', settings, settings)
local res_box = texts.new('${type}\n${resistances}${crueljoke}', settings.res_box, settings)
local map = images.new(settings.map, settings)
local missing_log = files.new('missing_families.txt', true)
local translocators = {{1, 3, 5}, {1, 3, 6}, {1, 2}}
local instances = {{1019, 1020}, {1021, 1022}, {1023, 1024}}
local last_position = {x = 0, y = 0, z = 0}
local thresholds = {2500, 5000, 7500, 10000, 12000}
local entry_request = {}
local mob_immune_status = {} 
local amp_notifier = {}
local flags = {}
local timing = {}
local amp_tools = {}
local packets_to_send = T{}
local last_threshold = 0
local segs_message_id = 40012
local auto_grabbing_coroutine = nil
local new_moglophone_ii_count = 0
local inside_ody_moglophone_ii_count = 3
local moglophone_start_time = settings.moglophone_start_time or nil
local active_charge = settings.active_charge
local MogSegments_record = settings.MogSegments_record
local mogdisplay = true
local last_target = ''
local last_target_name = ''
local last_npc = nil
local last_menu = nil
local last_npc_index = nil
local zone_in_amount = nil

flags.segzone = nil
flags.sheolzone = nil
flags.in_Rabao_zone = false
flags.gaolzone = nil
flags.soundCurrentlyPlaying = false
flags.in_Odyssey_zone = false
flags.auto_grabbing_state = false
flags.auto_grabbing_in_progress = false
flags.auto_II_grabbing_state = false
flags.auto_II_grabbing_in_progress = false
flags.auto_amp_grabbing_in_progress = false
flags.auto_amp_grabbing_state = false
flags.manual_amp_grabbing_state = false
flags.alarmTriggered = false
flags.has_moglophone = true
flags.segments_loaded_fully = false
flags.inventory_fully_loaded = false
flags.busy_doing_stuff = false
flags.augmentation_techniques = false
flags.weapon_swap_triggered = nil
flags.is_standing_still = false
flags.zoning = false
flags.unable_to_grab = false
flags.action_cancellation = false
flags.face_target_triggered = false
flags.mobAlreadyTargetted = false
flags.resistance_intel = true
flags.targettingMessageDisplayed = nil

timing.last_disengage_time = os.time()
timing.last_move_time = os.clock()
timing.last_floorcheck_time = 0
timing.attempt_number = 0
timing.last_update_time = 0
timing.update_interval = 5
timing.spam_interval = 2
timing.last_KI_time = 0
timing.last_switch_time = 0
timing.cooldown_time = 2

amp_tools.amp_countdown = 0
amp_tools.amp_consumed = false
amp_tools.total_moogle_amps = nil
amp_tools.amps_needed = nil
amp_tools.amp_oi = nil
amp_tools.amp_oi_2 = nil

--Setting adjusters for those that have had settings files for this program since the early days--
ats_max_distance = settings.ats_max_distance or 30
if #settings.targets == 0 then
    settings.targets = L{'agon', 'nostos'}
    settings:save()
end
if not settings.toggle_auto_amp then
	settings.toggle_auto_amp = true
end
if settings.ats_mode == 2 then
	settings.ats_mode = 1
end
config.save(settings)
-----------------------------------------------------------------------------------------

local function has_immune_buff(mob)
    if mob_immune_status[mob.id] then
	log(("Skipping %s due to Invincible/Perfect Dodge."):format(mob.name))
        return true
	else
		return false
	end
end

local key_item_ids = {
    Moglophone = 3212,
    Moglophone_II = {3234, 3235, 3236}
}

local function has_key_item(key_item_id)
    local key_items = windower.ffxi.get_key_items()
    for _, id in ipairs(key_items) do
        if id == key_item_id then
            return true
        end
    end
    return false
end

local function count_moogle_amplifiers()
    local moogle_amplifier_count = 0
    local bags = {
        'inventory', 'safe', 'safe2', 'storage', 'locker',
        'satchel', 'sack', 'case', 'wardrobe', 'wardrobe2',
        'wardrobe3', 'wardrobe4', 'wardrobe5', 'wardrobe6',
        'wardrobe7', 'wardrobe8'
    }
    for _, bag_name in ipairs(bags) do
        local bag_items = windower.ffxi.get_items(bag_name)
        if bag_items and bag_items.max > 0 then 
            for _, item in ipairs(bag_items) do
                if item.id == 6608 then
                    moogle_amplifier_count = moogle_amplifier_count + item.count
                end
            end
        end
    end
    return moogle_amplifier_count
end

toggle_auto_amp = settings.toggle_auto_amp
local function toggleAutoAmp()
    toggle_auto_amp = not toggle_auto_amp
    if toggle_auto_amp then
        windower.add_to_chat(207, "Auto-amp pickup is now ON.")
    else
        windower.add_to_chat(207, "Auto-amp pickup is now OFF.")
    end
    settings.toggle_auto_amp = toggle_auto_amp
    config.save(settings)
end

toggle_auto_rp = settings.toggle_auto_rp
local function toggleAutoRP()
    toggle_auto_rp = not toggle_auto_rp
    if toggle_auto_rp then
        windower.add_to_chat(207, "Auto-amplifier RP is now ON.")
		inside_ody_moglophone_ii_count = 3
		amp_tools.amp_countdown = 0
    else
        windower.add_to_chat(207, "Auto-amplifier RP is now OFF.")
    end
    settings.toggle_auto_rp = toggle_auto_rp
    config.save(settings)
end

toggle_auto_weapon_swap = settings.toggle_auto_weapon_swap
local function toggleAutoWeaponSwap()
    toggle_auto_weapon_swap = not toggle_auto_weapon_swap
    if toggle_auto_weapon_swap then
        windower.add_to_chat(207, "Auto weapon swap is now ON.")
    else
        windower.add_to_chat(207, "Auto weapon swap is now OFF.")
    end
    settings.toggle_auto_weapon_swap = toggle_auto_weapon_swap
    config.save(settings)
end

toggle_sound = settings.toggle_sound
local function toggleSound()
    toggle_sound = not toggle_sound
    if toggle_sound then
        windower.add_to_chat(207, "Sound effects are now ON.")
    else
        windower.add_to_chat(207, "Sound effects are now OFF.")
    end
    settings.toggle_sound = toggle_sound
    config.save(settings)
end

-- Function to toggle SATS™
auto_ody_targetting = settings.auto_ody_targetting
local function auto_odytargetting()
    auto_ody_targetting = not auto_ody_targetting
    if auto_ody_targetting then
        windower.add_to_chat(207, "Auto-targetting systems online, max distance set to "..settings.ats_max_distance..'.')
        settings.auto_ody_targetting = true
    else
        windower.add_to_chat(207, "Auto-targetting systems offline.")
        settings.auto_ody_targetting = false
    end

    config.save(settings)
end

ats_mode = settings.ats_mode or 1
local function ats_mode_switch()
    if ats_mode == 1 then
        ats_mode = 2
        windower.add_to_chat(207, "Auto-targeting systems set to v.2.0; Prioritizing proximity > higher HP.")
    else
        ats_mode = 1
        windower.add_to_chat(207, "Auto-targeting systems set to v.1.0; Prioritizing same-name mobs > higher HP > proximity.")
    end

    settings.ats_mode = ats_mode
    config.save(settings)
end

function initialization()
    update_on_zone = true
    start_up = true
    previous_MogSegments = 0
    earned_MogSegments = 0
	newly_earned_MogSegments = 0
    initial_checkthrough = false
    coroutine.schedule(induct_data, 0.5)
end

function induct_data()
    if not windower.ffxi.get_info().logged_in then
        return
    end
    local packet = packets.new('outgoing', 0x115, {})
    packets.inject(packet)
end

windower.register_event('action',function (act)
	if not flags.segzone or not auto_ody_targetting then return end
	local doer = windower.ffxi.get_mob_by_id(act.actor_id)		
	local selfie = windower.ffxi.get_player()
	local class = act.category  
	local info = act.param 
	local peasants = act.targets
	local maintarget = windower.ffxi.get_mob_by_id(peasants[1].id)
	local valid_target = act.valid_target
	if doer and maintarget and (doer.is_npc or maintarget.name == selfie.name) and doer.name ~= selfie.name then 
		if class == 11 then
			if info then
				local ability = res.monster_abilities[info]
				if ability and (ability.en == "Invincible" or ability.en == "Perfect Dodge") then
					mob_immune_status[maintarget.id] = true
					target_nearest(settings.targets)
					coroutine.schedule(function()
						if mob_immune_status[maintarget.id] then
							mob_immune_status[maintarget.id] = false
						end
					end, 30)
				end
			end
		end
	end
end)

initialization()

windower.register_event('incoming chunk', function(id, data, org, modi, is_injected, is_blocked)
	local current_time
    -- Listens for Key_item packet while in rabao to update display for Moglophone / Moglophone II possession
	    if flags.in_Rabao_zone and not flags.zoning then
			current_time = os.clock()
            if id == 0x034 then
				local packetchecker = packets.parse('incoming', data)
				if packetchecker["NPC"] == 17789079 and packetchecker["NPC Index"] == 151 and packetchecker["_unknown1"] == 8 and packetchecker["Menu ID"] == 2005 then
					flags.busy_doing_stuff = true
				end
			elseif id == 0x055 and (current_time - timing.last_KI_time >= timing.spam_interval) and not flags.zoning then
                update_display()
				timing.last_KI_time = current_time
            end
        end
	if is_injected or id ~= 0x118 then
        return
    end
	current_time = os.clock()
	if current_time - timing.last_update_time < timing.update_interval then
		return
    end
    local p = packets.parse('incoming', org)
    local new_MogSegments = p["Mog Segments"]
	
    if start_up then
        previous_MogSegments = new_MogSegments
        start_up = false
    elseif new_MogSegments ~= previous_MogSegments then
		local player = windower.ffxi.get_player()
	    if player and player.name == current_character then 
            --earned_MogSegments = earned_MogSegments + (new_MogSegments - previous_MogSegments)
		else
		    earned_MogSegments = 0
		end
            previous_MogSegments = new_MogSegments
            update_display()
    end
	timing.last_update_time = current_time

end)

windower.register_event('incoming chunk', function(id, data, org, modi, is_injected, is_blocked)
    ---------------------------------------------------------------------------------------------
	if not flags.in_Odyssey_zone and not flags.in_Rabao_zone then return end
	local packet = packets.parse('incoming', data)
    if flags.in_Odyssey_zone then
        -- Parse the packet to log relevant information

        if id == 0x02A and not injected then
            --windower.add_to_chat(207,
                --string.format('Packet 0x02A - Message ID: %d, Param 1: %d, Param 2: %d', packet['Message ID'],
                    --packet['Param 1'], packet['Param 2']))
					
					
		------------------RP Charge tools--------------------------------
			if packet['Message ID'] == 40022 then
			   	if packet['Param 1'] == 6608 then
					active_charge = true
					windower.play_sound(sound_paths.charged)
					settings.active_charge = active_charge
					settings:save()
					log('RP Charge active.')
				end
			elseif packet['Message ID'] == 40020 then
					log('Someone else is on that job.')
				return true
			elseif packet['Message ID'] == 40016 then	
				if packet['Param 1'] > 5000 then
					active_charge = false
					settings.active_charge = active_charge
					settings:save()
					log('RP Charge expended.')
				end
			end
		----------------------------------------------------------------------
            if initial_checkthrough == true and not segs_message_id then
                induct_data()
            end
			if not flags.zoning and flags.segzone then
				-- Only process if Param 1 and Param 2 exist
				if packet['Param 2'] and packet['Param 1'] then
					if segs_message_id and packet['Message ID'] == segs_message_id and previous_MogSegments ~= packet['Param 2'] then
						-- Check to make sure we have captured the amount we started with.
							if zone_in_amount then
								previous_MogSegments = packet['Param 2']
								earned_MogSegments = packet['Param 2'] - zone_in_amount
							else
								zone_in_amount = previous_MogSegments
								previous_MogSegments = packet['Param 2']
								earned_MogSegments = packet['Param 2'] - zone_in_amount
							end
					elseif segs_message_id and packet['Message ID'] ~= segs_message_id and packet['Param 2'] == previous_MogSegments + packet['Param 1'] then
						-- This should indicate SE has added something to the currency 2 menu and we'll need to grab the new Message ID dynamically until this addon receives an update.
						segs_message_id = packet['Message ID']
					elseif not segs_message_id then
						-- If previous_MogSegments matches Param 2, this could indicate we're at the start
					
						if packet['Param 2'] == previous_MogSegments + packet['Param 1'] then
							segs_message_id = packet['Message ID'] -- Store the dynamic message ID
						else
							initial_checkthrough = true
						end
						-- Ensure segs_message_id is not nil before comparing
					end
					update_display()
				end
			end
        end
	elseif flags.in_Rabao_zone then
		if id == 0x02A and not injected then
			if packet['Message ID'] == 45041 then
				induct_data()
				log("Updating segments")
			end
		end
    end
end)

-- Function to process the queue
local function process_packet(packet)
	packets.inject(packet)
	------------Timing Control --------------------
	local packet_delayification = 1
	if flags.auto_grabbing_state then
		if #packets_to_send == 2 then
			packet_delayification = 2
		elseif #packets_to_send == 1 then
			packet_delayification = 1.5
		end
	elseif flags.auto_II_grabbing_state then
		if #packets_to_send == 4 then
			packet_delayification = 2
		elseif #packets_to_send == 3 then
			packet_delayification = 1
		elseif #packets_to_send == 2 then
			packet_delayification = 1.7
		elseif #packets_to_send == 1 then
			packet_delayification = 1
		end
	elseif flags.auto_amp_grabbing_state then
		if #packets_to_send == 4 then
			packet_delayification = 2
		elseif #packets_to_send == 3 then
			packet_delayification = 1
		elseif #packets_to_send == 2 then
			packet_delayification = 1.7
		elseif #packets_to_send == 1 then
			packet_delayification = 1
		end	
	end
	----------------------------------------------
	if not (flags.auto_grabbing_in_progress or flags.auto_II_grabbing_in_progress or flags.auto_amp_grabbing_in_progress) then return end
    if #packets_to_send > 0 then
        local next_packet = table.remove(packets_to_send, 1)
        coroutine.schedule(function() process_packet(next_packet) end, packet_delayification)
    else
        auto_grabbing_coroutine = nil
    end
---------------------------------------------------------------------
	if auto_grabbing_coroutine == nil then
		if flags.auto_amp_grabbing_state then
			local final_amp_count = count_moogle_amplifiers()
			if final_amp_count >= 3 and not flags.manual_amp_grabbing_state then   -- Now, was the operation a success ?
				windower.play_sound(sound_paths.amplifier)  -- Play my custom made sound if it was
				windower.send_command('get "Moogle Amplifier" all')
				log('Success')
				coroutine.sleep(0.5)
				update_display()
			elseif not flags.manual_amp_grabbing_state then
				log('Amplifier pickup failed.')
			end
			induct_data()
			amp_tools.amp_oi = nil
			amp_tools.amp_oi_2 = nil
			flags.auto_amp_grabbing_state = false
			flags.auto_amp_grabbing_in_progress = false
			flags.manual_amp_grabbing_state = false
		elseif flags.auto_grabbing_state then
			coroutine.sleep(2)
			local has_moglophone_now = has_key_item(key_item_ids.Moglophone)
			if has_moglophone_now then   -- Now, was the operation a success ?
				windower.play_sound(sound_paths.pickup)  -- Play my custom made sound if it was
				log('Success')
			else
			    if not flags.action_cancellation then
			        flags.unable_to_grab = true   -- if the attempt failed, and it wasn't because we cancelled it, we don't want to try again since this can mean the timer is off due to not having the addon loaded when picking up a moglophone.
				end
			end
			  -- signal the end of the procedure
			flags.auto_grabbing_state = false
			flags.auto_grabbing_in_progress = false
		elseif flags.auto_II_grabbing_state then
			coroutine.sleep(2)
			local moglophone_ii_held = 0
			for _, key_item_id in ipairs(key_item_ids.Moglophone_II) do
				if has_key_item(key_item_id) then
					moglophone_ii_held = moglophone_ii_held + 1
				end
			end
			if moglophone_ii_held == 3 then
				windower.play_sound(sound_paths.pickup)  -- Play my custom made sound if it was
				log('Success')
			end
			flags.auto_II_grabbing_state = false
			flags.auto_II_grabbing_in_progress = false
		end
	end
end
local function process_packet_queue()
    if #packets_to_send > 0 then
        local packet = table.remove(packets_to_send, 1)
        process_packet(packet)
    end
end

   -- WARNING THIS IS A VERY COMPLEX CALLBACK, IT IS NOT RECOMMENDED TO JACK AROUND WITH THIS.
windower.register_event('incoming chunk', function(id, data, org, modi, is_injected, is_blocked)	
	if--[[not player or ]] not flags.in_Rabao_zone or not (flags.auto_grabbing_state or flags.auto_II_grabbing_state or flags.auto_amp_grabbing_state or entry_request.poke or entry_request.enter_poke) then return end
	if not (flags.auto_grabbing_in_progress or flags.auto_II_grabbing_in_progress or flags.auto_amp_grabbing_in_progress or entry_request.poke or entry_request.enter_poke) then return end
	if id == 0x034 then
		local player = windower.ffxi.get_player()
		local p = packets.parse('incoming', data)
		local moogle_npc = p["NPC"] == 17789079
		local veridical_conflux = p["NPC"] == 17789076
		local clearedForTakeoff = p["Menu Parameters"]:unpack('b8', 1) == 0
		local proper_moogle_menu = p["Menu ID"] == 2001
		local entry_menu = p["Menu ID"] == 176
		
		if clearedForTakeoff and proper_moogle_menu then
			if moogle_npc and flags.auto_amp_grabbing_state and amp_tools.amp_oi and amp_tools.amp_oi_2 then
			
				if amp_tools.amp_oi ~= (amp_tools.amps_needed * 256) + 13 or amp_tools.amp_oi_2 ~= (amp_tools.amps_needed * 256) + 11 then log('Sum Ting Wong.') return end 
				
				last_npc = moogle_npc
				last_menu = 2001
				last_npc_index = 151
				table.insert(packets_to_send, packets.new('outgoing', 0x05B, {
					["Target"] = 17789079,
					["Option Index"] = 11,
					["_unknown1"] = 0,
					["Target Index"] = 151,
					["Automated Message"] = true,
					["_unknown2"] = 0,
					["Zone"] = 247,
					["Menu ID"] = 2001,
					delay = 2
				}))
				table.insert(packets_to_send, packets.new('outgoing', 0x05B, {
					["Target"] = 17789079,
					["Option Index"] = amp_tools.amp_oi,
					["_unknown1"] = 6608,
					["Target Index"] = 151,
					["Automated Message"] = true,
					["_unknown2"] = 0,
					["Zone"] = 247,
					["Menu ID"] = 2001,
					delay = 1
				}))
				table.insert(packets_to_send, packets.new('outgoing', 0x05B, {
					["Target"] = 17789079,
					["Option Index"] = amp_tools.amp_oi_2,
					["_unknown1"] = 6608,
					["Target Index"] = 151,
					["Automated Message"] = true,
					["_unknown2"] = 0,
					["Zone"] = 247,
					["Menu ID"] = 2001,
					delay = 1
				}))
				table.insert(packets_to_send, packets.new('outgoing', 0x05B, {
					["Target"]= 17789079,
					["Option Index"]= 0,
					["_unknown1"]= 16384,
					["Target Index"]= 151,
					["Automated Message"]=false,
					["_unknown2"] = 0,
					["Zone"] = 247,
					["Menu ID"] = 2001,
					delay = 2
				}))
				table.insert(packets_to_send, packets.new('outgoing', 0x016, {
					["Target Index"] = player.index,
					delay = 2.5
				}))

				if not auto_grabbing_coroutine then
					auto_grabbing_coroutine = coroutine.schedule(process_packet_queue, 0)
				end

				return true 
			elseif moogle_npc and flags.auto_grabbing_state then
				last_npc = moogle_npc
				last_menu = 2001
				last_npc_index = 151
				table.insert(packets_to_send, packets.new('outgoing', 0x05B, {
					["Target"] = 17789079,
					["Option Index"] = 1,
					["_unknown1"] = 0,
					["Target Index"] = 151,
					["Automated Message"] = true,
					["_unknown2"] = 0,
					["Zone"] = 247,
					["Menu ID"] = 2001,
					delay = 1
				}))
				table.insert(packets_to_send, packets.new('outgoing', 0x05B, {
					["Target"] = 17789079,
					["Option Index"] = 4,
					["_unknown1"] = 0,
					["Target Index"] = 151,
					["Automated Message"] = false,
					["_unknown2"] = 0,
					["Zone"] = 247,
					["Menu ID"] = 2001,
					delay = 2
				}))
				table.insert(packets_to_send, packets.new('outgoing', 0x016, {
					["Target Index"] = player.index,
					delay = 2.5
				}))

				if not auto_grabbing_coroutine then
					auto_grabbing_coroutine = coroutine.schedule(process_packet_queue, 0)
				end

				return true 
			elseif moogle_npc and flags.auto_II_grabbing_state then
					last_npc = moogle_npc
					last_menu = 2001
					last_npc_index = 151
					table.insert(packets_to_send, packets.new('outgoing', 0x05B, {
						["Target"] = 17789079,
						["Option Index"] = 11,
						["_unknown1"] = 0,
						["Target Index"] = 151,
						["Automated Message"] = true,
						["_unknown2"] = 0,
						["Zone"] = 247,
						["Menu ID"] = 2001,
						delay = 1
				}))
					if gaol_entry_keyitems == 2  then --- Only a single moglophone is needed
						table.insert(packets_to_send, packets.new('outgoing', 0x05B, {
							["Target"] = 17789079,
							["Option Index"] = 268,
							["_unknown1"] = 0,
							["Target Index"] = 151,
							["Automated Message"] = true,
							["_unknown2"] = 0,
							["Zone"] = 247,
							["Menu ID"] = 2001,
							delay = 2
						}))
						table.insert(packets_to_send, packets.new('outgoing', 0x05B, {
							["Target"] = 17789079,
							["Option Index"] = 267,
							["_unknown1"] = 0,
							["Target Index"] = 151,
							["Automated Message"] = true,
							["_unknown2"] = 0,
							["Zone"] = 247,
							["Menu ID"] = 2001,
							delay = 1.5
						}))
						table.insert(packets_to_send, packets.new('outgoing', 0x05B, {
							["Target"]= 17789079,
							["Option Index"]= 0,
							["_unknown1"]= 16384,
							["Target Index"]= 151,
							["Automated Message"]=false,
							["_unknown2"] = 0,
							["Zone"] = 247,
							["Menu ID"] = 2001,
							delay = 2
						}))
					elseif gaol_entry_keyitems == 1 then  --- Two moglophones are needed
						table.insert(packets_to_send, packets.new('outgoing', 0x05B, {
							["Target"] = 17789079,
							["Option Index"] = 524,
							["_unknown1"] = 0,
							["Target Index"] = 151,
							["Automated Message"] = true,
							["_unknown2"] = 0,
							["Zone"] = 247,
							["Menu ID"] = 2001,
							delay = 2
						}))
						table.insert(packets_to_send, packets.new('outgoing', 0x05B, {
							["Target"] = 17789079,
							["Option Index"] = 523,
							["_unknown1"] = 0,
							["Target Index"] = 151,
							["Automated Message"] = true,
							["_unknown2"] = 0,
							["Zone"] = 247,
							["Menu ID"] = 2001,
							delay = 1.5
						}))
						table.insert(packets_to_send, packets.new('outgoing', 0x05B, {
							["Target"]= 17789079,
							["Option Index"]= 0,
							["_unknown1"]= 16384,
							["Target Index"]= 151,
							["Automated Message"]=false,
							["_unknown2"] = 0,
							["Zone"] = 247,
							["Menu ID"] = 2001,
							delay = 2
						}))
					elseif gaol_entry_keyitems == 0 then   --- all 3 moglophones are needed
						table.insert(packets_to_send, packets.new('outgoing', 0x05B, {
							["Target"] = 17789079,
							["Option Index"] = 780,
							["_unknown1"] = 0,
							["Target Index"] = 151,
							["Automated Message"] = true,
							["_unknown2"] = 0,
							["Zone"] = 247,
							["Menu ID"] = 2001,
							delay = 1
						}))
						table.insert(packets_to_send, packets.new('outgoing', 0x05B, {
							["Target"] = 17789079,
							["Option Index"] = 779,
							["_unknown1"] = 0,
							["Target Index"] = 151,
							["Automated Message"] = true,
							["_unknown2"] = 0,
							["Zone"] = 247,
							["Menu ID"] = 2001,
							delay = 2.5
						}))
						table.insert(packets_to_send, packets.new('outgoing', 0x05B, {
							["Target"]= 17789079,
							["Option Index"]= 0,
							["_unknown1"]= 16384,
							["Target Index"]= 151,
							["Automated Message"]=false,
							["_unknown2"] = 0,
							["Zone"] = 247,
							["Menu ID"] = 2001,
							delay = 2
						}))
					end
					table.insert(packets_to_send, packets.new('outgoing', 0x016, {
						["Target Index"] = player.index,
						delay = 2.5
					}))

					if not auto_grabbing_coroutine then
						auto_grabbing_coroutine = coroutine.schedule(process_packet_queue, 0)
					end

			return true 
			end
		elseif veridical_conflux and entry_request.poke then
				entry_request.response = true
				last_npc = veridical_conflux
				last_menu = 172
				last_npc_index = 148
			return true
		elseif veridical_conflux and entry_request.enter_poke then
			if entry_menu then
				entry_request.enter_response = true
				last_npc = veridical_conflux
				last_menu = 176
				last_npc_index = 148
				return true
			else
				last_npc = veridical_conflux
				last_menu = 172
				last_npc_index = 148
				return false
			end
		elseif p["Menu Parameters"]:unpack('b8', 1) ~= 108 and p["Menu Parameters"]:unpack('b8', 1) ~= 100 then
			log('Congratulations on your win ! !')
			windower.play_sound(sound_paths.win)
			flags.busy_doing_stuff = true
			flags.augmentation_techniques = true
			coroutine.schedule(function() 
			flags.busy_doing_stuff = false 
			flags.augmentation_techniques = false
			end, 17)
			if flags.auto_II_grabbing_state then
				flags.auto_II_grabbing_state = false
				flags.auto_II_grabbing_in_progress = false
			elseif flags.auto_grabbing_state then
				flags.auto_grabbing_state = false
				flags.auto_grabbing_in_progress = false
			elseif flags.auto_amp_grabbing_state then
				flags.auto_amp_grabbing_state = false
				flags.auto_amp_grabbing_in_progress = false
				amp_tools.amp_oi = nil
				amp_tools.amp_oi_2 = nil
			end
		elseif p["Menu Parameters"]:unpack('b8', 1) == 108 or p["Menu Parameters"]:unpack('b8', 1) == 100 then
			log('You have unfinished business with the Odyssey Moogle. Handle that business.')
			flags.unable_to_grab = true
			flags.busy_doing_stuff = true
		end	
	end
end)

function general_release()
    windower.packets.inject_incoming(0x052, string.char(0,0,0,0,0,0,0,0))
    windower.packets.inject_incoming(0x052, string.char(0,0,0,0,1,0,0,0))
end
function release(menu_id)
    windower.packets.inject_incoming(0x052, 'ICHC':pack(0,2,2001,0))
    windower.packets.inject_incoming(0x052, string.char(0,0,0,0,1,0,0,0)) 
end

function moogle_resettinator(quiet)
	local player = windower.ffxi.get_player()
	if flags.auto_II_grabbing_state then
		flags.action_cancellation = true
		flags.auto_II_grabbing_state = false
		flags.auto_II_grabbing_in_progress = false
	elseif flags.auto_grabbing_state then
		flags.action_cancellation = true
		flags.auto_grabbing_state = false
		flags.auto_grabbing_in_progress = false
	elseif flags.auto_amp_grabbing_state then
		flags.action_cancellation = true
		flags.auto_amp_grabbing_state = false
		flags.auto_amp_grabbing_in_progress = false
		amp_tools.amp_oi = nil
		amp_tools.amp_oi_2 = nil
	end
	general_release()
	release(last_menu)
	local packet = packets.new('outgoing', 0x05B)
	packet["Target"]= last_npc
	packet["Option Index"]="0"
	packet["_unknown1"]="16384"
	packet["Target Index"]= last_npc_index
	packet["Automated Message"]=false
	packet["_unknown2"]=0
	packet["Zone"]=windower.ffxi.get_info()['zone']
	packet["Menu ID"]= last_menu
	packets.inject(packet)

	coroutine.sleep(0.5)
	
	local packet = packets.new('outgoing', 0x016, {["Target Index"] = player.index,})
	packets.inject(packet)
	flags.unable_to_grab = false
	last_npc = nil
	last_npc_index = nil
	last_menu = nil
end

function display_message(earned_MogSegments)
        if earned_MogSegments >= 14000 and last_threshold < 14000 then
            windower.add_to_chat(207, '14,000 Segments. ')
            windower.add_to_chat(121, player_name .. '\'s new title: "The greatest there ever was or will be." ')
            if not flags.soundCurrentlyPlaying and toggle_sound == true then
                flags.soundCurrentlyPlaying = true
                --windower.play_sound(sound_paths.a_minor)
                coroutine.sleep(3)
                flags.soundCurrentlyPlaying = false
            end
            last_threshold = 14000
        elseif earned_MogSegments >= 12000 and last_threshold < 12000 then
            windower.add_to_chat(207, '12,000 Segments. You\'re a SegC beast!')
            last_threshold = 12000
        elseif earned_MogSegments >= 7500 and last_threshold < 7500 then
            last_threshold = 7500
        elseif earned_MogSegments >= 5000 and last_threshold < 5000 then
            last_threshold = 5000
        elseif earned_MogSegments >= 2500 and last_threshold < 2500 then
            last_threshold = 2500
        end
end

-- Function to interpolate between colors
local function interpolate_color(start_color, end_color, fraction)
    local red = start_color.red + (end_color.red - start_color.red) * fraction
    local green = start_color.green + (end_color.green - start_color.green) * fraction
    local blue = start_color.blue + (end_color.blue - start_color.blue) * fraction
    return {
        red = red,
        green = green,
        blue = blue
    }
end

-- Function to determine the interpolated color based on MogSegments count
local function determine_color(MogSegments)
    local thresholds = {
	{value = 0,color = {red = 200,green = 80,blue = 0}}, -- Dark Orange
	{value = 2000,color = {red = 230,green = 110,blue = 0}}, -- Medium Orange
	{value = 4000,color = {red = 255,green = 125,blue = 0}}, -- Bright Orange
	{value = 6000,color = {red = 225,green = 150,blue = 0}}, -- Yellowish Orange
	{value = 8000,color = {red = 180,green = 190,blue = 0}}, -- Yellowish Green
	{value = 10000,color = {red = 130,green = 220,blue = 0}}, -- Yellow-Green
	{value = 12000,color = {red = 90,green = 240,blue = 0}}, -- Bright Lime Green
	{value = 14000,color = {red = 50,green = 255,blue = 50}} -- Purple
    }
    for i = 1, #thresholds - 1 do
        local current = thresholds[i]
        local next = thresholds[i + 1]

        if MogSegments >= current.value and MogSegments < next.value then
            local fraction = (MogSegments - current.value) / (next.value - current.value)
            return interpolate_color(current.color, next.color, fraction)
        end
    end
    -- If MogSegments goes further we maintain the last color (purple)
    return thresholds[#thresholds].color
end

local key_item_ids = {
    Moglophone = 3212, 
    Moglophone_II = {3234, 3235, 3236}
}

local function has_key_item(key_item_id)
    local key_items = windower.ffxi.get_key_items()
    for _, id in ipairs(key_items) do
        if id == key_item_id then
            return true
        end
    end
    return false
end

function format_with_commas(amount)
    local formatted = tostring(amount):reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return formatted:sub(1, 1) == "," and formatted:sub(2) or formatted
end

local function start_moglophone_timer()
    moglophone_start_time = os.time() -- Get the current real-world time
    settings.moglophone_start_time = moglophone_start_time -- Save the start time to settings file
	alarmDisabled = false  
	if alarmDisabled == false then flags.alarmTriggered = false end   
	settings.alarmDisabled = alarmDisabled  
    config.save(settings) 
	update_display()
end

local function load_timer_from_settings()
	moglophone_start_time = settings.moglophone_start_time
	alarmDisabled = settings.alarmDisabled
end

local function moglophone_alarm_handler()
	--local zone_identification = windower.ffxi.get_info().zone
	local has_moglophone_now = has_key_item(key_item_ids.Moglophone)
	if flags.has_moglophone == false and remaining_time < 1 and not alarmDisabled and not flags.in_Odyssey_zone and not flags.auto_grabbing_in_progress and not flags.zoning then
     flags.alarmTriggered = true 
		if not flags.auto_grabbing_in_progress and not has_moglophone_now then
		    windower.play_sound(sound_paths.prelude)
		    log('Time to pickup Moglophone; //op silence to disable alarm')
		    update_display()
		end

		coroutine.schedule(moglophone_alarm_handler, 180)
	else
	    return
	end
end
--Auto Amp Grabbinationeringizationator transfunctioner.
function auto_amp_grabber(amps_needed)	
    if flags.auto_amp_grabbing_state or flags.busy_doing_stuff then return end -- Filter double function calls
    local player = windower.ffxi.get_player()
	amp_tools.amp_oi = (amps_needed * 256) + 13
	amp_tools.amp_oi_2 = (amps_needed * 256) + 11
	if  (amps_needed == 1 and (amp_tools.amp_oi ~= 269 or amp_tools.amp_oi_2 ~= 267)) or 
		(amps_needed == 2 and (amp_tools.amp_oi ~= 525 or amp_tools.amp_oi_2 ~= 523)) or 
		(amps_needed == 3 and (amp_tools.amp_oi ~= 781 or amp_tools.amp_oi_2 ~= 779)) then 
		log('Invalid procedure, manual-amp grabber interfered; Cancelling') return
	end
    flags.auto_amp_grabbing_in_progress = true
	if (amp_tools.total_moogle_amps >= 3) or (player.name ~= current_character) or flags.is_standing_still == false then
	    log('Not able to auto-buy amplifier(s).')
			flags.auto_amp_grabbing_in_progress = false
			flags.auto_amp_grabbing_state = false
			amp_tools.amp_oi = nil
			amp_tools.amp_oi_2 = nil
	    return
	else 
	    log('Preparing to buy amplifier(s) in 5 seconds.')
	    coroutine.sleep(5)
		if flags.busy_doing_stuff then     -- If the menu was opened manually	
			flags.auto_amp_grabbing_in_progress = false
			flags.auto_amp_grabbing_state = false
			amp_tools.amp_oi = nil
			amp_tools.amp_oi_2 = nil
			log('Manual interaction detected, cancelling automated interaction.')
			return 
		end 
	end
	local me,target_id,moogle_distance
	target_id = 17789079
	moogle_distance = windower.ffxi.get_mob_by_id(target_id).distance
	if flags.auto_amp_grabbing_state then return end  -- Filter double function calls
	if flags.auto_amp_grabbing_in_progress and not flags.busy_doing_stuff then
		coroutine.schedule(function() 
			flags.auto_amp_grabbing_in_progress = false
			flags.auto_amp_grabbing_state = false
			amp_tools.amp_oi = nil
			amp_tools.amp_oi_2 = nil
		end, 17)
		if math.sqrt(moogle_distance) < 6 then
			windower.add_to_chat(200, 'Buying amplifier(s)...')
			flags.auto_amp_grabbing_state = true
			local packet = packets.new('outgoing', 0x01A, {
				["Target"]=17789079,
				["Target Index"]=151,
				["Category"]=0,
				["Param"]=0,
				["_unknown1"]=0})
			packets.inject(packet)
		else
			log('You are not standing within 6 yalms of the moogle, cannot buy amplifier(s).')
			flags.auto_amp_grabbing_in_progress = false
			flags.auto_amp_grabbing_state = false
			amp_tools.amp_oi = nil
			amp_tools.amp_oi_2 = nil
			return
		end
	else
	    log('Action cancelled.')
		flags.auto_amp_grabbing_in_progress = false
        flags.auto_amp_grabbing_state = false
		amp_tools.amp_oi = nil
		amp_tools.amp_oi_2 = nil
		return
	end
end

function manual_amp_grabber(amps_needed)	
    if flags.auto_amp_grabbing_state or flags.busy_doing_stuff then return end -- Filter double function calls
    local player = windower.ffxi.get_player()
	amp_tools.amp_oi = (amps_needed * 256) + 13
	amp_tools.amp_oi_2 = (amps_needed * 256) + 11
	if  (amps_needed == 1 and (amp_tools.amp_oi ~= 269 or amp_tools.amp_oi_2 ~= 267)) or 
		(amps_needed == 2 and (amp_tools.amp_oi ~= 525 or amp_tools.amp_oi_2 ~= 523)) or 
		(amps_needed == 3 and (amp_tools.amp_oi ~= 781 or amp_tools.amp_oi_2 ~= 779)) then 
		log('Invalid procedure, auto-amp grabber interfered; Cancelling') return 
	end
    flags.auto_amp_grabbing_in_progress = true
	local me,target_id,moogle_distance
	target_id = 17789079
	moogle_distance = windower.ffxi.get_mob_by_id(target_id).distance
	if flags.auto_amp_grabbing_state then return end  -- Filter double function calls
	if flags.auto_amp_grabbing_in_progress and not flags.busy_doing_stuff then
		if math.sqrt(moogle_distance) < 6 then
			windower.add_to_chat(200, 'Buying amplifier(s)...')
			flags.auto_amp_grabbing_state = true
			local packet = packets.new('outgoing', 0x01A, {
				["Target"]=17789079,
				["Target Index"]=151,
				["Category"]=0,
				["Param"]=0,
				["_unknown1"]=0})
			packets.inject(packet)
		else
			log('You are not standing within 6 yalms of the moogle, cannot buy amplifier(s).')
			flags.auto_amp_grabbing_in_progress = false
			flags.auto_amp_grabbing_state = false
			amp_tools.amp_oi = nil
			amp_tools.amp_oi_2 = nil
			return
		end
	else
	    log('Action cancelled.')
		flags.auto_amp_grabbing_in_progress = false
        flags.auto_amp_grabbing_state = false
		amp_tools.amp_oi = nil
		amp_tools.amp_oi_2 = nil
		return
	end
end

function auto_moglophone_grabber()	
    if flags.auto_grabbing_state or flags.busy_doing_stuff then return end -- Filter double function calls
    local player = windower.ffxi.get_player()
    local has_moglophone_now = has_key_item(key_item_ids.Moglophone)
    flags.auto_grabbing_in_progress = true
	if (remaining_time > 5) or (has_moglophone_now) or (player.name ~= current_character) or flags.is_standing_still == false then
	    log('Not able to pickup moglophone.')
	    return
	else 
	    log('Preparing to pickup moglophone in '..(remaining_time + 5)..' seconds.')
	    coroutine.sleep(remaining_time + 5)
		if flags.busy_doing_stuff then     -- If the menu was opened manually	
			flags.auto_grabbing_in_progress = false
			flags.auto_grabbing_state = false
			log('Manual interaction detected, cancelling automated interaction.')
			return 
		end 
	end
	local me,target_id,moogle_distance
	target_id = 17789079
	moogle_distance = windower.ffxi.get_mob_by_id(target_id).distance
	if flags.auto_grabbing_state then return end  -- Filter double function calls
	if flags.auto_grabbing_in_progress and not flags.busy_doing_stuff then
		coroutine.schedule(function() 
			flags.auto_grabbing_in_progress = false
			flags.auto_grabbing_state = false
		end, 17)
		if math.sqrt(moogle_distance) < 6 then
			windower.add_to_chat(200, 'Picking up moglophone...')
			flags.auto_grabbing_state = true
			flags.alarmTriggered = true
			local packet = packets.new('outgoing', 0x01A, {
				["Target"]=17789079,
				["Target Index"]=151,
				["Category"]=0,
				["Param"]=0,
				["_unknown1"]=0})
			packets.inject(packet)
		else
			log('You are not standing within 6 yalms of the moogle, cannot grab moglophone.')
			flags.auto_grabbing_in_progress = false
			flags.auto_grabbing_state = false
			return
		end
	else
	    log('Action cancelled.')
		flags.auto_grabbing_in_progress = false
        flags.auto_grabbing_state = false
		return
	end
end

function auto_moglophone_II_grabinator(_moglophone_2_count)
    if flags.auto_II_grabbing_state or flags.busy_doing_stuff then return end  -- Filter double function calls
    local previous_moglophone_2_count = _moglophone_2_count
    local player = windower.ffxi.get_player()

    flags.auto_II_grabbing_in_progress = true
	if flags.is_standing_still == false or (_moglophone_2_count == 3) or (player.name ~= current_character) then
	    log('Not able to pickup Moglophone II.')
	    return
	else
	    log('Preparing to pickup moglophone II(s) in 5 seconds.')
	    coroutine.sleep(5)
		if flags.busy_doing_stuff then     -- If the menu was opened manually	
			flags.auto_II_grabbing_state = false
			flags.auto_II_grabbing_in_progress = false 
			log('Manual interaction detected, cancelling automated interaction.')
			return 
		end 
	end
	local me,target_id,moogle_distance
	target_id = 17789079
	moogle_distance = windower.ffxi.get_mob_by_id(target_id).distance
	if flags.auto_II_grabbing_state then return end  -- Filter double function calls
	if flags.auto_II_grabbing_in_progress and not flags.busy_doing_stuff then	
		coroutine.schedule(function() 
			flags.auto_II_grabbing_state = false
			flags.auto_II_grabbing_in_progress = false
		end, 17)
		if math.sqrt(moogle_distance) < 6 then
			windower.add_to_chat(200, 'Picking up moglophone II(s)...')
			flags.auto_II_grabbing_state = true
			local packet = packets.new('outgoing', 0x01A, {
				["Target"]=17789079,
				["Target Index"]=151,
				["Category"]=0,
				["Param"]=0,
				["_unknown1"]=0})
			packets.inject(packet)
		else
			log('You are not standing within 6 yalms of the moogle, cannot grab moglophone II(s).')
			flags.auto_II_grabbing_state = false
			flags.auto_II_grabbing_in_progress = false
			return
		end
	else
		log('Action cancelled.')
		flags.auto_II_grabbing_state = false
		flags.auto_II_grabbing_in_progress = false
		return
	end
end

function in_lobby_check()
    local required_npcs = {"Porter Moogle", "Pilgrim Moogle", "Veridical Conflux"}
    for _, npc_name in ipairs(required_npcs) do
        local npc = windower.ffxi.get_mob_by_name(npc_name)
        if not npc then
            return false 
        end

        local player = windower.ffxi.get_mob_by_target('me')
        if not player then return false end

        local dx = npc.x - player.x
        local dy = npc.y - player.y
        local dz = npc.z - player.z
        local dist = math.sqrt(dx*dx + dy*dy + dz*dz)

        if dist > 35 then
            return false
        end
    end
    return true
end

local function use_amplifier()
	local attempt_sequence = "Nada"
	
	timing.attempt_number = timing.attempt_number + 1
	
	if timing.attempt_number == 2 then
		attempt_sequence = "First"
	elseif timing.attempt_number == 3 then
		attempt_sequence = "Second"
	elseif timing.attempt_number == 4 then
		attempt_sequence = "Third"
	elseif timing.attempt_number == 5 then
		attempt_sequence = "Fourth"
	elseif timing.attempt_number == 6 then
		attempt_sequence = "Fifth"
	elseif timing.attempt_number >= 7 then
		attempt_sequence = "Fifth+"
	end
	--if in_lobby_check() then auto_use_amp_in_progress = false return end
	log('You do not have an active Moogle Amplifier attempting to use; ('..attempt_sequence..' attempt.)\n//op tarp to toggle auto-rp')
	coroutine.sleep(2)
	windower.send_command('get "Moogle Amplifier" all')
	coroutine.sleep(3)
	windower.send_command('input /item "Moogle Amplifier" <me>')
	coroutine.schedule(function() auto_use_amp_in_progress = false end, 60)
end

local function amp_dinger()
	if amp_tools.amp_consumed or in_lobby_check() then auto_use_amp_in_progress = false  return end
	--auto_use_amp_in_progress = true
	coroutine.schedule(function() --[[auto_use_amp_in_progress = false ]] amp_dinger() end, 240)
	if toggle_sound then windower.play_sound(sound_paths.alert) end
	amp_tools.amp_countdown = 0
	log('You do not have an active Moogle Amplifier.\n//op tarp to toggle auto-rp')
end

function has_buff(buff_id)
    local buffs = windower.ffxi.get_player().buffs
    for _, buff in ipairs(buffs) do
        if buff == buff_id then return true end
    end
    return false
end

local function get_odypro_logo()
    local primary_color = {red = 255, green = 120, blue = 0} -- Main Orange Color
    local highlight_color = {red = 255, green = 120, blue = 0} -- Soft Gold Highlight

    -- Simulate a bold effect by stacking colors
    local logo_str = string.format(
        '\\cs(%d,%d,%d)Ody\\cr\\cs(%d,%d,%d)Pro\\cr',
        highlight_color.red, highlight_color.green, highlight_color.blue,
        primary_color.red, primary_color.green, primary_color.blue
    )
    
    return logo_str
end

local function update_moglophone_display()
	local real_time = os.time()
	local elapsed_time = real_time - settings.moglophone_start_time
	
	remaining_time = 72000 - elapsed_time

	if remaining_time < 0 then
		remaining_time = 0
	end

	local hours = math.floor(remaining_time / 3600)
	local minutes = math.floor((remaining_time % 3600) / 60)
	local seconds = math.floor(remaining_time % 60 )
	local color = {red = 210, green = 60, blue = 0} -- Red by default
	if remaining_time <= 80 * 60 then
		color = {red = 0, green = 255, blue = 0} -- Green when less than 1 hour
	elseif remaining_time <= 10 * 60 * 60 then
		color = {red = 255, green = 255, blue = 0} -- Yellow in the middle
	end

	local time_str = string.format('\\cs(%d,%d,%d)%02d:%02d\\cr', color.red, color.green, color.blue, hours, minutes)
	
	return time_str
end

-- Function to update the display text
function update_display()

	local time_str = update_moglophone_display()
    --------------------------------------------------------------------------------------------  
    
        local has_moglophone_now = has_key_item(key_item_ids.Moglophone)
	if remaining_time <= 0 then
        if not flags.has_moglophone and has_moglophone_now and flags.in_Rabao_zone == true then
            -- you didn't have the moglophone, and now you do - start the timer.
            start_moglophone_timer()
			coroutine.schedule(function() flags.unable_to_grab = false end, 2)
        end
	end
		
        flags.has_moglophone = has_moglophone_now
	-----------------------------------------------------------------------------------------
    local display_str = ""
    local green_color = {
        red = 0,
        green = 255,
        blue = 0
    }
	local red_color = { red = 255, green = 0, blue = 0 }
	
	-- Moogle Amplifier Display --------------------------------------------------------------------
        local moogle_amplifier_count = count_moogle_amplifiers()
		amp_tools.total_moogle_amps = moogle_amplifier_count
        local amplifier_color = moogle_amplifier_count >= 3 and green_color or red_color
        local amplifier_display = string.format(
            '\\cs(%d,%d,%d)%d\\cr',
            amplifier_color.red, amplifier_color.green, amplifier_color.blue, moogle_amplifier_count
        )
    -------------------------------------------------------------------------------------------------
    local moglophone_ii_count = 0
    local moglophone_symbol = flags.has_moglophone and
                                  string.format('\\cs(%d,%d,%d)√\\cr', green_color.red, green_color.green,
            green_color.blue) or ' ' -- Display count for Moglophone II (0, 1, 2, or 3)
    for _, key_item_id in ipairs(key_item_ids.Moglophone_II) do
        if has_key_item(key_item_id) then
            moglophone_ii_count = moglophone_ii_count + 1

        end
    end
	----------------------------Amp buff checker----------------------------------------------------
	if flags.in_Odyssey_zone then
	
		if not flags.segzone and flags.gaolzone then
			if amp_tools.total_moogle_amps >= 1 then
				if not has_buff(629) and not flags.zoning then
					if moglophone_ii_count ~= inside_ody_moglophone_ii_count or (timing.attempt_number >= 1 and timing.attempt_number <= 14) then   -- We need an amp since we're inside odyssey and we've just lost a moglophone II or we've already tried to use an amp and failed.
						amp_tools.amp_consumed = false
						amp_tools.amp_countdown = amp_tools.amp_countdown + 1
							if timing.attempt_number == 0 then
								timing.attempt_number = 1
							end
						if toggle_auto_rp then
							if not auto_use_amp_in_progress and amp_tools.amp_countdown >= 5 then
								if not in_lobby_check() then
									auto_use_amp_in_progress = true
									use_amplifier()
								end
							end
						elseif not toggle_auto_rp and not amp_tools.amp_consumed and amp_tools.amp_countdown >= 5 then
							if not in_lobby_check() then
								timing.attempt_number = 0
								amp_tools.amp_countdown = 0
								amp_dinger()
							end
						end
						inside_ody_moglophone_ii_count = moglophone_ii_count
					end	
					--if auto_use_amp_in_progress and in_lobby_check() then
						--auto_use_amp_in_progress = false
					--end
				else
					inside_ody_moglophone_ii_count = moglophone_ii_count
					amp_tools.amp_consumed = true
					timing.attempt_number = 0
					amp_tools.amp_countdown = 0
					auto_use_amp_in_progress = false
				end
			end
		elseif flags.zoning then 
			if in_lobby_check() then
				flags.gaolzone = true
				flags.segzone = false
			end
		end
	end
	
		if moglophone_ii_count ~= new_moglophone_ii_count then   -- Update Mog Segment count since we've spent mog segments on moglophone IIs
			induct_data()
			new_moglophone_ii_count = moglophone_ii_count
		end
		------------------------Odyssey-Moogle-Tools-----------------------------------------------
	if flags.in_Rabao_zone and not flags.zoning and not flags.busy_doing_stuff then		
		local me,target_id,moogle_distance
		target_id = 17789079
		-----------------------Auto-Amp-Grabbing Machinery---------------------------------------------
		if previous_MogSegments > 13500 and flags.segments_loaded_fully and flags.is_standing_still and flags.inventory_fully_loaded then
			local playerinv = windower.ffxi.get_items().inventory
			local freeslots = playerinv.max - playerinv.count
			if amp_tools.total_moogle_amps < 3 and toggle_auto_amp then
				if freeslots >= 1 then
					amp_tools.amps_needed = 3 - amp_tools.total_moogle_amps
					if not flags.auto_grabbing_in_progress and not flags.auto_II_grabbing_in_progress and not flags.auto_amp_grabbing_in_progress then
						local mob = windower.ffxi.get_mob_by_id(target_id)
						if mob and mob.distance then
							moogle_distance = math.sqrt(mob.distance)
							if moogle_distance < 6 then
								if flags.is_standing_still and not flags.busy_doing_stuff then
									flags.action_cancellation = false
									flags.auto_amp_grabbing_in_progress = true
									auto_amp_grabber(amp_tools.amps_needed)
								else
									log('Movement cancelled auto-amp-grabbing')
								end
							end
						end
					end
				else
				    log('You do not have an open inventory slot to auto-grab amplifier(s).')
				end
			end
		end
		------------------------Auto-Moglophone grabbing machinery---------------------------------
		if not flags.unable_to_grab and not flags.zoning then
			if not flags.auto_grabbing_in_progress and not flags.auto_II_grabbing_in_progress and not flags.auto_amp_grabbing_in_progress then
				if flags.has_moglophone == false and remaining_time < 1 and flags.in_Rabao_zone and not flags.auto_grabbing_in_progress and not flags.zoning then
					mob = windower.ffxi.get_mob_by_id(target_id)
					if mob and mob.distance then
						moogle_distance = math.sqrt(mob.distance)
						if moogle_distance < 6 then
							if flags.is_standing_still and not flags.busy_doing_stuff then
								flags.action_cancellation = false
								flags.auto_grabbing_in_progress = true
								auto_moglophone_grabber()
							end
						end
					end
				end
			end
		end
		-------------------------------------------------------------------------------------------
		------------------------Auto-moglophone II Grabbing machinery------------------------------
		gaol_entry_keyitems = moglophone_ii_count
		if not flags.zoning then
			if not flags.auto_grabbing_in_progress and not flags.auto_II_grabbing_in_progress and not flags.auto_amp_grabbing_in_progress then
				if flags.in_Rabao_zone and flags.is_standing_still and
				   ((gaol_entry_keyitems == 2 and previous_MogSegments >= 3000) or
					(gaol_entry_keyitems == 1 and previous_MogSegments >= 6000) or
					(gaol_entry_keyitems == 0 and previous_MogSegments >= 9000)) then
					
					mob = windower.ffxi.get_mob_by_id(target_id)
					if mob and mob.distance then
						moogle_distance = math.sqrt(mob.distance)
						if moogle_distance < 6 and not flags.busy_doing_stuff then
							if not flags.auto_II_grabbing_in_progress then
								flags.action_cancellation = false
								flags.auto_II_grabbing_in_progress = true
								auto_moglophone_II_grabinator(gaol_entry_keyitems)
							end
						end
					end
				end
			end
		end
	end
	---------------------------------------------------------------------------------------------		
    local moglophone_ii_display = string.format('\\cs(%d,%d,%d)%d\\cr', green_color.red, green_color.green,
        green_color.blue, moglophone_ii_count)
		
	local charge_indicator = active_charge and "\\cs(0,255,0)√\\cr" or " "
	
    if flags.in_Rabao_zone or flags.in_Odyssey_zone or mogdisplay then
        display_str = display_str .. "| Moglophone: " .. moglophone_symbol .. " | Moglophone II: " .. moglophone_ii_display .. " | Amplifier: " .. amplifier_display .. " | Charge: " .. charge_indicator
    end
	--prevent RP exchanges from adding to instance segments.
	if flags.in_Rabao_zone and not flags.zoning then
		earned_MogSegments = 0
	end
	-----------------------------Magic------------------------------------------------
	if earned_MogSegments ~= 0 and earned_MogSegments < newly_earned_MogSegments then
	   earned_MogSegments = newly_earned_MogSegments                   
	else                                                               
		newly_earned_MogSegments = earned_MogSegments                  
	end   
    if earned_MogSegments < 0 then
        earned_MogSegments = 0
    end	
	----------------------------Magic--------------------------------------------------
	
    -- Determine the color for earned_MogSegments based on its value

    local color = determine_color(earned_MogSegments)
    local minimumSegThreshold = 100000
    local previous_color = {
        red = 255,
        green = 255,
        blue = 255
    } -- Default white

    if previous_MogSegments < minimumSegThreshold then
        previous_color = {
            red = 210,
            green = 60,
            blue = 0
        } -- Red if below threshold
    end
    -- local moglophone_display = get_moglophone_display()
	local odypro_logo = get_odypro_logo()
    -- Format the text with earned_MogSegments in a specific color
    local text = string.format(
        ' %s  | %s | \\cs(%d,%d,%d)Mog Segments: %s\\cr | Instance Record: %s |  \\cs(%d,%d,%d)Instance Segments: %s\\cr\\cr %s',
        odypro_logo, time_str, previous_color.red, previous_color.green, previous_color.blue,
        format_with_commas(previous_MogSegments), format_with_commas(MogSegments_record), color.red, color.green,
        color.blue, format_with_commas(earned_MogSegments), display_str)
    -------------  ***    Fonts   Verdana   Impact    Lucida Console    Verdana and impact were close 2nd and 3rd
    -- white
    display:color(255, 255, 255)

    -- Update display with formatted text
    display:text(text)

    -- Display message based on earned_MogSegments (if necessary)
    display_message(earned_MogSegments)

end

local function odyssey_queue(zoneChoice)
	local can_enter_segs = has_key_item(key_item_ids.Moglophone)
	local SheolInstance
	if flags.busy_doing_stuff then log('Finish manual menu interaction') return end
	if flags.auto_grabbing_in_progress or flags.auto_II_grabbing_in_progress or flags.auto_amp_grabbing_in_progress then log('Automated interaction in progress, please wait until this has finished.') return end
	if zoneChoice == 1 then
		SheolInstance = "Sheol A"
	elseif zoneChoice == 2 then
		SheolInstance = "Sheol B"
	elseif zoneChoice == 3 then
		SheolInstance = "Sheol C"
	elseif zoneChoice == 4 then
		SheolInstance = "Sheol Gaol"
	end
	if (gaol_entry_keyitems == 3 and zoneChoice == 4) or ( can_enter_segs and (zoneChoice >= 1 and zoneChoice <= 3)) then	
				entry_request.poke = true
				local me,target_id,conflux_distance
				target_id = 17789076
				conflux_distance = windower.ffxi.get_mob_by_id(target_id).distance
		if math.sqrt(conflux_distance) < 6 then
				windower.add_to_chat(200, 'Requesting '..SheolInstance..' entry...')
					local packet = packets.new('outgoing', 0x01A, {
					["Target"]=17789076,
					["Target Index"]=148,
					["Category"]=0,
					["Param"]=0,
					["_unknown1"]=0})
				packets.inject(packet)
			coroutine.sleep(1.5)
			if entry_request.response then
					local packet = packets.new('outgoing', 0x05B)
					packet["Target"]=17789076
					packet["Option Index"]= zoneChoice
					packet["_unknown1"]= 0
					packet["Target Index"]= 148
					packet["Automated Message"]=true
					packet["_unknown2"]=0
					packet["Zone"]=windower.ffxi.get_info()['zone']
					packet["Menu ID"]=172
				packets.inject(packet)
			coroutine.sleep(0.5)
					local packet = packets.new('outgoing', 0x05B)
					packet["Target"]=17789076
					packet["Option Index"]= zoneChoice
					packet["_unknown1"]= 0
					packet["Target Index"]= 148
					packet["Automated Message"]=false
					packet["_unknown2"]=0
					packet["Zone"]=windower.ffxi.get_info()['zone']
					packet["Menu ID"]=172
				packets.inject(packet)
			coroutine.sleep(1)
			else
				log('Unable to request entry.')
			end
		else
			log('You are not within 6 yalms of the conflux')
		end
			entry_request = {}
	elseif (zoneChoice >= 1 and zoneChoice <= 3) and not can_enter_segs then
		log('You do not have a moglophone to enter Seg C with.')
	elseif (gaol_entry_keyitems ~= 3 and zoneChoice == 4) then
		log('You have '..gaol_entry_keyitems..' Moglophone IIs unable to enter.')
	end
end

local function odyssey_enter(zoneChoice)
	if flags.busy_doing_stuff then log('Finish manual menu interaction') return end
	if flags.auto_grabbing_in_progress or flags.auto_II_grabbing_in_progress or flags.auto_amp_grabbing_in_progress then log('Automated interaction in progress, please wait until this has finished.') return end
		entry_request.enter_poke = true
		local me,target_id,conflux_distance
		target_id = 17789076
		conflux_distance = windower.ffxi.get_mob_by_id(target_id).distance
	if math.sqrt(conflux_distance) < 6 then
		windower.add_to_chat(200, 'Now entering Odyssey...')
				local packet = packets.new('outgoing', 0x01A, {
				["Target"]=17789076,
				["Target Index"]=148,
				["Category"]=0,
				["Param"]=0,
				["_unknown1"]=0})
			packets.inject(packet)
		coroutine.sleep(1.5)
		if entry_request.enter_response then
				local packet = packets.new('outgoing', 0x05B)
				packet["Target"]=17789076
				packet["Option Index"]= 1
				packet["_unknown1"]= 0
				packet["Target Index"]= 148
				packet["Automated Message"]=true
				packet["_unknown2"]=0
				packet["Zone"]=windower.ffxi.get_info()['zone']
				packet["Menu ID"]=176
			packets.inject(packet)
		coroutine.sleep(3)
				local packet = packets.new('outgoing', 0x05B)
				packet["Target"]=17789076
				packet["Option Index"]= 2
				packet["_unknown1"]= 0
				packet["Target Index"]= 148
				packet["Automated Message"]=false
				packet["_unknown2"]=0
				packet["Zone"]=windower.ffxi.get_info()['zone']
				packet["Menu ID"]=176
			packets.inject(packet)
		coroutine.sleep(1)
		else
			log('Unable to enter, queue first with //op sheola  //op sheolb  //op sheolc  or  //op gaol ; Then use this command to enter Odyssey.')
		end
	else
		log('You are not within 6 yalms of the conflux')
	end
	entry_request = {}
end

windower.register_event('login', function()
    -- Check the player name or ID on login
    local player = windower.ffxi.get_player()
    if player and player.name ~= current_character then
	    coroutine.sleep(2)
	    induct_data()
		coroutine.sleep(3)
        print('Character switched from '..current_character..' to '..player.name)
		coroutine.sleep(5)
		current_character = player.name
		--windower.send_command('op r')
        --current_character = player.name
    end
end)

windower.register_event('addon command', function(...)
    local args = {...}
    cmd = command and command:lower()
    local arg = {...}
	
    args[1] = args[1]:lower()
    if args[2] then
        args[2] = args[2]:lower()
    end
    if args[3] then
        args[3] = args[3]:lower()
    end
	local current_main_job = windower.ffxi.get_player().main_job
    if args[1] == 'toggle' then
        if arg[2] == 'resistances' then
            local target = windower.ffxi.get_mob_by_target('t')
            if settings.res_box.show then
                res_box:hide()
                notice("Resistances will now be hidden.")
            elseif flags.in_Odyssey_zone and target and
                target.spawn_type == 16 and target.valid_target then
                res_box:show()
            end
            if not settings.res_box.show then
                notice("Resistances will now be shown.")
            end
            settings.res_box.show = not settings.res_box.show
            settings:save()

        elseif arg[2] == 'joke' then
            if settings.res_box.joke then
                notice("Cruel Joke compatability will now be hidden.")
            else
                notice("Cruel Joke compatability will now be shown.")
            end
            settings.res_box.joke = not settings.res_box.joke
            settings:save()
            last_target = ''
        else
            error("Accepts either 'segments' or 'resistances'.")
        end

    elseif args[1] == 'bg' then
        arg[2] = tonumber(arg[2])
        if arg[1] == 'all' or arg[1] == 'resistances' then
            if not arg[2] or arg[2] < 0 or arg[2] > 255 then
                error("Transparency value must be between 0 and 255.")
            else
                if arg[1] == 'all' or arg[1] == 'resistances' then
                    settings.res_box.bg.alpha = arg[2]
                    settings:save()
                    res_box:bg_alpha(arg[2])
                end
            end
        else
            error("Accepts either 'resistances' or 'all'.")
        end
    elseif args[1] == 'map' then
        if not flags.sheolzone then
            error("Must be in either Sheol A, B or C to interact with maps.")
        elseif arg[2] == 'center' then
            map:pos_x(windower.get_windower_settings().ui_x_res / 2 - settings.map.size.width / 2)
            map:pos_y(windower.get_windower_settings().ui_y_res / 2 - settings.map.size.height / 2)
        elseif arg[2] == 'size' then
            if not tonumber(arg[3]) then
                error("[size] must be an integer.")
            else
                settings.map.size.height = tonumber(arg[3])
                settings.map.size.width = tonumber(arg[3])
                map:size(settings.map.size.width, settings.map.size.height)
                settings:save()
                config.reload(settings)
            end
        elseif arg[2] == 'floor' then
            if not tonumber(arg[3]) then
                error("[floor] must be an integer fitting this Sheol.")
            else
                map:path(windower.addon_path .. 'maps/' .. flags.sheolzone .. '-' .. arg[3] .. '.png')
            end
        else
            if map and map:visible() then
                map:hide()
            else
                map:show()
            end
        end
    elseif args[1] == 'reset' then
        earned_MogSegments = 0
        update_display()
    elseif args[1] == 'reload' or args[1] == 'r' then
        windower.send_command('lua r OdyPro')
    elseif args[1] == 'togglesound' or args[1] == 'ts' then
        toggleSound()
    elseif args[1] == 'toggleautoamp' or args[1] == 'taa' then
        toggleAutoAmp()
    elseif args[1] == 'toggleautorp' or args[1] == 'tarp' then
        toggleAutoRP()
    elseif args[1] == 'autoweaponswap' or args[1] == 'aws' then
		toggleAutoWeaponSwap()
    elseif args[1] == 'show' then
        display:show()
    elseif args[1] == 'hide' then
        display:hide()
        --------------------------------------
    elseif args[1] == 'add' and args[2] then
        local target = args[2]
        if target == 'nil' then
            return
        end
        target = target:lower()
        if not settings.targets:contains(target) then
            settings.targets:append(target)
            settings.targets:sort()
            settings:save()
        end
        windower.add_to_chat(204, target .. ' added to mob scanner')
        --------------------------------------------------------------			
    elseif args[1] == 'target' or args[1] == 't' then
        target_nearest(settings.targets)
        --windower.add_to_chat(204, 'Targeting ..')
        ----------------------------------------
    elseif args[1] == 'autotarget' or args[1] == 'at' then
        auto_odytargetting()
    elseif args[1] == 'autotargetsystem' or args[1] == 'ats' then
        ats_mode_switch()
--------------------------------------------------------- 
    elseif args[1] == 'autotargetdistance' or args[1] == 'atd' then
        ats_max_distance = tonumber(arg[2])
		settings.ats_max_distance = ats_max_distance 
		config.save(settings)
		log('Auto-targetting systems max distance set to '..settings.ats_max_distance..'.')
	elseif args[1] == 'pickup' then
		alarmDisable = false
		flags.alarmTriggered = false
        start_moglophone_timer()
		update_display()
        --------------------------------------------
	elseif args[1] == 'amp' then
		local purchase_num = args[2]
		local playerinv = windower.ffxi.get_items().inventory
		local freeslots = playerinv.max - playerinv.count

		if flags.in_Rabao_zone and not flags.zoning then
            if freeslots >= 1 then		
				if amp_tools.total_moogle_amps >= 3 or not toggle_auto_amp then
					if not flags.auto_amp_grabbing_state or flags.auto_amp_grabbing_in_progress then
						amp_tools.amps_needed = purchase_num
						flags.manual_amp_grabbing_state = true
						flags.auto_amp_grabbing_in_progress = true
						manual_amp_grabber(purchase_num)
					else
						log('Auto-amp-grabbing in progress, action cancelled.')
					end
				else
					log('You have < 3 Moogle Amplifiers and your Auto-amp-grabbing is toggled on, please wait at the moogle or //op taa to continue.')
				end
			else
				log('You have no inventory space.')
			end
		else
			log('You are not in Rabao')
		end
		---------------------------------------------
	elseif args[1] == 'silence' then
		windower.play_sound(sound_paths.blank)
		alarmDisabled = true
        --------------------------------------------
	elseif args[1] == 'timerreset' then
		moglophone_start_time = moglophone_start_time - remaining_time + (remaining_time * .001)  -- set the timer to 1min remaining and turn off alarm switches for alarm test n config.
		settings.moglophone_start_time = moglophone_start_time
		alarmDisable = false
		flags.alarmTriggered = false
		config.save(settings)
		update_display()
	elseif args[1] == 'mogdisplay' or args[1] == 'md' then
		if mogdisplay then
		    mogdisplay = false
		elseif not mogdisplay then
			mogdisplay = true
		end
		update_display()
        --------------------------------------------
	elseif args[1] == 'charge' then
		active_charge = true
		windower.play_sound(sound_paths.charged)
		settings.active_charge = active_charge
		settings:save()
		log('RP Charge active.')
	elseif args[1] == 'uncharge' then
		active_charge = false
		settings.active_charge = active_charge
		settings:save()
		log('RP Charge expended.')
	elseif args[1] == 'unstuck' then
		if not (last_npc and last_menu and last_npc_index) then
			last_npc = 17789079
			last_menu = 2001
			last_npc_index = 151
			log('If menulock is not cleared after a few seconds, use //op unstuck2 ')
		end
		moogle_resettinator(true)
		--------------------------------------------
	elseif args[1] == 'unstuck2' then
		if not last_npc then
			last_npc = 17789076
			last_menu = 172
			last_npc_index = 148
		end
		moogle_resettinator(true)
		log('Attempting to clear veridical conflux menu lock. unstuck2 should only be used if op gaol or op sheol was used last, otherwise use op unstuck .')
		--------------------------
	elseif args[1] == 'sheola' then 
		odyssey_queue(1)
	elseif args[1] == 'sheolb' then 
		odyssey_queue(2)
	elseif args[1] == 'sheolc' then 
		odyssey_queue(3)
	elseif args[1] == 'gaol' then 
		odyssey_queue(4)
	elseif args[1] == 'enter' then 
		odyssey_enter(4)
	elseif args[1] == 'leave' then 
		windower.send_command('input /item "Moglophone II" <me>')
	elseif args[1] == 'port' then   -- since the superwarp command is pretty close the the OdyPro command prefix i'll just have OdyPro translate these commands.
		windower.send_command('od port')
	elseif args[1] == 'p' and args[2] == 'port' then 
		windower.send_command('od p port')
	elseif args[1] == 'exit' then 
		windower.send_command('od exit')
	elseif args[1] == 'p' and args[2] == 'exit' then 
		windower.send_command('od p exit')
	elseif args[1] == '1' then 
		windower.send_command('od 1')
	elseif args[1] == 'p' and args[2] == '1' then 
		windower.send_command('od p 1')
	elseif args[1] == '2' then 
		windower.send_command('od 2')
	elseif args[1] == 'p' and args[2] == '2' then 
		windower.send_command('od p 2')
	elseif args[1] == '3' then 
		windower.send_command('od 3')
	elseif args[1] == 'p' and args[2] == '3' then 
		windower.send_command('od p 3')
	elseif args[1] == 'test' then 
		print(flags.sheolzone)
    elseif args[1]  == 'slashing' or args[1] == 'piercing' or args[1] == 'blunt' then
        if args[2] == '' then
            windower.add_to_chat(123, '[OdyPro] Current ' .. args[1] .. ' set: ' .. tostring(settings.job_weapon_sets[current_main_job][args[1]]))
        else
            settings.job_weapon_sets[current_main_job][args[1]] = args[2]
            config.save(settings)
            windower.add_to_chat(122, '[OdyPro] Saved ' .. args[1] .. ' weapon set to ' .. args[2])
        end
    elseif args[1] == 'help' then
        windower.add_to_chat(207, 'OdyPro help:')
        windower.add_to_chat(206, '-------------C O M M A N D  L I S T-------------')
        windower.add_to_chat(207, '//op reset, togglesound or ts, toggleautoamp or taa, tarp, aws, slashing (weaponmode name), piercing (weaponmode name), blunt (weaponmode name), amp #, show, hide, mogdisplay or md, charge, uncharge, gaol, reload or r, unstuck, unstuck2, add [target], target or t , autotarget or at , autotargetdistance or atd # , ats,  silence , toggle [resistances/joke] , bg [resistances/all] , map, map center, map size [size], map floor [floor]')
        windower.add_to_chat(206, '-----C O M M A N D S   E X P L A N A T I O N----')
        windower.add_to_chat(207, '- reset : sets the Instance Mog Segments to 0 and updates the display.')
        windower.add_to_chat(207, '- togglesound / ts: toggle sound effects off and on (on by default).')
		windower.add_to_chat(207, '- toggleautoamp / taa: toggle auto-amp-grabbing off and on (on by default).')
		windower.add_to_chat(207, '- tarp / toggleautorp : toggle auto-RP-mode, automatically use amplifiers while inside Gaol. (on by default).')
		windower.add_to_chat(207, '- amp #: Buys the designated # of moogle amplifiers')
		windower.add_to_chat(207, '- charge: Manually changes your RP charge status to active.')
		windower.add_to_chat(207, '- uncharge: Manually changes your RP charge status to inactive.')
		windower.add_to_chat(207, '- sheola: Queue to enter Sheol A.')
		windower.add_to_chat(207, '- sheolb: Queue to enter Sheol B.')
		windower.add_to_chat(207, '- sheolc: Queue to enter Sheol C.')
		windower.add_to_chat(207, '- gaol: Queue to enter Sheol Gaol.')
		windower.add_to_chat(207, '- enter: Enter Odyssey after your number is called.')
        windower.add_to_chat(207, '- show: makes the display visible (default).')
        windower.add_to_chat(207, '- hide: hides the display box')
        windower.add_to_chat(207, '- mogdisplay / md: toggles display of all ody moogle data outside of Rabao and Walk Of Echoes.')
        windower.add_to_chat(207, '- reload / r: reloads addon.')
		windower.add_to_chat(207, '- unstuck : cancels menu soft-lock state if this happens.')
		windower.add_to_chat(207, '- unstuck2 : cancels menu soft-lock state with veridical conflux; should only be used if unstuck does not clear menu-lock.')
		------------------------A U T O - T A R G E T T I N G   S Y S.  C O M M A N D S--------------------------------------------
		windower.add_to_chat(206, '------A U T O - T A R G E T T I N G   S Y S.  ------')
        windower.add_to_chat(207, '- add [target keyword] i.e. Crab or Nostos Crab or Nostos adds keyword to target scanner.')
        windower.add_to_chat(207, '- target / t: scans and targets nearest mob specified with the add command')
        windower.add_to_chat(207, '- autotarget / at: toggles auto-targetting system.')
		windower.add_to_chat(207, '- autotargetdistance / atd # : sets the max yalms for the auto-targetting system.')
		windower.add_to_chat(207, '- autotargetsystem / ats : toggles between V.1 and V.2 auto-targetting systems (V1 is best all around atm.)')
		--------------------------A U T O - W E A P O N S W A P - C O M M A N D S-----------------------------------------------
		windower.add_to_chat(206, '------A U T O - W E A P O N S W A P - C O M M A N D S  ------')
        windower.add_to_chat(207, '- aws : toggles the auto-weapon-swap system')
        windower.add_to_chat(207, '- slashing (weaponmode name): saves a weaponmode name to slashing specific to the job you are on.')
        windower.add_to_chat(207, '- piercing (weaponmode name): saves a weaponmode name to piercing specific to the job you are on.')
		windower.add_to_chat(207, '- blunt (weaponmode name): saves a weaponmode name to blunt specific to the job you are on.')
		------------------------M O G L O P H O N E   T I M E R   C O M M A N D S--------------------------------------------------
		windower.add_to_chat(206, '------M O G L O P H O N E   T I M E R  ------')
		windower.add_to_chat(207, '- silence : silences the moglophone pickup alarm.')
		windower.add_to_chat(207, '- pickup : manually starts the moglophone timer.')
		windower.add_to_chat(207, '- timerreset : manually subtracts approximately 19 hours and 59 minutes from the moglophone timer. (Debugging function.)')
        -------------------------R E S I S T A N C E   A N D    M A P   C O M M A N D S--------------------------------------------
		windower.add_to_chat(206, '------R E S I S T A N C E   A N D    M A P  -----')
        windower.add_to_chat(207, '- toggle [resistances/joke] : Shows/hides either info *FIXED*')
        windower.add_to_chat(207, '- bg [resistances/all] [0-255] : Sets the alpha channel for backgrounds. *FIXED*')
        windower.add_to_chat(207, '- map : Toggle the current floor\'s map')
        windower.add_to_chat(207, '- map center : Repositions the map to the center of the screen')
        windower.add_to_chat(207, '- map size [size] : Sets the map to the new [size] #. *FIXED*')
        windower.add_to_chat(207, '- map floor [floor] : Sets the map to reflect [floor] #. *FIXED*')
        windower.add_to_chat(206, 'Enjoy!')
	else 
		log('You went full retard... you never go full retard.')
		coroutine.sleep(2)
		windower.send_command('op help')
    end
end)

function save_record()
    if earned_MogSegments > 1 and earned_MogSegments > MogSegments_record and earned_MogSegments < 17000 then
        MogSegments_record = earned_MogSegments
        settings.MogSegments_record = MogSegments_record
        config.save(settings)
    end
    coroutine.sleep(1)
    if MogSegments_record >= earned_MogSegments then
        earned_MogSegments = 0
    end
    update_display()
end

update_display()

local function check_zone()
	local zone_id = windower.ffxi.get_info().zone
    if zone_id == 279 or zone_id == 298 then
        flags.in_Odyssey_zone = true
        coroutine.schedule(function()
            update_display()
            induct_data()
        end, 2)
        coroutine.schedule(function()
			if not flags.sheolzone then
			flags.gaolzone = true
			end
        end, 10)
    elseif zone_id == 247 then
        flags.in_Rabao_zone = true
		flags.in_Odyssey_zone = false
		coroutine.schedule(function()
            flags.in_Rabao_zone = true
            update_display()
        end, 3)
    else
        flags.in_Rabao_zone = false
        flags.in_Odyssey_zone = false
    end
end

function set_up_entry()
	--if not flags.gaolzone then
    -- initiate running functions
		res_monitor = windower.register_event('target change', print_resistances)
		floor_monitor = windower.register_event('outgoing chunk', watch_floor_change)
	--end
end

function watch_for_entry(id, data, modified, injected, blocked)
    -- the rabao conflux will send an NPC interaction with our character upon/before zoning that tells us the zone we'll be in (A/B/C/Gaol)
    if id == 0x034 and not injected then
        local packet = packets.parse('incoming', data)
        if packet['Menu ID'] == 173 and packet['NPC'] == windower.ffxi.get_player().id then
            local i = packet['Menu Parameters']:unpack('i', 1)
            flags.sheolzone = i < 4 and i > 0 and i or nil
			flags.gaolzone = i == 4 or nil
			flags.segzone = flags.sheolzone
        end
    end
end

local weapon_cache = {
    skill = nil,
    name = nil,
    last_update = 0
}

local weapon_types = {
    [1]  = "blunt",    -- Hand-to-Hand
    [2]  = "piercing", -- Dagger
    [3]  = "slashing", -- Sword
    [4]  = "slashing", -- Great Sword
    [5]  = "slashing", -- Axe
    [6]  = "slashing", -- Great Axe
    [7]  = "slashing", -- Scythe
    [8]  = "piercing", -- Polearm
    [9]  = "slashing", -- Katana
    [10] = "slashing", -- Great Katana
    [11] = "blunt",    -- Club
    [12] = "blunt",    -- Staff
}

local function get_current_weapon_type()
    -- simple rate limit: don't spam gear lookups faster than once every 0.5s
    if os.clock() - weapon_cache.last_update < 0.5 and weapon_cache.skill then
        return weapon_cache.skill, weapon_cache.name
    end

    local items = windower.ffxi.get_items()
    if not items or not items.equipment or not items.equipment.main or not items.equipment.main_bag then
        return weapon_cache.skill, weapon_cache.name
    end

    local main_index = items.equipment.main
    local main_bag = items.equipment.main_bag
    if main_index == 0 then
        return weapon_cache.skill, weapon_cache.name
    end

    local main_item = windower.ffxi.get_items(main_bag, main_index)
    if not main_item or not main_item.id or main_item.id == 0 then
        return weapon_cache.skill, weapon_cache.name
    end

    local item_res = res.items[main_item.id]
    if not item_res or not item_res.skill then
        return weapon_cache.skill, weapon_cache.name
    end

    local weapon_type = weapon_types[item_res.skill]
    weapon_cache.skill = weapon_type
    weapon_cache.name = item_res.en
    weapon_cache.last_update = os.clock()

    return weapon_type, item_res.en
end

local function auto_swap_weapon_if_needed(best_type, values)
	if not best_type or not values then return end
    local preferred_valid = nil
	local current_main_job = windower.ffxi.get_player().main_job
	--if not global_current_weapon then
	local current = get_current_weapon_type()
		--global_current_weapon = current
	--else
		--current = global_current_weapon
	--end
    if not current then return end

    -- If current already matches best, no swap
    if current == best_type then return end

    -- Check if all values are the same (e.g. 1.000 across the board)
    local all_equal = (values.slashing == values.piercing and values.piercing == values.blunt)
    if all_equal then
		local TP = windower.ffxi.get_player().vitals.tp
		if TP < 850 then  
			--windower.add_to_chat(123, '[OdyPro] All resistances equal, favoring slashing')
			best_type = "slashing"
			best_val = values.slashing
			--return
		end
    end
    -- === Adjustable Threshold ===
    -- Only swap if the difference between current and best is at least this much
    local SWAP_THRESHOLD = 0.25  -- << tweak this as needed >>
    local current_val = values[current] or 0
    local best_val    = values[best_type] or 0

    if (best_val - current_val) <= SWAP_THRESHOLD and not all_equal and best_val >= 1.000 then
		local TP = windower.ffxi.get_player().vitals.tp
			if values.slashing >= 1.000 then
					if best_val - values.slashing <= .25 and TP < 850 then
							best_type = "slashing"
							preferred_valid = true
					elseif current_val >= best_val and TP > 850 then
						return
					else
						best_type = "slashing"
						preferred_valid = true
					end
					if current == best_type then return end
			elseif values.piercing == values.blunt then
				if current_main_job == 'DRG' or current_main_job == 'BRD' or current_main_job == 'COR' then
					best_type = "piercing"
					preferred_valid = true
				else
					best_type = "blunt"
					preferred_valid = true
				end
			else
				--windower.add_to_chat(123, '[OdyPro] Difference too small, skipping swap.')
				return
			end
    end
	-- If slashing has a good value we just want to maintain that and stop unnecessary swapping.
	if not preferred_valid then
		if values.slashing >= 1.000 then
			best_type = "slashing"
			if current == best_type then return end
		-- If we aren't on cor, brd, drg or other jobs that prefer piercing over blunt then its best to use a club like maxentius, loxotic or mafic
		elseif values.piercing == values.blunt and values.blunt > values.slashing and (current_main_job == 'WAR' or current_main_job == 'RDM' or current_main_job == 'DRK') then
			best_type = "blunt"
			if current == best_type then return end
		end
	end
    -- Lookup what the user wants to equip for this type
    local set_name = settings.job_weapon_sets[current_main_job][best_type]
    if toggle_auto_weapon_swap and (current_main_job ~= 'PLD' and current_main_job ~= 'RUN') then
        if set_name then
			if best_type == 'piercing' then
				windower.play_sound(sound_paths.piercing)
			elseif best_type == 'slashing' then
				windower.play_sound(sound_paths.slashing)
			elseif best_type == 'blunt' then
				windower.play_sound(sound_paths.blunt)
			end
            windower.send_command('gs c set weapons ' .. set_name)
			--global_current_weapon = best_type
            --windower.add_to_chat(122, '[OdyPro] Swapping weaponmode to ' .. set_name .. ' (' .. best_type .. ')')
        else
            windower.add_to_chat(123, '[OdyPro] No weapon set configured for ' .. best_type)
        end
    end
		--preferred_valid = false
end

function build_res_strings(target, target_index)
    if flags.gaolzone then return end
    local name = target.name
    local family = (name:find('Nostos') or name:find('Agon')) and name:gsub('^%a+%s', '') or name
    local res_string = ''
    local ele_string = ''
    local type
	--local weapon_swap_triggered = nil
    -- loop over mobs, find current, and get its family key
    for k, v in pairs(types) do
        if table.find(v, family) then
            type = k
            break
        end
    end

    -- skip if data not found
    if not resistances[family] or not types[type] then
	local msg = string.format("[Resistances] Missing data for family '%s' (type=%s)", tostring(family), tostring(type))
		windower.add_to_chat(123, msg)
		flags.resistance_intel = false
		missing_log:append(msg.."\n")
        res_box:hide()
        return
	else
		flags.resistance_intel = true
    end

    local max_ele = table.max(resistances[family])
	------------------------------------
	local best_type, best_value
	local values = {}
	------------------------------------
    -- loop over weapon types
    for i = 1, 3 do
        local weapon = resistances['Legend'][i]
        local resistance = weapon == types[type][1] and resistances[family][i] - 0.5 or resistances[family][i]
		if toggle_auto_weapon_swap then
			values[weapon:lower()] = resistance
			if not best_value or resistance > best_value then
				best_value = resistance
				best_type = weapon:lower()  -- "slashing", "piercing", "blunt"
			end
		end
        local color = resistance > 1 and [[\cs(0, 255, 0)]] or resistance < 1 and [[\cs(255, 0, 0)]] or [[\cs(255, 255, 255)]]
        res_string = res_string .. '\n' .. color .. string.rpad(weapon .. ':', ' ', 10) ..
                         string.lpad(tostring(resistance * 100), ' ', 3) .. [[%\cr]]
    end

    -- loop over elements
    for i = 5, 12 do
        local ele = string.slice(resistances['Legend'][i], 1, 2)
        local val = types[type][1] == 'Magic' and resistances[family][i] - 0.5 or resistances[family][i]
        local color = val == max_ele and [[\cs(0, 255, 0)]] or val < 1 and [[\cs(255, 0, 0)]] or [[\cs(255, 255, 255)]]

        if i == 9 then
            ele_string = ele_string .. '\n' .. color .. ele .. ':' ..
                             string.lpad(tostring(math.round(val * 100, 0)), ' ', 3) .. [[%\cr]]
        elseif i == 5 then
            ele_string = ele_string .. color .. ele .. ':' ..
                             string.lpad(tostring(math.round(val * 100, 0)), ' ', 3) .. [[%\cr]]
        else
            ele_string = ele_string .. ' ' .. color .. ele .. ':' ..
                             string.lpad(tostring(math.round(val * 100, 0)), ' ', 3) .. [[%\cr]]
        end
    end

    res_box.name = name
    res_box.type = type
    res_box.resistances = res_string .. '\n\n' .. ele_string

    if settings.res_box.joke then
        local color = resistances[family][4] == 0.000 and [[\cs(200, 125, 0)]] or [[\cs(55, 210, 0)]]
        res_box.crueljoke = color .. '\n\nCruel Joke' .. [[\cr]]
    end
	if toggle_auto_weapon_swap then
		local TP = windower.ffxi.get_player().vitals.tp
		if TP < 999 then
			auto_swap_weapon_if_needed(best_type,values)
		elseif not flags.weapon_swap_triggered then
			windower.add_to_chat(122, '['..TP..' TP] Executing potential swap in 5s .. WS quickly.')
			flags.weapon_swap_triggered = true
			coroutine.schedule(function() 
			auto_swap_weapon_if_needed(best_type,values)  
			flags.weapon_swap_triggered = false 
			end, 5)
		end
	end
end

function print_resistances(target_index)
    if flags.gaolzone then windower.unregister_event(res_monitor, floor_monitor) return end
	if settings.res_box.show then
        local target = windower.ffxi.get_mob_by_index(target_index)
        local is_halo = target and target.name:contains('Halo')

        -- only redraw if the mob is different from last one ** or auto-weapon-swap-mode is on.
        if target_index > 0 and not is_halo and target.spawn_type == 16 and target.valid_target then
			if (target.name ~= last_target or toggle_auto_weapon_swap) then
				build_res_strings(target, target_index)
				last_target = target.name
				last_target_name = target.name
			else
				last_target_name = target.name
			end
        end

        -- only show when enemy is a mob
        if target and target.spawn_type == 16 and target.valid_target and not is_halo and flags.resistance_intel then
            res_box:show()
        else
            res_box:hide()
        end
	else
		local target = windower.ffxi.get_mob_by_index(target_index)
		last_target_name = target.name
    end
end

function watch_floor_change(id, data, modified, injected, blocked)  
   local current_time = os.clock()
    if id == 0x05B and current_time - timing.last_floorcheck_time > 4 then 

        local packet = packets.parse('outgoing', data)
        local new_floor

        -- conflux menu was used
        if tostring(packet):contains('Conflux') then
            -- even numbered confluxes always teleport one floor down where that floor equals the confluxes number divided by two
            if packet['Option Index'] % 2 == 0 then
                new_floor = packet['Option Index'] / 2 == 0 and 1 or packet['Option Index'] / 2
                -- odd numbered confluxes always teleport one floor up
            else
                -- store lowest floor
                local f = 1
                -- loop over odd conflux values
                for i = 1, 11, 2 do
                    -- increase floor by one each step
                    f = f + 1
                    -- stop at actual conflux that was used
                    if i == packet['Option Index'] then
                        new_floor = f
                        break
                    end
                end
            end

            -- translocator menu was used
        elseif tostring(packet):contains('Translocator') then
            -- 'option index' is the translocator that was warped to, corresponding floors are known values
            new_floor = translocators[flags.sheolzone][packet['Option Index']]
        end

        if new_floor then
            map:path(windower.addon_path .. 'maps/' .. flags.sheolzone .. '-' .. new_floor .. '.png')
			timing.last_floorcheck_time = os.clock()
        end
    end
end

function set_sheolzone_inside(id, data, modified, injected, blocked)
	-- checking any NPC update in range while flags.sheolzone is not set
    if id == 0x00E and not injected then

        local packet = packets.parse('incoming', data)
        local sender = windower.ffxi.get_mob_by_index(packet['Index']) and windower.ffxi.get_mob_by_index(packet['Index']).spawn_type or nil

        if sender and sender == 16 or sender == 2 then
            -- grab unique instance bit
            local instance = bit.band(bit.rshift(windower.ffxi.get_mob_by_index(packet['Index']).id, 12), 0xFFF)
            -- find out if current instance is Sheol A, B or C
            for k, v in pairs(instances) do
                if table.find(v, instance) then
                    flags.sheolzone = k
					flags.segzone = flags.sheolzone
                    map:path(windower.addon_path .. 'maps/' .. flags.sheolzone .. '-1.png')
                    set_up_entry()
                    break
                end
            end
            -- stop all of this from firing over and over again since we now know what instance we are in
            windower.unregister_event(sheolzone_fetcher)
        end
    end
end

function face_target(transgressor)
	local target = {}
	if transgressor then
		target = transgressor
	else 
		target = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().target_index)
	end
	local virtual_position = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index)
	if target then  
		local protraction = (math.atan2((target.y - virtual_position.y), (target.x - virtual_position.x))*180/math.pi)*-1
		windower.ffxi.turn((protraction):radian())
	else
		windower.add_to_chat(205,"You have no target")
	end
	local measurement = 2--math.sqrt(transgressor.distance) * 0.25
	coroutine.sleep(0.5)
	windower.ffxi.run(false)
	flags.face_target_triggered = false
	--get_after_it(target,measurement)
end

-- SATS™ My pride & joy.
function target_nearest(target_names)
    local player = windower.ffxi.get_player()
    local player_mob = windower.ffxi.get_mob_by_id(player.id)
    local within_height = false
    if player and player.vitals.hp == 0 then return end -- Don't run while dead.
    local last_target_lower = last_target_name and last_target_name:lower()

    if not flags.mobAlreadyTargetted then
        flags.mobAlreadyTargetted = true
        local mobs = windower.ffxi.get_mob_array()
        local agon_target
        local nm_target
        local fallback_target
		local mob_keywords
			if flags.segzone == 1 then
				mob_keywords = {
			------------------------Sheol A---------------------------
			'aegypius','ailuros','brachys','cynara','damysus','dione',
			'eurytus','gloios','harpe','kusarikku','leucippe','megaera',
			'physis','ptelea','salmandra','tipuli',
				}
			elseif flags.segzone == 2 then
				mob_keywords = {
			------------------------Sheol B---------------------------
			'akidu','allergorhai','apollinaris','azdaha',
			'bendigeidfran','bes','chelamma','chnubis',
			'malefis','lokberry','fornax','gandji','gravehaunter',
			'ishum','kuk','langmeidong','man-kheper-re','maverick',
			'nerites','ptesan','shara','simir','spyrysyon','tabitjet',
			'taniwha','tripix','zacatzontli',
			}
			elseif flags.segzone == 3 then
				mob_keywords = {
			------------------------Sheol C---------------------------
            'asena', 'steward', 'dabbat',
            'lotanu', 'bygul', 'kurmajara', 'wayra tata',
			--------------------------------------------------
				}
			else
				mob_keywords = {
				}
			end

        for _, mob in pairs(mobs) do
            if mob.valid_target and mob.hpp > 0 and math.sqrt(mob.distance) <= ats_max_distance then
                if math.abs(mob.z - player_mob.z) <= 3 then
                    within_height = true
                    local mob_name = mob.name:lower()
				
                    -- PRIORITY 1: Look for NM keywords
                    local matched = false
                    for _, keyword in ipairs(mob_keywords) do
                        if mob_name:find(keyword) then
                            matched = true
                            break
                        end
                    end
                    if matched and not has_immune_buff(mob) then
							if not nm_target then
								nm_target = mob
							end
                    -- PRIORITY 2: Look for "Agon"
                    elseif mob_name:find("agon") and not has_immune_buff(mob) then
							if not agon_target or mob.distance < agon_target.distance then
								agon_target = mob
							end
                    -- PRIORITY 3: Other target_names
					-- In the future I will possibly reduce tolerance so distance weighs more
                    else
                        for _, target_name in ipairs(target_names) do
                            if mob_name:find(target_name:lower()) then
                                -- bias weight system, like AI models. (in-development)
                                local same_name_bonus = (last_target_lower and mob_name == last_target_lower) and 10 or 0
                                local score_new = mob.hpp - (math.sqrt(mob.distance) * 0.25) + same_name_bonus
                                local score_old = fallback_target and (fallback_target.hpp - (math.sqrt(fallback_target.distance) * 0.25) + ((fallback_target.name:lower() == last_target_lower) and 10 or 0)) or -999

                                if not fallback_target or score_new > score_old then
                                    fallback_target = mob
                                end
                            end
                        end
                    end
                end
            end
        end

        local closest = nm_target or agon_target or fallback_target

        if not closest then
            if not within_height then
                windower.add_to_chat(166, 'Target found within distance limit, but beyond the height threshold.')
                within_height = false
            else
                windower.add_to_chat(166, 'No specified targets within distance limit.')
            end
            flags.mobAlreadyTargetted = false
            return
        end
			--if not flags.in_Odyssey_zone then
				--last_target_name = closest.name
			--end
			
        -- Engage target
        local current_engage_time = os.time()
        if (player.status == 1 or player.status == 2) or (current_engage_time - timing.last_disengage_time <= 3) then
            windower.add_to_chat(207, 'Switching target...')
            local p = packets.new('outgoing', 0x01A)
            p['Target'] = closest.id
            p['Target Index'] = closest.index
            p['Category'] = 0x0F
            p['Param'] = 0
            p['X Offset'] = 0
            p['Z Offset'] = 0
            p['Y Offset'] = 0
            packets.inject(p)

            local p2 = packets.new('outgoing', 0x016)
            p2['Target Index'] = closest.index
            packets.inject(p2)
        end

        if math.sqrt(closest.distance) <= 15 and not flags.face_target_triggered then
            flags.face_target_triggered = true
            windower.play_sound(sound_paths.swapnrun)
            coroutine.schedule(function() face_target(closest) end, 0.6)
        end

        if not flags.face_target_triggered then
            coroutine.sleep(0.2)
            windower.ffxi.run(false)
            coroutine.sleep(1)
            windower.ffxi.run(false)
        end
    end
    flags.mobAlreadyTargetted = false
end

--The alternate auto-targeting-system: Prioritizes proximity over higher HP. 
math.randomseed(os.time() + windower.ffxi.get_player().id)
function target_nearest_2(target_names)
	local player = windower.ffxi.get_player()
	local player_mob = windower.ffxi.get_mob_by_id(player.id)
	local within_height = false
	local same_name_present = false
	local last_target_lower = last_target_name and last_target_name:lower()
	if player and player.vitals.hp == 0 then return end -- Don't run if dead

	if not flags.mobAlreadyTargetted then
		flags.mobAlreadyTargetted = true
		local mobs = windower.ffxi.get_mob_array()
		local closest
		local prioritize_agon = true
		local mob_keywords = {
			'asena', 'steward', 'dabbat',
			'lotanu', 'bygul', 'kurmajara', 'wayra tata'
		}
		-- First pass: look only for 'Agon' mobs
		for _, mob in pairs(mobs) do
			if mob.valid_target and mob.hpp > 0 and math.sqrt(mob.distance) <= ats_max_distance then
				if math.abs(mob.z - player_mob.z) <= 3 then
					within_height = true
					local mob_name = mob.name:lower()
					local matched = false
					for _, keyword in ipairs(mob_keywords) do
						if mob_name:find(keyword) then
							matched = true
							break
						end
					end
					if matched and not has_immune_buff(mob) then
						if not closest then
							closest = mob
						end
					elseif string.find(mob.name:lower(), 'agon') and not has_immune_buff(mob) then
						if not closest then
							closest = mob
						else
							if mob.hpp == 100 and mob.distance <= (closest.distance + 5) then
								closest = mob
							elseif mob.hpp >= 90 and mob.distance <= (closest.distance + 2.5) then
								closest = mob
							elseif mob.hpp >= 75 and mob.distance < closest.distance then
								closest = mob
							end
						end
					end
				end
			end
		end

		-- Second pass: fallback to normal target_names if no Agon mob found
		if not closest then
			for _, mob in pairs(mobs) do
				if mob.valid_target and mob.hpp > 0 and math.sqrt(mob.distance) <= ats_max_distance then
					if math.abs(mob.z - player_mob.z) <= 3 then
					local mob_name = mob.name:lower()
						for _, target_name in ipairs(target_names) do
							if string.find(mob.name:lower(), target_name:lower()) then
							  local same_name_bonus = (last_target_lower and mob_name == last_target_lower)
								if not closest then
									closest = mob
								elseif same_name_bonus then
									same_name_present = true
									if mob.hpp == 100 and mob.distance <= (closest.distance + 5) then
										closest = mob
									elseif mob.hpp >= 90 and mob.distance <= (closest.distance + 2.5) then
										closest = mob
									elseif mob.hpp >= 75 and mob.distance < closest.distance then
										closest = mob
									end
								elseif not same_name_present then
									if mob.hpp == 100 and mob.distance <= (closest.distance + 5) then
										closest = mob
									elseif mob.hpp >= 90 and mob.distance <= (closest.distance + 2.5) then
										closest = mob
									elseif mob.hpp >= 75 and mob.distance < closest.distance then
										closest = mob
									end
								end
							end
						end	
					end
				end
			end
		end

		if not closest then
			if not within_height then
				windower.add_to_chat(205, 'Target found within distance limit, but beyond the height threshold.')
			else
				windower.add_to_chat(205, 'Cannot find valid target within distance limit.')
			end
			flags.mobAlreadyTargetted = false
			return
		end
		--last_target_name = closest.name

		local current_engage_time = os.time()
		if (player.status == 1 or player.status == 2) or (current_engage_time - timing.last_disengage_time <= 3) then
					    windower.add_to_chat(207, 'Switching target...')
			local p = packets.new('outgoing', 0x01A)
			p['Target'] = closest.id
			p['Target Index'] = closest.index
			p['Category'] = 0x0F
			p['Param'] = 0
			p['X Offset'] = 0
			p['Z Offset'] = 0
			p['Y Offset'] = 0
			packets.inject(p)

			local p2 = packets.new('outgoing', 0x016)
			p2['Target Index'] = closest.index
			packets.inject(p2)
		end

		if math.sqrt(closest.distance) <= 15 and not flags.face_target_triggered then
			flags.face_target_triggered = true
			windower.play_sound(sound_paths.swapnrun)
			coroutine.schedule(function() face_target(closest) end, 0.6)
		end

		if not flags.face_target_triggered then
			coroutine.sleep(0.2)
			windower.ffxi.run(false)
			coroutine.sleep(1)
			windower.ffxi.run(false)
		end
	end

	flags.mobAlreadyTargetted = false
end

function check_standing_still()
    local player = windower.ffxi.get_info().logged_in and windower.ffxi.get_mob_by_id(windower.ffxi.get_player().id)
    if not player then return end

    -- Get current position
    local current_position = {x = player.x, y = player.y, z = player.z}

    -- Check if the player has moved
    if math.abs(current_position.x - last_position.x) > 0.01 or
       math.abs(current_position.y - last_position.y) > 0.01 or
       math.abs(current_position.z - last_position.z) > 0.01 then
        -- Player has moved
        last_position = current_position
        timing.last_move_time = os.clock()
        flags.is_standing_still = false
		if flags.busy_doing_stuff and not flags.augmentation_techniques then  -- since we have moved we know that we're no longer in a menu; Re-enable automated moogle interactions
			flags.busy_doing_stuff = false
		end
    else
        -- Check how long been still
        if os.clock() - timing.last_move_time > 5 then
            flags.is_standing_still = true
        end
    end
end

windower.register_event('prerender', function()
    local current_engage_time = os.time()
    local player = windower.ffxi.get_player()
	local targetter_current_time = os.clock()
	----------------------------------------------------
    if flags.in_Rabao_zone then
	    check_standing_still()
	end
    if targetter_current_time - timing.last_switch_time < timing.cooldown_time then
        return -- If we're still within the cooldown, don't do anything
    end
    if player and (player.status == 1 or player.status == 2) then
		timing.last_disengage_time = os.time()
	end
    local current_target = windower.ffxi.get_mob_by_target('t')

    -- If the current target is dead, switch to the next target

	if player and player.vitals.hp == 0 then return end   --  We dont want this firing over and over while we're dead.
        if current_target and current_target.hpp == 0 and auto_ody_targetting and (current_engage_time - timing.last_disengage_time <= 3) and player.vitals.hp ~= 0 then
	        if flags.targettingMessageDisplayed == nil then
			    windower.add_to_chat(207, 'Scanning for specified targets...')
			    flags.targettingMessageDisplayed = true
		    end

        -- Switch to the nearest target and update the last switch time
	    	if ats_mode == 1 then
                 target_nearest(settings.targets)
                 timing.last_switch_time = os.clock() -- Update the last switch time
		    elseif ats_mode == 2 then
                target_nearest_2(settings.targets)
                timing.last_switch_time = os.clock() -- Update the last switch time
			end
        end
	
    -----------------------------------------------------------------------
	flags.targettingMessageDisplayed = nil
end)
-------------------------------------------

windower.register_event('time change', function()
   if not flags.auto_grabbing_in_progress and not flags.auto_II_grabbing_in_progress and not flags.auto_amp_grabbing_in_progress then
		if remaining_time < 1 and flags.alarmTriggered == false then 
			if not flags.zoning then
				local player = windower.ffxi.get_player()
				if player.name == current_character and not flags.zoning then
					moglophone_alarm_handler()
				end
			end
		end 
		local random_delay = math.random(0, 30) / 10
		coroutine.schedule(function() update_display()end, random_delay)
		return
	else
		return
	end
end)
-----------------------------------------------
windower.register_event('unload', function() 
	save_record()
end)

windower.register_event('zone change', function(new_id, old_id)
	flags.zoning = true
	amp_notifier = {}
	inside_ody_moglophone_ii_count = 3
	weapon_cache.skill = nil
    weapon_cache.name = nil
    weapon_cache.last_update = 0
    coroutine.schedule(function()
        flags.zoning = false
    end, 15)
    coroutine.schedule(function()
        if old_id == 279 or old_id == 298 then
            coroutine.schedule(function()
			flags.in_Odyssey_zone = false
			zone_in_amount = nil
			if flags.segzone and not flags.gaolzone then
				log('Total haul: ' .. earned_MogSegments)
			end
			flags.segzone = nil
			flags.gaolzone = false
            save_record()
			end, 3)
        end
        if new_id == 247 then
            rabao_monitor = windower.register_event('incoming chunk', watch_for_entry)
            flags.in_Rabao_zone = true
            update_display()
        elseif old_id == 247 and (new_id == 298 or new_id == 279) then
			coroutine.schedule(function()
				if not flags.sheolzone or flags.sheolzone > 3 then
				flags.gaolzone = true
				end
			end, 10)
            coroutine.sleep(1)
            last_threshold = 0
            windower.send_command('op reset')
			flags.in_Odyssey_zone = true
            induct_data()
			zone_in_amount = previous_MogSegments
            if flags.sheolzone then
                set_up_entry()
                map:path(windower.addon_path .. 'maps/' .. flags.sheolzone .. '-1.png')
            else
                sheolzone_fetcher = windower.register_event('incoming chunk', set_sheolzone_inside)
            end
        end
		
        if flags.sheolzone and (old_id == 298 or old_id == 279) then
            windower.unregister_event(res_monitor, floor_monitor)
        end
		
        if rabao_monitor and old_id == 247 then
            windower.unregister_event(rabao_monitor)
        end
        if old_id == 247 then
            flags.in_Rabao_zone = false
            update_display()
        end
    end, 3)
end)

windower.register_event('load', function()
    windower.add_to_chat(207, 'Welcome to OdyPro 3.4.1 !')
    if auto_ody_targetting then
        windower.add_to_chat(207, "Auto-targetting systems online, max distance set to "..ats_max_distance..'.')
    else
        windower.add_to_chat(207, "Auto-targetting systems offline.")
    end
    windower.add_to_chat(207, 'It is strongly recommended to read over the new commands with //op help')
	windower.play_sound(sound_paths.odyproload)
	display:show()
    coroutine.schedule(function()
	    load_timer_from_settings()
        check_zone()
        update_display()
    end, 1)
    coroutine.schedule(function()
		flags.segments_loaded_fully = true
    end, 4)
    coroutine.schedule(function()
		flags.inventory_fully_loaded = true
    end, 20)
    if windower.ffxi.get_info().zone == 298 or windower.ffxi.get_info().zone == 279 then
        sheolzone_fetcher = windower.register_event('incoming chunk', set_sheolzone_inside)
    elseif windower.ffxi.get_info().zone == 247 then
        rabao_monitor = windower.register_event('incoming chunk', watch_for_entry)
    end
    local player = windower.ffxi.get_player()
    if player then
        current_character = player.name
    end
end)

-- Handles some of the automated interaction manual-overriding
windower.register_event('outgoing chunk',function(id,data,modified,injected,blocked)
  if flags.in_Rabao_zone then 
    if id == 0x01A and not injected then 
		local p = packets.parse('outgoing', data)
		if p["Target"] == 17789079 or p["Target"] == 17789076 then
			flags.busy_doing_stuff = true
		end
			if (flags.auto_grabbing_in_progress or flags.auto_II_grabbing_in_progress or flags.auto_amp_grabbing_in_progress) then 
				if not flags.action_cancellation then
					if flags.auto_amp_grabbing_state or flags.auto_grabbing_state or flags.auto_II_grabbing_state then
						moogle_resettinator(true)
						coroutine.sleep(1)
						return false
					end
				end
			end
	elseif id == 0x05B and not injected then
		local p = packets.parse('outgoing', data)
		if p["_unknown1"] == 16384 and flags.busy_doing_stuff then
			flags.busy_doing_stuff = false
		elseif p["Target"] == 17789079 and p["Option Index"] == 0 and p["_unknown1"] == 0 and p["Menu ID"] == 2001 and p["Automated Message"] == false and flags.busy_doing_stuff then
			flags.busy_doing_stuff = false
		elseif p["Target"] == 17789079 and p["Option Index"] == 0 and p["Menu ID"] == 2005 and p["Automated Message"] == false and flags.busy_doing_stuff then
			flags.busy_doing_stuff = false
		end
    end
  end
end)