using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.ActivityMonitor;
using Toybox.Application;
using Toybox.Time.Gregorian;

class TotallySimpleView extends WatchUi.WatchFace {
	
	var timeFont 	= null; // custom font for the time 
	var altFont 	= null;	// alternate font choice
	var penColor 	= null;	// color of ring for minutes
	var heartState	= null; // current state of heart rate
	var steps 		= null; // current num of steps
	var calories	= null; // current stress level

    function initialize() {
        WatchFace.initialize();
    }
    
    function calculateHeartRateState() {
    	var hrIterator = ActivityMonitor.getHeartRateHistory(null, true);
		var lastRecordedHr = hrIterator.next();
		var newHeartState = 0;
		if (lastRecordedHr.heartRate < 80) {
			newHeartState = 0;
		}
		else if (lastRecordedHr.heartRate < 120) {
			newHeartState = 1;
		}
		else {
			newHeartState = 2;
		}
		return newHeartState;
   	}
   	
   	function getHeartBitmap(state) {
   		var heartBitmap = null;
   		
   		switch(state) {
   			case 0:
   				heartBitmap = loadResource(Rez.Drawables.GreenHeart);
   				break;
   			case 1:
   				heartBitmap = loadResource(Rez.Drawables.YellowHeart);
   				break;
   			case 2:
   				heartBitmap = loadResource(Rez.Drawables.RedHeart);
   				break;
   			default:
   				System.println("invalid state: " + state);
   				break;
   		}
   		
   		return heartBitmap;
   	}
   	
   	function getCalories() {
   	   	var info = ActivityMonitor.getInfo();
   		var cal = info.calories;
   		return cal;
   	}
   	
	function getCaloriesState(cal) {
		var calorieGoal = 2000.0;
		if (cal < calorieGoal / 3) {
			return 0;
		}
		else if (cal < (2 * calorieGoal / 3)) {
			return 1;
		}
		else {
			return 2;
		}
	}
   	
   	function getBoltBitmap(state) {
   		var boltBitmap = null;
   		
   		switch(state) {
   			case 0:
   				boltBitmap = loadResource(Rez.Drawables.RedBolt);
   				break;
   			case 1:
   				boltBitmap = loadResource(Rez.Drawables.YellowBolt);
   				break;
   			case 2:
   				boltBitmap = loadResource(Rez.Drawables.GreenBolt);
   				break;
   			default:
   				System.println("invalid state: " + state);
   				break;
   		}
   		
   		return boltBitmap;
   	}
   	
   	function getSteps() {
   		var info = ActivityMonitor.getInfo();
   		steps = info.steps;
   		return steps;
    }
   	

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        timeFont = loadResource(Rez.Fonts.roboto);
        altFont = loadResource(Rez.Fonts.robotoThin);
        penColor = Application.Properties.getValue("PenColor");
		heartState = calculateHeartRateState();
    }

    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        var clockTime = System.getClockTime();
        var hour = clockTime.hour;
        hour = hour % 12;
        if (hour == 0) {
        	hour = 12; 
        }
        var minutes = clockTime.min;
        var hourString = Lang.format("$1$", [hour]);
        
        // + draw background circle 
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillCircle(dc.getWidth() / 2, dc.getHeight() / 2, dc.getWidth() / 2);
        // - draw background circle
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // + draw date
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateString = Lang.format("$1$ $2$", [today.day_of_week, today.day]);
        dc.drawText(dc.getWidth() / 2, (dc.getHeight() / 4) - 14, altFont, dateString, Graphics.TEXT_JUSTIFY_CENTER);
        // - draw date
        
        // + draw heart
        heartState = calculateHeartRateState();
	    dc.drawBitmap((dc.getWidth() / 4) - 24, (dc.getHeight() / 2) - 24, getHeartBitmap(heartState));
        // - draw heart
        
        // + draw calorie bolt
        calories = getCalories();
        var caloriesState = getCaloriesState(calories);
        var calString = Lang.format("$1$ ", [calories]);
        dc.drawText((3 * dc.getWidth() / 4), dc.getWidth() / 2, altFont, calString, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawBitmap((3 * dc.getWidth() / 4) - 12, (dc.getHeight() / 2) - 24, getBoltBitmap(caloriesState));
        // - draw calorie bolt
        
        // + draw steps 
        steps = getSteps();
        var stepString = Lang.format("$1$", [steps]);
        dc.drawText(dc.getWidth() / 2, (3 * dc.getHeight() / 4) - 14, altFont, stepString, Graphics.TEXT_JUSTIFY_CENTER);
        // - draw steps
        
        // + draw minute arc
        var degreeOffset = minutes * 6; // every minute = 6 degrees around circle
        var startDegree = 90;
        var endDegree = startDegree - degreeOffset;
        // look into full ring whenever hour:00
        if (endDegree <= 0) {
        	endDegree = 360 + endDegree; 
        }
        dc.setColor(penColor, penColor); // change this based of setting
        dc.setPenWidth(25);
        dc.drawArc(dc.getWidth() / 2, dc.getHeight() / 2, dc.getWidth() / 2, 1, startDegree, endDegree); // 1 == the arc direction. opposite would be 0
        // - draw minute arc
        
        // + draw hour
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var timeFontSize = 64;
        dc.drawText(dc.getWidth() / 2, (dc.getHeight() / 2) - (timeFontSize / 2), timeFont, hourString, Graphics.TEXT_JUSTIFY_CENTER); 
        // - draw hour
    }
    
    function onSettingsChanged() {
    	System.println("Settings changed");
		penColor = Application.Properties.getValue("PenColor");
		requestUpdate();
	}

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
