package  {
	
	//prebuilt Flash classes
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	//our own custom class
	import MainTimer;
	
	public class MainDocument extends MovieClip {
		//initial variable values
		private var currentNumberOfEnemiesOnstage:int;
		private var initialNumberOfEnemiesToCreate:int = 2;
		private var enemyKills:int;
		private var childtoRemove:int;
		private var level:int = 1;
		private var makeNewEnemyTimer:Timer = new Timer(3000,1);
		private var finishOffEnemy:Timer = new Timer(500,1);
		private var gameTimer:MainTimer;
		private var thePlayer:player;
		private var theEnemy:Enemy;
		private var maxEnemies:int = 5;
		private var e:int = 0;
		private var childrenOnStage:int;
		private var lastX:int; //variable to store the last x position of the player
		private var theStageNeedsToScroll:Boolean=false; //flag variable for scrolling
		private var numChildrenInGameStage:int;
		private var jump:JumpSound = new JumpSound();
		private var slap:SlapSound = new SlapSound();
		private var token:TokenSound = new TokenSound();
		private var loopMusic:bckSound = new bckSound();

		public function MainDocument() {
			//This is the constructor function for MainDocument()
			trace("the main document is alive");
			makeNewEnemyTimer.addEventListener(TimerEvent.TIMER_COMPLETE, makeNewEnemyHandler);
			makeNewEnemyTimer.start();
			
			//create a new instance of the MainTimer class
			gameTimer = new MainTimer();
			
			//add it to the stage
			addChild(gameTimer);
			
			//adjust its position
			gameTimer.x = 20;
			gameTimer.y = 20;
			
			//add the player
			thePlayer = new player();
			addChild(thePlayer);
			
			//adjust its position on the stage
			thePlayer.x = stage.stageWidth *0.5;
			
			//assign the name property
			thePlayer.name = "player";
			
			// ***************  WEEK 8: play background music Modification for week 8 course Project **********************
			loopMusic.play();
			
			//control the creation of enemies
			while(e < initialNumberOfEnemiesToCreate)
			{
				createEnemy();
				e++;
			}// end while
			
			//init variable for tracking "kills"
			enemyKills = 0;
			killScoreBox.text = String(enemyKills) + "KILLS";
			
			// update this variable every time a child is added to the stage
			childrenOnStage = this.numChildren;
			
			// add event listener to control timing of main game loop
			addEventListener(Event.ENTER_FRAME, mainGameLoop);
			
			
			//add the enemy for testing
			//theEnemy = new Enemy();
			//addChild(theEnemy);
			
			//adjust its position on the stage
			//theEnemy.x = 200;
			//theEnemy.y = 200;
			
			//Add event listener to control timing of main game loop
			addEventListener(Event.ENTER_FRAME,mainGameLoop);
			
			//Prapare for keystroke listeners
			stage.focus = stage;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);

		}//end constructor
		
		private function keyDownHandler(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case 37: //left
					thePlayer.moveLeft();
				break;
				case 38: // up
					jump.play();
					thePlayer.startJumping();
				break;
				case 39: //right
					thePlayer.moveRight();
				break;
				case 40: //down to attack
					slap.play();
					thePlayer.attack();
				break;
			}//end switch
		}//end function keyDownHandler
		
		private function keyUpHandler(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case 37: //left
				case 39: //right
					thePlayer.standStill();
				break;
				case 38: // jump
					break;
				case 40: // down to attack
					break;
				default: //anything
			}//end switch
		}//end function keyUpHandler
		
		private function createEnemy():void
		{
			trace("create enemy");
			theEnemy = new Enemy((Math.random() * 5) + 1); // pass in a random speed between 1 and 5
			addChild(theEnemy); // Place in a random spot on stage
			theEnemy.x = (Math.random()* stage.stageWidth);
			theEnemy.y = 0;
			// assign the "name" property
			theEnemy.name = "enemy";
			
			//update this variable every time a child is added to the stage
			childrenOnStage = this.numChildren;
		}// end function createEnemy
		
		//the main loop for the game
		private function mainGameLoop(event:Event):void
		{
			checkForGameReset();
			removeOrCreateNewEnemies();
			processCollisions();
			scrollStage();
		}// end function mainGameLoop
		
		private function checkForGameReset():void
		{// define conditions
			if(gameTimer.timerHasStopped == true)
			{
				resetBoard();
			}
			else if(thePlayer.y > stage.stageHeight)
			{
				resetBoard();
			}
			else if(theGameStage.theFish.hitTestPoint(thePlayer.x,thePlayer.y,true)&& theStageNeedsToScroll == false)
			{
				resetBoard();
			}
			else if(health.width <= 2)
			{
				resetBoard();
			}
		}// end function checkForGameReset
		
		private function resetBoard():void
		{
			health.width = 300;
			thePlayer.x = stage.stageWidth * 0.5;
			theGameStage.x = stage.stageWidth * 0.5;
			thePlayer.y = 0;
			theGameStage.y = 0;
			enemyKills = 0;
			gameTimer.resetTimer();
		}// end function resetBoard
		
		private function processCollisions():void
		{
		//set up main loop to look through all collidable objects on stage
			for(var c:int;c < childrenOnStage;c++)
				{//test for a player or enemy child on stage
					if(getChildAt(c).name == "player" || getChildAt(c).name == "enemy")
					{//see if object is touching the game stage
						if(theGameStage.hitTestPoint(getChildAt(c).x, getChildAt(c).y, true))
						{//while it is still touching inch it up just until it stops
							while(theGameStage.hitTestPoint(getChildAt(c).x, getChildAt(c).y, true) == true)
							{// called from CollisionObject Class, so force the connection
								CollisionObject(getChildAt(c)).incrementUpward();
								if(theGameStage.hitTestPoint(getChildAt(c).x, getChildAt(c).y, true) == false)
								{
									CollisionObject(getChildAt(c)).keepOnBoundary(); // make it stick
								}//end if
				
							}//end while
						}// end if touching
					}//end if player or enemy
					
					/////////////////Collision with ENEMIES////////////////////////////////
					if(getChildAt(c).name == "enemy")
					{
						if(getChildAt(c).hitTestPoint(thePlayer.x, thePlayer.y, true))
						{
							if(thePlayer.isAttacking == false)
							{
								//we are being attacked (and not defending)
								//*************** WEEK 8 MOD: Modification from orgininal -2 damage to player for week 8 course project *********
								health.width = health.width -4;
								Enemy(getChildAt(c)).makeEnemyAttack();
							}
							else
							{
								// we are attacking that enemy
								//childToRemove = c;
								Enemy(getChildAt(c)).makeEnemyDie();
								finishOffEnemy.start();
								finishOffEnemy.addEventListener(TimerEvent.TIMER_COMPLETE, finishOffEnemyComplete);
							}//end else
						}
						else if(Enemy(getChildAt(c)).enemyIsAttacking == true)
						{
							//if there isn't a collision between player and enemy,
							//BUT the enemy is attacking
							Enemy(getChildAt(c)).makeEnemyStopAttacking();
						}//end else
					}//end if

				}// end for loop
				
				///////////////////////////// token collision detection ///////////////////////////////////////

				numChildrenInGameStage = theGameStage.numChildren;
				
				for(var d:int = 0; d < numChildrenInGameStage; d++)
				{
					if(theGameStage.getChildAt(d).hasOwnProperty("isToken")&& theGameStage.getChildAt(d).visible == true)
					{
						if(thePlayer.hitTestObject(theGameStage.getChildAt(d)))
						{
							trace("hit token");
							//play sound
							token.play();
							// ********************** WEEK 8 MOD: Modification of adding health to player once hit a fish token it will gain health ******************
							health.width = health.width +6;
							theGameStage.removeChildAt(d);
							numChildrenInGameStage = theGameStage.numChildren;
						}//end if
					}//end if
				}//end for
				
				
				
				
		}// end of function processCollisions
		
		private function scrollStage():void
		{// figure out logic
			if(thePlayer.x != lastX)
			{
				theStageNeedsToScroll=true;
			}
			else
			{
				theStageNeedsToScroll=false;
			}//end if
			if(theStageNeedsToScroll==true)
			{
				for(var b:int=0; b < childrenOnStage; b++)
				{
					if(getChildAt(b).name=="enemy")
					{
						getChildAt(b).x +=(stage.stageWidth * 0.5)- thePlayer.x;
					}//end if
				}//end for
				theGameStage.x +=(stage.stageWidth * 0.5)- thePlayer.x;
			}//end if
			
			thePlayer.x = stage.stageWidth * 0.5;
			lastX = thePlayer.x;
			
		}// end fuction scrollStage
		
		private function removeOrCreateNewEnemies():void
		{
			for(var c:int = 0; c < childrenOnStage; c++)
			{
				if(getChildAt(c).name == "enemy" && getChildAt(c).y > stage.stageHeight)
				{
					removeChildAt(c);
					createEnemy();
				}//end if
				if(getChildAt(c).name == "enemy" && getChildAt(c).x < thePlayer.x - stage.stageWidth)
				{
					removeChildAt(c);
					createEnemy();
				}//end if
			}//end for loop
		}//end function removeOrCreateNewEnemies
		
		private function makeNewEnemyHandler(event:TimerEvent):void
		{
			currentNumberOfEnemiesOnstage = 0;
			for(var c:int = 0; c < childrenOnStage; c++)
			{
				if(getChildAt(c).name == "enemy")
				{
					currentNumberOfEnemiesOnstage++;
				}//end if
			}//end for
			if(currentNumberOfEnemiesOnstage < maxEnemies)
			{
				trace("not enough enemies onstage, make more");
				createEnemy();
			}//end if
			makeNewEnemyTimer.start();
		}//end function makeNewEnemyHandler
		
		public function finishOffEnemyComplete(event:TimerEvent):void
		{
			enemyKills++;
			killScoreBox.text = String(enemyKills) + "KILLS";
			//removeChildAt(childToRemove);
			childrenOnStage = this.numChildren;
		}//end function finishOffEnemyComplete

	}//end class
	
}//end package
