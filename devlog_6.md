# Devlog 6

I was pretty much quiet about the project for almost two weeks, but I have a fair reason for it. Started the project in TIC-80 but decided to swithc to [Löve](https://love2d.org/wiki/Main_Page), still a lua engine but there aren't any restrictions like in fantasy consoles. The past dozen days were spent by porting the game to the new API that Löve provides and getting everything back to where it was.

new gif

I recently [merged](https://github.com/Achie72/love2d-shmup/pull/1) all the old stuff written in the new and finally work can begin on new features! No time to rest, let's add movement to our enemies!

moving gif

The code behind this is basically the same idea used in [Lina: Witches Of The Moon](https://achie.itch.io/lina-witches-of-the-moon), enemies have certain movement pattern assigned to them and they move accordingly. I added a little flavour to them in the way of stopping enemies in the [moment they shoot](https://gist.github.com/Achie72/235240d2a5dfded9069eb4532c30205c)

For the game to have a releasable MVP I needed to have some scaling so it won't become easy, a game loop and a better spawner function. Enter the [**Director**](https://gist.github.com/Achie72/832687ce95c0c0ccae1c168be41bdf8c). The director is a new object created that handles enemy spawning. It has certain credits it can spend, and every enemy and elite type has a cost attached to it. In the future the director could be further tweaked, to maybe always spawn the biggest thing, keep bigger pauses etc... The enemy span code now will try to spawn a random enemy with a random elite type, checks if the director has enough credits to spawn it and to if it can. This whole process will be tried 40 times before we give up on spawning a new enemy. Upon death now or enemies will replenish the director's credit count with their respective cost and finally during gameplay we increase the allowance of the director to make the game harder over time.

The last thing implemented is the enemy elite type, more preciesly 3 of them. Flaming, Lightning and Freezing enemies are now in the game and all of them have a special attribute.
Flaming enemies will leave a burning fire trail behind (the code is basically the Explosion effect we discussed in Devlog 3). Lightning enemies move and shoot twice as fast and Freezing enemies shoot slowing bullets! All of them have a little icon above their sprite, which is not final yet, but it is close to the effect I want.