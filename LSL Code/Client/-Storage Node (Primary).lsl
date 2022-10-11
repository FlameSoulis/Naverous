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
            if(k == "ADDPRIMARY")
            {
                //First break down the data into a temporary list
                list lTempList = llParseString2List(msg,["--"],[]);
                //Now check to see if the data is acceptable
                if(llGetListLength(lTempList) == 2)
                {
                    //Add the data
                    Data = (Data = []) + Data + [msg];
                }
                else
                {
                    //If the data is incorrect, respond with the error
                    llSay(0,"'"+msg+"' is in the incorrect format for primary categories.");
                }
                //Clear the list
                lTempList = [];
            }
            //Is it to clear the system?
            else if(k == "CLEARALL" || k == "CLEARPRIMARY")
            {
                //Well...clear the data
                Data = [];
            }
            //Do we need to send something or is it a first time setup?
            else if(k == "UPDATEPRIMARY" || k == "1STSETUPBUTTONS")
            {
                //We now need to update the buttons, so clear them
                llMessageLinked(LINK_SET,200,"","CLEARALL");
                //Wait for it...
                llSleep(0.5);
                //Set the first button
                llMessageLinked(LINK_SET,200,"1","BUTTONSELECTED");
                //First create a temporary integer
                integer iTempIntegerA;
                //Now we go through the list sending it to the 1st layer buttons
                for(iTempIntegerA=0;iTempIntegerA < llGetListLength(Data);++iTempIntegerA)
                {
                    //Send it to all the buttons
                    llMessageLinked(LINK_SET,iTempIntegerA+201,llList2String(Data,iTempIntegerA),"SETBUTTON");
                }
                //If we are a first setup, then we need to pass this on
                if(k == "1STSETUPBUTTONS") llMessageLinked(LINK_SET,53,llList2String(Data,0),"1STSETUPBUTTONS2");;
            }
        }
    }
}
