key PrimaryCategoryReader;
key SecondaryCategoryReader;
key ItemsReader;

integer PrimaryCategoryCounter;
integer SecondaryCategoryCounter;
integer ItemsCounter;

default
{
    link_message(integer c, integer num, string msg, key k)
    {
        //Data Phase Packets
        if(num == 52)
        {
            //Initialization
            if(k == "INITIATE")
            {
                //State the starting point
                llSay(0,".NET Storage Manager Starting...");
                //Check for the notecards
                if(llGetInventoryType("-Primary Categories") == INVENTORY_NOTECARD)
                {
                    if(llGetInventoryType("-Secondary Categories") == INVENTORY_NOTECARD)
                    {
                        if(llGetInventoryType("-Items") == INVENTORY_NOTECARD)
                        {
                            //State our status
                            llSay(0,"Clearing, Reading, and compiling data...");
                            //Clear all our tables
                            llMessageLinked(LINK_SET,55,"","CLEARPRIMARY");
                            llMessageLinked(LINK_SET,55,"","CLEARSECONDARY");
                            llMessageLinked(LINK_SET,55,"","CLEARITEMS");
                            //Reset all coutners
                            PrimaryCategoryCounter=SecondaryCategoryCounter=ItemsCounter=0;
                            //Start Reading
                            PrimaryCategoryReader = llGetNotecardLine("-Primary Categories",PrimaryCategoryCounter++);
                            SecondaryCategoryReader = llGetNotecardLine("-Secondary Categories",SecondaryCategoryCounter++);
                            ItemsReader = llGetNotecardLine("-Items",ItemsCounter++);
                        }
                        else
                        {
                            //Report any errors
                            llSay(0,"Unable to find '-Items' notecard!");
                            //Send Error Packet
                            llMessageLinked(LINK_SET,52,"DATASTORAGE","ERROR");
                        }
                    }
                    else
                    {
                        //Report any errors
                        llSay(0,"Unable to find '-Secondary Categories' notecard!");
                        //Send Error Packet
                        llMessageLinked(LINK_SET,52,"DATASTORAGE","ERROR");
                    }
                }
                else
                {
                    //Report any errors
                    llSay(0,"Unable to find '-Primary Categories' notecard!");
                    //Send Error Packet
                    llMessageLinked(LINK_SET,52,"DATASTORAGE","ERROR");
                }
            }
        }
    }
    
    dataserver(key id, string data)
    {
        llSleep(1.25);
        integer dataread;
        //Is it a primary category data?
        if(id == PrimaryCategoryReader)
        {
            dataread=1;
            //Is the data the end?
            if(data != EOF)
            {
                //If it is not a comment, first download the data
                if(llGetSubString(data,0,1) != "//")
                    llMessageLinked(LINK_SET,55,data,"ADDPRIMARY");
                //Now read the next line
                PrimaryCategoryReader = llGetNotecardLine("-Primary Categories",PrimaryCategoryCounter++);
            }
            else
            {
                //Otherwise state our finished data and reset the counter
                llSay(0,"Finished Reading Primary Categories!");
                PrimaryCategoryCounter=0;
            }
        }
        //Is it a secondary category data?
        else if(id == SecondaryCategoryReader)
        {
            dataread=1;
            //Is the data the end?
            if(data != EOF)
            {
                //If it is not a comment, first download the data
                if(llGetSubString(data,0,1) != "//")
                    llMessageLinked(LINK_SET,55,data,"ADDSECONDARY");
                //Now read the next line
                SecondaryCategoryReader = llGetNotecardLine("-Secondary Categories",SecondaryCategoryCounter++);
            }
            else
            {
                //Otherwise state our finished data and reset the counter
                llSay(0,"Finished Reading Secondary Categories!");
                SecondaryCategoryCounter=0;
            }
        }
        //Is it a secondary category data?
        else if(id == ItemsReader)
        {
            dataread=1;
            //Is the data the end?
            if(data != EOF)
            {
                //If it is not a comment, first download the data
                if(llGetSubString(data,0,1) != "//")
                    llMessageLinked(LINK_SET,55,data,"ADDITEMS");
                //Now read the next line
                ItemsReader = llGetNotecardLine("-Items",ItemsCounter++);
            }
            else
            {
                //Otherwise state our finished data and reset the counter
                llSay(0,"Finished Reading Items!");
                ItemsCounter=0;
            }
        }
        //Check to see if we aren't done
        if((ItemsCounter+SecondaryCategoryCounter+PrimaryCategoryCounter)==0 && dataread)
        {
            //If we are, send our completion packet
            llMessageLinked(LINK_SET,52,"DATASTORAGE","COMPLETE");
        }
    }
}
