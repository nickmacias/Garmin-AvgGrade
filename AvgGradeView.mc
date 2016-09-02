using Toybox.Application;
using Toybox.WatchUi as Ui;

class AvgGradeView extends Ui.SimpleDataField {

  var saveGrade=new[10]; // record 10 prior altitude readings here
  var nextLoc=0; // save next altitude at saveAlt[nextLoc]
  var prevRet=0.0; // previous return value (in case we can't re-compute this time)
  var prevAlt=0.0; // previous altitude reading
  var prevDist=0.0; // previous distance. only load data when this changes...
  
  function initialize() {
    SimpleDataField.initialize();

    label = "Avg Grade";

// initialize gradient array
    var i;
    for (i=0;i<10;i++){
     saveGrade[i]=10000.0; // this flag means invalid grade stored
    }
  }
  
  // compute smoothed gradient
  function compute(info) {
  
    if (info==null){ // does this ever happen???
      return(prevRet);
    }
    
    if ((info.altitude==null)||(info.elapsedDistance==null)){ // data not available (weird)
      return(prevRet);
    }
    
    if (info.elapsedDistance==prevDist){
      return(prevRet); // skip out quickly!
    }
    
    // we've moved! Calculate and save current gradient
    saveGrade[nextLoc]=(info.altitude-prevAlt)/(info.elapsedDistance-prevDist);
    prevAlt=info.altitude;
    prevDist=info.elapsedDistance; // save these for next time
    ++nextLoc;
    if (nextLoc==10){
      nextLoc=0;
    } // circular queue
    
  // average last 10 gradients and return that figure
  // (ignore if = 10000)

    var i;
    var gradeSum=0.0;
    var gradeNum=0;
    var gradeAvg;

    for (i=0;i<10;i++){
      if (saveGrade[i] != 10000.0){
        ++gradeNum;
        gradeSum=gradeSum+saveGrade[i];
      }
    } // ready to calculate average
    gradeAvg=gradeSum/gradeNum; // should be legal
    prevRet=100.0*gradeAvg;
    return(prevRet);
  }
}

class AvgGrade extends Application.AppBase
{
  function initialize()
  {
    AppBase.initialize();
  }
  
  function getInitialView()
  {
    return(new AvgGradeView());
  }
}