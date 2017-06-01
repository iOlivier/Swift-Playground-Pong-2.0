# Swift Playground: Pong

This project contains my WWDC 2017 Scholarship submission.

## Pong V2.0

My Swift Playground is a tribute to Pong, a very old computer game. I gave this vintage game a fresh new look with visual effects.
While playing the game, the borders of the field change when the ball touches them. This also triggers a sound. On every scored goal, fireworks will be presented to the player who scores the point.

### Technology

-	SpriteKit: I used SpriteKit and it’s features to develop this wonderful 2D game. I used SKShapeNodes with CategoryBitMasks to detect if my objects collided.
-	SpriteKit Particle Emitter: When a user scores a goal, I use the particle emitter to play the stunning fireworks.
-	AVAudioPlayer: This allows me to play a sound when the ball touches one of the borders or when playing fireworks.
-	Touch: By implementing the override functions touchesBegan, touchesMoved and touchesEnded I was able to implement multi touch on my Playground.
-	Threads: I play sounds and special effects in a separate thread to make the app more fluent.
