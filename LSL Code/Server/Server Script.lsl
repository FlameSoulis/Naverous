//3 Class Vender
//Created by Flame Swenholt

//Time between each update scan
integer iUpdateCheckDelay=15;

//Initialilaztion State
default
{
    state_entry()
    {
        //Declare out resetting of the nodes
        llSay(0, "Restarting nodes...");
        //Send out the master reset packet with a stupid message =P
        llMessageLinked(LINK_SET,51,"RESETALL","PACKET");
        //Wait a few for the nodes to square away
        llSleep(1.0);
        //Declare our execution of the Data Node
        llSay(0, "Executing data node...");
        //Send out the delcaration to the data node
        llMessageLinked(LINK_SET,52,"DATASTORAGE","INITIATE");
    }
    
    link_message(integer link, integer num, string msg, key k)
    {
        //Check to see if it's a Data Phase Packet
        if(num == 52)
        {
            //Check to see if the phase states completion of the DataStorage
            if(k == "COMPLETE" && msg == "DATASTORAGE")
            {
                //State our completion!
                llSay(0,"Data Storage Setup Complete!");
                //Enter the main server mode
                state ServerMode;
            }
            else if(k == "ERROR" && msg == "DATASTORAGE")
            {
                //State the error
                llSay(0,"Data Storage Node encountered an error!");
            }
        }
    }
}

//The main server state
state ServerMode
{
    state_entry()
    {
        //State our entry into the main state
        llSay(0,"Server Mode Entered!");
        //Inform our key
        llOwnerSay("Server's Key: "+(string)llGetKey());
        //Set the timer
        llSetTimerEvent(iUpdateCheckDelay);
    }
    
    timer()
    {
        //Send our update checker
        llMessageLinked(LINK_SET,55,"","CHECKFORUPDATE");
    }
    
    link_message(integer link, integer num, string msg, key k)
    {
        //If we have a purchase come in, we get this
        if(num == 54)
        {
            //First create a temporary list
            list lTempList;
            //Now parse the message into the list
            lTempList=llParseString2List(msg,["--"],[]);
            //Inform the purchaser we got it, and thank them kindly
            llInstantMessage(llList2Key(lTempList,0),"Thank you for your purchase. Your purchase information was received and we are now sending you your item. It should arive shortly.");
            //Tell US about the purchase
            llInstantMessage(llGetOwner(),llList2String(lTempList,1)+" has purchased the "+llList2String(lTempList,4)+" at "+
                llList2String(lTempList,8)+", "+llList2String(lTempList,7)+" for "+llList2String(lTempList,6)+"L$!");
            //Hand them the item
            llGiveInventory(llList2Key(lTempList,0),llList2String(lTempList,5));
        }
    }
}