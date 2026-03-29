- We're creating a game called paintings that is intended to be played both on PC and mobile. Keep that in mind at all times.
- The game is a card placement / tableau builder with combo mechanics, using famous paintings as cards.


- The game is composed of a canvas and a hand of cards.
- Te player can drag cards from their hand onto the canvas to create a tableau.
- Each card will score points when it's placed on the canvas, and can also trigger combo effects.



- Structure of the main screen.
  - The canvas is the background of the game. It is composed of a 40x40 checkered grid of squares, each square is 128x128px.
  - The camera can be panned on the background by dragging the mouse or swiping on mobile.
  - The hand of cards is located at the bottom of the screen. It contains all the cards that the player has in hand.
  - The hand can be scrolled left and right with arrows if there are more than 5 cards in the deck.
  - The scoring UI is located at the top of the screen. It displays the player's current score and the score that needs to be reached to win the game (example: 100 points).

- camera controls:
  - The player can pan the camera by dragging the mouse or swiping on mobile.
  - The camera movement should be smooth and have some inertia.
  - The player should not be able to pan the camera outside the bounds of the canvas.


- Each card had characterisctics:
	- A name, which is the name of the painting.
	- An image, which is the image of the painting.
	- A size, which is the size of the card in grid squares (e.g. 1x1, 2x2, etc.). By default all cards are 3x3, but some cards can be larger or smaller.	
	- A scoring function that calculates the points the card is worth when placed on the canvas. The scoring function can be based on the card's position on the canvas, the cards adjacent to it, or any other factor. By default, the scoring function is to award 10 points.
  - 4 values that are the TOP, RIGHT, BOTTOM, and LEFT edges of the card. These values are used to determine if combo effects are triggered when the card is placed on the canvas.
	- A point value, which is the number of points the card is worth when placed on	 the canvas. The point value can be increased by triggering combo effects.

- Hand
  - The player starts with a hand of 5 cards.
  - When a card is placed on the canvas, it is removed from the hand.
  - In the hand, the card is displayed only by its image, and all the images have the same height (256px).
  - When the player clicks on a card in the hand, it is selected and can be dragged onto the canvas.


- Dragging and dropping cards.
  - As soon as the player starts dragging a card, the whole hand UI starts to fade out, and the dragged card is displayed at its actual size (e.g. 3x3 squares would be 384x384px).
  - The player can drag the card around the canvas, and the card will snap to the grid.
  - When the player releases the card, it is placed on the canvas and the hand UI fades back in.
  - If the player tries to place the card on an invalid position (e.g. overlapping another card, or outside the bounds of the canvas), the card will snap back to the hand and the hand UI will fade back in.

- Combo effets:
 - Do not implement combo effects in the first version of the game, but keep in mind that they will be added later.

- Structure of the scenes:
 - The main scene of the game is called "Main.tscn". It contains the canvas, the hand, and the scoring UI.
 - The canvas is a separate scene called "Canvas.tscn". It contains the grid and the logic for placing cards on the canvas.
 - The hand is a separate scene called "Hand.tscn". It contains the logic for displaying the hand of cards and dragging them onto the canvas.
 - Each card is a separate scene called "Card.tscn". It contains the logic for displaying the card and calculating its score when placed on the canvas.
 - The scoring UI is a separate scene called "GameUI.tscn". It contains the logic for displaying the player's score and the score needed to win.
