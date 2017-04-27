package  
{
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class CollisionObject extends MovieClip 
	{
		protected var downwardVelocity:Number;
		protected var isRunning:Boolean;
		protected var isJumping:Boolean;

		public function CollisionObject() 
		{// constructor code
			trace("i am any object that collides with the boundary");
			//initialize object to zero velocity and is not running
			downwardVelocity = 0;
			isRunning = false;
			//add and event listener for when the Flash playback head enters a frame
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}//end of constructor function
		
		//create the function that handles the ENTER_FRAME event
		private function handleEnterFrame(event:Event):void
		{//update by increasing the value of the velocity variable
			downwardVelocity += 2;
			//update the actual y-position of the object
			this.y += downwardVelocity;
			//"this" refers to the current referenced object
			
		}// end function handleEnterFrame
		
		public function incrementUpward()
		{//increment the y position up until not colliding
			this.y -= 0.1;
		}//end of public function incrementUpward
		
		public function keepOnBoundary()
		{
			downwardVelocity = 0; //stops object from falling
			positionOnLanding(); // calls function
		}// end public function keepOnBoundary
		
		public function positionOnLanding()
		{
			//do nothing here --  let it be overridden by subclasses
		}// end public function positionOnLanding

	} // end class
	
} //end package
