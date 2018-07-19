using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.ActivityMonitor;
using Toybox.Application;

class TotallySimpleView extends WatchUi.WatchFace {
	
	var timeFont 	= null; // custom font for the time 
	var penColor 	= null;	// color of ring for minutes
	var heartState	= null; // current state of heart rate

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

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        timeFont = loadResource(Rez.Fonts.roboto);
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
        
        // + draw minute arc
        var degreeOffset = minutes * 6; // every minute = 6 degrees around circle
        var startDegree = 90;
        var endDegree = startDegree - degreeOffset;
        if (endDegree <= 0) {
        	endDegree = 360 + endDegree; 
        }
        dc.setColor(penColor, penColor); // change this based of setting
        dc.setPenWidth(25);
        dc.drawArc(dc.getWidth() / 2, dc.getHeight() / 2, dc.getWidth() / 2, 1, startDegree, endDegree); // 1 == the arc direction. opposite would be 0
        // - draw minute arc
        
        // + draw time
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var timeFontSize = 64;
        dc.drawText(dc.getWidth() / 2, (dc.getHeight() / 2) - (timeFontSize / 2), timeFont, hourString, Graphics.TEXT_JUSTIFY_CENTER); 
        // - draw time
        
        // + draw heart
        heartState = calculateHeartRateState();
	    dc.drawBitmap((dc.getWidth() / 4) - 30, (dc.getHeight() / 2) - 24, getHeartBitmap(heartState));
        // - draw heart
        
        // + draw steps 
        
        // - draw steps
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
