//Stores all the data (Duh!)
list Data;

default
{
    link_message(integer c, integer num, string msg, key k)
    {
        //If it's the master reset packet...
        if(num == 51)
        {
            //Reset the script
            llResetScript();
        }
        //If it's a storage packet
        else if(num == 53)
        {
            //First ensure it is a packet that goes to this system
            //Is the command to add?
            if(k == "ADDSECONDARY")
            {
                //First break down the data into a temporary list
                list lTempList = llParseString2List(msg,["--"],[]);
                //Now check to see if the data is acceptable
                if(llGetListLength(lTempList) == 3)
                {
                    //Add the data
                    Data = (Data = []) + Data + [msg];
                }
                else
                {
                    //If the data is incorrect, respond with the error
                    llSay(0,"'"+msg+"' is in the incorrect format for secondary categories.");
                }
                //Clear the list
                lTempList = [];
            }
            //Is it to clear the system?
            else if(k == "CLEARALL" || k == "CLEARSECONDARY")
            {
                //Well...clear the data
                Data = [];
            }
            //Do we need to send something or is it a first time setup?
            else if(k == "UPDATESECONDARY" || k == "1STSETUPBUTTONS2")
            {
                //We now need to update the buttons, so clear them
                llMessageLinked(LINK_SET,250,"","CLEARALL");
                //Wait for it...
                llSleep(0.5);
                //Set the first button
                llMessageLinked(LINK_SET,250,"1","BUTTONSELECTED");
                //Decode our data
                list lDecode = llParseString2List(msg,["--"],[]);
                //First create a temporary integer and a temporary list
                integer iTempIntegerA;
                integer iTempIntegerB;
                integer iTempIntegerC=-1;
                list lTempList;
                //Now we go through the list sending it to the 1st layer buttons
                for(iTempIntegerA=0;iTempIntegerA < llGetListLength(Data);++iTempIntegerA)
                {
                    //Decode the data entry into the list
                    lTempList = llParseString2List(llList2String(Data,iTempIntegerA),["--"],[]);
                    //Check to see if the data is right for what we need
                    if(llList2String(lDecode,0) == llList2String(lTempList,0))
                    {
                        //Update the buttons
                        llMessageLinked(LINK_SET,iTempIntegerB+251,llList2String(Data,iTempIntegerA),"SETBUTTON");
                        //Increment our placeholder
                        ++iTempIntegerB;
                        //If this is the first one, then select it now
                        if(iTempIntegerC == -1) iTempIntegerC = iTempIntegerA;
                    }
                }
                //Dump our data
                lDecode = [];
                lTempList = [];
                //Inform the items storage to update
                llMessageLinked(LINK_SET,53,llList2String(Data,iTempIntegerC),"UPDATEITEMS");
            }
        }
    }
}
