SECTION 1: BIRD'S EYE VIEW - Broad design





Basic Gameplay:
1) Movement
2) Hiding
3) Combat
4) Theft
5) Magic

Complex Systems (goal is first 2 or 3 out of 5):
1) Platforming
2) Enemy seeking for player behavior (line of sight stealth, complex AI)
3) Light/dark stealth system
4) Immersive sound
5) Sound-based stealth

Core Gamefeel Philosophies:
1) Traversal
2) Atmosphere
3) Sneaking and stealing
4) Spatial and auditory awareness
5) Many ways to move through spaces and solve problems







SECTION 2: WHAT'S IN THE BOX - Desired concrete mechanics





|||
PLAYER
|||

[!] Movement
--- Wallrun - Preserve momentum, chain a Walljump
--- Walljump - Jump off wall, chain a Walljump

[!] Kill
--- Immediately eliminate enemy

[.] Bonk
-?- Take your time to incapacitate enemy

[!] Abilities
--- Blink - Short range teleport
-?- Push - Force push
-?- Link - Link enemies together
-?- Slow - Slow or Stop Time
-?- Spark - Blow up with fire

[.] Weapons
-?- Crossbow - Shoot enemies
-?- Blowpipe - Sleep enemies



|||
ENEMY
|||

[!] Alert Level
--- Unaware
--- Searching
--- Tracking

[!] Patrol
--- Dumb Guard - Search around post
--- Smart Warrior - Search around last found position
--- Hunter Mage - Find player anyhwhere, once seen

[.] Shoot
-?- Some Dumb Guards - Shoots player
-?- Some Smart Warriors - Points out player to others
-?- Some Hunter Mages - Explosion where player is



|||
BOSS
|||

[?] Await player
--- Patrol around a certain space
--- Guard an Important Item

[?] Sense player
--- Keep aware of entrances
--- Do not leave Important Item Space

[?] Battle
--- Predict player behavior
--- Counter player tactics
--- Pursue player death 







SECTION 3: THE PATH - Step-by-step implementation plan





1.. Be able to move around in level
1.1. Wallrun
1.2. Walljump
1.3. Chaining movement mechanics in a way that makes sense and is fun

2.. Have enemies
2.1. Be able to kill enemies
2.2. Enemy alert levels
2.2.1. Enemies can spot and attack player
2.2.2. Enemies can search for player
2.2.3. Enemies have patroul routes or will hunt for you
2.3. Designated damage and assassinate mechanics

3.. Open-ended levels
3.1. Have multiple routes to get from place to place
3.2. Have a few entrance points for levels

4.. Theft
4.1. Main objective you must take
4.2. Loot to steal

5.. Magic/Weapons
5.1. Basic short-range teleport ability
5.1.1. Mana meter
5.1.2. Health meter
5.1.3. Health potions can be picked up in world and used
5.3. Ability wheel
5.4. Different magic powers
5.5. Upgrading is possible

6.. Aesthetics
6.1. Visually striking lighting
6.2. Light-based stealth

7.. Acoustics
7.1. Immersive sound
7.2. Sound-based stealth

8.. Difficulty
8.1. Standard basic objectives
8.2. Kill no one also
8.3. Minimum loot requirement

9.. Save-game system
9.1. Checkpoint based

10.. Multiple levels
10.1. Distinct level design in both form and visuals
10.2. Loose narrative between levels

11.. Voices
11.1. Player
11.2. Guards
11.3. Boss

12.. Minimal stylized cutscenes between levels

