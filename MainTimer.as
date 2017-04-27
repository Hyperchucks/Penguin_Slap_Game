package  {
	
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	
	public class MainTimer extends MovieClip {
		//Init vars for class
		private var currentMin:int;
		private var currentSec:int;
		
		//Create one-second timer from Flash's Timer Class
		private var oneSecondTimer:Timer = new Timer(1000,1);
		public var timerHasStopped:Boolean=false;
		
		
		public function MainTimer() {
			// constructor code
			trace("the main timer is here");
			
			//initialize our private data members
			currentMin = 2;
			currentSec = 5;
			
			//convert values and place in textboxes
			minBox.text = String(currentMin);
			
			if(currentSec < 10)
				{
				secBox.text = "0" + String(currentSec); //add leading to zero
				}//end of if
			else
				{
				secBox.text = String(currentSec);
				}//end of else
				
				oneSecondTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
				oneSecondTimer.start();
				
		}//end function MainTimer
			
		private function onTimerComplete(event:TimerEvent):void {
			
			currentSec = currentSec -1;
			if(currentSec < 0)
			{
				currentSec = 59;
				currentMin -= 1;
			}//end if
			if(currentMin < 0)
			{
				currentMin = 0;
				currentSec = 0;
				timerHasStopped = true;
			}//end if
			else
			{
				oneSecondTimer.start();
			}//end else
			
			//update our display
			minBox.text = String(currentMin);
			secBox.text = String(currentSec);
			
			//Adjust display for seconds less than 10
			if(currentSec < 10)
			{
				secBox.text = "0" + String(currentSec);
			}//end if
			
		}//end of onTimerComplete
		
		public function resetTimer():void
		{
			//update our display
			currentMin = 1;
			currentSec = 5;
			minBox.text = String(currentMin);
			secBox.text = String(currentSec);
			//adjust display for seconds less than 10
			if(currentSec < 10)
			{
				secBox.text = "0" + String(currentSec);
			}//end if
			timerHasStopped = false;
			oneSecondTimer.start();
		}
			
		
	}//end class
	
}//end package
