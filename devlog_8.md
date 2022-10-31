# Devlog 8

The last two days were slower in development, I'm trying to gather what I really want for the MVP/alpha release at the end of the Devtober2022 jam. A gameplay loop, playable gameplay and game feel are necesseary and I really do want to include some scaling and highscores so the game has replay values.

Last time we added the gameplay loop to the game, so this time we just refine it a tad and add proper scaling to the game, for which we need a better spawning system first. Enter the [Director](https://gist.github.com/Achie72/832687ce95c0c0ccae1c168be41bdf8c)!

It's not a really showy part of the code, basically we created a new configurable object, that assign weight values to every enemy and has a certain number of credits that it can spend on spawning enemies when it comes to it. It tries a few random combinations of enemy and elite pairing, checks if it has enough credit for it to spawn and creates the enemy. In the future the director could be further tweaked, to maybe always spawn the biggest thing, keep bigger pauses etc..

The other smaller change is the scaling, now enemies will have more HP and attack speed the later we are in the game, thanks to the directors difficulty scale!

And for last, we got a few new statistics to look at the end screen. The pilot style is calculated very simply yet, based on missed hits and most spent location on a screen area, but I hope in the future we can get more complex with it!

