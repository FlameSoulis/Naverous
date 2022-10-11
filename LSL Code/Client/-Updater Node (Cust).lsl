//Delay in Days/Hours/Minutes/Seconds between scans
integer Days    = 0;
integer Hours   = 3;
integer Minutes = 0;
integer Seconds = 0;

//SYSTEM DATA

//Current Update Date/Time
string DateTime="";
//HttpHolder for the request
key kHttpRequest;
//Address holder
string sScriptAddress;
//Address obtainer
key kSetupData;

default
{
    state_entry()
    {
        integer time=   (Days * 24 * 60 * 60) +
                        (Hours * 60 * 60)+
                        (Minutes * 60)+
                        (Seconds);
        //MATH TIME!!!
        llSetTimerEvent(time);
        //Get our address
        if(llGetInventoryType("*Settings") == INVENTORY_NOTECARD)
            kSetupData = llGetNotecardLine("*Settings",0);
        else
            llSay(0,"No notecard named *Settings found!");
    }
    dataserver(key id, string data)
    {
        if(id ==  kSetupData)
        {
            sScriptAddress = data;
        }
    }
    timer()
    {
        //Setup the scan for the update
        kHttpRequest=llHTTPRequest(sScriptAddress,
            [HTTP_METHOD, "POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],
            "cmd=CHECKFORUPDATE");
    }
    http_response(key reqID, integer status, list data, string body)
    {
        //if it was NOT an error...
        if(status == 200)
        {
            //Is OUR response?
            if(reqID == kHttpRequest)
            {
                //If we do not have a current date, then we might want to update ourselves =P
                if(DateTime == "")
                    DateTime = body;
                //Onward!
                //Check to see if we need an update
                if(DateTime != body)
                {
                    //OMG! UPDATE NOW....after a delay
                    llSay(0,"An update was found! Please hold...");
                    //Wait awhiel for the server to finish any last minute things
                    llSleep(10);
                    //Now we begin the udpate BY RESETTEN THE VENDER master!
                    llResetOtherScript("*Vender Script");
                    //Update ourselves again
                    DateTime = body;
                }
            }
        }
    }
}
