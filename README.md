# Application Name
Shoot 'em up!

# Course
Hacking with Swift

# Education supplier
This iOS app is developed as a "self challenge" project in the iBook tutorial "Hacking with Swift" which forms part of the "Hacking with Swift" tutorial series, authored by Paul Hudson. Self challenges are apps developed from scratch, solo and un-assisted. The requirements are provided by the instructor in text base, list form. Some helpful hints are sometimes provided.

# Project Type
Self challenge

# Topics / milestones
- GamePlayKit

- SceneKit

- GameScene

- SKSpriteKitNode

- SKAction

- SKEmitterNode

- UIBezierPath

- CGPoint

- UIAlertController / UIAlertAction

- Notification / observer (with didSet)

- switch

- Git / Github

# Project goals / instructions

• Make your own app, starting from a blank canvas.</br>
• Your challenge is to make a shooting gallery game using SpriteKit: create three rows on the screen, then have targets slide across from one side to the other. </br>
• If the user taps a target, make it fade out and award them points.


How you implement this game really depends on what kind of shooting gallery games you’ve played in the past, but here are some suggestions to get you started:</br>
• Make some targets big and slow, and others small and fast. The small targets should be worth more points. </br>
• Add “bad” targets – things that cost the user points if they get shot accidentally. </br>


Make the top and bottom rows move left to right, but the middle row move right to left. </br>
• Add a timer that ticks down from 60 seconds. When it hits zero, show a Game Over
message. </br>
• Try going to https://openclipart.org/ to see what free artwork you can find.</br>
• Give the user six bullets per clip. Make them tap a different part of the screen to reload.</br>

</br><strong> Additional hints: </strong>
• Moving the targets in your shooting gallery is a perfect job for the follow() action. </br>
• Use a sequence so that targets move across the screen smoothly, then remove themselves when they are off screen.</br>
• You can create a timer using an SKLabelNode, a secondsRemaining integer, and a Timer that takes 1 away from secondsRemaining every 1 second.</br>
• Make sure you call invalidate() when the time runs out.</br>
• Use nodes(at:) to see what was tapped. If you don’t find a node named “Target” in the
returned array, you could subtract points for the player missing a shot.</br>
• You should be able to use a property observer for both player score and number of bullets 
remaining in clip. Changing the score or bullets would update the appropriate SKLabelNode on the screen.

# Stretch goals
Some features included are not part of the guided project, but are added as stretch goals. Stretch goals apply learned knowledge to accomplish and are completed unassisted. Stretch goals may either be suggested by the teaching instructor or self imposed. Strecth goals / features implemented (if any) will be listed here.

- Add Bonus (targetBonus) node to game scene using different images from standard (enemy) nodes which earn bonus points when sliced (suggested)

- Change SKLabel colors to inform user of actions to take (self imposed)

- Use images for when bullet is used, not used and full (self imposed)

- Add game sound effects triggered by user touches (self imposed)

- Add game background music (self imposed)

- Add Game Over image (scene node) when game ends (self imposed)

- Add Game Over Alert showing user game score and action button to Play again (self imposed)

- Enable user to Play again from Alert, when game ends (self imposed)

- App icons (self imposed)

- Source control with git (local) / github (remote) (self imposed)


# Completed
February, 2019
