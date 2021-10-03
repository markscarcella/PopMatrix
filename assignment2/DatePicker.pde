import controlP5.*;
import java.util.*;

class DatePicker {
  int xPos;
  int yPos;
  int padding = 10;

  int listWidth = 80;
  int listHeight = 40;

  String[] theYears;
  String[] theMonths;
  String[] theDays;
  
  String newStartDate = "2020-12-08 00:00:00";
  String newEndDate = "2020-12-08 24:00:00";
  String day;
  String month;
  String year;
  
  String[] date;

  Button load;
  ScrollableList dayList;
  ScrollableList monthList;
  ScrollableList yearList;

  //PopData popData;

  DatePicker(int x, int y) {
    xPos = x;
    yPos = y;

    fillDates();
    createScrollList();
    createButton();

    //popData = new PopData();
  }

  void fillDates()
  {
    theYears = new String[2];
    theYears[0] = "2021";
    theYears[1] = "2020";

    theMonths = new String[12];
    for (int j = 0; j < 12; j++)
    {
      if (j < 10)
      {
        theMonths[j] = "0"+(j+1);
      } else
      {
        theMonths[j] = String.valueOf(j+1);
      }
    }
    theDays = new String[31];
    for (int i = 0; i < 31; i++)
    {
      if (i < 10)
      {
        theDays[i] = "0"+(i+1);
      } else
      {
        theDays[i] = String.valueOf(i+1);
      }
    }

    // set a starter date
    date = new String[3];
    
    date[0] = "20";
    date[1] = "12";
    date[2] = "2020";    
  }

  void setDate(String type, String value) {
    switch (type)
    {
    case "day":
      int d = Integer.valueOf(value);
      if (d < 10)
      {
        //value = "0"+value;
      }
      date[0] = value;
      break;

    case "month":
      date[1] = value;
      break;

    case "year":
      date[2] = value;
      break;
    }
  }

  void update() {
    // show the date
    //textSize(12);
    //fill(255);
    //text(date[0]+":"+date[1]+":"+date[2], xPos-75, 15);
   
  }

  void createButton() {
    // create a new button with name 'buttonA'
    load = cp5.addButton("loadDate")
      .setValue(0)
      .setLabel("Set date")
      .setPosition(listWidth*3, yPos)
      .setSize(100, listHeight)
      ;
    
    /*load.onRelease(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        //String d = date[0];
        //String m = date[1];
        //String y = date[2];
        
        //newStartDate = y+"-"+m+"-"+d+" 05:00:00";
        //newEndDate =  y+"-"+m+"-"+d+" 24:00:00";
        
         // format timestampFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        // ***************************
        // make the call to load the data here
        // popData.loadDataFromDate(d, m, y);
        //****************************
      }
    }
    );*/
  }


  void createScrollList()
  {
    List years = Arrays.asList(theYears);
    /* add a ScrollableList, by default it behaves like a DropdownList */
    yearList = cp5.addScrollableList("years")
      .setPosition(xPos, yPos)
      .setLabel("2020")
      .setSize(listWidth, 100)
      .setBarHeight(listHeight)
      .setItemHeight(listHeight)
      .setOpen(false)
      .addItems(years)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;
    List months = Arrays.asList(theMonths);
    /* add a ScrollableList, by default it behaves like a DropdownList */
    monthList = cp5.addScrollableList("months")
      .setPosition(xPos+listWidth, yPos)
      .setLabel("12")
      .setSize(listWidth, 100)
      .setBarHeight(listHeight)
      .setItemHeight(listHeight)
      .setOpen(false)
      .addItems(months)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;
    List days = Arrays.asList(theDays);
    /* add a ScrollableList, by default it behaves like a DropdownList */
    dayList = cp5.addScrollableList("days")
      .setPosition(xPos+listWidth*2, yPos)
      .setLabel("08")
      .setSize(listWidth, 100)
      .setBarHeight(listHeight)
      .setItemHeight(listHeight)
      .setOpen(false)
      .addItems(days)
      // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
      ;

    // add moue events
    dayList.onRelease(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        int selected = int(theEvent.getController().getValue());
        setDate("day", theDays[selected].toString());
        day = theDays[selected].toString();
        println(day);
      }
    }
    );
    monthList.onRelease(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        int selected = int(theEvent.getController().getValue());
        setDate("month", theMonths[selected].toString());
         month = theMonths[selected].toString();
      }
    }
    );
    yearList.onRelease(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        int selected = int(theEvent.getController().getValue());
        setDate("year", theYears[selected].toString());
         year = theYears[selected].toString();
      }
    }
    );
  }
}
