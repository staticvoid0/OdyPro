--[[
    First value represents an additional resistance bonus supposedly given to mobs of that type inside Odyssey.
    Said bonus is strictly made up from observations made by the user base and has not been confirmed by SquareEnix
    as of the writing of this addon.
--]]

return {
    -- Nostos mobs and NMs
    ['Amorph']   = {'Magic',    'Allergorhai','Allergorhai\'s Worm','Bes','Bes\'s Hecteyes','Black Pudding','Clot','Flan','Gloios','Hecteyes','Leech','Slime','Worm'},
    ['Aquan']    = {'Slashing', 'Brachys','Crab','Fish','Jagil','Kraken','Nerites','Nerites\'s Crab','Pugil','Taniwha','Taniwha\'s Kraken','Uragnite'},
    ['Arcana']   = {'Piercing', 'Bendigeidfran','Bendigeidfran\'s Golem','Bomb','Bygul','Cluster','Evil Weapon','Fornax','Fornax\'s Cluster','Giant','Harpe','Ishum','Ishum\'s Bomb','Magic Pot','Mimic','Shara','Shara\'s Evil Weapon','Weapon'},
    ['Beast']    = {'Piercing', 'Ailuros','Asena','Buffalo','Bugard','Chnubis','Chnubis\'s Manticore','Coeurl','Dabbat al-Ard','Dhalmel','Karakul','Kusarikku','Leopard','Manticore','Marid','Opo-opo','Ptesan Wi','Ptesan Wi\'s Buffalo','Ram','Rarab','Sheep','Tiger'},
    ['Bird']     = {'Blunt',    'Aegypius','Apkallu','Bat','Bats','Bigbird','Colibri','Cockatrice','Gandji','Gandji\'s Roc','Langmeidong','Langmeidong\'s Roc','Leucippe','Megaera','Roc','Simir','Simir\'s Colibri','Vulture','Zacatzontli','Zacatzontli\'s Roc','Ziz'},
    ['Demon']    = {'Piercing', 'Ahriman','Chaos Steward','Imp','Soulflayer','Taurus'},
    ['Dragon']   = {'Blunt',    'Azdaha','Azdaha\'s Wyvern','Dahak','Drake','Kuk','Kuk\'s Shadow Dragon','Lotanu','Puk','Wayra Tata','Wyvern'},
    ['Lizard']   = {'Blunt',    'Eft','Kurmajara','Lizard','Raptor','Salmandra'},
    ['Plantoid'] = {'Magic',    'Ameretat','Cynara','Damysus','Dione','Eurytus','Flytrap','Funguar','Goobbue','Korrigan','Mandragora','Maverick Maude','Maude\'s Ameretat','Morbol','Physis','Ptelea','Sabotender','Sapling','Treant'},
    ['Undead']   = {'Slashing', 'Bhoot','Corse','Count Malefis','Doom Toad','Draugar','Ghost','Ghoul','Gravehaunter','Gravehaunter\'s Corse','Hound','Malefis\'s Vampire','Qutrub','Skeleton','Spyrysyon','Spyrysyon\'s Shadow'},
    ['Vermin']   = {'Magic',    'Akidu','Akidu\'s Damselfly','Beetle','Chelamma','Chelamma\'s Scorpion','Chigoe','Crawler','Damselfly','Defoliator','Diremite','Eruca','Fly','Gaganbo','Kheper\'s Beetle','Man-kheper-re','Scorpion','Spider','Spinner','Tabitjet','Tabitjet\'s Scorpion','Tipuli','Wamoura','Wamouracampa','Wasp'},
    ['Goblin']   = {'Unknown',  'Tripix','Tripix\'s Goblin'},
    -- Agon beastmen and a few NMs (cleric appears twice, for the sake of simplicity resistances.lua will refer to the Mamool cleric)
    -- TODO: Testing needed in Sheol A for the respective agon beastmen weapon resistances, also Tripix
    ['Orc']      = {'Unknown',  'Archer','Black Belt','Crusader','Fighter','Pugilist','Renegade','Thaumaturge','Villifier'},
    ['Yagudo']   = {'Unknown',  'Archon','Bruiser','Chirurgeon','Lyricist','Magus','Samurai','Shinobi','Spiritualist'},
    ['Quadav']   = {'Unknown',  'Champion','Cleric','Enchanter','Evoker','Marauder','Pillager','Ravager','Squire'},
    ['Antica']   = {'Blunt',    'Apollinaris VII-II','Apollinaris\'s Antican','Cleaver','Culler','Errant','Magister','Man-at-Arms','Soldier','Swiftcaster','Warden'},
    ['Sahagin']  = {'Piercing', 'Chemister','Dragonmaster','Healer','Lancer','Mendicant','Muse','Stoicist','Tamer'},
    ['Tonberry'] = {'Slashing', 'Agent','Assassin','Channeler','Fleet-footed Lokberry','Lokberry\'s Tonberry','Hexer','Kunoichi','Pickpocket','Rogue','Spy'},
    ['Mamool']   = {'Piercing', 'Cleric','Heretic','Initiate','Instigator','Marquess','Phalanx','Pilferer','Praetor'},
    ['Troll']    = {'Blunt',    'Clearmind','Defender','Footsoldier','Infidel','Ritualist','Sharpshooter','Shieldsaint','Viscount'},
    ['Lamia']    = {'Slashing', 'Adjudicator','Dignitary','Marksman','Monarch','Rabblerouser','Scallywag','Vizier','Yojimbo'},
}