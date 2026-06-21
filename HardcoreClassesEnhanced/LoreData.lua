----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Lore Data
--
-- Brief lore descriptions for each core enhanced class, sourced from
-- the Warcraft Wiki (warcraft.wiki.gg).
--
-- Only the 27 core-set characters have lore entries.
-- Additional characters (Blademaster, Tinker, Brewmaster) do not.
----------------------------------------------------------------------

HCE = HCE or {}

----------------------------------------------------------------------
-- Set of additional (non-core) character names
----------------------------------------------------------------------
HCE.AdditionalCharacters = {
    ["Runemaster"] = true,
    ["Berserker"]      = true,
    ["Brave"]  = true,
    ["Wilderness Stalker"] = true,
    ["Lightslayer"] = true,
    ["Hedge Wizard"] = true,
    ["Warden"] = true,
    ["Tinker"] = true,
    ["Dark Ranger"] = true,
    ["Sister of Steel"] = true,
    ["Dragonsworn"] = true,
    ["Spirit Champion"] = true,
    ["Archmage of Kirin Tor"] = true,
    ["Ley Walker"] = true,
    ["Graven One"] = true,
}

----------------------------------------------------------------------
-- Lore text per core character (sourced from warcraft.wiki.gg)
----------------------------------------------------------------------
HCE.LoreData = {

    ["Apothecary"] = "The Royal Apothecary Society is an alchemical society created by Lady Sylvanas Windrunner in order to create a new undead plague to wipe out the Scourge. Once based in the Apothecarium in Undercity, its members are all Forsaken or other types of undead beings who are constantly brewing up new plagues and poisons to unleash upon their enemies. The other races of the Horde believe they are working on a remedy to cure their illness.",

    ["Beastmaster"] = "Beastmasters are orc hunters who devote their lives to commanding powerful wild beasts. They reject civilized firearms. Their pets are brothers, not tools — and their death is permanent. Beastmasters are drawn to the perilous primal world, invigorated by its dangerous and untamed nature. They seek to hunt the biggest and most challenging game.",

    ["Prospector"] = "Subterranean realms demand a different sort of scout. Prospectors focus their efforts on the dark, enclosed places underground, which allows them to triumph in all dungeonlike areas. They wander the world searching for untapped veins of ore. Dwarven prospectors are proficient with all simple and martial weapons, and light armor. They are valuable trackers and ambushers.",

    ["Bloodmage"] = "Blood mages are blood elves adept at controlling fire magic. While they were still members of the Alliance resistance, the blood elves began to turn to the darkest parts of magic, disregarding the water and frost spells of the Kirin Tor for the fire and heat of what some people fear to be demonic magic. They are master enchanters and travel with phoenix companions. The blood elves that are fallen victim to the Scourge have joined the Forsaken, hence, the Forsaken have some bloodmages in their ranks as well.",

    ["Elven Ranger"] = "Elven Rangers of the Night Elves are elite ranged combatants specializing in archery, tracking, and woodland warfare. Turning to nature itself for aid, they possess minor druidic abilities expressed in their traps. They operate as solo, without animal pets.",

    ["Buccaneer"] = "Buccaneers are seafaring combatants who sail between ports, taming jungle beasts and wielding guns alongside rapiers. They live by the pirate's code, answering to no crown, with a parrot on one shoulder and a cutlass in hand. They also love fishing.",

    ["Death Knight"] = "Death knights are melee fighters that wield dark magic. Originally created by Gul'dan during the Second War as orc warlocks placed into the bodies of fallen human knights. They command necrotic magic (drain spells), skeletal steeds, and hit with their truncheons.",

    ["Demon Hunter"] = "Demon hunters, the disciples of Illidan Stormrage, uphold a dark legacy, one that frightens their allies and enemies alike. The Illidari embrace fel and chaotic magics — energies that have long threatened the world of Azeroth — believing them necessary to challenge the Burning Legion. They fight against the forces of Chaos using their own terrible powers against it. They wield twin blades shirtless and operate outside traditional society.",

    ["Druid of the Claw"] = "The Druids of the Claw are a clan of druids charged with the protection of Val'sharah from any that would seek to disrupt the balance of nature. Druids of the Claw are masters of their mighty animal forms. When they transform into bears, they become ferocious physical combatants and protectors of nature. They were woken up from their centuries-long hibernation by Malfurion Stormrage in the Barrow Deeps and were rallied to fight in the Battle of Mount Hyjal during the Third War. They live a secluded life, rarely going  into towns or cities and therefore not using the amenities. They fight against the Venture Company who seek to mine and exploit Azeroth's nature.",

    ["Earthcaller"] = "Earthcallers are mighty warrior shamans who embrace the spirits to assist them in battles. They strengthen their spiritual connection until they can feel the spirits of the earth flowing within their body and thoughts, strengthening their arms and quickening their minds. Whispered fragments impart insight into battle as ancestors speak of ways to overcome all foes. Earthcallers have mastery of elemental earth, the toughest and strongest of the elements. Similar to their element of choice, they wear strong and durable armor and shields.",

    ["Exemplar"] = "Battlefields are bloody places, but they are also the proving grounds of heroes. Among the many legendary feats of bravery are the deeds of the exemplars: men and women who strike fear into the hearts of their enemies through intimidation and demoralization. They also inspire courage in their allies, holding their banners high and charging into battle, shouting encouragement to those who ride beside them. To be an exemplar is to sacrifice a great deal of freedom in pursuit of a path that's narrower than a warrior's or paladin's. They are living symbols of faith and justice, wearing guild tabards and Stormwind colors as ordained protectors of the innocent.",

    ["Techno-mage"] = "Techno-mages are arcane scholars who combine their magical knowledge with the use of technology. They are primarily gnomes, and wear advanced goggles that enhance their arcane sight. Following the Battle for Broken Shore, Gnomeregan Mechano-Mages were deployed during the Legion Invasions. Once saved by Alliance adventurers, they summoned Mechano-Peeps and helped fight the demonic invaders.",

    ["Mountain King"] = "The mountain kings, or thanes as they are known in Khaz Modan, are the mightiest dwarven warriors under the mountain. Wielding warhammers, hand axes, and shields, these fierce fighters live to test themselves against worthy opponents. Unconcerned with their race's preoccupation with mechanical devices and mining precious minerals, Mountain Kings live only for battle. Dedicated to safeguarding the Alliance which saved their kingdom during the Second War, the mountain kings can be counted upon to rally behind any banner that stands between freedom and the ever-looming shadow of evil.",

    ["Mountaineer"] = "Mountaineers are dwarven rangers using custom-built rifles and massive axes. They are mostly found in Khaz Modan, but they often travel wide and seek out quests that bring glory to Ironforge. They are a prized division of the Ironforge Army, and have fought in many battles. Most mountaineers wear green uniforms, but a few have been spotted wearing a purple or yellow uniform.",

    ["Necromancer"] = "These insidious magicians were once thought to be aspiring geniuses by the Magocracy of Dalaran. However, their insatiable lust to delve into the secrets of the dark arts drove them to forsake their very souls. Ner'zhul, the Lich King, granted these malevolent sorcerers true power over life in exchange for their loyalty and obedience. An aspiring Necromancer may still be learning to raise the dead, but they have perfected their ability to drain life from the living. Necromancers are not Warlocks, hence, they cannot summon demons.",

    ["Plagueshifter"] = "Few forces have devastated the world as badly as plague. The Plaguelands of Lordaeron are a testament to the ravages that disease can bring to the world. After long and careful deliberation the Horde formed a new order of druids, the plagueshifters, who were charged with reclaiming the Plaguelands and other stricken areas. Using their shapeshifting powers to adapt to tainted environments, plagueshifters study the plague to turn disease against those who created it.",

    ["Priestess of the Moon"] = "The priestesses of the moon are the women who make up the elite night elf clergy, the Sisterhood of Elune. They epitomize the power and grace of Elune, their race's ancient moon goddess. They ride the fearless frostsabers into battle. Charged with the safekeeping of the night elf lands and armed with magical energy — the priestesses of the moon will stop at nothing to rid their ancient land of evil.",

    ["Pyremaster"] = "Orcs burn their dead. In a world filled with magic, magic insinuates itself in ritual. Founded in the mysteries of certain cults on Draenor, the pyremaster is the enactor of ritual. This funerary priest guides the dead through fire, through loss of flesh, so their naked spirits may conquer the elements; in order to protect his duties and his person, he commands and fire. They are associated with orcish shamanic traditions, hence, they ride wolves and don't summon shadow demons or use wands.",

    ["Blademaster"] = "In the orc society, blademasters are known as legendary warriors of the Burning Blade clan. Sticky, smelly, and highly flammable, blazegrease is liberally applied to the swords and axes of the Burning Blade clan before battle. Though some warriors choose to ignite their weapons before battle, most let the inevitable contact of blades and armor spark the blazegrease for unpredictable intimidation.",

    ["Savagekin"] = "The most primal of druids, savagekin bear an ancient but obscure legacy. Whereas some druids seek to command nature or bond with it, the savagekin surrenders himself to the natural world, abandoning much of their humanity to live with the beasts. Savagekin are druids who spend most of their time in animal form. As animals they gain strength and finesse, but come close to becoming irreversibly feral. Savagekin constantly battle the inner beasts that threaten to consume them, clinging to their last vestiges of sentience.",

    ["Shadow Hunter"] = "Shadow hunters are reclusive and wily masters of voodoo and shadow magic and were once the highest authority amongst trolls and their respective warbands. Their spirit powers can both heal and curse, walking the line of dark and light in hope of saving the future of trollkind, doing whatever it takes to secure a future for their kin. The loa can channel themselves through the shadow hunters when they use their ceremonial rush'kah masks. They aren't traditional spellcasters - they can also dish out powerful melee strikes.",

    ["Scarlet Champion"] = "The Scarlet Crusade is a fanatical religious sect dedicated to the eradication of the undead from Lordaeron. Similarly to the Argent Dawn, the Crusade evolved from the Order of the Silver Hand in the aftermath of the Third War. While the Argent Dawn maintained the Silver Hand's original compassionate ideals by welcoming all races to fight the Scourge neutrally, the Scarlet Crusade devolved into a fanatical, xenophobic cult manipulated by outside forces. You were raised in the Scarlet Crusade but are now becoming aware of its corruption and twisted ethics.",

    ["Spiritwalker"] = "Spiritwalkers are mystical, white-furred tauren casters who travel far and wide to find kindred spirits. They carry lanterns to light shadowed spirit paths. Believed to be the ill omen of a coming age, white tauren are held in near reverence by their people in Kalimdor, often becoming reclusive shamans. Spiritwalkers maintain the balance between the world of the living and the spirit realm. They can travel into the memories of the dead to glean clues about the past.",

    ["Templar"] = "Templars are a type of paladin combatants. They are not only the most skilled in battle, but also the most righteous in their demeanor. Strength of arms and purity of mind are strict requirements. Templar paladins stop at nothing to fulfill their divine purpose of bringing justice and purging the wicked. They call down hammers of light and unleash devastating combinations of Physical and Holy attacks that vanquish their enemies. They are sworn to protect the living against undead corruption. They carry the Argent Dawn's trinket as proof of their sacred oath.",

    ["Brewmaster"] = "Brewmasters (also known as brewmeister or brewmaiden) are masters of crafting drinks and concoctions that grant special abilities to themselves and others. As sturdy brawlers who use liquid fortification and unpredictable movement to avoid damage and protect allies, they may seem to struggle with balance as they chug their concoctions in the middle of a fight, but this unpredictable behavior is far from foolhardiness. Brewmasters combine martial prowess with brewing mastery. They use staves to fight, and wear robes as well as exotic armor.",

    ["Spellblade"] = "Spellblades are spellcasters who accompany soldiers into the heart of battle. The generations of warfare on Azeroth have given spellblades time to hone useful spells into simple and secret rituals, called battlemagics, which are passed from spellblades to another. They can wield a sword in one hand, and a staff in the other. As spellblades accompany warriors into battle, they become better at defending themselves than other wizards. They fight on the front lines alongside footmen using frost magic to crowd control.",

    ["Witch Doctor"] = "Witch doctors are spellcasters and alchemists. Troll witch doctors utilize voodoo, arcane, shadow and nature magic, while augmenting their abilities with juju, mojo and muisek. Ancestral staves and Rush'kah masks are used by witch doctors to call upon their ancestors and loa. They often use the smoke herbs to draw evil from its hiding places.",

}
