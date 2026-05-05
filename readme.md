#Controls:
    Main Menu: ESCAPE
    Movement: WASD keys

---

#Notes:
    - the space key to enter / leave combat has been removed, now it will pull the enemy data from which enemy's vision cone touched the player
    - we can create unique enemy types by creating a new resource called EnemyStats
        - I recommend keeping these in the resources folder
    - here is a preview of two enemy types on two different enemies, both have different attack patterns, do different damage, and have different health
    - ![Alt EnemyStats](https://i.ibb.co/1fkc7BMX/Enemy-Stats.jpg)
    - to create an enemy type, just right-click the resources folder -> create new resource -> EnemyStats
    - the enemy scene object has an EnemyStats variable exposed in the inspector, just drag and drop your new resource onto the slot in the inspector, and do your thing, fun stuff!
    - if you enter that enemy's vision cone now, it'll have all the stats and patterns you set, simple as that

#Known Bugs:
    - For some reason, godot has an issue with resetting physics on the player (I have tried to fix this, but no solution yet),
    so if you spam 'new game' in the main menu, it seems to send the player flying across the screen every second start.