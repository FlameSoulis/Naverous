default
{
    link_message(integer c, integer num, string msg, key k)
    {
        //Is it a master reset?
        if(num == 51)
        {
            //Then reset
            llResetScript();
        }
        //Is it a Purchaser Packet?
        else if(num == 60)
        {
            //Do we need to manage a purchase
            if(k == "DOPURCHASE")
            {
                //Send it to our Communicator
                llMessageLinked(LINK_SET,55,msg,"DOPURCHASE");
            }
        }
    }
}
