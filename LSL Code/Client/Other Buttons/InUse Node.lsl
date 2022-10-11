//Stores the texture that should be shown when NOT in use
string kNotInUse = "NotInUse Img";
//The texture we shoudl use when we ARE in use
string kInUse = "InUse Img";
//What sides should we use?
integer iSides = ALL_SIDES;
//How long can the user delay with his/her actions
integer iDelay = 45; //Seconds

//SYSTEM DATA
//Stores the current user's key
key kCurrentUser;

default
{
    state_entry()
    {
        if(llGetObjectDesc() != "")
        {
            //Use the data to set our ACTUAL data
            iSides = (integer)llGetObjectDesc();
        }
        //Set us to the NOT IN USE texture
        llSetTexture(kNotInUse,iSides);
    }
    timer()
    {
        //If this event occurs, then we need to reset the buttons
        llMessageLinked(LINK_SET,200,"","NOUSER");
        llMessageLinked(LINK_SET,250,"","NOUSER");
        llMessageLinked(LINK_SET,300,"","NOUSER");
        //And reset ourselves
        llResetScript();
    }
    link_message(integer link, integer num, string msg, key k)
    {
        //Is it the master reset?
        if(num == 51)
        {
            //Reset the script then
            llResetScript();
        }
        //Is it a packet of ours?
        else if(num == 56)
        {
            //Is it someone touching us?
            if(k == "NEWUSER")
            {
                //First new dude, so lets start our timer
                llSetTimerEvent(iDelay);
                //Now we change our texture
                llSetTexture(kInUse,iSides);
                //Inform all the buttons of the new user
                llMessageLinked(LINK_SET,200,msg,"NEWUSER");
                llMessageLinked(LINK_SET,250,msg,"NEWUSER");
                llMessageLinked(LINK_SET,300,msg,"NEWUSER");
                //Record the new user
                kCurrentUser = (key)msg;
            }
            //Is someone touching us when we are ALREADY in use?
            else if(k == "BADUSER")
            {
                //Instant Message the bastard
                llInstantMessage((key)msg,"We are sorry, but this vender is already in use by "+llKey2Name(kCurrentUser)+". Please wait until he/she is done with her session.");
            }
        }
    }
}
