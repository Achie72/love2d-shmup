# Devlog 7

Still on the road for a MVP (minimum viable product) for this projects and todays agenda was basically a better gameplay loop. Last time I implemented a really basic one, that just restarted the game as a whole, but let's be real that isn't really fun. So enter the state machine for the menu system!

The main menu is pretty simple, not sure how I will update it in the future, but for the moment I like it! Simple selection indication and menu points with the startfield background and the occasional straggler alien flying across the screen.
In the background we basically have a `gameMode` variable that is set to different values based on where we are, menu, game, game over, credits etc... and in the code we have seperate update and draw functions of all of these that we switch between based upon the `gameMode` variable.

For the game over screen is started to tinker around with statistics I want to gather during gameplay that are worth showing in the end. Of course your gained upgrades are shown as well as a little feature that I really really like. The games saves which enemy kills you and shows it on the upper left corner!

But that is not all, as you return to the main menu, the same rascal enemy will fly away before giving space for other to arrive!